package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.annotation.SuppressLint
import android.os.Build
import android.view.View
import android.webkit.WebSettings
import androidx.webkit.WebSettingsCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.PreferredContentModeOptionType
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewInterface
import java.util.HashMap
import java.util.HashSet
import java.util.regex.Pattern

open class InAppWebViewSettings : ISettings<InAppWebViewInterface> {
    companion object {
        @JvmField
        val LOG_TAG = "InAppWebViewSettings"
    }

    @JvmField var useShouldOverrideUrlLoading: Boolean? = false
    @JvmField var useOnLoadResource: Boolean? = false
    @JvmField var useOnDownloadStart: Boolean? = false

    @Deprecated("Use clearCache on the controller instead.")
    @JvmField var clearCache: Boolean? = false

    @JvmField var userAgent: String = ""
    @JvmField var applicationNameForUserAgent: String = ""
    @JvmField var javaScriptEnabled: Boolean? = true
    @JvmField var javaScriptCanOpenWindowsAutomatically: Boolean? = false
    @JvmField var mediaPlaybackRequiresUserGesture: Boolean? = true
    @JvmField var minimumFontSize: Int? = 8
    @JvmField var verticalScrollBarEnabled: Boolean? = true
    @JvmField var horizontalScrollBarEnabled: Boolean? = true
    @JvmField var resourceCustomSchemes: MutableList<String> = mutableListOf()
    @JvmField var contentBlockers: MutableList<MutableMap<String, MutableMap<String, Any?>>> = mutableListOf()
    @JvmField var preferredContentMode: Int? = PreferredContentModeOptionType.RECOMMENDED.toValue()
    @JvmField var useShouldInterceptAjaxRequest: Boolean? = false
    @JvmField var useOnAjaxReadyStateChange: Boolean? = false
    @JvmField var useOnAjaxProgress: Boolean? = false
    @JvmField var interceptOnlyAsyncAjaxRequests: Boolean? = true
    @JvmField var useShouldInterceptFetchRequest: Boolean? = false
    @JvmField var incognito: Boolean? = false
    @JvmField var cacheEnabled: Boolean? = true
    @JvmField var transparentBackground: Boolean? = false
    @JvmField var disableVerticalScroll: Boolean? = false
    @JvmField var disableHorizontalScroll: Boolean? = false
    @JvmField var disableContextMenu: Boolean? = false
    @JvmField var supportZoom: Boolean? = true
    @JvmField var allowFileAccessFromFileURLs: Boolean? = false
    @JvmField var allowUniversalAccessFromFileURLs: Boolean? = false
    @JvmField var allowBackgroundAudioPlaying: Boolean? = false
    @JvmField var textZoom: Int? = null

    @Deprecated("Use clearSessionCache on the controller instead.")
    @JvmField var clearSessionCache: Boolean? = false

    @JvmField var builtInZoomControls: Boolean? = true
    @JvmField var displayZoomControls: Boolean? = false
    @JvmField var databaseEnabled: Boolean? = false
    @JvmField var domStorageEnabled: Boolean? = true
    @JvmField var useWideViewPort: Boolean? = true
    @JvmField var safeBrowsingEnabled: Boolean? = true
    @JvmField var mixedContentMode: Int? = null
    @JvmField var allowContentAccess: Boolean? = true
    @JvmField var allowFileAccess: Boolean? = true
    @JvmField var appCachePath: String? = null
    @JvmField var blockNetworkImage: Boolean? = false
    @JvmField var blockNetworkLoads: Boolean? = false
    @JvmField var cacheMode: Int? = WebSettings.LOAD_DEFAULT
    @JvmField var cursiveFontFamily: String = "cursive"
    @JvmField var defaultFixedFontSize: Int? = 16
    @JvmField var defaultFontSize: Int? = 16
    @JvmField var defaultTextEncodingName: String = "UTF-8"
    @JvmField var disabledActionModeMenuItems: Int? = null
    @JvmField var fantasyFontFamily: String = "fantasy"
    @JvmField var fixedFontFamily: String = "monospace"
    @Deprecated("Android WebView force dark is deprecated.")
    @JvmField var forceDark: Int? = null
    @Deprecated("Android WebView force dark strategy is deprecated.")
    @JvmField var forceDarkStrategy: Int? = null
    @JvmField var geolocationEnabled: Boolean? = true
    @JvmField var layoutAlgorithm: WebSettings.LayoutAlgorithm? = null
    @JvmField var loadWithOverviewMode: Boolean? = true
    @JvmField var loadsImagesAutomatically: Boolean? = true
    @JvmField var minimumLogicalFontSize: Int? = 8
    @JvmField var initialScale: Int? = 0
    @JvmField var needInitialFocus: Boolean? = true
    @JvmField var offscreenPreRaster: Boolean? = false
    @JvmField var sansSerifFontFamily: String = "sans-serif"
    @JvmField var serifFontFamily: String = "sans-serif"
    @JvmField var standardFontFamily: String = "sans-serif"
    @JvmField var saveFormData: Boolean? = true
    @JvmField var thirdPartyCookiesEnabled: Boolean? = true
    @JvmField var hardwareAcceleration: Boolean? = true
    @JvmField var supportMultipleWindows: Boolean? = false
    @JvmField var regexToCancelSubFramesLoading: Pattern? = null
    @JvmField var regexToAllowSyncUrlLoading: Pattern? = null
    @JvmField var overScrollMode: Int? = View.OVER_SCROLL_IF_CONTENT_SCROLLS
    @JvmField var networkAvailable: Boolean? = null
    @JvmField var scrollBarStyle: Int? = View.SCROLLBARS_INSIDE_OVERLAY
    @JvmField var verticalScrollbarPosition: Int? = View.SCROLLBAR_POSITION_DEFAULT
    @JvmField var scrollBarDefaultDelayBeforeFade: Int? = null
    @JvmField var scrollbarFadingEnabled: Boolean? = true
    @JvmField var scrollBarFadeDuration: Int? = null
    @JvmField var rendererPriorityPolicy: MutableMap<String, Any?>? = null
    @JvmField var useShouldInterceptRequest: Boolean? = false
    @JvmField var useOnRenderProcessGone: Boolean? = false
    @JvmField var disableDefaultErrorPage: Boolean? = false
    @JvmField var useHybridComposition: Boolean? = true
    @JvmField var verticalScrollbarThumbColor: String? = null
    @JvmField var verticalScrollbarTrackColor: String? = null
    @JvmField var horizontalScrollbarThumbColor: String? = null
    @JvmField var horizontalScrollbarTrackColor: String? = null
    @JvmField var algorithmicDarkeningAllowed: Boolean? = false
    @JvmField var enterpriseAuthenticationAppLinkPolicyEnabled: Boolean? = true
    @JvmField var webViewAssetLoader: MutableMap<String, Any?>? = null
    @JvmField var defaultVideoPoster: ByteArray? = null
    @JvmField var requestedWithHeaderOriginAllowList: MutableSet<String>? = null
    @JvmField var javaScriptHandlersOriginAllowList: MutableSet<Pattern>? = null
    @JvmField var javaScriptHandlersForMainFrameOnly: Boolean? = false
    @JvmField var javaScriptBridgeEnabled: Boolean? = true
    @JvmField var javaScriptBridgeOriginAllowList: MutableSet<String>? = null
    @JvmField var javaScriptBridgeForMainFrameOnly: Boolean? = null
    @JvmField var pluginScriptsOriginAllowList: MutableSet<String>? = null
    @JvmField var pluginScriptsForMainFrameOnly: Boolean? = false
    @JvmField var isUserInteractionEnabled: Boolean? = true
    @JvmField var alpha: Double? = null
    @JvmField var useOnShowFileChooser: Boolean? = false

    override fun parse(settings: MutableMap<String, Any?>): InAppWebViewSettings {
        settings.forEach { (key, value) ->
            if (value == null) return@forEach
            when (key) {
                "useShouldOverrideUrlLoading" -> useShouldOverrideUrlLoading = value as Boolean
                "useOnLoadResource" -> useOnLoadResource = value as Boolean
                "useOnDownloadStart" -> useOnDownloadStart = value as Boolean
                "clearCache" -> clearCache = value as Boolean
                "userAgent" -> userAgent = value as String
                "applicationNameForUserAgent" -> applicationNameForUserAgent = value as String
                "javaScriptEnabled" -> javaScriptEnabled = value as Boolean
                "javaScriptCanOpenWindowsAutomatically" -> javaScriptCanOpenWindowsAutomatically = value as Boolean
                "mediaPlaybackRequiresUserGesture" -> mediaPlaybackRequiresUserGesture = value as Boolean
                "minimumFontSize" -> minimumFontSize = value as Int
                "verticalScrollBarEnabled" -> verticalScrollBarEnabled = value as Boolean
                "horizontalScrollBarEnabled" -> horizontalScrollBarEnabled = value as Boolean
                "resourceCustomSchemes" -> resourceCustomSchemes = value as MutableList<String>
                "contentBlockers" -> contentBlockers = value as MutableList<MutableMap<String, MutableMap<String, Any?>>>
                "preferredContentMode" -> preferredContentMode = value as Int
                "useShouldInterceptAjaxRequest" -> useShouldInterceptAjaxRequest = value as Boolean
                "useOnAjaxReadyStateChange" -> useOnAjaxReadyStateChange = value as Boolean
                "useOnAjaxProgress" -> useOnAjaxProgress = value as Boolean
                "interceptOnlyAsyncAjaxRequests" -> interceptOnlyAsyncAjaxRequests = value as Boolean
                "useShouldInterceptFetchRequest" -> useShouldInterceptFetchRequest = value as Boolean
                "incognito" -> incognito = value as Boolean
                "cacheEnabled" -> cacheEnabled = value as Boolean
                "transparentBackground" -> transparentBackground = value as Boolean
                "disableVerticalScroll" -> disableVerticalScroll = value as Boolean
                "disableHorizontalScroll" -> disableHorizontalScroll = value as Boolean
                "disableContextMenu" -> disableContextMenu = value as Boolean
                "textZoom" -> textZoom = value as Int
                "clearSessionCache" -> clearSessionCache = value as Boolean
                "builtInZoomControls" -> builtInZoomControls = value as Boolean
                "displayZoomControls" -> displayZoomControls = value as Boolean
                "supportZoom" -> supportZoom = value as Boolean
                "databaseEnabled" -> databaseEnabled = value as Boolean
                "domStorageEnabled" -> domStorageEnabled = value as Boolean
                "useWideViewPort" -> useWideViewPort = value as Boolean
                "safeBrowsingEnabled" -> safeBrowsingEnabled = value as Boolean
                "mixedContentMode" -> mixedContentMode = value as Int
                "allowContentAccess" -> allowContentAccess = value as Boolean
                "allowFileAccess" -> allowFileAccess = value as Boolean
                "allowFileAccessFromFileURLs" -> allowFileAccessFromFileURLs = value as Boolean
                "allowUniversalAccessFromFileURLs" -> allowUniversalAccessFromFileURLs = value as Boolean
                "appCachePath" -> appCachePath = value as String
                "blockNetworkImage" -> blockNetworkImage = value as Boolean
                "blockNetworkLoads" -> blockNetworkLoads = value as Boolean
                "cacheMode" -> cacheMode = value as Int
                "cursiveFontFamily" -> cursiveFontFamily = value as String
                "defaultFixedFontSize" -> defaultFixedFontSize = value as Int
                "defaultFontSize" -> defaultFontSize = value as Int
                "defaultTextEncodingName" -> defaultTextEncodingName = value as String
                "disabledActionModeMenuItems" -> disabledActionModeMenuItems = value as Int
                "fantasyFontFamily" -> fantasyFontFamily = value as String
                "fixedFontFamily" -> fixedFontFamily = value as String
                "forceDark" -> forceDark = value as Int
                "forceDarkStrategy" -> forceDarkStrategy = value as Int
                "geolocationEnabled" -> geolocationEnabled = value as Boolean
                "layoutAlgorithm" -> setLayoutAlgorithm(value as String)
                "loadWithOverviewMode" -> loadWithOverviewMode = value as Boolean
                "loadsImagesAutomatically" -> loadsImagesAutomatically = value as Boolean
                "minimumLogicalFontSize" -> minimumLogicalFontSize = value as Int
                "initialScale" -> initialScale = value as Int
                "needInitialFocus" -> needInitialFocus = value as Boolean
                "offscreenPreRaster" -> offscreenPreRaster = value as Boolean
                "sansSerifFontFamily" -> sansSerifFontFamily = value as String
                "serifFontFamily" -> serifFontFamily = value as String
                "standardFontFamily" -> standardFontFamily = value as String
                "saveFormData" -> saveFormData = value as Boolean
                "thirdPartyCookiesEnabled" -> thirdPartyCookiesEnabled = value as Boolean
                "hardwareAcceleration" -> hardwareAcceleration = value as Boolean
                "supportMultipleWindows" -> supportMultipleWindows = value as Boolean
                "regexToCancelSubFramesLoading" -> regexToCancelSubFramesLoading = Pattern.compile(value as String)
                "regexToAllowSyncUrlLoading" -> regexToAllowSyncUrlLoading = Pattern.compile(value as String)
                "overScrollMode" -> overScrollMode = value as Int
                "networkAvailable" -> networkAvailable = value as Boolean
                "scrollBarStyle" -> scrollBarStyle = value as Int
                "verticalScrollbarPosition" -> verticalScrollbarPosition = value as Int
                "scrollBarDefaultDelayBeforeFade" -> scrollBarDefaultDelayBeforeFade = value as Int
                "scrollbarFadingEnabled" -> scrollbarFadingEnabled = value as Boolean
                "scrollBarFadeDuration" -> scrollBarFadeDuration = value as Int
                "rendererPriorityPolicy" -> rendererPriorityPolicy = value as MutableMap<String, Any?>
                "useShouldInterceptRequest" -> useShouldInterceptRequest = value as Boolean
                "useOnRenderProcessGone" -> useOnRenderProcessGone = value as Boolean
                "disableDefaultErrorPage" -> disableDefaultErrorPage = value as Boolean
                "useHybridComposition" -> useHybridComposition = value as Boolean
                "verticalScrollbarThumbColor" -> verticalScrollbarThumbColor = value as String
                "verticalScrollbarTrackColor" -> verticalScrollbarTrackColor = value as String
                "horizontalScrollbarThumbColor" -> horizontalScrollbarThumbColor = value as String
                "horizontalScrollbarTrackColor" -> horizontalScrollbarTrackColor = value as String
                "algorithmicDarkeningAllowed" -> algorithmicDarkeningAllowed = value as Boolean
                "enterpriseAuthenticationAppLinkPolicyEnabled" -> enterpriseAuthenticationAppLinkPolicyEnabled = value as Boolean
                "allowBackgroundAudioPlaying" -> allowBackgroundAudioPlaying = value as Boolean
                "webViewAssetLoader" -> webViewAssetLoader = value as MutableMap<String, Any?>
                "defaultVideoPoster" -> defaultVideoPoster = value as ByteArray
                "requestedWithHeaderOriginAllowList" -> requestedWithHeaderOriginAllowList =
                    (value as? List<*>)?.filterIsInstance<String>()?.toMutableSet()
                "javaScriptHandlersOriginAllowList" -> {
                    javaScriptHandlersOriginAllowList = HashSet<Pattern>().apply {
                        (value as? List<*>)?.filterIsInstance<String>()?.forEach {
                            add(Pattern.compile(it))
                        }
                    }
                }
                "javaScriptHandlersForMainFrameOnly" -> javaScriptHandlersForMainFrameOnly = value as Boolean
                "javaScriptBridgeEnabled" -> javaScriptBridgeEnabled = value as Boolean
                "javaScriptBridgeOriginAllowList" -> javaScriptBridgeOriginAllowList =
                    (value as? List<*>)?.filterIsInstance<String>()?.toMutableSet()
                "javaScriptBridgeForMainFrameOnly" -> javaScriptBridgeForMainFrameOnly = value as Boolean
                "pluginScriptsOriginAllowList" -> pluginScriptsOriginAllowList =
                    (value as? List<*>)?.filterIsInstance<String>()?.toMutableSet()
                "pluginScriptsForMainFrameOnly" -> pluginScriptsForMainFrameOnly = value as Boolean
                "isUserInteractionEnabled" -> isUserInteractionEnabled = value as Boolean
                "alpha" -> alpha = value as Double
                "useOnShowFileChooser" -> useOnShowFileChooser = value as Boolean
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("useShouldOverrideUrlLoading", useShouldOverrideUrlLoading)
        put("useOnLoadResource", useOnLoadResource)
        put("useOnDownloadStart", useOnDownloadStart)
        put("clearCache", clearCache)
        put("userAgent", userAgent)
        put("applicationNameForUserAgent", applicationNameForUserAgent)
        put("javaScriptEnabled", javaScriptEnabled)
        put("javaScriptCanOpenWindowsAutomatically", javaScriptCanOpenWindowsAutomatically)
        put("mediaPlaybackRequiresUserGesture", mediaPlaybackRequiresUserGesture)
        put("minimumFontSize", minimumFontSize)
        put("verticalScrollBarEnabled", verticalScrollBarEnabled)
        put("horizontalScrollBarEnabled", horizontalScrollBarEnabled)
        put("resourceCustomSchemes", resourceCustomSchemes)
        put("contentBlockers", contentBlockers)
        put("preferredContentMode", preferredContentMode)
        put("useShouldInterceptAjaxRequest", useShouldInterceptAjaxRequest)
        put("useOnAjaxReadyStateChange", useOnAjaxReadyStateChange)
        put("useOnAjaxProgress", useOnAjaxProgress)
        put("interceptOnlyAsyncAjaxRequests", interceptOnlyAsyncAjaxRequests)
        put("useShouldInterceptFetchRequest", useShouldInterceptFetchRequest)
        put("incognito", incognito)
        put("cacheEnabled", cacheEnabled)
        put("transparentBackground", transparentBackground)
        put("disableVerticalScroll", disableVerticalScroll)
        put("disableHorizontalScroll", disableHorizontalScroll)
        put("disableContextMenu", disableContextMenu)
        put("textZoom", textZoom)
        put("clearSessionCache", clearSessionCache)
        put("builtInZoomControls", builtInZoomControls)
        put("displayZoomControls", displayZoomControls)
        put("supportZoom", supportZoom)
        put("databaseEnabled", databaseEnabled)
        put("domStorageEnabled", domStorageEnabled)
        put("useWideViewPort", useWideViewPort)
        put("safeBrowsingEnabled", safeBrowsingEnabled)
        put("mixedContentMode", mixedContentMode)
        put("allowContentAccess", allowContentAccess)
        put("allowFileAccess", allowFileAccess)
        put("allowFileAccessFromFileURLs", allowFileAccessFromFileURLs)
        put("allowUniversalAccessFromFileURLs", allowUniversalAccessFromFileURLs)
        put("appCachePath", appCachePath)
        put("blockNetworkImage", blockNetworkImage)
        put("blockNetworkLoads", blockNetworkLoads)
        put("cacheMode", cacheMode)
        put("cursiveFontFamily", cursiveFontFamily)
        put("defaultFixedFontSize", defaultFixedFontSize)
        put("defaultFontSize", defaultFontSize)
        put("defaultTextEncodingName", defaultTextEncodingName)
        put("disabledActionModeMenuItems", disabledActionModeMenuItems)
        put("fantasyFontFamily", fantasyFontFamily)
        put("fixedFontFamily", fixedFontFamily)
        put("forceDark", forceDark)
        put("forceDarkStrategy", forceDarkStrategy)
        put("geolocationEnabled", geolocationEnabled)
        put("layoutAlgorithm", getLayoutAlgorithm())
        put("loadWithOverviewMode", loadWithOverviewMode)
        put("loadsImagesAutomatically", loadsImagesAutomatically)
        put("minimumLogicalFontSize", minimumLogicalFontSize)
        put("initialScale", initialScale)
        put("needInitialFocus", needInitialFocus)
        put("offscreenPreRaster", offscreenPreRaster)
        put("sansSerifFontFamily", sansSerifFontFamily)
        put("serifFontFamily", serifFontFamily)
        put("standardFontFamily", standardFontFamily)
        put("saveFormData", saveFormData)
        put("thirdPartyCookiesEnabled", thirdPartyCookiesEnabled)
        put("hardwareAcceleration", hardwareAcceleration)
        put("supportMultipleWindows", supportMultipleWindows)
        put("regexToCancelSubFramesLoading", regexToCancelSubFramesLoading?.pattern())
        put("regexToAllowSyncUrlLoading", regexToAllowSyncUrlLoading?.pattern())
        put("overScrollMode", overScrollMode)
        put("networkAvailable", networkAvailable)
        put("scrollBarStyle", scrollBarStyle)
        put("verticalScrollbarPosition", verticalScrollbarPosition)
        put("scrollBarDefaultDelayBeforeFade", scrollBarDefaultDelayBeforeFade)
        put("scrollbarFadingEnabled", scrollbarFadingEnabled)
        put("scrollBarFadeDuration", scrollBarFadeDuration)
        put("rendererPriorityPolicy", rendererPriorityPolicy)
        put("useShouldInterceptRequest", useShouldInterceptRequest)
        put("useOnRenderProcessGone", useOnRenderProcessGone)
        put("disableDefaultErrorPage", disableDefaultErrorPage)
        put("useHybridComposition", useHybridComposition)
        put("verticalScrollbarThumbColor", verticalScrollbarThumbColor)
        put("verticalScrollbarTrackColor", verticalScrollbarTrackColor)
        put("horizontalScrollbarThumbColor", horizontalScrollbarThumbColor)
        put("horizontalScrollbarTrackColor", horizontalScrollbarTrackColor)
        put("algorithmicDarkeningAllowed", algorithmicDarkeningAllowed)
        put("enterpriseAuthenticationAppLinkPolicyEnabled", enterpriseAuthenticationAppLinkPolicyEnabled)
        put("allowBackgroundAudioPlaying", allowBackgroundAudioPlaying)
        put("defaultVideoPoster", defaultVideoPoster)
        put("requestedWithHeaderOriginAllowList", requestedWithHeaderOriginAllowList?.toList())
        put("javaScriptHandlersOriginAllowList", javaScriptHandlersOriginAllowList?.map { it.pattern() })
        put("javaScriptHandlersForMainFrameOnly", javaScriptHandlersForMainFrameOnly)
        put("javaScriptBridgeEnabled", javaScriptBridgeEnabled)
        put("javaScriptBridgeOriginAllowList", javaScriptBridgeOriginAllowList?.toList())
        put("javaScriptBridgeForMainFrameOnly", javaScriptBridgeForMainFrameOnly)
        put("pluginScriptsOriginAllowList", pluginScriptsOriginAllowList?.toList())
        put("pluginScriptsForMainFrameOnly", pluginScriptsForMainFrameOnly)
        put("isUserInteractionEnabled", isUserInteractionEnabled)
        put("alpha", alpha)
        put("useOnShowFileChooser", useOnShowFileChooser)
    }

    @SuppressLint("RestrictedApi")
    override fun getRealSettings(inAppWebView: InAppWebViewInterface): MutableMap<String, Any?> {
        val realSettings = toMap()
        val webView = inAppWebView as? InAppWebView ?: return realSettings
        realSettings["alpha"] = webView.alpha

        val settings = webView.settings
        realSettings["userAgent"] = settings.userAgentString
        realSettings["javaScriptEnabled"] = settings.javaScriptEnabled
        realSettings["javaScriptCanOpenWindowsAutomatically"] = settings.javaScriptCanOpenWindowsAutomatically
        realSettings["mediaPlaybackRequiresUserGesture"] = settings.mediaPlaybackRequiresUserGesture
        realSettings["minimumFontSize"] = settings.minimumFontSize
        realSettings["verticalScrollBarEnabled"] = webView.isVerticalScrollBarEnabled
        realSettings["horizontalScrollBarEnabled"] = webView.isHorizontalScrollBarEnabled
        realSettings["textZoom"] = settings.textZoom
        realSettings["builtInZoomControls"] = settings.builtInZoomControls
        realSettings["supportZoom"] = settings.supportZoom()
        realSettings["displayZoomControls"] = settings.displayZoomControls
        realSettings["databaseEnabled"] = settings.databaseEnabled
        realSettings["domStorageEnabled"] = settings.domStorageEnabled
        realSettings["useWideViewPort"] = settings.useWideViewPort
        if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ENABLE)) {
            realSettings["safeBrowsingEnabled"] = WebSettingsCompat.getSafeBrowsingEnabled(settings)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            realSettings["safeBrowsingEnabled"] = settings.safeBrowsingEnabled
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            realSettings["mixedContentMode"] = settings.mixedContentMode
        }
        realSettings["allowContentAccess"] = settings.allowContentAccess
        realSettings["allowFileAccess"] = settings.allowFileAccess
        realSettings["allowFileAccessFromFileURLs"] = settings.allowFileAccessFromFileURLs
        realSettings["allowUniversalAccessFromFileURLs"] = settings.allowUniversalAccessFromFileURLs
        realSettings["blockNetworkImage"] = settings.blockNetworkImage
        realSettings["blockNetworkLoads"] = settings.blockNetworkLoads
        realSettings["cacheMode"] = settings.cacheMode
        realSettings["cursiveFontFamily"] = settings.cursiveFontFamily
        realSettings["defaultFixedFontSize"] = settings.defaultFixedFontSize
        realSettings["defaultFontSize"] = settings.defaultFontSize
        realSettings["defaultTextEncodingName"] = settings.defaultTextEncodingName
        if (WebViewFeature.isFeatureSupported(WebViewFeature.DISABLED_ACTION_MODE_MENU_ITEMS)) {
            realSettings["disabledActionModeMenuItems"] = WebSettingsCompat.getDisabledActionModeMenuItems(settings)
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            realSettings["disabledActionModeMenuItems"] = settings.disabledActionModeMenuItems
        }
        realSettings["fantasyFontFamily"] = settings.fantasyFontFamily
        realSettings["fixedFontFamily"] = settings.fixedFontFamily
        if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK)) {
            realSettings["forceDark"] = WebSettingsCompat.getForceDark(settings)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            realSettings["forceDark"] = settings.forceDark
        }
        if (WebViewFeature.isFeatureSupported(WebViewFeature.FORCE_DARK_STRATEGY)) {
            realSettings["forceDarkStrategy"] = WebSettingsCompat.getForceDarkStrategy(settings)
        }
        realSettings["layoutAlgorithm"] = settings.layoutAlgorithm.name
        realSettings["loadWithOverviewMode"] = settings.loadWithOverviewMode
        realSettings["loadsImagesAutomatically"] = settings.loadsImagesAutomatically
        realSettings["minimumLogicalFontSize"] = settings.minimumLogicalFontSize
        if (WebViewFeature.isFeatureSupported(WebViewFeature.OFF_SCREEN_PRERASTER)) {
            realSettings["offscreenPreRaster"] = WebSettingsCompat.getOffscreenPreRaster(settings)
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            realSettings["offscreenPreRaster"] = settings.offscreenPreRaster
        }
        realSettings["sansSerifFontFamily"] = settings.sansSerifFontFamily
        realSettings["serifFontFamily"] = settings.serifFontFamily
        realSettings["standardFontFamily"] = settings.standardFontFamily
        realSettings["saveFormData"] = settings.saveFormData
        realSettings["supportMultipleWindows"] = settings.supportMultipleWindows()
        realSettings["overScrollMode"] = webView.overScrollMode
        realSettings["scrollBarStyle"] = webView.scrollBarStyle
        realSettings["verticalScrollbarPosition"] = webView.verticalScrollbarPosition
        realSettings["scrollBarDefaultDelayBeforeFade"] = webView.scrollBarDefaultDelayBeforeFade
        realSettings["scrollbarFadingEnabled"] = webView.isScrollbarFadingEnabled
        realSettings["scrollBarFadeDuration"] = webView.scrollBarFadeDuration
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            realSettings["rendererPriorityPolicy"] = hashMapOf(
                "rendererRequestedPriority" to webView.rendererRequestedPriority,
                "waivedWhenNotVisible" to webView.rendererPriorityWaivedWhenNotVisible
            )
        }
        if (WebViewFeature.isFeatureSupported(WebViewFeature.ALGORITHMIC_DARKENING) &&
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q
        ) {
            realSettings["algorithmicDarkeningAllowed"] =
                WebSettingsCompat.isAlgorithmicDarkeningAllowed(settings)
        }
        if (WebViewFeature.isFeatureSupported(WebViewFeature.ENTERPRISE_AUTHENTICATION_APP_LINK_POLICY)) {
            realSettings["enterpriseAuthenticationAppLinkPolicyEnabled"] =
                WebSettingsCompat.getEnterpriseAuthenticationAppLinkPolicyEnabled(settings)
        }
        if (WebViewFeature.isFeatureSupported(WebViewFeature.REQUESTED_WITH_HEADER_ALLOW_LIST)) {
            realSettings["requestedWithHeaderOriginAllowList"] =
                WebSettingsCompat.getRequestedWithHeaderOriginAllowList(settings)?.toList()
        }
        return realSettings
    }

    private fun setLayoutAlgorithm(value: String?) {
        if (value == null) return
        if (value == "NARROW_COLUMNS") {
            layoutAlgorithm = WebSettings.LayoutAlgorithm.NARROW_COLUMNS
        }
        if (value == "NARROW_COLUMNS" || value == "NORMAL") {
            layoutAlgorithm = WebSettings.LayoutAlgorithm.NORMAL
        }
        if (value == "NARROW_COLUMNS" || value == "NORMAL" || value == "TEXT_AUTOSIZING") {
            layoutAlgorithm = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING
            } else {
                WebSettings.LayoutAlgorithm.NORMAL
            }
        }
    }

    private fun getLayoutAlgorithm(): String? = when (layoutAlgorithm) {
        WebSettings.LayoutAlgorithm.NORMAL -> "NORMAL"
        WebSettings.LayoutAlgorithm.TEXT_AUTOSIZING -> if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            "TEXT_AUTOSIZING"
        } else {
            "NORMAL"
        }
        WebSettings.LayoutAlgorithm.NARROW_COLUMNS -> "NARROW_COLUMNS"
        null -> null
        else -> null
    }
}
