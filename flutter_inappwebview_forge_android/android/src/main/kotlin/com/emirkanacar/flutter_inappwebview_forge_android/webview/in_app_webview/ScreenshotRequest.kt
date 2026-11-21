package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.graphics.Bitmap
import java.util.concurrent.atomic.AtomicBoolean

/**
 * One accepted takeScreenshot() call, tracked from admission until its bitmap
 * work is over.
 *
 * - The reply is owned by InAppWebView and is only sent on the WebView looper
 *   through completeScreenshotResult(), which is idempotent.
 * - [cancel] and [tryMarkStarted] decide who owns an unstarted request: a
 *   cancel that wins the start latch releases it, otherwise the capture stage
 *   does.
 * - [markFinished] makes the admission permit release happen exactly once,
 *   from whichever thread finishes the bitmap work.
 *
 * Capture parameters are written on the looper before the request is handed
 * to the encoder thread; the Handler post publishes them.
 */
internal class ScreenshotRequest(
  val id: Long,
  val operationId: Long,
  val configuration: Map<String, Any?>,
  val pixelDensity: Float
) {
  private val cancelled = AtomicBoolean(false)
  private val started = AtomicBoolean(false)
  private val finished = AtomicBoolean(false)

  var captureTask: Runnable? = null

  var compressFormat: Bitmap.CompressFormat = Bitmap.CompressFormat.PNG
  var quality: Int = 100
  var captureX: Int = 0
  var captureY: Int = 0
  var captureWidth: Int = 0
  var captureHeight: Int = 0
  /** Whether snapshotWidth was set; the encoder then scales to dstWidth x dstHeight. */
  var scaleToSnapshot: Boolean = false
  var dstWidth: Int = 0
  var dstHeight: Int = 0
  var drawScaled: Boolean = false
  var usePixelCopy: Boolean = false
  /** The captured bitmap already has the snapshot size (drawScaled or PixelCopy). */
  @Volatile
  var alreadyScaled: Boolean = false

  val isCancelled: Boolean
    get() = cancelled.get()

  /** Returns false if the request was already cancelled. */
  fun cancel(): Boolean = cancelled.compareAndSet(false, true)

  /** Returns false if the capture stage already started or a cancel claimed it. */
  fun tryMarkStarted(): Boolean = started.compareAndSet(false, true)

  /** Returns true exactly once. */
  fun markFinished(): Boolean = finished.compareAndSet(false, true)
}
