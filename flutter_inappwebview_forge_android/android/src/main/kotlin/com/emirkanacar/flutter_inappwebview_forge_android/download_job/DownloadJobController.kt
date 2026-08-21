package com.emirkanacar.flutter_inappwebview_forge_android.download_job

import android.app.DownloadManager
import android.content.Context
import android.database.Cursor
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.webkit.CookieManager
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import io.flutter.plugin.common.MethodChannel
import java.io.File

open class DownloadJobController(
    @JvmField var id: String,
    @JvmField var url: String,
    @JvmField var userAgent: String?,
    @JvmField var mimeType: String?,
    @JvmField var resultFilePath: String,
    @JvmField var plugin: InAppWebViewFlutterPlugin?
) : Disposable {
    companion object {
        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX =
            "com.emirkanacar/flutter_inappwebview_downloadjobcontroller_"

        private const val STATE_QUEUED = 0
        private const val STATE_RUNNING = 1
        private const val STATE_COMPLETED = 2
        private const val STATE_FAILED = 3
        private const val STATE_CANCELED = 4
    }

    @JvmField
    var channelDelegate: DownloadJobChannelDelegate? = null

    private var downloadId: Long = -1L
    private var state: Int = STATE_QUEUED
    private var progress: Double = 0.0
    private var error: String? = null
    private val handler = Handler(Looper.getMainLooper())
    private val pollRunnable = object : Runnable {
        override fun run() {
            if (state == STATE_CANCELED || state == STATE_COMPLETED || state == STATE_FAILED) {
                return
            }
            queryProgress()
            if (state == STATE_QUEUED || state == STATE_RUNNING) {
                handler.postDelayed(this, 500)
            }
        }
    }

    init {
        val currentPlugin = plugin
            ?: error("A plugin instance is required to create a download job controller.")
        val channel = MethodChannel(
            currentPlugin.requireMessenger(),
            METHOD_CHANNEL_NAME_PREFIX + id
        )
        channelDelegate = DownloadJobChannelDelegate(this, channel)
    }

    fun start() {
        val context = plugin?.applicationContext ?: plugin?.activity
        if (context == null) {
            fail("A Context is required to start a native download.")
            return
        }
        val destination = File(resultFilePath)
        destination.parentFile?.mkdirs()
        val request = DownloadManager.Request(Uri.parse(url)).apply {
            setAllowedOverMetered(true)
            setAllowedOverRoaming(true)
            setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE)
            setDestinationUri(Uri.fromFile(destination))
            mimeType?.let { setMimeType(it) }
            userAgent?.let { addRequestHeader("User-Agent", it) }
            val cookies = CookieManager.getInstance().getCookie(url)
            if (!cookies.isNullOrEmpty()) {
                addRequestHeader("Cookie", cookies)
            }
        }
        val manager = context.getSystemService(Context.DOWNLOAD_SERVICE) as? DownloadManager
        if (manager == null) {
            fail("DownloadManager is unavailable.")
            return
        }
        try {
            downloadId = manager.enqueue(request)
            state = STATE_RUNNING
            handler.post(pollRunnable)
        } catch (exception: Exception) {
            fail(exception.message)
        }
    }

    fun cancel() {
        val context = plugin?.applicationContext ?: plugin?.activity
        val manager = context?.getSystemService(Context.DOWNLOAD_SERVICE) as? DownloadManager
        if (downloadId >= 0) {
            manager?.remove(downloadId)
        }
        state = STATE_CANCELED
        handler.removeCallbacks(pollRunnable)
        channelDelegate?.onComplete(false, "canceled")
    }

    fun getInfo(): MutableMap<String, Any?> {
        return hashMapOf(
            "id" to id,
            "url" to url,
            "resultFilePath" to resultFilePath,
            "progress" to progress,
            "state" to state,
            "error" to error
        )
    }

    private fun queryProgress() {
        val context = plugin?.applicationContext ?: plugin?.activity ?: return
        val manager = context.getSystemService(Context.DOWNLOAD_SERVICE) as? DownloadManager ?: return
        val query = DownloadManager.Query().setFilterById(downloadId)
        var cursor: Cursor? = null
        try {
            cursor = manager.query(query)
            if (cursor == null || !cursor.moveToFirst()) {
                return
            }
            val status = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_STATUS))
            val bytes = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_BYTES_DOWNLOADED_SO_FAR))
            val total = cursor.getLong(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_TOTAL_SIZE_BYTES))
            if (total > 0) {
                progress = bytes.toDouble() / total.toDouble()
                channelDelegate?.onProgressChanged(progress)
            }
            when (status) {
                DownloadManager.STATUS_SUCCESSFUL -> {
                    state = STATE_COMPLETED
                    progress = 1.0
                    handler.removeCallbacks(pollRunnable)
                    channelDelegate?.onProgressChanged(1.0)
                    channelDelegate?.onComplete(true, null)
                }
                DownloadManager.STATUS_FAILED -> {
                    val reason = cursor.getInt(cursor.getColumnIndexOrThrow(DownloadManager.COLUMN_REASON))
                    fail("DownloadManager failed with reason $reason")
                }
            }
        } catch (exception: Exception) {
            fail(exception.message)
        } finally {
            cursor?.close()
        }
    }

    private fun fail(message: String?) {
        state = STATE_FAILED
        error = message
        handler.removeCallbacks(pollRunnable)
        channelDelegate?.onComplete(false, message)
    }

    override fun dispose() {
        handler.removeCallbacks(pollRunnable)
        plugin?.downloadJobManager?.jobs?.remove(id)
        channelDelegate?.dispose()
        channelDelegate = null
        plugin = null
    }
}
