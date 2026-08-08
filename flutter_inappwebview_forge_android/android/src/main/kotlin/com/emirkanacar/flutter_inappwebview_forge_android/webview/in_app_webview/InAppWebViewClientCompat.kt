package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.annotation.SuppressLint
import android.graphics.Bitmap
import android.net.http.SslError
import android.os.Build
import android.os.Message
import android.util.Log
import android.view.KeyEvent
import android.webkit.ClientCertRequest
import android.webkit.HttpAuthHandler
import android.webkit.RenderProcessGoneDetail
import android.webkit.SslErrorHandler
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView

import androidx.annotation.RequiresApi
import androidx.webkit.SafeBrowsingResponseCompat
import androidx.webkit.WebResourceErrorCompat
import androidx.webkit.WebViewClientCompat
import androidx.webkit.WebViewFeature

import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserDelegate
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceErrorExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceRequestExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceResponseExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate

open class InAppWebViewClientCompat(
    private var inAppBrowserDelegate: InAppBrowserDelegate?
) : WebViewClientCompat() {
    companion object {
        @JvmField
        protected val LOG_TAG = "IAWebViewClientCompat"
    }

    private val delegate = InAppWebViewClient(inAppBrowserDelegate)

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean =
        delegate.shouldOverrideUrlLoading(view, request)

    override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean =
        delegate.shouldOverrideUrlLoading(view, url)

    fun loadCustomJavaScriptOnPageStarted(view: WebView) {
        delegate.loadCustomJavaScriptOnPageStarted(view)
    }

    fun loadCustomJavaScriptOnPageFinished(view: WebView) {
        delegate.loadCustomJavaScriptOnPageFinished(view)
    }

    override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
        delegate.onPageStarted(view, url, favicon)
    }

    override fun onPageFinished(view: WebView, url: String) {
        delegate.onPageFinished(view, url)
    }

    override fun doUpdateVisitedHistory(view: WebView, url: String, isReload: Boolean) {
        delegate.doUpdateVisitedHistory(view, url, isReload)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onReceivedError(
        view: WebView,
        request: WebResourceRequest,
        error: WebResourceErrorCompat
    ) {
        val webView = view as? InAppWebView ?: return
        if (request.isForMainFrame) {
            if (webView.customSettings.disableDefaultErrorPage == true) {
                webView.stopLoading()
                webView.loadUrl("about:blank")
            }

            webView.isLoading = false
            delegate.resetAuthenticationState()

            val errorCode = if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_CODE)) {
                error.getErrorCode()
            } else {
                -1
            }
            val description = if (
                WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION)
            ) {
                error.getDescription()?.toString() ?: ""
            } else {
                ""
            }
            inAppBrowserDelegate?.didFailNavigation(
                request.url.toString(),
                errorCode,
                description
            )
        }

        webView.channelDelegate?.onReceivedError(
            WebResourceRequestExt.fromWebResourceRequest(request),
            WebResourceErrorExt.fromWebResourceError(error)
        )
    }

    @SuppressLint("RestrictedApi")
    override fun onReceivedError(
        view: WebView,
        errorCode: Int,
        description: String,
        failingUrl: String
    ) {
        delegate.onReceivedError(view, errorCode, description, failingUrl)
    }

    @RequiresApi(Build.VERSION_CODES.M)
    override fun onReceivedHttpError(
        view: WebView,
        request: WebResourceRequest,
        errorResponse: WebResourceResponse
    ) {
        delegate.onReceivedHttpError(view, request, errorResponse)
    }

    override fun onReceivedHttpAuthRequest(
        view: WebView,
        handler: HttpAuthHandler,
        host: String,
        realm: String
    ) {
        delegate.onReceivedHttpAuthRequest(view, handler, host, realm)
    }

    override fun onReceivedSslError(
        view: WebView,
        handler: SslErrorHandler,
        sslError: SslError
    ) {
        delegate.onReceivedSslError(view, handler, sslError)
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onReceivedClientCertRequest(view: WebView, request: ClientCertRequest) {
        delegate.onReceivedClientCertRequest(view, request)
    }

    override fun onScaleChanged(view: WebView, oldScale: Float, newScale: Float) {
        delegate.onScaleChanged(view, oldScale, newScale)
    }

    @RequiresApi(Build.VERSION_CODES.O_MR1)
    override fun onSafeBrowsingHit(
        view: WebView,
        request: WebResourceRequest,
        threatType: Int,
        callback: SafeBrowsingResponseCompat
    ) {
        val webView = view as? InAppWebView ?: run {
            callback.showInterstitial(false)
            return
        }
        val resultCallback = object : WebViewChannelDelegate.SafeBrowsingHitCallback() {
            override fun nonNullSuccess(
                response: com.emirkanacar.flutter_inappwebview_forge_android.types.SafeBrowsingResponse
            ): Boolean {
                val report = response.isReport
                return when (response.action) {
                    0 -> if (WebViewFeature.isFeatureSupported(
                            WebViewFeature.SAFE_BROWSING_RESPONSE_BACK_TO_SAFETY
                        )
                    ) {
                        callback.backToSafety(report)
                        false
                    } else {
                        true
                    }
                    1 -> if (WebViewFeature.isFeatureSupported(
                            WebViewFeature.SAFE_BROWSING_RESPONSE_PROCEED
                        )
                    ) {
                        callback.proceed(report)
                        false
                    } else {
                        true
                    }
                    else -> if (WebViewFeature.isFeatureSupported(
                            WebViewFeature.SAFE_BROWSING_RESPONSE_SHOW_INTERSTITIAL
                        )
                    ) {
                        callback.showInterstitial(report)
                        false
                    } else {
                        true
                    }
                }
            }

            override fun defaultBehaviour(
                result: com.emirkanacar.flutter_inappwebview_forge_android.types.SafeBrowsingResponse?
            ) {
                super@InAppWebViewClientCompat.onSafeBrowsingHit(
                    view,
                    request,
                    threatType,
                    callback
                )
            }

            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
                defaultBehaviour(null)
            }
        }

        val channelDelegate = webView.channelDelegate
        if (channelDelegate != null) {
            channelDelegate.onSafeBrowsingHit(request.url.toString(), threatType, resultCallback)
        } else {
            resultCallback.defaultBehaviour(null)
        }
    }

    fun shouldInterceptRequest(
        view: WebView,
        request: WebResourceRequestExt
    ): WebResourceResponse? = delegate.shouldInterceptRequest(view, request)

    override fun shouldInterceptRequest(view: WebView, url: String): WebResourceResponse? =
        delegate.shouldInterceptRequest(view, url)

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun shouldInterceptRequest(
        view: WebView,
        request: WebResourceRequest
    ): WebResourceResponse? = delegate.shouldInterceptRequest(view, request)

    override fun onFormResubmission(view: WebView, dontResend: Message, resend: Message) {
        delegate.onFormResubmission(view, dontResend, resend)
    }

    override fun onPageCommitVisible(view: WebView, url: String) {
        delegate.onPageCommitVisible(view, url)
    }

    @RequiresApi(Build.VERSION_CODES.O)
    override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean =
        delegate.onRenderProcessGone(view, detail)

    override fun onReceivedLoginRequest(
        view: WebView,
        realm: String,
        account: String?,
        args: String
    ) {
        delegate.onReceivedLoginRequest(view, realm, account, args)
    }

    override fun onUnhandledKeyEvent(view: WebView, event: KeyEvent) {
        delegate.onUnhandledKeyEvent(view, event)
    }

    fun dispose() {
        delegate.dispose()
        inAppBrowserDelegate = null
    }
}
