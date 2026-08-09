package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.graphics.Bitmap
import android.net.Uri
import android.net.http.SslError
import android.os.Build
import android.os.Message
import android.util.Log
import android.view.KeyEvent
import android.webkit.ClientCertRequest
import android.webkit.CookieManager
import android.webkit.CookieSyncManager
import android.webkit.HttpAuthHandler
import android.webkit.RenderProcessGoneDetail
import android.webkit.SafeBrowsingResponse
import android.webkit.SslErrorHandler
import android.webkit.ValueCallback
import android.webkit.WebResourceError
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import android.webkit.WebView
import android.webkit.WebViewClient

import androidx.annotation.RequiresApi
import androidx.webkit.WebResourceRequestCompat
import androidx.webkit.WebViewFeature

import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.credential_database.CredentialDatabase
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserDelegate
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS
import com.emirkanacar.flutter_inappwebview_forge_android.types.ClientCertChallenge
import com.emirkanacar.flutter_inappwebview_forge_android.types.ClientCertResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.CustomSchemeResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.HttpAuthResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.HttpAuthenticationChallenge
import com.emirkanacar.flutter_inappwebview_forge_android.types.NavigationAction
import com.emirkanacar.flutter_inappwebview_forge_android.types.NavigationActionPolicy
import com.emirkanacar.flutter_inappwebview_forge_android.types.ServerTrustAuthResponse
import com.emirkanacar.flutter_inappwebview_forge_android.types.ServerTrustChallenge
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLCredential
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLProtectionSpace
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLRequest
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceErrorExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceRequestExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceResponseExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate

import java.io.ByteArrayInputStream
import java.net.URI
import java.net.URISyntaxException
import java.util.concurrent.atomic.AtomicInteger
import java.util.concurrent.atomic.AtomicLong
import java.util.regex.Matcher

open class InAppWebViewClient(
  protected var inAppBrowserDelegate: InAppBrowserDelegate?
) : WebViewClient() {

  companion object {
    @JvmField
    protected val LOG_TAG = "IAWebViewClient"

    @JvmField
    protected var previousAuthRequestFailureCount = 0

    @JvmField
    protected var credentialsProposed: MutableList<URLCredential>? = null

    private const val MAX_CONCURRENT_SYNC_INTERCEPT_REQUESTS = 2
  }

  private val synchronousInterceptRequestsInFlight = AtomicInteger(0)
  private val nativeNavigationSequence = AtomicLong(0)

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  override fun shouldOverrideUrlLoading(view: WebView, request: WebResourceRequest): Boolean {
    val webView = view as? InAppWebView
    if (webView == null) return false
    val requestUrl = request.url.toString()

    if (allowSyncUrlLoading(webView, requestUrl)) {
      // Allow the request synchronously.
      return false
    }

    if (webView.customSettings.useShouldOverrideUrlLoading == true) {
      val nativeNavigationContinues =
        request.isForMainFrame && isHttpOrHttpsUrl(requestUrl)
      var isRedirect = false
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT)) {
        isRedirect = WebResourceRequestCompat.isRedirect(request)
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        isRedirect = request.isRedirect
      }
      onShouldOverrideUrlLoading(
        webView,
        requestUrl,
        request.method,
        request.requestHeaders,
        request.isForMainFrame,
        request.hasGesture(),
        isRedirect,
        nativeNavigationContinues,
        nativeNavigationSequence.incrementAndGet()
      )
    }
    if (!request.isForMainFrame) {
      webView.customSettings.regexToCancelSubFramesLoading?.let { regex ->
        return regex.matcher(requestUrl).matches()
      }
    }
    if (webView.customSettings.useShouldOverrideUrlLoading == true) {
      // There isn't any way to load an URL for a frame that is not the main frame,
      // so if the request is not for the main frame, the navigation is allowed.
      return request.isForMainFrame && !isHttpOrHttpsUrl(requestUrl)
    }

    return false
  }

  override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
    val webView = view as? InAppWebView ?: return false

    if (allowSyncUrlLoading(webView, url)) {
      // Allow the request synchronously.
      return false
    }

    if (webView.customSettings.useShouldOverrideUrlLoading == true) {
      val nativeNavigationContinues = isHttpOrHttpsUrl(url)
      onShouldOverrideUrlLoading(
        webView,
        url,
        "GET",
        null,
        true,
        false,
        false,
        nativeNavigationContinues,
        nativeNavigationSequence.incrementAndGet()
      )
      return !nativeNavigationContinues
    }
    return false
  }

  private fun isHttpOrHttpsUrl(url: String): Boolean {
    val scheme = Uri.parse(url).scheme ?: return false
    return scheme.equals("http", ignoreCase = true) ||
      scheme.equals("https", ignoreCase = true)
  }

  private fun allowSyncUrlLoading(webView: InAppWebView, url: String): Boolean {
    webView.customSettings.regexToAllowSyncUrlLoading?.let { regex ->
      if (regex.matcher(url).matches()) {
        Log.d(
          LOG_TAG,
          "Request '$url' automatically allowed as it is a match for 'regexToAllowSyncUrlLoading'."
        )
        return true
      }
    }
    return false
  }

  private fun allowShouldOverrideUrlLoading(
    webView: WebView,
    url: String,
    headers: MutableMap<String, String>?,
    isForMainFrame: Boolean
  ) {
    if (isForMainFrame) {
      // There isn't any way to load an URL for a frame that is not the main frame,
      // so call this only on main frame.
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP && headers != null) {
        webView.loadUrl(url, headers)
      } else {
        webView.loadUrl(url)
      }
    }
  }
  fun onShouldOverrideUrlLoading(
    webView: InAppWebView,
    url: String,
    method: String,
    headers: MutableMap<String, String>?,
    isForMainFrame: Boolean,
    hasGesture: Boolean,
    isRedirect: Boolean,
    nativeNavigationContinues: Boolean = false,
    nativeNavigationId: Long? = null
  ) {
    val request = URLRequest(url, method, null, headers)
    val navigationAction = NavigationAction(request, isForMainFrame, hasGesture, isRedirect)

    val callback = object : WebViewChannelDelegate.ShouldOverrideUrlLoadingCallback() {
      override fun nonNullSuccess(result: NavigationActionPolicy): Boolean {
        when (result) {
          NavigationActionPolicy.ALLOW ->
            if (!nativeNavigationContinues) {
              allowShouldOverrideUrlLoading(webView, url, headers, isForMainFrame)
            }
          NavigationActionPolicy.CANCEL ->
            if (nativeNavigationContinues &&
              (nativeNavigationId == null ||
                nativeNavigationSequence.get() == nativeNavigationId)
            ) {
              webView.stopLoading()
            }
        }
        return false
      }

      override fun defaultBehaviour(result: NavigationActionPolicy?) {
        if (!nativeNavigationContinues) {
          allowShouldOverrideUrlLoading(webView, url, headers, isForMainFrame)
        }
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.shouldOverrideUrlLoading(navigationAction, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  @SuppressLint("RestrictedApi")
  fun loadCustomJavaScriptOnPageStarted(view: WebView) {
    val webView = view as? InAppWebView ?: return

    if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      val source = webView.userContentController.generateWrappedCodeForDocumentStart()
      webView.evaluateJavascript(source, null)
    }
  }

  fun loadCustomJavaScriptOnPageFinished(view: WebView) {
    val webView = view as? InAppWebView ?: return

    if (!WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
      val source = webView.userContentController.generateWrappedCodeForDocumentEnd()
      webView.evaluateJavascript(source, null)
    }
  }

  override fun onPageStarted(view: WebView, url: String, favicon: Bitmap?) {
    val webView = view as? InAppWebView ?: return
    webView.isLoading = true
    webView.disposeWebMessageChannels()
    webView.userContentController.resetContentWorlds()
    loadCustomJavaScriptOnPageStarted(webView)

    super.onPageStarted(view, url, favicon)

    inAppBrowserDelegate?.didStartNavigation(url)
    webView.channelDelegate?.onLoadStart(url)
  }

  @Suppress("DEPRECATION")
  override fun onPageFinished(view: WebView, url: String) {
    val webView = view as? InAppWebView ?: return
    webView.isLoading = false
    loadCustomJavaScriptOnPageFinished(webView)
    previousAuthRequestFailureCount = 0
    credentialsProposed = null

    super.onPageFinished(view, url)

    inAppBrowserDelegate?.didFinishNavigation(url)

    // WebView does not reliably store cookies to local device storage.
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().flush()
    } else {
      CookieSyncManager.getInstance().sync()
    }

    val js = JavaScriptBridgeJS.PLATFORM_READY_JS_SOURCE()
    webView.evaluateJavascript(js, null)
    webView.channelDelegate?.onLoadStop(url)
  }

  override fun doUpdateVisitedHistory(view: WebView, url: String, isReload: Boolean) {
    super.doUpdateVisitedHistory(view, url, isReload)

    // The url argument sometimes does not contain the changed URL, so read it again.
    val currentUrl = view.url ?: url
    inAppBrowserDelegate?.didUpdateVisitedHistory(currentUrl)

    val webView = view as? InAppWebView ?: return
    webView.channelDelegate?.onUpdateVisitedHistory(currentUrl, isReload)
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  override fun onReceivedError(
    view: WebView,
    request: WebResourceRequest,
    error: WebResourceError
  ) {
    val webView = view as InAppWebView

    if (request.isForMainFrame) {
      if (webView.customSettings.disableDefaultErrorPage == true) {
        webView.stopLoading()
        webView.loadUrl("about:blank")
      }

      webView.isLoading = false
      previousAuthRequestFailureCount = 0
      credentialsProposed = null

      inAppBrowserDelegate?.didFailNavigation(
        request.url.toString(),
        error.errorCode,
        error.description?.toString() ?: ""
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
    val webView = view as InAppWebView

    if (webView.customSettings.disableDefaultErrorPage == true) {
      webView.stopLoading()
      webView.loadUrl("about:blank")
    }

    webView.isLoading = false
    previousAuthRequestFailureCount = 0
    credentialsProposed = null
    inAppBrowserDelegate?.didFailNavigation(failingUrl, errorCode, description)

    val request = WebResourceRequestExt(failingUrl, null, false, false, true, "GET")
    val error = WebResourceErrorExt(errorCode, description)
    webView.channelDelegate?.onReceivedError(request, error)

    super.onReceivedError(view, errorCode, description, failingUrl)
  }

  @RequiresApi(api = Build.VERSION_CODES.M)
  override fun onReceivedHttpError(
    view: WebView,
    request: WebResourceRequest,
    errorResponse: WebResourceResponse
  ) {
    super.onReceivedHttpError(view, request, errorResponse)

    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedHttpError(
      WebResourceRequestExt.fromWebResourceRequest(request),
      WebResourceResponseExt.fromWebResourceResponse(errorResponse)
    )
  }

  override fun onReceivedHttpAuthRequest(
    view: WebView,
    handler: HttpAuthHandler,
    host: String,
    realm: String
  ) {
    val url = view.url
    var protocol = "https"
    var port = 0

    if (url != null) {
      try {
        val uri = URI(url)
        uri.scheme?.let { protocol = it }
        port = uri.port
      } catch (e: URISyntaxException) {
        Log.e(LOG_TAG, "", e)
      }
    }

    previousAuthRequestFailureCount++

    if (credentialsProposed == null) {
      credentialsProposed = CredentialDatabase.getInstance(view.context)
        .getHttpAuthCredentials(host, protocol, realm, port)
    }

    val credentialProposed = credentialsProposed?.firstOrNull()
    val protectionSpace = URLProtectionSpace(
      host,
      protocol,
      realm,
      port,
      view.certificate,
      null
    )
    val challenge = HttpAuthenticationChallenge(
      protectionSpace,
      previousAuthRequestFailureCount,
      credentialProposed
    )

    val webView = view as InAppWebView
    val finalProtocol = protocol
    val finalPort = port
    val callback = object : WebViewChannelDelegate.ReceivedHttpAuthRequestCallback() {
      override fun nonNullSuccess(response: HttpAuthResponse): Boolean {
        when (response.action) {
          1 -> {
            val username = response.username
            val password = response.password
            if (response.isPermanentPersistence) {
              CredentialDatabase.getInstance(view.context).setHttpAuthCredential(
                host,
                finalProtocol,
                realm,
                finalPort,
                username,
                password
              )
            }
            handler.proceed(username, password)
          }
          2 -> {
            val proposedCredentials = credentialsProposed
            if (!proposedCredentials.isNullOrEmpty()) {
              val credential = proposedCredentials.removeAt(0)
              handler.proceed(credential.getUsername(), credential.getPassword())
            } else {
              handler.cancel()
            }
            // Use the custom CredentialDatabase.
          }
          else -> {
            credentialsProposed = null
            previousAuthRequestFailureCount = 0
            handler.cancel()
          }
        }
        return false
      }

      override fun defaultBehaviour(result: HttpAuthResponse?) {
        super@InAppWebViewClient.onReceivedHttpAuthRequest(view, handler, host, realm)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onReceivedHttpAuthRequest(challenge, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  override fun onReceivedSslError(
    view: WebView,
    handler: SslErrorHandler,
    sslError: SslError
  ) {
    val url = sslError.url
    var host = ""
    var protocol = "https"
    var port = 0

    try {
      val uri = URI(url)
      host = uri.host ?: ""
      protocol = uri.scheme ?: "https"
      port = uri.port
    } catch (e: URISyntaxException) {
      Log.e(LOG_TAG, "", e)
    }

    val protectionSpace = URLProtectionSpace(
      host,
      protocol,
      null,
      port,
      sslError.certificate,
      sslError
    )
    val challenge = ServerTrustChallenge(protectionSpace)

    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.ReceivedServerTrustAuthRequestCallback() {
      override fun nonNullSuccess(response: ServerTrustAuthResponse): Boolean {
        when (response.action) {
          1 -> handler.proceed()
          else -> handler.cancel()
        }
        return false
      }

      override fun defaultBehaviour(result: ServerTrustAuthResponse?) {
        super@InAppWebViewClient.onReceivedSslError(view, handler, sslError)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onReceivedServerTrustAuthRequest(challenge, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  override fun onReceivedClientCertRequest(view: WebView, request: ClientCertRequest) {
    val url = view.url
    val host = request.host
    var protocol = "https"
    val port = request.port

    if (url != null) {
      try {
        val uri = URI(url)
        uri.scheme?.let { protocol = it }
      } catch (e: URISyntaxException) {
        Log.e(LOG_TAG, "", e)
      }
    }

    val protectionSpace = URLProtectionSpace(
      host,
      protocol,
      null,
      port,
      view.certificate,
      null
    )
    val challenge = ClientCertChallenge(protectionSpace, request.principals, request.keyTypes)

    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.ReceivedClientCertRequestCallback() {
      override fun nonNullSuccess(response: ClientCertResponse): Boolean {
        val plugin = webView.plugin
        when (response.action) {
          1 -> if (plugin != null) {
            val privateKeyAndCertificates = Util.loadPrivateKeyAndCertificate(
              plugin,
              response.certificatePath,
              response.certificatePassword,
              response.keyStoreType
            )
            if (privateKeyAndCertificates != null) {
              request.proceed(
                privateKeyAndCertificates.privateKey,
                privateKeyAndCertificates.certificates
              )
            } else {
              request.cancel()
            }
          } else {
            request.cancel()
          }
          2 -> request.ignore()
          else -> request.cancel()
        }

        return false
      }

      override fun defaultBehaviour(result: ClientCertResponse?) {
        super@InAppWebViewClient.onReceivedClientCertRequest(view, request)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onReceivedClientCertRequest(challenge, callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  override fun onScaleChanged(view: WebView, oldScale: Float, newScale: Float) {
    super.onScaleChanged(view, oldScale, newScale)
    val webView = view as InAppWebView
    webView.zoomScale = newScale / Util.getPixelDensity(webView.context)
    webView.channelDelegate?.onZoomScaleChanged(oldScale, newScale)
  }

  @RequiresApi(api = Build.VERSION_CODES.O_MR1)
  override fun onSafeBrowsingHit(
    view: WebView,
    request: WebResourceRequest,
    threatType: Int,
    callback: SafeBrowsingResponse
  ) {
    val webView = view as InAppWebView
    val resultCallback = object : WebViewChannelDelegate.SafeBrowsingHitCallback() {
      override fun nonNullSuccess(
        response: com.emirkanacar.flutter_inappwebview_forge_android.types.SafeBrowsingResponse
      ): Boolean {
        when (response.action) {
          0 -> callback.backToSafety(response.isReport)
          1 -> callback.proceed(response.isReport)
          else -> callback.showInterstitial(response.isReport)
        }
        return false
      }

      override fun defaultBehaviour(
        result: com.emirkanacar.flutter_inappwebview_forge_android.types.SafeBrowsingResponse?
      ) {
        super@InAppWebViewClient.onSafeBrowsingHit(view, request, threatType, callback)
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

  fun shouldInterceptRequest(view: WebView, request: WebResourceRequestExt): WebResourceResponse? {
    val webView = view as InAppWebView

    val assetLoader = webView.webViewAssetLoaderExt?.loader
    if (assetLoader != null) {
      try {
        val uri = Uri.parse(request.url)
        val webResourceResponse = assetLoader.shouldInterceptRequest(uri)
        if (webResourceResponse != null) {
          return webResourceResponse
        }
      } catch (e: Exception) {
        Log.e(LOG_TAG, "", e)
      }
    }

    if (webView.customSettings.useShouldInterceptRequest == true) {
      var response: WebResourceResponseExt? = null
      val channelDelegate = webView.channelDelegate
      if (channelDelegate != null) {
        if (
          synchronousInterceptRequestsInFlight.incrementAndGet() >
          MAX_CONCURRENT_SYNC_INTERCEPT_REQUESTS
        ) {
          synchronousInterceptRequestsInFlight.decrementAndGet()
          Log.w(
            LOG_TAG,
            "Too many synchronous shouldInterceptRequest callbacks are pending; " +
              "allowing the resource request to continue."
          )
          return null
        }

        try {
          response = channelDelegate.shouldInterceptRequest(request)
        } catch (e: InterruptedException) {
          Thread.currentThread().interrupt()
          Log.e(LOG_TAG, "", e)
          return null
        } finally {
          synchronousInterceptRequestsInFlight.decrementAndGet()
        }
      }

      if (response != null) {
        val inputStream = response.data?.let { ByteArrayInputStream(it) }
        if (
          Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
          response.statusCode != null &&
          response.reasonPhrase != null
        ) {
          return WebResourceResponse(
            response.contentType,
            response.contentEncoding,
            response.statusCode ?: 0,
            response.reasonPhrase ?: "",
            response.headers,
            inputStream
          )
        } else {
          return WebResourceResponse(response.contentType, response.contentEncoding, inputStream)
        }
      }

      return null
    }

    val url = request.url
    var scheme = url.substringBefore(":").lowercase()
    try {
      Uri.parse(request.url).scheme?.let { scheme = it }
    } catch (_: Exception) {
      // Keep the scheme parsed from the URL prefix.
    }

    if (webView.customSettings.resourceCustomSchemes.contains(scheme)) {
      var customSchemeResponse: CustomSchemeResponse? = null
      val channelDelegate = webView.channelDelegate
      if (channelDelegate != null) {
        try {
          customSchemeResponse = channelDelegate.onLoadResourceWithCustomScheme(request)
        } catch (e: InterruptedException) {
          Log.e(LOG_TAG, "", e)
          return null
        }
      }

      if (customSchemeResponse != null) {
        var response: WebResourceResponse? = null
        try {
          response = webView.contentBlockerHandler.checkUrl(
            webView,
            request,
            customSchemeResponse.contentType
          )
        } catch (e: Exception) {
          Log.e(LOG_TAG, "", e)
        }
        if (response != null)
          return response
        return WebResourceResponse(
          customSchemeResponse.contentType,
          customSchemeResponse.contentType,
          ByteArrayInputStream(customSchemeResponse.data)
        )
      }
    }

    var response: WebResourceResponse? = null
    if (webView.contentBlockerHandler.getRuleList().isNotEmpty()) {
      try {
        response = webView.contentBlockerHandler.checkUrl(webView, request)
      } catch (e: Exception) {
        Log.e(LOG_TAG, "", e)
      }
    }
    return response
  }

  override fun shouldInterceptRequest(view: WebView, url: String): WebResourceResponse? {
    val requestExt = WebResourceRequestExt(url, null, false, false, true, "GET")
    return shouldInterceptRequest(view, requestExt)
  }

  @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
  override fun shouldInterceptRequest(
    view: WebView,
    request: WebResourceRequest
  ): WebResourceResponse? {
    val requestExt = WebResourceRequestExt.fromWebResourceRequest(request)
    return shouldInterceptRequest(view, requestExt)
  }

  override fun onFormResubmission(view: WebView, dontResend: Message, resend: Message) {
    val webView = view as InAppWebView
    val callback = object : WebViewChannelDelegate.FormResubmissionCallback() {
      override fun nonNullSuccess(action: Int): Boolean {
        when (action) {
          0 -> resend.sendToTarget()
          else -> dontResend.sendToTarget()
        }
        return false
      }

      override fun defaultBehaviour(result: Int?) {
        super@InAppWebViewClient.onFormResubmission(view, dontResend, resend)
      }

      override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        Log.e(LOG_TAG, "$errorCode, ${errorMessage ?: ""}")
        defaultBehaviour(null)
      }
    }

    val channelDelegate = webView.channelDelegate
    if (channelDelegate != null) {
      channelDelegate.onFormResubmission(webView.url ?: "", callback)
    } else {
      callback.defaultBehaviour(null)
    }
  }

  override fun onPageCommitVisible(view: WebView, url: String) {
    super.onPageCommitVisible(view, url)

    val webView = view as InAppWebView
    webView.channelDelegate?.onPageCommitVisible(url)
  }

  @RequiresApi(api = Build.VERSION_CODES.O)
  override fun onRenderProcessGone(view: WebView, detail: RenderProcessGoneDetail): Boolean {
    val webView = view as InAppWebView

    val channelDelegate = webView.channelDelegate
    if (webView.customSettings.useOnRenderProcessGone == true && channelDelegate != null) {
      channelDelegate.onRenderProcessGone(detail.didCrash(), detail.rendererPriorityAtExit())
      return true
    }

    return super.onRenderProcessGone(view, detail)
  }

  override fun onReceivedLoginRequest(view: WebView, realm: String, account: String?, args: String) {
    val webView = view as InAppWebView
    webView.channelDelegate?.onReceivedLoginRequest(realm, account, args)
  }

  override fun onUnhandledKeyEvent(view: WebView, event: KeyEvent) = Unit

  fun dispose() {
    inAppBrowserDelegate = null
  }

  internal fun resetAuthenticationState() {
    previousAuthRequestFailureCount = 0
    credentialsProposed = null
  }
}
