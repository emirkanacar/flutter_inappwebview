package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.util.Log
import android.webkit.WebView
import androidx.webkit.WebViewFeature
import androidx.webkit.WebViewRenderProcess
import androidx.webkit.WebViewRenderProcessClient
import com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate

open class InAppWebViewRenderProcessClient : WebViewRenderProcessClient() {
    companion object {
        @JvmField
        protected val LOG_TAG = "IAWRenderProcessClient"
    }

    override fun onRenderProcessUnresponsive(
        view: WebView,
        renderer: WebViewRenderProcess?
    ) {
        val webView = view as? InAppWebView ?: return
        val callback = object : WebViewChannelDelegate.RenderProcessUnresponsiveCallback() {
            override fun nonNullSuccess(action: Int): Boolean {
                if (renderer != null) {
                    when (action) {
                        0 -> if (WebViewFeature.isFeatureSupported(
                                WebViewFeature.WEB_VIEW_RENDERER_TERMINATE
                            )
                        ) {
                            renderer.terminate()
                        }
                    }
                    return false
                }
                return true
            }

            override fun defaultBehaviour(result: Int?) {
                // Keep the WebView default behavior.
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
                completeDefaultBehaviour(null)
            }
        }

        val channelDelegate = webView.channelDelegate
        if (channelDelegate != null) {
            channelDelegate.onRenderProcessUnresponsive(webView.url ?: "", callback)
        } else {
            callback.completeDefaultBehaviour(null)
        }
    }

    override fun onRenderProcessResponsive(
        view: WebView,
        renderer: WebViewRenderProcess?
    ) {
        val webView = view as? InAppWebView ?: return
        val callback = object : WebViewChannelDelegate.RenderProcessResponsiveCallback() {
            override fun nonNullSuccess(action: Int): Boolean {
                if (renderer != null) {
                    when (action) {
                        0 -> if (WebViewFeature.isFeatureSupported(
                                WebViewFeature.WEB_VIEW_RENDERER_TERMINATE
                            )
                        ) {
                            renderer.terminate()
                        }
                    }
                    return false
                }
                return true
            }

            override fun defaultBehaviour(result: Int?) {
                // Keep the WebView default behavior.
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
                completeDefaultBehaviour(null)
            }
        }

        val channelDelegate = webView.channelDelegate
        if (channelDelegate != null) {
            channelDelegate.onRenderProcessResponsive(webView.url ?: "", callback)
        } else {
            callback.completeDefaultBehaviour(null)
        }
    }

    fun dispose() {
        // No resources are held by the render-process client.
    }
}
