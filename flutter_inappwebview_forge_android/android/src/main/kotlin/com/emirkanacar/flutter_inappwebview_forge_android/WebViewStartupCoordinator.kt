package com.emirkanacar.flutter_inappwebview_forge_android

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewStartUpConfig
import java.util.concurrent.ExecutorService
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
    private const val STARTUP_TIMEOUT_MS = 5_000L

    private val mainHandler = Handler(Looper.getMainLooper())
    private var backgroundExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val lock = Any()
    private val pendingCallbacks = ArrayList<() -> Unit>()

    private var startupRequested = false
    private var startupCompleted = false
    private var disposed = false
    private var startupGeneration = 0L

    fun start(context: Context) {
        synchronized(lock) {
            if (disposed) {
                // Engine detach disposes the coordinator's executor. A later engine attach must
                // be able to start a fresh provider initialization cycle.
                disposed = false
                startupRequested = false
                startupCompleted = false
                backgroundExecutor = Executors.newSingleThreadExecutor()
                startupGeneration += 1
            }
        }
        runWhenReady(context) {}
    }

    fun runWhenReady(context: Context, callback: () -> Unit) {
        var shouldStart = false
        var runImmediately = false
        var requestGeneration = 0L

        synchronized(lock) {
            if (disposed) {
                return
            }
            if (startupCompleted) {
                runImmediately = true
            } else {
                pendingCallbacks.add(callback)
                if (!startupRequested) {
                    startupRequested = true
                    shouldStart = true
                    requestGeneration = startupGeneration
                }
            }
        }

        if (runImmediately) {
            mainHandler.post { callback() }
        } else if (shouldStart) {
            requestStartup(context.applicationContext, requestGeneration)
        }
    }

    @Suppress("DEPRECATION")
    private fun requestStartup(context: Context, generation: Long) {
        val executor = synchronized(lock) {
            if (disposed || generation != startupGeneration) {
                null
            } else {
                backgroundExecutor
            }
        } ?: return

        // Some WebView providers can leave the asynchronous startup callback pending while
        // Chromium is still bringing up its browser process. Do not let that hold the first
        // platform-view load forever; native bridge and document-start registration already
        // have bounded retries for this provider state.
        mainHandler.postDelayed(
            { complete(generation, timedOut = true) },
            STARTUP_TIMEOUT_MS
        )

        try {
            val config = WebViewStartUpConfig.Builder(executor)
                .setShouldRunUiThreadStartUpTasks(true)
                .build()
            WebViewCompat.startUpWebView(
                context,
                config,
                object : WebViewCompat.WebViewStartUpCallback {
                    override fun onSuccess(result: androidx.webkit.WebViewStartUpResult) {
                        complete(generation)
                    }
                }
            )
        } catch (error: RuntimeException) {
            Log.w(LOG_TAG, "Asynchronous WebView startup is unavailable; continuing normally.", error)
            complete(generation)
        } catch (error: LinkageError) {
            // An application can force an older AndroidX WebKit version at resolution time.
            Log.w(LOG_TAG, "AndroidX WebKit startup API is unavailable; continuing normally.", error)
            complete(generation)
        }
    }

    private fun complete(generation: Long, timedOut: Boolean = false) {
        val callbacks = synchronized(lock) {
            if (disposed || generation != startupGeneration || startupCompleted) {
                return
            }
            startupCompleted = true
            val result = pendingCallbacks.toList()
            pendingCallbacks.clear()
            result
        }

        if (timedOut) {
            Log.w(
                LOG_TAG,
                "WebView provider startup did not complete within ${STARTUP_TIMEOUT_MS}ms; " +
                    "continuing with bounded native registration retries."
            )
        }

        callbacks.forEach { callback ->
            mainHandler.post { callback() }
        }
    }

    fun dispose() {
        val executor = synchronized(lock) {
            disposed = true
            startupGeneration += 1
            pendingCallbacks.clear()
            backgroundExecutor
        }
        mainHandler.removeCallbacksAndMessages(null)
        executor.shutdownNow()
    }
}
