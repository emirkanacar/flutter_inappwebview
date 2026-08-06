package com.emirkanacar.flutter_inappwebview_forge_android

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewStartUpConfig
import java.util.concurrent.Executors

/**
 * Coordinates the optional asynchronous WebView provider startup introduced by AndroidX WebKit.
 *
 * WebView APIs that can block on Chromium must not run until the provider startup callback has
 * completed. Older WebKit providers may not implement this API, so a failed startup request is
 * treated as a signal to use the normal WebView path.
 */
internal object WebViewStartupCoordinator {
    private const val LOG_TAG = "WebViewStartup"

    private val mainHandler = Handler(Looper.getMainLooper())
    private val backgroundExecutor = Executors.newSingleThreadExecutor()
    private val lock = Any()
    private val pendingCallbacks = ArrayList<() -> Unit>()

    private var startupRequested = false
    private var startupCompleted = false

    fun start(context: Context) {
        runWhenReady(context) {}
    }

    fun runWhenReady(context: Context, callback: () -> Unit) {
        var shouldStart = false
        var runImmediately = false

        synchronized(lock) {
            if (startupCompleted) {
                runImmediately = true
            } else {
                pendingCallbacks.add(callback)
                if (!startupRequested) {
                    startupRequested = true
                    shouldStart = true
                }
            }
        }

        if (runImmediately) {
            mainHandler.post { callback() }
        } else if (shouldStart) {
            requestStartup(context.applicationContext)
        }
    }

    @Suppress("DEPRECATION")
    private fun requestStartup(context: Context) {
        try {
            val config = WebViewStartUpConfig.Builder(backgroundExecutor)
                .setShouldRunUiThreadStartUpTasks(true)
                .build()
            WebViewCompat.startUpWebView(
                context,
                config,
                object : WebViewCompat.WebViewStartUpCallback {
                    override fun onSuccess(result: androidx.webkit.WebViewStartUpResult) {
                        complete()
                    }
                }
            )
        } catch (error: RuntimeException) {
            Log.w(LOG_TAG, "Asynchronous WebView startup is unavailable; continuing normally.", error)
            complete()
        } catch (error: LinkageError) {
            // An application can force an older AndroidX WebKit version at resolution time.
            Log.w(LOG_TAG, "AndroidX WebKit startup API is unavailable; continuing normally.", error)
            complete()
        }
    }

    private fun complete() {
        val callbacks = synchronized(lock) {
            if (startupCompleted) {
                return
            }
            startupCompleted = true
            val result = pendingCallbacks.toList()
            pendingCallbacks.clear()
            result
        }

        callbacks.forEach { callback ->
            mainHandler.post { callback() }
        }
    }
}
