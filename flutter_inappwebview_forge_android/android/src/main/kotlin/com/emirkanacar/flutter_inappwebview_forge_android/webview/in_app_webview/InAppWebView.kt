@file:Suppress("DEPRECATION")

package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.animation.ObjectAnimator
import android.animation.PropertyValuesHolder
import android.annotation.SuppressLint
import android.annotation.TargetApi
import android.content.Context
import android.content.res.Resources
import android.content.pm.PackageInfo
import android.graphics.*
import android.graphics.drawable.ColorDrawable
import android.net.Uri
import android.os.*
import android.print.*
import android.text.TextUtils
import android.util.AttributeSet
import android.util.Log
import android.view.*
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection
import android.view.inputmethod.InputMethodManager
import android.webkit.*
import android.widget.*
import android.widget.AbsoluteLayout
import androidx.annotation.RequiresApi
import androidx.webkit.*
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.WebViewStartupCoordinator
import com.emirkanacar.flutter_inappwebview_forge_android.R
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.content_blocker.*
import com.emirkanacar.flutter_inappwebview_forge_android.find_interaction.FindInteractionController
import com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser.InAppBrowserDelegate
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.*
import com.emirkanacar.flutter_inappwebview_forge_android.print_job.*
import com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh.PullToRefreshLayout
import com.emirkanacar.flutter_inappwebview_forge_android.types.*
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewInterface
import com.emirkanacar.flutter_inappwebview_forge_android.webview.JavaScriptBridgeInterface
import com.emirkanacar.flutter_inappwebview_forge_android.webview.WebViewChannelDelegate
import com.emirkanacar.flutter_inappwebview_forge_android.webview.ContextMenuSettings
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageChannel
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageListener
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.util.ArrayList
import java.util.HashMap
import java.util.Iterator
import java.util.Set
import java.util.UUID
import org.json.JSONObject

class InAppWebView : InputAwareWebView, InAppWebViewInterface {
  companion object {
    private const val LOG_TAG = "InAppWebView"
    private const val MAX_NATIVE_REGISTRATION_ATTEMPTS = 8
    private const val NATIVE_REGISTRATION_RETRY_DELAY_MS = 100L

    @JvmField
    val METHOD_CHANNEL_NAME_PREFIX =
      "com.emirkanacar/flutter_inappwebview_"

    @JvmField
    val mHandler = Handler(Looper.getMainLooper())
  }

  @JvmField
  var plugin: InAppWebViewFlutterPlugin? = null

  @JvmField
  var inAppBrowserDelegate: InAppBrowserDelegate? = null

  @JvmField
  var id: Any? = null

  @JvmField
  var windowId: Int? = null

  @JvmField
  var inAppWebViewClient: InAppWebViewClient? = null

  @JvmField
  var inAppWebViewClientCompat: InAppWebViewClientCompat? = null

  @JvmField
  var inAppWebViewChromeClient: InAppWebViewChromeClient? = null

  @JvmField
  var inAppWebViewRenderProcessClient: InAppWebViewRenderProcessClient? = null

  @JvmField
  var channelDelegate: WebViewChannelDelegate? = null

  @JvmField
  var javaScriptBridgeInterface: JavaScriptBridgeInterface? = null

  @JvmField
  var customSettings: InAppWebViewSettings = InAppWebViewSettings()

  @JvmField
  var isLoading: Boolean = false

  private var inFullscreen: Boolean = false

  @JvmField
  var zoomScale: Float = 1.0f

  @JvmField
  var contentBlockerHandler: ContentBlockerHandler = ContentBlockerHandler()

  @JvmField
  var gestureDetector: GestureDetector? = null

  @JvmField
  var floatingContextMenu: LinearLayout? = null

  @JvmField
  var contextMenu: MutableMap<String, Any?>? = null

  @JvmField
  var mainLooperHandler: Handler = Handler(getWebViewLooper())

  @JvmField
  var checkScrollStoppedTask: Runnable? = null

  @JvmField
  var initialPositionScrollStoppedTask: Int = 0

  @JvmField
  var newCheckScrollStoppedTask: Int = 100

  @JvmField
  var checkContextMenuShouldBeClosedTask: Runnable? = null

  @JvmField
  var newCheckContextMenuShouldBeClosedTaskTask: Int = 100

  @JvmField
  var userContentController: UserContentController = UserContentController(this)

  @JvmField
  var callAsyncJavaScriptCallbacks: MutableMap<String, ValueCallback<String>?> = HashMap()

  @JvmField
  var evaluateJavaScriptContentWorldCallbacks: MutableMap<String, ValueCallback<String>?> = HashMap()

  @JvmField
  var webMessageChannels: MutableMap<String, WebMessageChannel> = HashMap()

  @JvmField
  var webMessageListeners: MutableList<WebMessageListener> = ArrayList()

  private var initialUserOnlyScripts: MutableList<UserScript> = ArrayList()

  @JvmField
  var findInteractionController: FindInteractionController? = null

  @JvmField
  var webViewAssetLoaderExt: WebViewAssetLoaderExt? = null

  private var interceptOnlyAsyncAjaxRequestsPluginScript: PluginScript? = null

  private val expectedBridgeSecret: String = UUID.randomUUID().toString()

  private var javaScriptBridgeEnabled: Boolean = true
  private var nativeRegistrationsDeferred = false
  private var nativeRegistrationsRegistered = false
  private var nativeRegistrationRequestScheduled = false
  private var nativeRegistrationAttempts = 0
  private var isDisposed = false
  private val nativeRegistrationCallbacks: MutableList<() -> Unit> = ArrayList()
  private var pendingScrollX: Int? = null
  private var pendingScrollY: Int? = null
  private var scrollChangedDispatchScheduled = false
  private val dispatchPendingScrollChanged = Runnable {
    val x = pendingScrollX
    val y = pendingScrollY
    pendingScrollX = null
    pendingScrollY = null
    scrollChangedDispatchScheduled = false
    if (!isDisposed && x != null && y != null) {
      channelDelegate?.onScrollChanged(x, y)
    }
  }

  constructor(context: Context) : super(context)

  constructor(context: Context, attrs: AttributeSet?) : super(context, attrs)

  constructor(context: Context, attrs: AttributeSet?, defaultStyle: Int) :
    super(context, attrs, defaultStyle)

  constructor(
    context: Context,
    plugin: InAppWebViewFlutterPlugin,
    id: Any,
    windowId: Int?,
    customSettings: InAppWebViewSettings,
    contextMenu: MutableMap<String, Any?>?,
    containerView: View?,
    userScripts: List<UserScript>
  ) : super(context, containerView, customSettings.useHybridComposition) {
    this.plugin = plugin
    this.id = id
    val channel = MethodChannel(
      plugin.requireMessenger(),
      METHOD_CHANNEL_NAME_PREFIX + id
    )
    channelDelegate = WebViewChannelDelegate(this, channel)
    this.windowId = windowId
    this.customSettings = customSettings
    this.contextMenu = contextMenu
    initialUserOnlyScripts = userScripts.toMutableList()
    plugin.activity?.registerForContextMenu(this)
  }

  fun createWebViewClient(inAppBrowserDelegate: InAppBrowserDelegate?): WebViewClient {
    val packageInfo: PackageInfo? = WebViewCompat.getCurrentWebViewPackage(context)
    if (packageInfo == null) {
      Log.d(LOG_TAG, "Using InAppWebViewClient implementation")
      return InAppWebViewClient(inAppBrowserDelegate)
    }

    val isChromiumWebView = packageInfo.packageName == "com.android.webview" ||
      packageInfo.packageName == "com.google.android.webview" ||
      packageInfo.packageName == "com.android.chrome"

    val isChromiumWebViewBugFixed = if (isChromiumWebView) {
      val majorVersion = packageInfo.versionName
        ?.substringBefore(".")
        ?.toIntOrNull() ?: 0
      majorVersion >= 73
    } else {
      false
    }

    return if (isChromiumWebViewBugFixed || !isChromiumWebView) {
      Log.d(LOG_TAG, "Using InAppWebViewClientCompat implementation")
      InAppWebViewClientCompat(inAppBrowserDelegate)
    } else {
      Log.d(LOG_TAG, "Using InAppWebViewClient implementation")
      InAppWebViewClient(inAppBrowserDelegate)
    }
  }

  override fun setAlpha(alpha: Float) {
    val parent = parent
    if (parent is PullToRefreshLayout) {
      parent.alpha = alpha
    } else {
      super.setAlpha(alpha)
    }
  }

  @SuppressLint("RestrictedApi")
  fun prepare() {
    prepare(true)
  }

  @SuppressLint("RestrictedApi")
  fun prepare(deferNativeRegistrations: Boolean) {
    isDisposed = false
    mainLooperHandler.removeCallbacks(dispatchPendingScrollChanged)
    removeCallbacks(dispatchPendingScrollChanged)
    pendingScrollX = null
    pendingScrollY = null
    scrollChangedDispatchScheduled = false
    nativeRegistrationsDeferred = deferNativeRegistrations
    nativeRegistrationsRegistered = false
    nativeRegistrationAttempts = 0

    customSettings.alpha?.let { setAlpha(it.toFloat()) }

    javaScriptBridgeEnabled = customSettings.javaScriptBridgeEnabled == true
    if (customSettings.javaScriptBridgeOriginAllowList?.isEmpty() == true) {
      javaScriptBridgeEnabled = false
    }

    plugin?.let {
      webViewAssetLoaderExt =
        WebViewAssetLoaderExt.fromMap(customSettings.webViewAssetLoader, it, context)
    }

    inAppWebViewChromeClient = InAppWebViewChromeClient(plugin, this, inAppBrowserDelegate)
    setWebChromeClient(inAppWebViewChromeClient)

    val webViewClient = createWebViewClient(inAppBrowserDelegate)
    when (webViewClient) {
      is InAppWebViewClientCompat -> {
        inAppWebViewClientCompat = webViewClient
        setWebViewClient(webViewClient)
      }

      is InAppWebViewClient -> {
        inAppWebViewClient = webViewClient
        setWebViewClient(webViewClient)
      }
    }

    if (
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)
    ) {
      inAppWebViewRenderProcessClient = InAppWebViewRenderProcessClient()
      WebViewCompat.setWebViewRenderProcessClient(this, inAppWebViewRenderProcessClient)
    }

    if (!deferNativeRegistrations) {
      requestNativeRegistrations()
    }

    if (customSettings.useOnDownloadStart == true) {
      setDownloadListener(DownloadStartListener())
    }

    val settings = getSettings()
    settings.javaScriptEnabled = customSettings.javaScriptEnabled == true
    settings.javaScriptCanOpenWindowsAutomatically =
      customSettings.javaScriptCanOpenWindowsAutomatically == true
    settings.builtInZoomControls = customSettings.builtInZoomControls == true
    settings.displayZoomControls = customSettings.displayZoomControls == true
    settings.setSupportMultipleWindows(customSettings.supportMultipleWindows == true)

    if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
      WebSettingsCompat.setSafeBrowsingEnabled(
        settings,
        customSettings.safeBrowsingEnabled == true
      )
    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      settings.safeBrowsingEnabled = customSettings.safeBrowsingEnabled == true
    }

    settings.mediaPlaybackRequiresUserGesture =
      customSettings.mediaPlaybackRequiresUserGesture == true
    settings.databaseEnabled = customSettings.databaseEnabled == true
    settings.domStorageEnabled = customSettings.domStorageEnabled == true

    if (customSettings.userAgent.isNotEmpty()) {
      settings.userAgentString = customSettings.userAgent
    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
      settings.userAgentString = WebSettings.getDefaultUserAgent(context)
    }

    if (customSettings.applicationNameForUserAgent.isNotEmpty() &&
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1
    ) {
      val userAgent = if (customSettings.userAgent.isNotEmpty()) {
        customSettings.userAgent
      } else {
        WebSettings.getDefaultUserAgent(context)
      }
      settings.userAgentString =
        userAgent + " " + customSettings.applicationNameForUserAgent
    }

    if (customSettings.clearCache == true) {
      clearAllCache()
    } else if (customSettings.clearSessionCache == true) {
      clearSessionCookies()
    }

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().setAcceptThirdPartyCookies(
        this,
        customSettings.thirdPartyCookiesEnabled == true
      )
    }

    settings.loadWithOverviewMode = customSettings.loadWithOverviewMode == true
    settings.useWideViewPort = customSettings.useWideViewPort == true
    settings.setSupportZoom(customSettings.supportZoom == true)
    customSettings.textZoom?.let { settings.textZoom = it }

    setVerticalScrollBarEnabled(
      customSettings.disableVerticalScroll != true &&
        customSettings.verticalScrollBarEnabled == true
    )
    setHorizontalScrollBarEnabled(
      customSettings.disableHorizontalScroll != true &&
        customSettings.horizontalScrollBarEnabled == true
    )

    if (customSettings.transparentBackground == true) {
      setBackgroundColor(Color.TRANSPARENT)
    }

    if (
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
      customSettings.mixedContentMode != null
    ) {
      settings.mixedContentMode =
        customSettings.mixedContentMode ?: WebSettings.MIXED_CONTENT_NEVER_ALLOW
    }

    settings.allowContentAccess = customSettings.allowContentAccess == true
    settings.allowFileAccess = customSettings.allowFileAccess == true
    settings.allowFileAccessFromFileURLs =
      customSettings.allowFileAccessFromFileURLs == true
    if (customSettings.allowUniversalAccessFromFileURLs == true) {
      Log.w(
        LOG_TAG,
        "Ignoring allowUniversalAccessFromFileURLs on Android; use WebViewAssetLoader or a " +
          "controlled HTTPS origin for local resources."
      )
    }

    setCacheEnabled(customSettings.cacheEnabled == true)
    customSettings.appCachePath
      ?.takeIf { it.isNotEmpty() && customSettings.cacheEnabled == true }
      ?.let { Util.invokeMethodIfExists(settings, "setAppCachePath", it) }

    settings.blockNetworkImage = customSettings.blockNetworkImage == true
    settings.blockNetworkLoads = customSettings.blockNetworkLoads == true
    customSettings.cacheMode?.let { settings.cacheMode = it }
    settings.cursiveFontFamily = customSettings.cursiveFontFamily
    settings.defaultFixedFontSize = customSettings.defaultFixedFontSize ?: 16
    settings.defaultFontSize = customSettings.defaultFontSize ?: 16
    settings.defaultTextEncodingName = customSettings.defaultTextEncodingName

    customSettings.disabledActionModeMenuItems?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS)) {
        WebSettingsCompat.setDisabledActionModeMenuItems(settings, it)
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
        settings.disabledActionModeMenuItems = it
      }
    }

    settings.fantasyFontFamily = customSettings.fantasyFontFamily
    settings.fixedFontFamily = customSettings.fixedFontFamily

    customSettings.forceDark?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
        WebSettingsCompat.setForceDark(settings, it)
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
        settings.forceDark = it
      }
    }

    customSettings.forceDarkStrategy?.let {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK_STRATEGY)) {
        try {
          WebSettingsCompat.setForceDarkStrategy(settings, it)
        } catch (e: Exception) {
          Log.w(
            LOG_TAG,
            "Unable to apply forceDarkStrategy for the active WebView provider.",
            e
          )
        }
      }
    }

    settings.setGeolocationEnabled(customSettings.geolocationEnabled == true)
    customSettings.layoutAlgorithm?.let { settings.layoutAlgorithm = it }
    settings.loadsImagesAutomatically = customSettings.loadsImagesAutomatically == true
    settings.minimumFontSize = customSettings.minimumFontSize ?: 8
    settings.minimumLogicalFontSize = customSettings.minimumLogicalFontSize ?: 8
    setInitialScale(customSettings.initialScale ?: 0)
    settings.setNeedInitialFocus(customSettings.needInitialFocus == true)

    if (WebViewFeature.isFeatureSupported(WebViewFeature.OFF_SCREEN_PRERASTER)) {
      WebSettingsCompat.setOffscreenPreRaster(settings, customSettings.offscreenPreRaster == true)
    } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      settings.offscreenPreRaster = customSettings.offscreenPreRaster == true
    }

    settings.sansSerifFontFamily = customSettings.sansSerifFontFamily
    settings.serifFontFamily = customSettings.serifFontFamily
    settings.standardFontFamily = customSettings.standardFontFamily

    if (customSettings.preferredContentMode ==
      PreferredContentModeOptionType.DESKTOP.toValue()
    ) {
      setDesktopMode(true)
    }

    settings.saveFormData = customSettings.saveFormData == true
    if (customSettings.incognito == true) {
      setIncognito(true)
    }

    if (customSettings.useHybridComposition == true) {
      setLayerType(
        if (customSettings.hardwareAcceleration == true) {
          View.LAYER_TYPE_HARDWARE
        } else {
          View.LAYER_TYPE_NONE
        },
        null
      )
    }

    setScrollBarStyle(customSettings.scrollBarStyle ?: View.SCROLLBARS_INSIDE_OVERLAY)
    if (customSettings.scrollBarDefaultDelayBeforeFade != null) {
      setScrollBarDefaultDelayBeforeFade(
        customSettings.scrollBarDefaultDelayBeforeFade ?: 0
      )
    } else {
      customSettings.scrollBarDefaultDelayBeforeFade =
        scrollBarDefaultDelayBeforeFade
    }

    isScrollbarFadingEnabled = customSettings.scrollbarFadingEnabled == true
    if (customSettings.scrollBarFadeDuration != null) {
      setScrollBarFadeDuration(customSettings.scrollBarFadeDuration ?: 0)
    } else {
      customSettings.scrollBarFadeDuration = scrollBarFadeDuration
    }

    setVerticalScrollbarPosition(
      customSettings.verticalScrollbarPosition ?: View.SCROLLBAR_POSITION_DEFAULT
    )

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
      customSettings.verticalScrollbarThumbColor?.let {
        setVerticalScrollbarThumbDrawable(ColorDrawable(Color.parseColor(it)))
      }
      customSettings.verticalScrollbarTrackColor?.let {
        setVerticalScrollbarTrackDrawable(ColorDrawable(Color.parseColor(it)))
      }
      customSettings.horizontalScrollbarThumbColor?.let {
        setHorizontalScrollbarThumbDrawable(ColorDrawable(Color.parseColor(it)))
      }
      customSettings.horizontalScrollbarTrackColor?.let {
        setHorizontalScrollbarTrackDrawable(ColorDrawable(Color.parseColor(it)))
      }
    }

    setOverScrollMode(customSettings.overScrollMode ?: View.OVER_SCROLL_IF_CONTENT_SCROLLS)
    customSettings.networkAvailable?.let { setNetworkAvailable(it) }

    customSettings.rendererPriorityPolicy
      ?.takeIf { it.isNotEmpty() && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O }
      ?.let { policy ->
        val priority = (policy["rendererRequestedPriority"] as? Number)?.toInt() ?: 0
        val waived = policy["waivedWhenNotVisible"] as? Boolean ?: false
        setRendererPriorityPolicy(priority, waived)
      }

    if (
      WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING) &&
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    ) {
      WebSettingsCompat.setAlgorithmicDarkeningAllowed(
        settings,
        customSettings.algorithmicDarkeningAllowed == true
      )
    }

    if (
      WebViewFeature.isFeatureSupported(
        WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY
      )
    ) {
      WebSettingsCompat.setEnterpriseAuthenticationAppLinkPolicyEnabled(
        settings,
        customSettings.enterpriseAuthenticationAppLinkPolicyEnabled == true
      )
    }

    customSettings.webAuthenticationSupport?.let { support ->
      if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_AUTHENTICATION)) {
        WebSettingsCompat.setWebAuthenticationSupport(settings, support)
      }
    }

    if (
      customSettings.requestedWithHeaderOriginAllowList != null &&
      WebViewFeature.isFeatureSupported(WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST)
    ) {
      WebSettingsCompat.setRequestedWithHeaderOriginAllowList(
        settings,
        customSettings.requestedWithHeaderOriginAllowList ?: mutableSetOf()
      )
    }

    contentBlockerHandler.getRuleList().clear()
    for (contentBlocker in customSettings.contentBlockers) {
      val trigger = contentBlocker["trigger"] as? MutableMap<String, Any?> ?: continue
      val action = contentBlocker["action"] as? MutableMap<String, Any?> ?: continue
      contentBlockerHandler.getRuleList().add(
        ContentBlocker(
          ContentBlockerTrigger.fromMap(trigger),
          ContentBlockerAction.fromMap(action)
        )
      )
    }

    setFindListener(object : WebView.FindListener {
      override fun onFindResultReceived(
        activeMatchOrdinal: Int,
        numberOfMatches: Int,
        isDoneCounting: Boolean
      ) {
        findInteractionController?.channelDelegate?.onFindResultReceived(
          activeMatchOrdinal,
          numberOfMatches,
          isDoneCounting
        )
        channelDelegate?.onFindResultReceived(
          activeMatchOrdinal,
          numberOfMatches,
          isDoneCounting
        )
      }
    })

    gestureDetector = GestureDetector(
      context,
      object : GestureDetector.SimpleOnGestureListener() {
        override fun onSingleTapUp(event: MotionEvent): Boolean {
          if (floatingContextMenu != null) {
            hideContextMenu()
          }
          return super.onSingleTapUp(event)
        }
      }
    )

    checkScrollStoppedTask = Runnable {
      val newPosition = scrollY
      if (initialPositionScrollStoppedTask == newPosition) {
        onScrollStopped()
      } else {
        initialPositionScrollStoppedTask = newPosition
        checkScrollStoppedTask?.let {
          mainLooperHandler.postDelayed(it, newCheckScrollStoppedTask.toLong())
        }
      }
    }

    if (
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT &&
      customSettings.useHybridComposition != true
    ) {
      checkContextMenuShouldBeClosedTask = Runnable {
        if (floatingContextMenu != null) {
          evaluateJavascript(
            PluginScriptsUtil.CHECK_CONTEXT_MENU_SHOULD_BE_HIDDEN_JS_SOURCE,
            null,
            ValueCallback { value ->
              if (value == null || value == "true") {
                if (floatingContextMenu != null) {
                  hideContextMenu()
                }
              } else {
                checkContextMenuShouldBeClosedTask?.let {
                  mainLooperHandler.postDelayed(
                    it,
                    newCheckContextMenuShouldBeClosedTaskTask.toLong()
                  )
                }
              }
            }
          )
        }
      }
    }

    var downX = 0f
    var downY = 0f
    setOnTouchListener { _, event ->
      gestureDetector?.onTouchEvent(event)

      if (event.action == MotionEvent.ACTION_UP) {
        checkScrollStoppedTask?.run()
      }

      if (
        customSettings.disableHorizontalScroll == true &&
        customSettings.disableVerticalScroll == true
      ) {
        event.action == MotionEvent.ACTION_MOVE
      } else if (
        customSettings.disableHorizontalScroll == true ||
        customSettings.disableVerticalScroll == true
      ) {
        when (event.action) {
          MotionEvent.ACTION_DOWN -> {
            downX = event.x
            downY = event.y
          }

          MotionEvent.ACTION_MOVE,
          MotionEvent.ACTION_CANCEL,
          MotionEvent.ACTION_UP -> {
            if (customSettings.disableHorizontalScroll == true) {
              event.setLocation(downX, event.y)
            } else {
              event.setLocation(event.x, downY)
            }
          }
        }
        false
      } else {
        false
      }
    }

    setOnLongClickListener {
      val hitTestResult =
        com.emirkanacar.flutter_inappwebview_forge_android.types.HitTestResult
          .fromWebViewHitTestResult(getHitTestResult())
      hitTestResult?.let { channelDelegate?.onLongPressHitTestResult(it) }
      false
    }
  }

  /**
   * Starts bridge/script registration after the platform view has been attached to Flutter.
   * Headless WebViews call this from [prepare] instead, because they have no platform-view attach
   * callback until they are later surfaced.
   */
  fun onPlatformViewAttached() {
    if (!isDisposed && nativeRegistrationsDeferred) {
      requestNativeRegistrations()
    }
  }

  fun whenNativeRegistrationsReady(callback: () -> Unit) {
    if (isDisposed) {
      return
    }
    if (nativeRegistrationsRegistered) {
      post { callback() }
    } else {
      nativeRegistrationCallbacks.add(callback)
    }
  }

  private fun requestNativeRegistrations() {
    if (isDisposed || nativeRegistrationsRegistered || nativeRegistrationRequestScheduled) {
      return
    }

    nativeRegistrationRequestScheduled = true
    WebViewStartupCoordinator.runWhenReady(context) {
      if (isDisposed) {
        nativeRegistrationRequestScheduled = false
        return@runWhenReady
      }
      post {
        if (isDisposed) {
          nativeRegistrationRequestScheduled = false
          return@post
        }
        nativeRegistrationRequestScheduled = false
        registerNativeWebViewInterfaces()
      }
    }
  }

  private fun registerNativeWebViewInterfaces() {
    if (isDisposed || nativeRegistrationsRegistered || plugin == null) {
      return
    }

    nativeRegistrationAttempts += 1
    var bridgeReady = true

    if (javaScriptBridgeEnabled && javaScriptBridgeInterface == null) {
      val bridge = JavaScriptBridgeInterface(this, expectedBridgeSecret)
      try {
        addJavascriptInterface(bridge, JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())
        javaScriptBridgeInterface = bridge
      } catch (error: RuntimeException) {
        bridgeReady = false
        Log.e(LOG_TAG, "Unable to register the JavaScript bridge", error)
      }
    }

    if (
      windowId == null ||
      !WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)
    ) {
      prepareAndAddUserScripts()
    }
    userContentController.retryPendingScriptRegistrations()

    if (bridgeReady && !userContentController.hasPendingScriptRegistrations()) {
      nativeRegistrationsRegistered = true
      val callbacks = nativeRegistrationCallbacks.toList()
      nativeRegistrationCallbacks.clear()
      callbacks.forEach { callback -> post { callback() } }
      return
    }

    if (nativeRegistrationAttempts >= MAX_NATIVE_REGISTRATION_ATTEMPTS) {
      Log.e(
        LOG_TAG,
        "WebView bridge or document-start scripts could not be registered after " +
          "$MAX_NATIVE_REGISTRATION_ATTEMPTS attempts; continuing without blocking the first load."
      )
      nativeRegistrationsRegistered = true
      val callbacks = nativeRegistrationCallbacks.toList()
      nativeRegistrationCallbacks.clear()
      callbacks.forEach { callback -> post { callback() } }
      return
    }

    mainLooperHandler.postDelayed(
      {
        nativeRegistrationRequestScheduled = false
        requestNativeRegistrations()
      },
      NATIVE_REGISTRATION_RETRY_DELAY_MS
    )
  }

  fun prepareAndAddUserScripts() {
    if (javaScriptBridgeEnabled) {
      userContentController.addPluginScript(
        PromisePolyfillJS.PROMISE_POLYFILL_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly == true
        )
      )

      val javaScriptBridgeOriginAllowList =
        customSettings.javaScriptBridgeOriginAllowList
          ?: customSettings.pluginScriptsOriginAllowList
      val javaScriptBridgeForMainFrameOnly =
        customSettings.javaScriptBridgeForMainFrameOnly
          ?: customSettings.pluginScriptsForMainFrameOnly
          ?: false

      userContentController.addPluginScript(
        JavaScriptBridgeJS.JAVASCRIPT_BRIDGE_JS_PLUGIN_SCRIPT(
          expectedBridgeSecret,
          javaScriptBridgeOriginAllowList,
          javaScriptBridgeForMainFrameOnly
        )
      )
      userContentController.addPluginScript(
        PrintJS.PRINT_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly == true
        )
      )
      userContentController.addPluginScript(
        OnWindowBlurEventJS.ON_WINDOW_BLUR_EVENT_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList
        )
      )
      userContentController.addPluginScript(
        OnWindowFocusEventJS.ON_WINDOW_FOCUS_EVENT_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList
        )
      )

      interceptOnlyAsyncAjaxRequestsPluginScript =
        InterceptAjaxRequestJS.createInterceptOnlyAsyncAjaxRequestsPluginScript(
          customSettings.interceptOnlyAsyncAjaxRequests == true
        )

      if (customSettings.useShouldInterceptAjaxRequest == true) {
        interceptOnlyAsyncAjaxRequestsPluginScript?.let {
          userContentController.addPluginScript(it)
        }
        userContentController.addPluginScript(
          InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly == true,
            customSettings.useOnAjaxReadyStateChange == true,
            customSettings.useOnAjaxProgress == true
          )
        )
      }

      if (customSettings.useShouldInterceptFetchRequest == true) {
        userContentController.addPluginScript(
          InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly == true
          )
        )
      }

      if (customSettings.useOnLoadResource == true) {
        userContentController.addPluginScript(
          OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly == true
          )
        )
      }

      if (customSettings.useHybridComposition != true) {
        userContentController.addPluginScript(
          PluginScriptsUtil.CHECK_GLOBAL_KEY_DOWN_EVENT_TO_HIDE_CONTEXT_MENU_JS_PLUGIN_SCRIPT(
            customSettings.pluginScriptsOriginAllowList,
            customSettings.pluginScriptsForMainFrameOnly == true
          )
        )
      }
    }

    userContentController.addUserOnlyScripts(initialUserOnlyScripts)
  }

  @Suppress("DEPRECATION")
  fun setIncognito(enabled: Boolean) {
    val settings = getSettings()
    if (enabled) {
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        CookieManager.getInstance().removeAllCookies(null)
      } else {
        CookieManager.getInstance().removeAllCookie()
      }

      settings.cacheMode = WebSettings.LOAD_NO_CACHE
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", false)
      clearHistory()
      clearCache(true)
      clearFormData()
      settings.setSavePassword(false)
      settings.saveFormData = false
    } else {
      settings.cacheMode = WebSettings.LOAD_DEFAULT
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", true)
      settings.setSavePassword(true)
      settings.saveFormData = true
    }
  }

  fun setCacheEnabled(enabled: Boolean) {
    val settings = getSettings()
    if (enabled) {
      Util.invokeMethodIfExists(
        settings,
        "setAppCachePath",
        context.cacheDir.absolutePath
      )
      settings.cacheMode = WebSettings.LOAD_DEFAULT
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", true)
    } else {
      settings.cacheMode = WebSettings.LOAD_NO_CACHE
      Util.invokeMethodIfExists(settings, "setAppCacheEnabled", false)
    }
  }

  override fun loadUrl(urlRequest: URLRequest) {
    val url = urlRequest.url
    if (urlRequest.method == "POST") {
      postUrl(url ?: "about:blank", urlRequest.body ?: ByteArray(0))
      return
    }

    val headers = urlRequest.headers
    if (headers != null) {
      loadUrl(url ?: "about:blank", headers)
    } else {
      loadUrl(url ?: "about:blank")
    }
  }

  @Throws(IOException::class)
  override fun loadFile(assetFilePath: String) {
    val currentPlugin = plugin ?: return
    loadUrl(Util.getUrlAsset(currentPlugin, assetFilePath))
  }

  override fun isLoading(): Boolean = isLoading

  @Suppress("DEPRECATION")
  private fun clearSessionCookies() {
    val manager = CookieManager.getInstance()
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      manager.removeSessionCookies(null)
    } else {
      manager.removeSessionCookie()
    }
  }

  @Deprecated("")
  @Suppress("DEPRECATION")
  private fun clearCookies() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
      CookieManager.getInstance().removeAllCookies(ValueCallback { })
    } else {
      CookieManager.getInstance().removeAllCookie()
    }
  }

  @Deprecated("")
  override fun clearAllCache() {
    clearCache(true)
    clearCookies()
    clearFormData()
    WebStorage.getInstance().deleteAllData()
  }

  override fun takeScreenshot(
    screenshotConfiguration: MutableMap<String, Any?>,
    result: MethodChannel.Result
  ) {
    val pixelDensity = Util.getPixelDensity(context)
    mainLooperHandler.post {
      try {
        var bitmapWidth = measuredWidth
        var bitmapHeight = measuredHeight
        var bitmapScrollX = scrollX
        var bitmapScrollY = scrollY
        var compressFormat = Bitmap.CompressFormat.PNG
        var quality = 100

        val rect = screenshotConfiguration["rect"] as? Map<*, *>
        if (rect != null) {
          bitmapScrollX =
            ((rect["x"] as? Number)?.toDouble()?.times(pixelDensity)?.plus(0.5))?.toInt()
              ?: bitmapScrollX
          bitmapScrollY =
            ((rect["y"] as? Number)?.toDouble()?.times(pixelDensity)?.plus(0.5))?.toInt()
              ?: bitmapScrollY
          bitmapWidth =
            ((rect["width"] as? Number)?.toDouble()?.times(pixelDensity)?.plus(0.5))?.toInt()
              ?: bitmapWidth
          bitmapHeight =
            ((rect["height"] as? Number)?.toDouble()?.times(pixelDensity)?.plus(0.5))?.toInt()
              ?: bitmapHeight
        }

        (screenshotConfiguration["compressFormat"] as? String)?.let { format ->
          try {
            compressFormat = Bitmap.CompressFormat.valueOf(format)
          } catch (e: IllegalArgumentException) {
            Log.e(LOG_TAG, "", e)
          }
        }
        quality = (screenshotConfiguration["quality"] as? Number)?.toInt() ?: quality

        var screenshotBitmap =
          Bitmap.createBitmap(bitmapWidth, bitmapHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(screenshotBitmap)
        canvas.translate(-bitmapScrollX.toFloat(), -bitmapScrollY.toFloat())
        draw(canvas)

        val byteArrayOutputStream = ByteArrayOutputStream()
        val snapshotWidth = (screenshotConfiguration["snapshotWidth"] as? Number)?.toDouble()
        if (snapshotWidth != null) {
          val destinationWidth = (snapshotWidth * pixelDensity + 0.5).toInt()
          val ratioBitmap =
            screenshotBitmap.width.toFloat() / screenshotBitmap.height.toFloat()
          val destinationHeight = (destinationWidth / ratioBitmap).toInt()
          screenshotBitmap = Bitmap.createScaledBitmap(
            screenshotBitmap,
            destinationWidth,
            destinationHeight,
            true
          )
        }

        if (!screenshotBitmap.compress(
            compressFormat,
            quality,
            byteArrayOutputStream
          )
        ) {
          Log.e(
            LOG_TAG,
            "Screenshot cannot be compressed using compressFormat " +
              compressFormat.name + " with quality " + quality,
            null
          )
        }

        try {
          byteArrayOutputStream.close()
        } catch (e: IOException) {
          Log.e(LOG_TAG, "", e)
        }
        screenshotBitmap.recycle()
        result.success(byteArrayOutputStream.toByteArray())
      } catch (e: IllegalArgumentException) {
        Log.e(LOG_TAG, "", e)
        result.success(null)
      }
    }
  }

  @SuppressLint("RestrictedApi")
  override fun setSettings(
    newCustomSettings: InAppWebViewSettings,
    newSettingsMap: HashMap<String, Any?>
  ) {
    val settings = getSettings()
    fun has(key: String): Boolean = newSettingsMap.containsKey(key)
    fun changed(key: String, oldValue: Any?, newValue: Any?): Boolean =
      has(key) && oldValue != newValue

    if (changed("javaScriptEnabled", customSettings.javaScriptEnabled, newCustomSettings.javaScriptEnabled)) {
      settings.javaScriptEnabled = newCustomSettings.javaScriptEnabled == true
    }

    if (changed(
        "useShouldInterceptAjaxRequest",
        customSettings.useShouldInterceptAjaxRequest,
        newCustomSettings.useShouldInterceptAjaxRequest
      )
    ) {
      enablePluginScriptAtRuntime(
        InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_AJAX_REQUEST_JS_SOURCE(),
        newCustomSettings.useShouldInterceptAjaxRequest == true,
        InterceptAjaxRequestJS.INTERCEPT_AJAX_REQUEST_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly == true,
          newCustomSettings.useOnAjaxReadyStateChange == true,
          newCustomSettings.useOnAjaxProgress == true
        )
      )
    }

    if (changed(
        "useOnAjaxReadyStateChange",
        customSettings.useOnAjaxReadyStateChange,
        newCustomSettings.useOnAjaxReadyStateChange
      )
    ) {
      evaluateJavascript(
        "((window.top == null || window.top === window) ? window : window.top)." +
          InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_ON_AJAX_READY_STATE_CHANGE() +
          " = " + (newCustomSettings.useOnAjaxReadyStateChange == true) + ";",
        null
      )
    }

    if (changed(
        "useOnAjaxProgress",
        customSettings.useOnAjaxProgress,
        newCustomSettings.useOnAjaxProgress
      )
    ) {
      evaluateJavascript(
        "((window.top == null || window.top === window) ? window : window.top)." +
          InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_ON_AJAX_PROGRESS() +
          " = " + (newCustomSettings.useOnAjaxProgress == true) + ";",
        null
      )
    }

    if (changed(
        "interceptOnlyAsyncAjaxRequests",
        customSettings.interceptOnlyAsyncAjaxRequests,
        newCustomSettings.interceptOnlyAsyncAjaxRequests
      )
    ) {
      interceptOnlyAsyncAjaxRequestsPluginScript?.let {
        enablePluginScriptAtRuntime(
          InterceptAjaxRequestJS.FLAG_VARIABLE_FOR_INTERCEPT_ONLY_ASYNC_AJAX_REQUESTS_JS_SOURCE(),
          newCustomSettings.interceptOnlyAsyncAjaxRequests == true,
          it
        )
      }
    }

    if (changed(
        "useShouldInterceptFetchRequest",
        customSettings.useShouldInterceptFetchRequest,
        newCustomSettings.useShouldInterceptFetchRequest
      )
    ) {
      enablePluginScriptAtRuntime(
        InterceptFetchRequestJS.FLAG_VARIABLE_FOR_SHOULD_INTERCEPT_FETCH_REQUEST_JS_SOURCE(),
        newCustomSettings.useShouldInterceptFetchRequest == true,
        InterceptFetchRequestJS.INTERCEPT_FETCH_REQUEST_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly == true
        )
      )
    }

    if (changed(
        "useOnLoadResource",
        customSettings.useOnLoadResource,
        newCustomSettings.useOnLoadResource
      )
    ) {
      enablePluginScriptAtRuntime(
        OnLoadResourceJS.FLAG_VARIABLE_FOR_ON_LOAD_RESOURCE_JS_SOURCE(),
        newCustomSettings.useOnLoadResource == true,
        OnLoadResourceJS.ON_LOAD_RESOURCE_JS_PLUGIN_SCRIPT(
          customSettings.pluginScriptsOriginAllowList,
          customSettings.pluginScriptsForMainFrameOnly == true
        )
      )
    }

    if (changed(
        "javaScriptCanOpenWindowsAutomatically",
        customSettings.javaScriptCanOpenWindowsAutomatically,
        newCustomSettings.javaScriptCanOpenWindowsAutomatically
      )
    ) {
      settings.javaScriptCanOpenWindowsAutomatically =
        newCustomSettings.javaScriptCanOpenWindowsAutomatically == true
    }
    if (changed("builtInZoomControls", customSettings.builtInZoomControls, newCustomSettings.builtInZoomControls)) {
      settings.builtInZoomControls = newCustomSettings.builtInZoomControls == true
    }
    if (changed("displayZoomControls", customSettings.displayZoomControls, newCustomSettings.displayZoomControls)) {
      settings.displayZoomControls = newCustomSettings.displayZoomControls == true
    }
    if (changed("safeBrowsingEnabled", customSettings.safeBrowsingEnabled, newCustomSettings.safeBrowsingEnabled)) {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
        WebSettingsCompat.setSafeBrowsingEnabled(settings, newCustomSettings.safeBrowsingEnabled == true)
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
        settings.safeBrowsingEnabled = newCustomSettings.safeBrowsingEnabled == true
      }
    }
    if (changed(
        "mediaPlaybackRequiresUserGesture",
        customSettings.mediaPlaybackRequiresUserGesture,
        newCustomSettings.mediaPlaybackRequiresUserGesture
      )
    ) {
      settings.mediaPlaybackRequiresUserGesture =
        newCustomSettings.mediaPlaybackRequiresUserGesture == true
    }
    if (changed("databaseEnabled", customSettings.databaseEnabled, newCustomSettings.databaseEnabled)) {
      settings.databaseEnabled = newCustomSettings.databaseEnabled == true
    }
    if (changed("domStorageEnabled", customSettings.domStorageEnabled, newCustomSettings.domStorageEnabled)) {
      settings.domStorageEnabled = newCustomSettings.domStorageEnabled == true
    }
    if (changed("userAgent", customSettings.userAgent, newCustomSettings.userAgent) &&
      newCustomSettings.userAgent.isNotEmpty()
    ) {
      settings.userAgentString = newCustomSettings.userAgent
    }
    if (changed(
        "applicationNameForUserAgent",
        customSettings.applicationNameForUserAgent,
        newCustomSettings.applicationNameForUserAgent
      ) && newCustomSettings.applicationNameForUserAgent.isNotEmpty() &&
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1
    ) {
      val userAgent = if (newCustomSettings.userAgent.isNotEmpty()) {
        newCustomSettings.userAgent
      } else {
        WebSettings.getDefaultUserAgent(context)
      }
      settings.userAgentString =
        userAgent + " " + newCustomSettings.applicationNameForUserAgent
    }

    if (newSettingsMap["clearCache"] != null && newCustomSettings.clearCache == true) {
      clearAllCache()
    } else if (
      newSettingsMap["clearSessionCache"] != null &&
      newCustomSettings.clearSessionCache == true
    ) {
      clearSessionCookies()
    }

    if (changed(
        "thirdPartyCookiesEnabled",
        customSettings.thirdPartyCookiesEnabled,
        newCustomSettings.thirdPartyCookiesEnabled
      ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP
    ) {
      CookieManager.getInstance().setAcceptThirdPartyCookies(
        this,
        newCustomSettings.thirdPartyCookiesEnabled == true
      )
    }
    if (changed("useWideViewPort", customSettings.useWideViewPort, newCustomSettings.useWideViewPort)) {
      settings.useWideViewPort = newCustomSettings.useWideViewPort == true
    }
    if (changed("supportZoom", customSettings.supportZoom, newCustomSettings.supportZoom)) {
      settings.setSupportZoom(newCustomSettings.supportZoom == true)
    }
    if (changed("textZoom", customSettings.textZoom, newCustomSettings.textZoom)) {
      newCustomSettings.textZoom?.let { settings.textZoom = it }
    }
    if (changed(
        "verticalScrollBarEnabled",
        customSettings.verticalScrollBarEnabled,
        newCustomSettings.verticalScrollBarEnabled
      )
    ) {
      setVerticalScrollBarEnabled(newCustomSettings.verticalScrollBarEnabled == true)
    }
    if (changed(
        "horizontalScrollBarEnabled",
        customSettings.horizontalScrollBarEnabled,
        newCustomSettings.horizontalScrollBarEnabled
      )
    ) {
      setHorizontalScrollBarEnabled(newCustomSettings.horizontalScrollBarEnabled == true)
    }
    if (changed(
        "transparentBackground",
        customSettings.transparentBackground,
        newCustomSettings.transparentBackground
      )
    ) {
      setBackgroundColor(
        if (newCustomSettings.transparentBackground == true) {
          Color.TRANSPARENT
        } else {
          Color.WHITE
        }
      )
    }
    if (
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
      changed("mixedContentMode", customSettings.mixedContentMode, newCustomSettings.mixedContentMode)
    ) {
      newCustomSettings.mixedContentMode?.let { settings.mixedContentMode = it }
    }
    if (changed(
        "supportMultipleWindows",
        customSettings.supportMultipleWindows,
        newCustomSettings.supportMultipleWindows
      )
    ) {
      settings.setSupportMultipleWindows(newCustomSettings.supportMultipleWindows == true)
    }
    if (changed("useOnDownloadStart", customSettings.useOnDownloadStart, newCustomSettings.useOnDownloadStart)) {
      setDownloadListener(
        if (newCustomSettings.useOnDownloadStart == true) DownloadStartListener() else null
      )
    }
    if (changed("allowContentAccess", customSettings.allowContentAccess, newCustomSettings.allowContentAccess)) {
      settings.allowContentAccess = newCustomSettings.allowContentAccess == true
    }
    if (changed("allowFileAccess", customSettings.allowFileAccess, newCustomSettings.allowFileAccess)) {
      settings.allowFileAccess = newCustomSettings.allowFileAccess == true
    }
    if (changed(
        "allowFileAccessFromFileURLs",
        customSettings.allowFileAccessFromFileURLs,
        newCustomSettings.allowFileAccessFromFileURLs
      )
    ) {
      settings.allowFileAccessFromFileURLs =
        newCustomSettings.allowFileAccessFromFileURLs == true
    }
    if (changed(
        "allowUniversalAccessFromFileURLs",
        customSettings.allowUniversalAccessFromFileURLs,
        newCustomSettings.allowUniversalAccessFromFileURLs
      )
    ) {
      if (newCustomSettings.allowUniversalAccessFromFileURLs == true) {
        Log.w(
          LOG_TAG,
          "Ignoring allowUniversalAccessFromFileURLs on Android; use WebViewAssetLoader or a " +
            "controlled HTTPS origin for local resources."
        )
      }
    }
    if (changed("cacheEnabled", customSettings.cacheEnabled, newCustomSettings.cacheEnabled)) {
      setCacheEnabled(newCustomSettings.cacheEnabled == true)
    }
    if (changed("appCachePath", customSettings.appCachePath, newCustomSettings.appCachePath)) {
      newCustomSettings.appCachePath?.let {
        Util.invokeMethodIfExists(settings, "setAppCachePath", it)
      }
    }
    if (changed("blockNetworkImage", customSettings.blockNetworkImage, newCustomSettings.blockNetworkImage)) {
      settings.blockNetworkImage = newCustomSettings.blockNetworkImage == true
    }
    if (changed("blockNetworkLoads", customSettings.blockNetworkLoads, newCustomSettings.blockNetworkLoads)) {
      settings.blockNetworkLoads = newCustomSettings.blockNetworkLoads == true
    }
    if (changed("cacheMode", customSettings.cacheMode, newCustomSettings.cacheMode)) {
      settings.cacheMode = newCustomSettings.cacheMode ?: WebSettings.LOAD_DEFAULT
    }
    if (changed("cursiveFontFamily", customSettings.cursiveFontFamily, newCustomSettings.cursiveFontFamily)) {
      settings.cursiveFontFamily = newCustomSettings.cursiveFontFamily
    }
    if (changed("defaultFixedFontSize", customSettings.defaultFixedFontSize, newCustomSettings.defaultFixedFontSize)) {
      settings.defaultFixedFontSize = newCustomSettings.defaultFixedFontSize ?: 16
    }
    if (changed("defaultFontSize", customSettings.defaultFontSize, newCustomSettings.defaultFontSize)) {
      settings.defaultFontSize = newCustomSettings.defaultFontSize ?: 16
    }
    if (changed(
        "defaultTextEncodingName",
        customSettings.defaultTextEncodingName,
        newCustomSettings.defaultTextEncodingName
      )
    ) {
      settings.defaultTextEncodingName = newCustomSettings.defaultTextEncodingName
    }

    if (changed(
        "disabledActionModeMenuItems",
        customSettings.disabledActionModeMenuItems,
        newCustomSettings.disabledActionModeMenuItems
      )
    ) {
      newCustomSettings.disabledActionModeMenuItems?.let {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS)) {
          WebSettingsCompat.setDisabledActionModeMenuItems(settings, it)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
          settings.disabledActionModeMenuItems = it
        }
      }
    }
    if (changed("fantasyFontFamily", customSettings.fantasyFontFamily, newCustomSettings.fantasyFontFamily)) {
      settings.fantasyFontFamily = newCustomSettings.fantasyFontFamily
    }
    if (changed("fixedFontFamily", customSettings.fixedFontFamily, newCustomSettings.fixedFontFamily)) {
      settings.fixedFontFamily = newCustomSettings.fixedFontFamily
    }
    if (changed("forceDark", customSettings.forceDark, newCustomSettings.forceDark)) {
      newCustomSettings.forceDark?.let {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
          WebSettingsCompat.setForceDark(settings, it)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
          settings.forceDark = it
        }
      }
    }
    if (changed("forceDarkStrategy", customSettings.forceDarkStrategy, newCustomSettings.forceDarkStrategy) &&
      WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK_STRATEGY)
    ) {
      newCustomSettings.forceDarkStrategy?.let {
        try {
          WebSettingsCompat.setForceDarkStrategy(settings, it)
        } catch (e: Exception) {
          Log.w(
            LOG_TAG,
            "Unable to update forceDarkStrategy for the active WebView provider.",
            e
          )
        }
      }
    }
    if (changed("geolocationEnabled", customSettings.geolocationEnabled, newCustomSettings.geolocationEnabled)) {
      settings.setGeolocationEnabled(newCustomSettings.geolocationEnabled == true)
    }
    if (changed("layoutAlgorithm", customSettings.layoutAlgorithm, newCustomSettings.layoutAlgorithm)) {
      newCustomSettings.layoutAlgorithm?.let { settings.layoutAlgorithm = it }
    }
    if (changed("loadWithOverviewMode", customSettings.loadWithOverviewMode, newCustomSettings.loadWithOverviewMode)) {
      settings.loadWithOverviewMode = newCustomSettings.loadWithOverviewMode == true
    }
    if (changed("loadsImagesAutomatically", customSettings.loadsImagesAutomatically, newCustomSettings.loadsImagesAutomatically)) {
      settings.loadsImagesAutomatically = newCustomSettings.loadsImagesAutomatically == true
    }
    if (changed("minimumFontSize", customSettings.minimumFontSize, newCustomSettings.minimumFontSize)) {
      settings.minimumFontSize = newCustomSettings.minimumFontSize ?: 8
    }
    if (changed(
        "minimumLogicalFontSize",
        customSettings.minimumLogicalFontSize,
        newCustomSettings.minimumLogicalFontSize
      )
    ) {
      settings.minimumLogicalFontSize = newCustomSettings.minimumLogicalFontSize ?: 8
    }
    if (changed("initialScale", customSettings.initialScale, newCustomSettings.initialScale)) {
      setInitialScale(newCustomSettings.initialScale ?: 0)
    }
    if (changed("needInitialFocus", customSettings.needInitialFocus, newCustomSettings.needInitialFocus)) {
      settings.setNeedInitialFocus(newCustomSettings.needInitialFocus == true)
    }
    if (changed("offscreenPreRaster", customSettings.offscreenPreRaster, newCustomSettings.offscreenPreRaster)) {
      if (WebViewFeature.isFeatureSupported(WebViewFeature.OFF_SCREEN_PRERASTER)) {
        WebSettingsCompat.setOffscreenPreRaster(settings, newCustomSettings.offscreenPreRaster == true)
      } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        settings.offscreenPreRaster = newCustomSettings.offscreenPreRaster == true
      }
    }
    if (changed("sansSerifFontFamily", customSettings.sansSerifFontFamily, newCustomSettings.sansSerifFontFamily)) {
      settings.sansSerifFontFamily = newCustomSettings.sansSerifFontFamily
    }
    if (changed("serifFontFamily", customSettings.serifFontFamily, newCustomSettings.serifFontFamily)) {
      settings.serifFontFamily = newCustomSettings.serifFontFamily
    }
    if (changed("standardFontFamily", customSettings.standardFontFamily, newCustomSettings.standardFontFamily)) {
      settings.standardFontFamily = newCustomSettings.standardFontFamily
    }
    if (changed("preferredContentMode", customSettings.preferredContentMode, newCustomSettings.preferredContentMode)) {
      when (PreferredContentModeOptionType.fromValue(
        newCustomSettings.preferredContentMode ?: PreferredContentModeOptionType.RECOMMENDED.toValue()
      )) {
        PreferredContentModeOptionType.DESKTOP -> setDesktopMode(true)
        PreferredContentModeOptionType.MOBILE,
        PreferredContentModeOptionType.RECOMMENDED -> setDesktopMode(false)
      }
    }
    if (changed("saveFormData", customSettings.saveFormData, newCustomSettings.saveFormData)) {
      settings.saveFormData = newCustomSettings.saveFormData == true
    }
    if (changed("incognito", customSettings.incognito, newCustomSettings.incognito)) {
      setIncognito(newCustomSettings.incognito == true)
    }
    if (
      customSettings.useHybridComposition == true &&
      changed("hardwareAcceleration", customSettings.hardwareAcceleration, newCustomSettings.hardwareAcceleration)
    ) {
      setLayerType(
        if (newCustomSettings.hardwareAcceleration == true) {
          View.LAYER_TYPE_HARDWARE
        } else {
          View.LAYER_TYPE_NONE
        },
        null
      )
    }

    if (newCustomSettings.contentBlockers.isNotEmpty()) {
      contentBlockerHandler.getRuleList().clear()
      for (contentBlocker in newCustomSettings.contentBlockers) {
        val trigger = contentBlocker["trigger"] as? MutableMap<String, Any?> ?: continue
        val action = contentBlocker["action"] as? MutableMap<String, Any?> ?: continue
        contentBlockerHandler.getRuleList().add(
          ContentBlocker(
            ContentBlockerTrigger.fromMap(trigger),
            ContentBlockerAction.fromMap(action)
          )
        )
      }
    }

    if (changed("scrollBarStyle", customSettings.scrollBarStyle, newCustomSettings.scrollBarStyle)) {
      setScrollBarStyle(newCustomSettings.scrollBarStyle ?: View.SCROLLBARS_INSIDE_OVERLAY)
    }
    if (changed(
        "scrollBarDefaultDelayBeforeFade",
        customSettings.scrollBarDefaultDelayBeforeFade,
        newCustomSettings.scrollBarDefaultDelayBeforeFade
      )
    ) {
      setScrollBarDefaultDelayBeforeFade(
        newCustomSettings.scrollBarDefaultDelayBeforeFade ?: 0
      )
    }
    if (changed(
        "scrollbarFadingEnabled",
        customSettings.scrollbarFadingEnabled,
        newCustomSettings.scrollbarFadingEnabled
      )
    ) {
      isScrollbarFadingEnabled = newCustomSettings.scrollbarFadingEnabled == true
    }
    if (changed(
        "scrollBarFadeDuration",
        customSettings.scrollBarFadeDuration,
        newCustomSettings.scrollBarFadeDuration
      )
    ) {
      setScrollBarFadeDuration(newCustomSettings.scrollBarFadeDuration ?: 0)
    }
    if (changed(
        "verticalScrollbarPosition",
        customSettings.verticalScrollbarPosition,
        newCustomSettings.verticalScrollbarPosition
      )
    ) {
      setVerticalScrollbarPosition(
        newCustomSettings.verticalScrollbarPosition ?: View.SCROLLBAR_POSITION_DEFAULT
      )
    }
    if (changed(
        "disableVerticalScroll",
        customSettings.disableVerticalScroll,
        newCustomSettings.disableVerticalScroll
      )
    ) {
      setVerticalScrollBarEnabled(
        newCustomSettings.disableVerticalScroll != true &&
          newCustomSettings.verticalScrollBarEnabled == true
      )
    }
    if (changed(
        "disableHorizontalScroll",
        customSettings.disableHorizontalScroll,
        newCustomSettings.disableHorizontalScroll
      )
    ) {
      setHorizontalScrollBarEnabled(
        newCustomSettings.disableHorizontalScroll != true &&
          newCustomSettings.horizontalScrollBarEnabled == true
      )
    }
    if (changed("overScrollMode", customSettings.overScrollMode, newCustomSettings.overScrollMode)) {
      setOverScrollMode(newCustomSettings.overScrollMode ?: View.OVER_SCROLL_IF_CONTENT_SCROLLS)
    }
    if (changed("networkAvailable", customSettings.networkAvailable, newCustomSettings.networkAvailable)) {
      newCustomSettings.networkAvailable?.let { setNetworkAvailable(it) }
    }
    if (changed(
        "rendererPriorityPolicy",
        customSettings.rendererPriorityPolicy,
        newCustomSettings.rendererPriorityPolicy
      ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.O
    ) {
      newCustomSettings.rendererPriorityPolicy?.let { policy ->
        setRendererPriorityPolicy(
          (policy["rendererRequestedPriority"] as? Number)?.toInt() ?: 0,
          policy["waivedWhenNotVisible"] as? Boolean ?: false
        )
      }
    }

    if (
      changed(
        "verticalScrollbarThumbColor",
        customSettings.verticalScrollbarThumbColor,
        newCustomSettings.verticalScrollbarThumbColor
      ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    ) {
      newCustomSettings.verticalScrollbarThumbColor?.let {
        setVerticalScrollbarThumbDrawable(ColorDrawable(Color.parseColor(it)))
      }
    }
    if (
      changed(
        "verticalScrollbarTrackColor",
        customSettings.verticalScrollbarTrackColor,
        newCustomSettings.verticalScrollbarTrackColor
      ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    ) {
      newCustomSettings.verticalScrollbarTrackColor?.let {
        setVerticalScrollbarTrackDrawable(ColorDrawable(Color.parseColor(it)))
      }
    }
    if (
      changed(
        "horizontalScrollbarThumbColor",
        customSettings.horizontalScrollbarThumbColor,
        newCustomSettings.horizontalScrollbarThumbColor
      ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    ) {
      newCustomSettings.horizontalScrollbarThumbColor?.let {
        setHorizontalScrollbarThumbDrawable(ColorDrawable(Color.parseColor(it)))
      }
    }
    if (
      changed(
        "horizontalScrollbarTrackColor",
        customSettings.horizontalScrollbarTrackColor,
        newCustomSettings.horizontalScrollbarTrackColor
      ) && Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    ) {
      newCustomSettings.horizontalScrollbarTrackColor?.let {
        setHorizontalScrollbarTrackDrawable(ColorDrawable(Color.parseColor(it)))
      }
    }

    if (
      changed(
        "algorithmicDarkeningAllowed",
        customSettings.algorithmicDarkeningAllowed,
        newCustomSettings.algorithmicDarkeningAllowed
      ) &&
      WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING) &&
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
    ) {
      WebSettingsCompat.setAlgorithmicDarkeningAllowed(
        settings,
        newCustomSettings.algorithmicDarkeningAllowed == true
      )
    }
    if (
      changed(
        "enterpriseAuthenticationAppLinkPolicyEnabled",
        customSettings.enterpriseAuthenticationAppLinkPolicyEnabled,
        newCustomSettings.enterpriseAuthenticationAppLinkPolicyEnabled
      ) &&
      WebViewFeature.isFeatureSupported(
        WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY
      )
    ) {
      WebSettingsCompat.setEnterpriseAuthenticationAppLinkPolicyEnabled(
        settings,
        newCustomSettings.enterpriseAuthenticationAppLinkPolicyEnabled == true
      )
    }
    if (
      changed(
        "requestedWithHeaderOriginAllowList",
        customSettings.requestedWithHeaderOriginAllowList,
        newCustomSettings.requestedWithHeaderOriginAllowList
      ) &&
      WebViewFeature.isFeatureSupported(WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST)
    ) {
      WebSettingsCompat.setRequestedWithHeaderOriginAllowList(
        settings,
        newCustomSettings.requestedWithHeaderOriginAllowList ?: mutableSetOf()
      )
    }

    plugin?.let { currentPlugin ->
      webViewAssetLoaderExt?.dispose()
      webViewAssetLoaderExt =
        WebViewAssetLoaderExt.fromMap(newCustomSettings.webViewAssetLoader, currentPlugin, context)
    }

    customSettings = newCustomSettings
  }

  override fun getCustomSettingsMap(): MutableMap<String, Any?> =
    customSettings.getRealSettings(this)

  fun enablePluginScriptAtRuntime(
    flagVariable: String,
    enable: Boolean,
    pluginScript: PluginScript?
  ) {
    if (pluginScript == null) return

    evaluateJavascript(
      "((window.top == null || window.top === window) ? window : window.top)." + flagVariable,
      null,
      ValueCallback { value ->
        val alreadyLoaded = value != null && !value.equals("null", ignoreCase = true)
        if (alreadyLoaded) {
          val enableSource =
            "((window.top == null || window.top === window) ? window : window.top)." +
              flagVariable + " = " + enable + ";"
          evaluateJavascript(enableSource, null)
          if (!enable) {
            userContentController.removePluginScript(pluginScript)
          }
        } else if (enable && javaScriptBridgeEnabled) {
          evaluateJavascript(pluginScript.source, null)
          userContentController.addPluginScript(pluginScript)
        }
      }
    )
  }

  fun injectDeferredObject(
    source: String,
    contentWorld: ContentWorld?,
    jsWrapper: String?,
    resultCallback: ValueCallback<String>?
  ) {
    val resultUuid =
      if (contentWorld != null && contentWorld != ContentWorld.PAGE) {
        UUID.randomUUID().toString()
      } else {
        null
      }

    var scriptToInject = source
    if (jsWrapper != null) {
      val jsonEsc = org.json.JSONArray()
      jsonEsc.put(source)
      val jsonRepresentation = jsonEsc.toString()
      scriptToInject = String.format(
        jsWrapper,
        jsonRepresentation.substring(1, jsonRepresentation.length - 1)
      )
    }

    if (resultUuid != null && resultCallback != null) {
      evaluateJavaScriptContentWorldCallbacks[resultUuid] = resultCallback
      scriptToInject = Util.replaceAll(
        PluginScriptsUtil.EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE(),
        PluginScriptsUtil.VAR_RANDOM_NAME,
        "_" + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
          "_" + Math.round(Math.random() * 1_000_000)
      )
        .replace(
          PluginScriptsUtil.VAR_PLACEHOLDER_VALUE,
          UserContentController.escapeCode(source)
        )
        .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)
    }

    val finalScriptToInject = scriptToInject
    mainLooperHandler.post {
      val generatedScript =
        userContentController.generateCodeForScriptEvaluation(finalScriptToInject, contentWorld)
      super.evaluateJavascript(
        generatedScript,
        ValueCallback { value ->
          if (resultUuid == null && resultCallback != null) {
            resultCallback.onReceiveValue(value)
          }
        }
      )
    }
  }

  override fun evaluateJavascript(
    source: String,
    contentWorld: ContentWorld?,
    resultCallback: ValueCallback<String>
  ) {
    injectDeferredObject(source, contentWorld, null, resultCallback)
  }

  override fun injectJavascriptFileFromUrl(
    urlFile: String,
    scriptHtmlTagAttributes: MutableMap<String, Any?>
  ) {
    var scriptAttributes = ""
    (scriptHtmlTagAttributes["type"] as? String)?.let { type ->
      scriptAttributes += " script.type = '" + type.replace("'", "\\\\'") + "'; "
    }
    (scriptHtmlTagAttributes["id"] as? String)?.let { id ->
      val escapedId = id.replace("'", "\\\\'")
      scriptAttributes += " script.id = '" + escapedId + "'; "
      scriptAttributes +=
        " script.onload = function() {" +
          "  if (window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + " != null) {" +
          "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
          ".callHandler('onInjectedScriptLoaded', '" + escapedId + "');" +
          "  }" +
          "};"
      scriptAttributes +=
        " script.onerror = function() {" +
          "  if (window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() + " != null) {" +
          "    window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
          ".callHandler('onInjectedScriptError', '" + escapedId + "');" +
          "  }" +
          "};"
    }
    if (scriptHtmlTagAttributes["async"] as? Boolean == true) {
      scriptAttributes += " script.async = true; "
    }
    if (scriptHtmlTagAttributes["defer"] as? Boolean == true) {
      scriptAttributes += " script.defer = true; "
    }
    (scriptHtmlTagAttributes["crossOrigin"] as? String)?.let {
      scriptAttributes += " script.crossOrigin = '" + it.replace("'", "\\\\'") + "'; "
    }
    (scriptHtmlTagAttributes["integrity"] as? String)?.let {
      scriptAttributes += " script.integrity = '" + it.replace("'", "\\\\'") + "'; "
    }
    if (scriptHtmlTagAttributes["noModule"] as? Boolean == true) {
      scriptAttributes += " script.noModule = true; "
    }
    (scriptHtmlTagAttributes["nonce"] as? String)?.let {
      scriptAttributes += " script.nonce = '" + it.replace("'", "\\\\'") + "'; "
    }
    (scriptHtmlTagAttributes["referrerPolicy"] as? String)?.let {
      scriptAttributes += " script.referrerPolicy = '" + it.replace("'", "\\\\'") + "'; "
    }

    val jsWrapper =
      "(function(d) { var script = d.createElement('script'); " +
        scriptAttributes +
        " script.src = %s; if (d.body != null) { d.body.appendChild(script); } })(document);"
    injectDeferredObject(urlFile, null, jsWrapper, null)
  }

  override fun injectCSSCode(source: String) {
    val jsWrapper =
      "(function(d) { var style = d.createElement('style'); style.innerHTML = %s;" +
        " if (d.head != null) { d.head.appendChild(style); } })(document);"
    injectDeferredObject(source, null, jsWrapper, null)
  }

  override fun injectCSSFileFromUrl(
    urlFile: String,
    cssLinkHtmlTagAttributes: MutableMap<String, Any?>
  ) {
    var cssLinkAttributes = ""
    var alternateStylesheet = ""

    (cssLinkHtmlTagAttributes["id"] as? String)?.let {
      cssLinkAttributes += " link.id = '" + it.replace("'", "\\\\'") + "'; "
    }
    (cssLinkHtmlTagAttributes["media"] as? String)?.let {
      cssLinkAttributes += " link.media = '" + it.replace("'", "\\\\'") + "'; "
    }
    (cssLinkHtmlTagAttributes["crossOrigin"] as? String)?.let {
      cssLinkAttributes += " link.crossOrigin = '" + it.replace("'", "\\\\'") + "'; "
    }
    (cssLinkHtmlTagAttributes["integrity"] as? String)?.let {
      cssLinkAttributes += " link.integrity = '" + it.replace("'", "\\\\'") + "'; "
    }
    (cssLinkHtmlTagAttributes["referrerPolicy"] as? String)?.let {
      cssLinkAttributes += " link.referrerPolicy = '" + it.replace("'", "\\\\'") + "'; "
    }
    if (cssLinkHtmlTagAttributes["disabled"] as? Boolean == true) {
      cssLinkAttributes += " link.disabled = true; "
    }
    if (cssLinkHtmlTagAttributes["alternate"] as? Boolean == true) {
      alternateStylesheet = "alternate "
    }
    (cssLinkHtmlTagAttributes["title"] as? String)?.let {
      cssLinkAttributes += " link.title = '" + it.replace("'", "\\\\'") + "'; "
    }

    val jsWrapper =
      "(function(d) { var link = d.createElement('link'); link.rel='" +
        alternateStylesheet +
        "stylesheet'; link.type='text/css'; " +
        cssLinkAttributes +
        " link.href = %s; if (d.head != null) { d.head.appendChild(link); } })(document);"
    injectDeferredObject(urlFile, null, jsWrapper, null)
  }

  override fun getCopyBackForwardList(): HashMap<String, Any?> {
    val currentList = copyBackForwardList()
    val currentSize = currentList.size
    val currentIndex = currentList.currentIndex
    val history = ArrayList<HashMap<String, Any?>>()

    for (index in 0 until currentSize) {
      val historyItem = currentList.getItemAtIndex(index)
      val historyItemMap = HashMap<String, Any?>()
      historyItemMap["originalUrl"] = historyItem.originalUrl
      historyItemMap["title"] = historyItem.title
      historyItemMap["url"] = historyItem.url
      historyItemMap["index"] = index
      historyItemMap["offset"] = index - currentIndex
      history.add(historyItemMap)
    }

    return HashMap<String, Any?>().apply {
      put("list", history)
      put("currentIndex", currentIndex)
    }
  }

  override fun onScrollChanged(x: Int, y: Int, oldX: Int, oldY: Int) {
    super.onScrollChanged(x, y, oldX, oldY)
    floatingContextMenu?.let {
      it.alpha = 0f
      it.visibility = View.GONE
    }
    if (x != oldX || y != oldY) {
      pendingScrollX = x
      pendingScrollY = y
      if (!scrollChangedDispatchScheduled) {
        scrollChangedDispatchScheduled = true
        if (isAttachedToWindow) {
          postOnAnimation(dispatchPendingScrollChanged)
        } else {
          mainLooperHandler.post(dispatchPendingScrollChanged)
        }
      }
    }
  }

  override fun scrollTo(x: Int?, y: Int?, animated: Boolean?) {
    if (animated == true) {
      val xValue = x ?: 0
      val yValue = y ?: 0
      val pvhX = PropertyValuesHolder.ofInt("scrollX", xValue)
      val pvhY = PropertyValuesHolder.ofInt("scrollY", yValue)
      ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY).setDuration(300).start()
    } else {
      super.scrollTo(x ?: 0, y ?: 0)
    }
  }

  override fun scrollBy(x: Int?, y: Int?, animated: Boolean?) {
    if (animated == true) {
      val xValue = x ?: 0
      val yValue = y ?: 0
      val pvhX = PropertyValuesHolder.ofInt("scrollX", scrollX + xValue)
      val pvhY = PropertyValuesHolder.ofInt("scrollY", scrollY + yValue)
      ObjectAnimator.ofPropertyValuesHolder(this, pvhX, pvhY).setDuration(300).start()
    } else {
      super.scrollBy(x ?: 0, y ?: 0)
    }
  }

  private inner class DownloadStartListener : DownloadListener {
    override fun onDownloadStart(
      url: String,
      userAgent: String,
      contentDisposition: String,
      mimeType: String,
      contentLength: Long
    ) {
      channelDelegate?.onDownloadStarting(
        DownloadStartRequest(
          url,
          userAgent,
          contentDisposition,
          mimeType,
          contentLength,
          URLUtil.guessFileName(url, contentDisposition, mimeType),
          null
        )
      )
    }
  }

  fun setDesktopMode(enabled: Boolean) {
    val webSettings = getSettings()
    val currentUserAgent = webSettings.userAgentString ?: ""
    val newUserAgent = if (enabled) {
      currentUserAgent.replace("Mobile", "eliboM").replace("Android", "diordnA")
    } else {
      currentUserAgent.replace("eliboM", "Mobile").replace("diordnA", "Android")
    }

    webSettings.userAgentString = newUserAgent
    webSettings.useWideViewPort = enabled
    webSettings.loadWithOverviewMode = enabled
    webSettings.setSupportZoom(enabled)
    webSettings.builtInZoomControls = enabled
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  override fun printCurrentPage(settings: PrintJobSettings?): String? {
    val activity = plugin?.activity ?: return null
    val printManager = activity.getSystemService(Context.PRINT_SERVICE) as? PrintManager
      ?: run {
        Log.e(LOG_TAG, "No PrintManager available")
        return null
      }

    val builder = PrintAttributes.Builder()
    var jobName = (title ?: url ?: "") + " Document"

    if (settings != null) {
      settings.jobName?.takeIf { it.isNotEmpty() }?.let { jobName = it }
      when (settings.orientation) {
        0 -> builder.setMediaSize(PrintAttributes.MediaSize.UNKNOWN_PORTRAIT)
        1 -> builder.setMediaSize(PrintAttributes.MediaSize.UNKNOWN_LANDSCAPE)
      }
      settings.mediaSize?.let { builder.setMediaSize(it.toMediaSize()) }
      settings.colorMode?.let { builder.setColorMode(it) }
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
        settings.duplexMode?.let { builder.setDuplexMode(it) }
      }
      settings.resolution?.let { builder.setResolution(it.toResolution()) }
    }

    var printAdapter: PrintDocumentAdapter =
      if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        createPrintDocumentAdapter(jobName)
      } else {
        createPrintDocumentAdapter()
      }

    var printJobController: PrintJobController? = null
    var printJobId: String? = null
    val currentPlugin = plugin
    if (settings?.handledByClient == true && currentPlugin?.printJobManager != null) {
      printJobId = UUID.randomUUID().toString()
      val generatedPrintJobId = printJobId ?: return null
      printJobController = PrintJobController(generatedPrintJobId, settings, currentPlugin)
      currentPlugin.printJobManager?.jobs?.set(printJobController.id, printJobController)
      val finalController = printJobController ?: return null
      printAdapter = InAppWebViewPrintDocumentAdapter(
        printAdapter,
        object : InAppWebViewPrintDocumentAdapter.PrintDocumentAdapterCallback() {
          override fun onFinish() {
            finalController.onComplete(true, null)
          }
        }
      )
    }

    val job = printManager.print(jobName, printAdapter, builder.build())
    printJobController?.setJob(job)
    return printJobId
  }

  override fun onCreateContextMenu(menu: ContextMenu) {
    super.onCreateContextMenu(menu)
    sendOnCreateContextMenuEvent()
  }

  private fun sendOnCreateContextMenuEvent() {
    val hitTestResult =
      com.emirkanacar.flutter_inappwebview_forge_android.types.HitTestResult
        .fromWebViewHitTestResult(getHitTestResult())
    hitTestResult?.let { channelDelegate?.onCreateContextMenu(it) }
  }

  private var contextMenuPoint = Point(0, 0)
  private var lastTouch = Point(0, 0)

  override fun onTouchEvent(event: MotionEvent): Boolean {
    if (customSettings.isUserInteractionEnabled != true) {
      return true
    }

    lastTouch = Point(event.x.toInt(), event.y.toInt())
    val parent = parent
    if (parent is PullToRefreshLayout && event.actionMasked == MotionEvent.ACTION_DOWN) {
      parent.isEnabled = false
    }
    return super.onTouchEvent(event)
  }

  override fun onOverScrolled(
    scrollX: Int,
    scrollY: Int,
    clampedX: Boolean,
    clampedY: Boolean
  ) {
    super.onOverScrolled(scrollX, scrollY, clampedX, clampedY)

    val overScrolledHorizontally = canScrollHorizontally() && clampedX
    val overScrolledVertically = canScrollVertically() && clampedY
    val parent = parent

    if (parent is PullToRefreshLayout && overScrolledVertically && scrollY <= 10) {
      setOverScrollMode(OVER_SCROLL_NEVER)
      parent.isEnabled = parent.settings.enabled == true
      setOverScrollMode(customSettings.overScrollMode ?: View.OVER_SCROLL_IF_CONTENT_SCROLLS)
    }

    if (overScrolledHorizontally || overScrolledVertically) {
      channelDelegate?.onOverScrolled(
        scrollX,
        scrollY,
        overScrolledHorizontally,
        overScrolledVertically
      )
    }
  }

  override fun dispatchTouchEvent(event: MotionEvent): Boolean =
    super.dispatchTouchEvent(event)

  override fun onCreateInputConnection(outAttrs: EditorInfo): InputConnection? {
    val connection = super.onCreateInputConnection(outAttrs)
    val currentContainer = containerView
    if (
      connection == null &&
      customSettings.useHybridComposition != true &&
      currentContainer != null
    ) {
      currentContainer.handler?.postDelayed({
        val inputMethodManager =
          context.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
        var isAcceptingText = false
        if (inputMethodManager != null) {
          try {
            isAcceptingText = inputMethodManager.isAcceptingText
          } catch (_: Exception) {
          }
        }

        val postedContainerView = containerView
        if (
          postedContainerView != null &&
          postedContainerView.isAttachedToWindow &&
          postedContainerView.windowToken != null &&
          inputMethodManager != null &&
          !isAcceptingText
        ) {
          try {
            inputMethodManager.hideSoftInputFromWindow(
              postedContainerView.windowToken,
              InputMethodManager.HIDE_NOT_ALWAYS
            )
          } catch (error: RuntimeException) {
            Log.w(LOG_TAG, "Unable to hide the input method after a stale WebView focus.", error)
          }
        }
      }, 128)
    }
    return connection
  }

  override fun startActionMode(callback: ActionMode.Callback): ActionMode? {
    if (
      customSettings.useHybridComposition == true &&
      customSettings.disableContextMenu != true &&
      contextMenu.isNullOrEmpty()
    ) {
      return startNativeActionMode(callback)
    }
    return rebuildActionMode(startNativeActionMode(callback), callback)
  }

  @RequiresApi(Build.VERSION_CODES.M)
  override fun startActionMode(callback: ActionMode.Callback, type: Int): ActionMode? {
    if (
      customSettings.useHybridComposition == true &&
      customSettings.disableContextMenu != true &&
      contextMenu.isNullOrEmpty()
    ) {
      return startNativeActionMode(callback, type)
    }
    return rebuildActionMode(startNativeActionMode(callback, type), callback)
  }

  private fun startNativeActionMode(
    callback: ActionMode.Callback,
    type: Int? = null
  ): ActionMode? {
    return try {
      if (type == null) {
        super.startActionMode(callback)
      } else {
        super.startActionMode(callback, type)
      }
    } catch (exception: Resources.NotFoundException) {
      Log.w(LOG_TAG, "Unable to create the native text-selection action mode", exception)
      null
    }
  }

  fun rebuildActionMode(
    actionMode: ActionMode?,
    callback: ActionMode.Callback
  ): ActionMode? {
    if (customSettings.useHybridComposition != true && containerView != null) {
      onWindowFocusChanged(containerView?.isFocused == true)
    }

    var hasBeenRemovedAndRebuilt = false
    if (floatingContextMenu != null) {
      hideContextMenu()
      hasBeenRemovedAndRebuilt = true
    }

    val currentActionMode = actionMode ?: return null
    val actionMenu = currentActionMode.menu

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      currentActionMode.hide(3000)
    }

    val defaultMenuItems = ArrayList<MenuItem>()
    for (index in 0 until actionMenu.size()) {
      defaultMenuItems.add(actionMenu.getItem(index))
    }
    actionMenu.clear()
    currentActionMode.finish()

    if (customSettings.disableContextMenu == true) {
      return currentActionMode
    }

    val menuView = LayoutInflater.from(context)
      .inflate(R.layout.floating_action_mode, this, false) as LinearLayout
    floatingContextMenu = menuView
    val horizontalScrollView = menuView.getChildAt(0) as HorizontalScrollView
    val menuItemListLayout = horizontalScrollView.getChildAt(0) as LinearLayout

    @Suppress("UNCHECKED_CAST")
    val customMenuItems =
      (contextMenu?.get("menuItems") as? List<*>)
        ?.mapNotNull { it as? Map<String, Any?> }
        ?: emptyList()

    val contextMenuSettings = ContextMenuSettings()
    @Suppress("UNCHECKED_CAST")
    val contextMenuSettingsMap =
      contextMenu?.get("settings") as? MutableMap<String, Any?>
    if (contextMenuSettingsMap != null) {
      contextMenuSettings.parse(contextMenuSettingsMap)
    }

    if (contextMenuSettings.hideDefaultSystemContextMenuItems != true) {
      for (menuItem in defaultMenuItems) {
        if (!menuItem.isVisible) {
          continue
        }

        val itemId = menuItem.itemId
        val itemTitle = try {
          menuItem.title?.toString().orEmpty()
        } catch (exception: Resources.NotFoundException) {
          Log.w(LOG_TAG, "Unable to read a native action-mode item title", exception)
          ""
        }
        val itemIcon = try {
          menuItem.icon
        } catch (exception: Resources.NotFoundException) {
          Log.w(LOG_TAG, "Unable to read a native action-mode item icon", exception)
          null
        }
        val hasMeaningfulTitle =
          itemTitle.isNotBlank() && !itemTitle.equals("false", ignoreCase = true)
        if (!hasMeaningfulTitle && itemIcon == null) {
          continue
        }

        val textView = LayoutInflater.from(context)
          .inflate(R.layout.floating_action_mode_item, this, false) as TextView
        textView.isEnabled = menuItem.isEnabled
        if (hasMeaningfulTitle) {
          textView.text = itemTitle
        } else {
          val iconSize =
            (24 * resources.displayMetrics.density).toInt().coerceAtLeast(1)
          itemIcon?.setBounds(0, 0, iconSize, iconSize)
          textView.text = ""
          textView.setCompoundDrawablesRelative(itemIcon, null, null, null)
        }
        textView.setOnClickListener {
          hideContextMenu()
          callback.onActionItemClicked(currentActionMode, menuItem)
          channelDelegate?.onContextMenuActionItemClicked(itemId, itemTitle)
        }
        menuItemListLayout.addView(textView)
      }
    }

    for (menuItem in customMenuItems) {
      val itemId = (menuItem["id"] as? Number)?.toInt() ?: 0
      val itemTitle = menuItem["title"] as? String ?: ""
      val textView = LayoutInflater.from(context)
        .inflate(R.layout.floating_action_mode_item, this, false) as TextView
      textView.text = itemTitle
      textView.setOnClickListener {
        hideContextMenu()
        channelDelegate?.onContextMenuActionItemClicked(itemId, itemTitle)
      }
      menuItemListLayout.addView(textView)
    }

    val x = lastTouch.x
    val y = lastTouch.y
    contextMenuPoint = Point(x, y)

    menuView.viewTreeObserver.addOnGlobalLayoutListener(object :
      ViewTreeObserver.OnGlobalLayoutListener {
      override fun onGlobalLayout() {
        if (floatingContextMenu != null) {
          menuView.viewTreeObserver.removeOnGlobalLayoutListener(this)
          if (getSettings().javaScriptEnabled == true) {
            onScrollStopped()
          } else {
            onFloatingActionGlobalLayout(x, y)
          }
        }
      }
    })

    addView(
      menuView,
      AbsoluteLayout.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT,
        ViewGroup.LayoutParams.WRAP_CONTENT,
        x,
        y
      )
    )

    if (hasBeenRemovedAndRebuilt) {
      sendOnCreateContextMenuEvent()
    }
    checkContextMenuShouldBeClosedTask?.run()
    return currentActionMode
  }

  fun onFloatingActionGlobalLayout(x: Int, y: Int) {
    val menu = floatingContextMenu ?: return
    val maxWidth = width
    val maxHeight = height
    val menuWidth = menu.width
    val menuHeight = menu.height
    var currentX = x - menuWidth / 2
    if (currentX < 0) {
      currentX = 0
    } else if (currentX + menuWidth > maxWidth) {
      currentX = maxWidth - menuWidth
    }

    var currentY = y - (menuHeight * 1.5f)
    if (currentY < 0) {
      currentY = (y + menuHeight).toFloat()
    }

    updateViewLayout(
      menu,
      AbsoluteLayout.LayoutParams(
        ViewGroup.LayoutParams.WRAP_CONTENT,
        ViewGroup.LayoutParams.WRAP_CONTENT,
        currentX + scrollX,
        currentY.toInt() + scrollY
      )
    )

    mainLooperHandler.post {
      floatingContextMenu?.let {
        it.visibility = View.VISIBLE
        it.animate().alpha(1f).setDuration(100).setListener(null)
      }
    }
  }

  fun hideContextMenu() {
    floatingContextMenu?.let { removeView(it) }
    floatingContextMenu = null
    channelDelegate?.onHideContextMenu()
  }

  fun onScrollStopped() {
    if (floatingContextMenu != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
      adjustFloatingContextMenuPosition()
    }
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  fun adjustFloatingContextMenuPosition() {
    evaluateJavascript(
      "(function(){" +
        "  var selection = window.getSelection();" +
        "  var rangeY = null;" +
        "  if (selection != null && selection.rangeCount > 0) {" +
        "    var range = selection.getRangeAt(0);" +
        "    var clientRect = range.getClientRects();" +
        "    if (clientRect.length > 0) {" +
        "      rangeY = clientRect[0].y;" +
        "    } else if (document.activeElement != null && " +
        "document.activeElement.tagName.toLowerCase() !== 'iframe') {" +
        "      var boundingClientRect = document.activeElement.getBoundingClientRect();" +
        "      rangeY = boundingClientRect.y;" +
        "    }" +
        "  }" +
        "  return rangeY;" +
        "})();",
      ValueCallback { value ->
        val menu = floatingContextMenu ?: return@ValueCallback
        if (value != null && !value.equals("null", ignoreCase = true)) {
          val x = contextMenuPoint.x
          val y =
            (value.toFloat() * Util.getPixelDensity(context) + menu.height / 3.5f).toInt()
          contextMenuPoint.y = y
          onFloatingActionGlobalLayout(x, y)
        } else {
          menu.visibility = View.VISIBLE
          menu.animate().alpha(1f).setDuration(100).setListener(null)
          onFloatingActionGlobalLayout(contextMenuPoint.x, contextMenuPoint.y)
        }
      }
    )
  }

  @RequiresApi(Build.VERSION_CODES.KITKAT)
  override fun getSelectedText(resultCallback: ValueCallback<String>) {
    evaluateJavascript(
      PluginScriptsUtil.GET_SELECTED_TEXT_JS_SOURCE,
      ValueCallback { value ->
        val selectedText =
          if (value != null && !value.equals("null", ignoreCase = true)) {
            value.substring(1, value.length - 1)
          } else {
            null
          }
        resultCallback.onReceiveValue(selectedText)
      }
    )
  }

  override fun requestFocusNodeHref(): MutableMap<String, Any?> {
    val message = mHandler.obtainMessage()
    requestFocusNodeHref(message)
    val bundle = message.peekData() ?: Bundle()
    return HashMap<String, Any?>().apply {
      put("src", bundle.getString("src"))
      put("url", bundle.getString("url"))
      put("title", bundle.getString("title"))
    }
  }

  override fun requestImageRef(): MutableMap<String, Any?> {
    val message = mHandler.obtainMessage()
    requestImageRef(message)
    val bundle = message.peekData() ?: Bundle()
    return HashMap<String, Any?>().apply {
      put("url", bundle.getString("url"))
    }
  }

  @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
  override fun callAsyncJavaScript(
    functionBody: String,
    arguments: MutableMap<String, Any?>,
    contentWorld: ContentWorld?,
    resultCallback: ValueCallback<String>
  ) {
    val resultUuid = UUID.randomUUID().toString()
    callAsyncJavaScriptCallbacks[resultUuid] = resultCallback

    val functionArguments = JSONObject(arguments)
    val keys = functionArguments.keys()
    val functionArgumentNamesList = ArrayList<String>()
    val functionArgumentValuesList = ArrayList<String>()

    while (keys.hasNext()) {
      val key = keys.next()
      functionArgumentNamesList.add(key)
      functionArgumentValuesList.add("obj." + key)
    }

    val functionArgumentNames = TextUtils.join(", ", functionArgumentNamesList)
    val functionArgumentValues = TextUtils.join(", ", functionArgumentValuesList)
    val functionArgumentsObject = Util.JSONStringify(arguments)

    val sourceToInject =
      PluginScriptsUtil.CALL_ASYNC_JAVA_SCRIPT_WRAPPER_JS_SOURCE()
        .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES, functionArgumentNames)
        .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_VALUES, functionArgumentValues)
        .replace(PluginScriptsUtil.VAR_FUNCTION_ARGUMENTS_OBJ, functionArgumentsObject)
        .replace(PluginScriptsUtil.VAR_FUNCTION_BODY, functionBody)
        .replace(PluginScriptsUtil.VAR_RESULT_UUID, resultUuid)

    val generatedSource =
      userContentController.generateCodeForScriptEvaluation(sourceToInject, contentWorld)
    evaluateJavascript(generatedSource, null)
  }

  @TargetApi(Build.VERSION_CODES.LOLLIPOP)
  override fun isSecureContext(resultCallback: ValueCallback<Boolean>) {
    evaluateJavascript(
      "window.isSecureContext",
      ValueCallback { value ->
        if (
          value == null ||
          value.isEmpty() ||
          value.equals("null", ignoreCase = true) ||
          value.equals("false", ignoreCase = true)
        ) {
          resultCallback.onReceiveValue(false)
        } else {
          resultCallback.onReceiveValue(true)
        }
      }
    )
  }

  override fun canScrollVertically(): Boolean =
    computeVerticalScrollRange() > computeVerticalScrollExtent()

  override fun canScrollHorizontally(): Boolean =
    computeHorizontalScrollRange() > computeHorizontalScrollExtent()

  override fun createCompatWebMessageChannel(): WebMessageChannel {
    val id = UUID.randomUUID().toString()
    val channel = WebMessageChannel(id, this)
    webMessageChannels[id] = channel
    return channel
  }

  override fun createWebMessageChannel(
    callback: ValueCallback<WebMessageChannel>
  ): WebMessageChannel {
    val channel = createCompatWebMessageChannel()
    callback.onReceiveValue(channel)
    return channel
  }

  @Throws(Exception::class)
  override fun addWebMessageListener(webMessageListener: WebMessageListener) {
    if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
      val nativeListener = webMessageListener.listener ?: return
      WebViewCompat.addWebMessageListener(
        this,
        webMessageListener.jsObjectName,
        webMessageListener.allowedOriginRules,
        nativeListener
      )
    } else {
      if (!javaScriptBridgeEnabled) return
      webMessageListener.initJsInstance()
    }
    webMessageListeners.add(webMessageListener)
  }

  override fun disposeWebMessageChannels() {
    webMessageChannels.values.toList().forEach { it.dispose() }
    webMessageChannels.clear()
  }

  override fun disposeWebMessageListeners() {
    webMessageListeners.toList().forEach { it.dispose() }
    webMessageListeners.clear()
  }

  override fun getWebViewLooper(): Looper =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
      super.getWebViewLooper()
    } else {
      Looper.getMainLooper()
    }

  override fun isInFullscreen(): Boolean = inFullscreen

  override fun setInFullscreen(inFullscreen: Boolean) {
    this.inFullscreen = inFullscreen
  }

  internal fun restoreFullscreenStateAfterRendererGone() {
    if (!isInFullscreen()) return

    inAppWebViewChromeClient?.onHideCustomView()
    if (isInFullscreen()) {
      channelDelegate?.onExitFullscreen()
      setInFullscreen(false)
    }
  }

  @Throws(Exception::class)
  override fun postWebMessage(
    message: com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessage,
    targetOrigin: Uri,
    callback: ValueCallback<String>
  ) {
    throw UnsupportedOperationException()
  }

  private fun refreshGeometryAfterLayoutChange() {
    if (isDisposed) return
    postInvalidateOnAnimation()
    requestLayout()
  }

  override fun onSizeChanged(w: Int, h: Int, oldw: Int, oldh: Int) {
    super.onSizeChanged(w, h, oldw, oldh)
    if (w != oldw || h != oldh) {
      refreshGeometryAfterLayoutChange()
    }
  }

  override fun onWindowVisibilityChanged(visibility: Int) {
    if (customSettings.allowBackgroundAudioPlaying == true) {
      if (visibility != View.GONE) {
        super.onWindowVisibilityChanged(View.VISIBLE)
      }
      if (visibility != View.GONE) {
        refreshGeometryAfterLayoutChange()
      }
      return
    }
    super.onWindowVisibilityChanged(visibility)
    if (visibility != View.GONE) {
      refreshGeometryAfterLayoutChange()
    }
  }

  override fun getZoomScale(): Float = zoomScale

  override fun getZoomScale(callback: ValueCallback<Float>) {
    callback.onReceiveValue(zoomScale)
  }

  override fun getContextMenu(): MutableMap<String, Any?>? = contextMenu

  override fun setContextMenu(contextMenu: MutableMap<String, Any?>?) {
    this.contextMenu = contextMenu
  }

  override fun getPlugin(): InAppWebViewFlutterPlugin =
    plugin ?: error("The Flutter plugin is not available.")

  override fun setPlugin(plugin: InAppWebViewFlutterPlugin) {
    this.plugin = plugin
  }

  override fun getInAppBrowserDelegate(): InAppBrowserDelegate? = inAppBrowserDelegate

  override fun setInAppBrowserDelegate(inAppBrowserDelegate: InAppBrowserDelegate?) {
    this.inAppBrowserDelegate = inAppBrowserDelegate
  }

  override fun getUserContentController(): UserContentController = userContentController

  fun setInitialUserOnlyScripts(userScripts: List<UserScript>) {
    initialUserOnlyScripts = userScripts.toMutableList()
  }

  override fun setUserContentController(userContentController: UserContentController) {
    this.userContentController = userContentController
  }

  override fun getWebMessageChannels(): MutableMap<String, WebMessageChannel> =
    webMessageChannels

  override fun setWebMessageChannels(
    webMessageChannels: MutableMap<String, WebMessageChannel>
  ) {
    this.webMessageChannels = webMessageChannels
  }

  override fun getContentHeight(callback: ValueCallback<Int>) {
    callback.onReceiveValue(super.getContentHeight())
  }

  override fun getContentWidth(callback: ValueCallback<Int>) {
    evaluateJavascript(
      "document.documentElement.scrollWidth;",
      ValueCallback { value ->
        val contentWidth =
          if (value != null && !value.equals("null", ignoreCase = true)) {
            value.toIntOrNull()
          } else {
            null
          }
        callback.onReceiveValue(contentWidth)
      }
    )
  }

  override fun getHitTestResult(
    callback: ValueCallback<com.emirkanacar.flutter_inappwebview_forge_android.types.HitTestResult>
  ) {
    callback.onReceiveValue(
      com.emirkanacar.flutter_inappwebview_forge_android.types.HitTestResult
        .fromWebViewHitTestResult(super.getHitTestResult())
    )
  }

  override fun getChannelDelegate(): WebViewChannelDelegate? = channelDelegate

  override fun setChannelDelegate(channelDelegate: WebViewChannelDelegate?) {
    this.channelDelegate = channelDelegate
  }

  override fun getCustomSettings(): InAppWebViewSettings = customSettings

  override fun showInputMethod() {
    val activity = plugin?.activity ?: return
    if (!isAttachedToWindow || windowToken == null) return
    val inputMethodManager =
      activity.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
    try {
      inputMethodManager?.showSoftInput(this, 0)
    } catch (error: RuntimeException) {
      Log.w(LOG_TAG, "Unable to show the input method for the WebView.", error)
    }
  }

  override fun hideInputMethod() {
    val activity = plugin?.activity ?: return
    val inputMethodManager =
      activity.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
    if (inputMethodManager != null) {
      val inputWindowToken =
        if (customSettings.useHybridComposition != true && containerView != null) {
          containerView?.windowToken
        } else {
          windowToken
        }
      if (inputWindowToken != null) {
        try {
          inputMethodManager.hideSoftInputFromWindow(inputWindowToken, 0)
        } catch (error: RuntimeException) {
          Log.w(LOG_TAG, "Unable to hide the input method for the WebView.", error)
        }
      }
    }
  }

  override fun saveState(): ByteArray? {
    val bundle = Bundle()
    if (saveState(bundle) != null) {
      val parcel = Parcel.obtain()
      bundle.writeToParcel(parcel, 0)
      val bytes = parcel.marshall()
      parcel.recycle()
      return bytes
    }
    return null
  }

  override fun restoreState(state: ByteArray): Boolean {
    val parcel = Parcel.obtain()
    return try {
      parcel.unmarshall(state, 0, state.size)
      parcel.setDataPosition(0)
      val bundle = Bundle.CREATOR.createFromParcel(parcel)
      restoreState(bundle) != null
    } catch (e: Exception) {
      e.printStackTrace()
      false
    } finally {
      parcel.recycle()
    }
  }

  override fun dispose() {
    if (isDisposed) return
    isDisposed = true
    nativeRegistrationsRegistered = true
    nativeRegistrationRequestScheduled = false
    nativeRegistrationCallbacks.clear()
    finishPendingAsyncJavaScriptCallbacksOnDispose()
    channelDelegate?.dispose()
    channelDelegate = null
    super.dispose()

    getSettings().javaScriptEnabled = false
    removeJavascriptInterface(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())

    if (
      Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q &&
      WebViewFeature.isFeatureSupported(WebViewFeature.WEB_VIEW_RENDERER_CLIENT_BASIC_USAGE)
    ) {
      WebViewCompat.setWebViewRenderProcessClient(this, null)
    }

    setWebChromeClient(WebChromeClient())
    setWebViewClient(object : WebViewClient() {
      override fun onPageFinished(view: WebView?, url: String?) {
        destroy()
      }
    })

    interceptOnlyAsyncAjaxRequestsPluginScript = null
    userContentController.dispose()
    findInteractionController?.dispose()
    findInteractionController = null
    webViewAssetLoaderExt?.dispose()
    webViewAssetLoaderExt = null

    val currentWindowId = windowId
    val currentPlugin = plugin
    if (currentWindowId != null) {
      currentPlugin?.inAppWebViewManager?.windowWebViewMessages?.remove(currentWindowId)
    }

    mainLooperHandler.removeCallbacksAndMessages(null)
    mHandler.removeCallbacksAndMessages(null)
    disposeWebMessageChannels()
    disposeWebMessageListeners()
    removeAllViews()
    checkContextMenuShouldBeClosedTask?.let { removeCallbacks(it) }
    checkScrollStoppedTask?.let { removeCallbacks(it) }
    mainLooperHandler.removeCallbacks(dispatchPendingScrollChanged)
    removeCallbacks(dispatchPendingScrollChanged)
    pendingScrollX = null
    pendingScrollY = null
    scrollChangedDispatchScheduled = false
    evaluateJavaScriptContentWorldCallbacks.clear()
    inAppBrowserDelegate = null

    inAppWebViewRenderProcessClient?.dispose()
    inAppWebViewRenderProcessClient = null
    inAppWebViewChromeClient?.dispose()
    inAppWebViewChromeClient = null
    inAppWebViewClientCompat?.dispose()
    inAppWebViewClientCompat = null
    inAppWebViewClient?.dispose()
    inAppWebViewClient = null
    javaScriptBridgeInterface?.dispose()
    javaScriptBridgeInterface = null
    plugin = null
    loadUrl("about:blank")
  }

  private fun finishPendingAsyncJavaScriptCallbacksOnDispose() {
    val pendingCallbacks = ArrayList(callAsyncJavaScriptCallbacks.values)
    callAsyncJavaScriptCallbacks.clear()
    val disposedResult = JSONObject().apply {
      put("value", JSONObject.NULL)
      put("error", "WebView disposed")
    }.toString()
    pendingCallbacks.forEach { callback ->
      callback?.onReceiveValue(disposedResult)
    }
  }

  override fun destroy() {
    super.destroy()
  }
}
