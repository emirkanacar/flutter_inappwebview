package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.graphics.Bitmap
import android.os.Handler
import android.os.HandlerThread
import android.os.Process
import android.util.Log
import java.io.ByteArrayOutputStream
import java.util.concurrent.atomic.AtomicInteger

/**
 * Off-looper half of the screenshot pipeline: scale and compress.
 *
 * One process-wide background thread runs the work, so a burst of captures
 * cannot compete with the UI thread or each other. A counting permit taken at
 * admission bounds how many captured bitmaps can be alive at once; it is
 * released when a request's bitmap work is over, not when it replies, so a
 * cancelled capture still counts until its bitmap is freed.
 */
internal object ScreenshotEncoder {
  private const val LOG_TAG = "ScreenshotEncoder"

  /** Process-wide limit on accepted screenshots whose bitmap work is not over. */
  const val MAX_IN_FLIGHT = 4

  private val inFlight = AtomicInteger(0)

  val handler: Handler by lazy {
    val thread = HandlerThread(
      "fiwv-screenshot-encode",
      Process.THREAD_PRIORITY_BACKGROUND + Process.THREAD_PRIORITY_MORE_FAVORABLE
    )
    thread.start()
    Handler(thread.looper)
  }

  /** Takes an admission permit; false means the process-wide limit is reached. */
  fun tryAcquire(): Boolean {
    while (true) {
      val current = inFlight.get()
      if (current >= MAX_IN_FLIGHT) return false
      if (inFlight.compareAndSet(current, current + 1)) return true
    }
  }

  fun release() {
    while (true) {
      val current = inFlight.get()
      if (current <= 0) return
      if (inFlight.compareAndSet(current, current - 1)) return
    }
  }

  /**
   * Hands [bitmap] to the encoder thread, which then owns it. Returns false
   * (and recycles the bitmap) if the thread cannot take it; the caller then
   * settles the request itself.
   */
  fun submit(
    request: ScreenshotRequest,
    bitmap: Bitmap,
    deliver: (ScreenshotRequest, ByteArray?) -> Unit
  ): Boolean {
    val posted = handler.post { encode(request, bitmap, deliver) }
    if (!posted) {
      bitmap.recycle()
    }
    return posted
  }

  /**
   * Scales (unless already at the snapshot size) and compresses [bitmap] on
   * the encoder thread, frees every bitmap, and always calls [deliver] once.
   * A cancel stops the work at the next checkpoint, including inside
   * Bitmap.compress through [CancellableByteArrayOutputStream].
   */
  fun encode(
    request: ScreenshotRequest,
    bitmap: Bitmap,
    deliver: (ScreenshotRequest, ByteArray?) -> Unit
  ) {
    var scaled: Bitmap? = null
    var bytes: ByteArray? = null
    val stream = CancellableByteArrayOutputStream(request)
    try {
      if (request.isCancelled) return
      var output: Bitmap = bitmap
      if (request.scaleToSnapshot && !request.alreadyScaled) {
        output = Bitmap.createScaledBitmap(bitmap, request.dstWidth, request.dstHeight, true)
        // createScaledBitmap can return the source itself; only a distinct
        // bitmap is tracked so that it is recycled exactly once.
        if (output !== bitmap) {
          scaled = output
        }
      }
      if (request.isCancelled) return
      if (output.compress(request.compressFormat, request.quality, stream)) {
        bytes = stream.toByteArray()
      } else if (!request.isCancelled) {
        // A failed compress leaves an empty or truncated buffer; reply null.
        Log.e(
          LOG_TAG,
          "Screenshot cannot be compressed using compressFormat " +
            request.compressFormat.name + " with quality " + request.quality,
          null
        )
      }
    } catch (e: ScreenshotCancelledException) {
      // Cancelled mid-compress.
    } catch (e: Throwable) {
      // Includes OutOfMemoryError from createScaledBitmap on low-memory devices.
      Log.e(LOG_TAG, "Screenshot failed", e)
    } finally {
      scaled?.recycle()
      bitmap.recycle()
      deliver(request, if (request.isCancelled) null else bytes)
    }
  }
}

/** Thrown from a cancelled compress; carries no stack trace. */
internal class ScreenshotCancelledException : RuntimeException("Screenshot cancelled") {
  override fun fillInStackTrace(): Throwable = this
}

/** Aborts Bitmap.compress as soon as its request is cancelled. */
internal class CancellableByteArrayOutputStream(
  private val request: ScreenshotRequest
) : ByteArrayOutputStream() {
  override fun write(b: Int) {
    if (request.isCancelled) throw ScreenshotCancelledException()
    super.write(b)
  }

  override fun write(b: ByteArray, off: Int, len: Int) {
    if (request.isCancelled) throw ScreenshotCancelledException()
    super.write(b, off, len)
  }
}
