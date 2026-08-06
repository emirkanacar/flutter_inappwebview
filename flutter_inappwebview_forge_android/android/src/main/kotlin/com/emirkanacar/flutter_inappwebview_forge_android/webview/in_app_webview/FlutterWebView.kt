package com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview

import android.annotation.SuppressLint
import android.content.Context
import android.hardware.display.DisplayManager
import android.os.Message
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.webkit.WebView
import android.widget.FrameLayout
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.find_interaction.FindInteractionController
import com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh.PullToRefreshLayout
import com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh.PullToRefreshSettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.URLRequest
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScript
import com.emirkanacar.flutter_inappwebview_forge_android.webview.PlatformWebView
import java.io.IOException
import java.util.ArrayList
import java.util.HashMap

open class FlutterWebView : PlatformWebView {
    companion object {
        @JvmField
        internal val LOG_TAG = "IAWFlutterWebView"
    }

    @JvmField
    var webView: InAppWebView? = null

    @JvmField
    var pullToRefreshLayout: PullToRefreshLayout? = null

    @JvmField
    var keepAliveId: String? = null

    constructor(
        plugin: InAppWebViewFlutterPlugin,
        context: Context,
        id: Any,
        params: HashMap<String, Any?>
    ) : this(plugin, context, id, params, true)

    @Suppress("UNCHECKED_CAST")
    constructor(
        plugin: InAppWebViewFlutterPlugin,
        context: Context,
        id: Any,
        params: HashMap<String, Any?>,
        deferNativeRegistrations: Boolean
    ) {
        val displayListenerProxy = DisplayListenerProxy()
        val displayManager = context.getSystemService(Context.DISPLAY_SERVICE) as? DisplayManager
            ?: throw IllegalStateException("DisplayManager is not available.")
        displayListenerProxy.onPreWebViewInitialization(displayManager)

        keepAliveId = params["keepAliveId"] as? String

        val initialSettings = params["initialSettings"] as? MutableMap<String, Any?>
        val contextMenu = params["contextMenu"] as? MutableMap<String, Any?>
        val windowId = (params["windowId"] as? Number)?.toInt()
        val initialUserScripts = params["initialUserScripts"] as? List<MutableMap<String, Any?>>
        val pullToRefreshInitialSettings =
            params["pullToRefreshSettings"] as? MutableMap<String, Any?>

        val customSettings = InAppWebViewSettings()
        customSettings.parse(initialSettings ?: hashMapOf())

        val userScripts = ArrayList<UserScript>()
        initialUserScripts?.forEach { initialUserScript ->
            UserScript.fromMap(initialUserScript)?.let(userScripts::add)
        }

        val currentWebView = InAppWebView(
            context,
            plugin,
            id,
            windowId,
            customSettings,
            contextMenu,
            if (customSettings.useHybridComposition == true) null else plugin.flutterView,
            userScripts
        )
        webView = currentWebView
        displayListenerProxy.onPostWebViewInitialization(displayManager)

        // Set MATCH_PARENT layout params to the WebView, otherwise it won't take all
        // the available space.
        currentWebView.layoutParams = FrameLayout.LayoutParams(
            ViewGroup.LayoutParams.MATCH_PARENT,
            ViewGroup.LayoutParams.MATCH_PARENT
        )

        val pullToRefreshSettings = PullToRefreshSettings()
        pullToRefreshSettings.parse(pullToRefreshInitialSettings ?: hashMapOf())
        val currentPullToRefreshLayout = PullToRefreshLayout(
            context,
            plugin,
            id,
            pullToRefreshSettings
        )
        pullToRefreshLayout = currentPullToRefreshLayout
        currentPullToRefreshLayout.addView(currentWebView)
        currentPullToRefreshLayout.prepare()

        val findInteractionController = FindInteractionController(currentWebView, plugin, id, null)
        currentWebView.findInteractionController = findInteractionController
        findInteractionController.prepare()

        currentWebView.prepare(deferNativeRegistrations)
    }

    override fun getView(): View? = pullToRefreshLayout ?: webView

    @SuppressLint("RestrictedApi")
    override fun makeInitialLoad(params: HashMap<String, Any?>) {
        makeInitialLoad(params, true)
    }

    @SuppressLint("RestrictedApi")
    fun makeInitialLoad(
        params: HashMap<String, Any?>,
        deferUntilPlatformViewAttach: Boolean
    ) {
        val currentWebView = webView ?: return

        val initialLoad = Runnable {
            makeInitialLoadAfterPlatformViewAttach(params)
        }
        currentWebView.whenNativeRegistrationsReady {
            if (deferUntilPlatformViewAttach) {
                currentWebView.post(initialLoad)
            } else {
                initialLoad.run()
            }
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun makeInitialLoadAfterPlatformViewAttach(params: HashMap<String, Any?>) {
        val currentWebView = webView ?: return

        val windowId = (params["windowId"] as? Number)?.toInt()
        val initialUrlRequest = params["initialUrlRequest"] as? MutableMap<String, Any?>
        val initialFile = params["initialFile"] as? String
        val initialData = params["initialData"] as? Map<String, String>

        if (windowId != null) {
            val manager = currentWebView.plugin?.inAppWebViewManager
            val resultMessage: Message? = manager?.windowWebViewMessages?.get(windowId)
            if (resultMessage != null) {
                (resultMessage.obj as? WebView.WebViewTransport)?.setWebView(currentWebView)
                resultMessage.sendToTarget()
                if (WebViewFeature.isFeatureSupported(WebViewFeature.DOCUMENT_START_SCRIPT)) {
                    // A WebView created using a window id does not always receive
                    // document-start scripts during initial construction.
                    // See https://github.com/pichillilorenzo/flutter_inappwebview/issues/1455
                    currentWebView.post {
                        currentWebView.prepareAndAddUserScripts()
                    }
                }
            }
        } else {
            if (initialFile != null) {
                try {
                    currentWebView.loadFile(initialFile)
                } catch (error: IOException) {
                    Log.e(LOG_TAG, "$initialFile asset file cannot be found!", error)
                }
            } else if (initialData != null) {
                currentWebView.loadDataWithBaseURL(
                    initialData["baseUrl"],
                    initialData["data"] ?: "",
                    initialData["mimeType"],
                    initialData["encoding"],
                    initialData["historyUrl"]
                )
            } else if (initialUrlRequest != null) {
                val urlRequest = URLRequest.fromMap(initialUrlRequest)
                if (urlRequest != null) {
                    currentWebView.loadUrl(urlRequest)
                }
            }
        }
    }

    override fun dispose() {
        if (keepAliveId == null) {
            val currentWebView = webView
            if (currentWebView != null) {
                // A renderer/GPU failure can dispose the platform view without
                // delivering WebChromeClient.onHideCustomView(). Clean up the
                // fullscreen state before destroying the WebView so Flutter
                // still receives the exit event and the custom view is removed
                // when the activity is available.
                if (currentWebView.isInFullscreen()) {
                    currentWebView.inAppWebViewChromeClient?.onHideCustomView()
                    if (currentWebView.isInFullscreen()) {
                        currentWebView.channelDelegate?.onExitFullscreen()
                        currentWebView.setInFullscreen(false)
                    }
                }
                currentWebView.dispose()
                webView = null

                pullToRefreshLayout?.let { layout ->
                    layout.dispose()
                    pullToRefreshLayout = null
                }
            }
        }
    }

    override fun onInputConnectionLocked() {
        val currentWebView = webView ?: return
        if (currentWebView.inAppBrowserDelegate == null &&
            currentWebView.customSettings.useHybridComposition != true
        ) {
            currentWebView.lockInputConnection()
        }
    }

    override fun onInputConnectionUnlocked() {
        val currentWebView = webView ?: return
        if (currentWebView.inAppBrowserDelegate == null &&
            currentWebView.customSettings.useHybridComposition != true
        ) {
            currentWebView.unlockInputConnection()
        }
    }

    override fun onFlutterViewAttached(flutterView: View) {
        val currentWebView = webView ?: return
        currentWebView.setContainerView(flutterView)
        currentWebView.onPlatformViewAttached()
    }

    override fun onFlutterViewDetached() {
        val currentWebView = webView ?: return
        currentWebView.setContainerView(null)
    }
}
