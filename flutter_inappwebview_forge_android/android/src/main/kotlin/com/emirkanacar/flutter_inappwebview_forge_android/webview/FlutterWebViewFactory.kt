package com.emirkanacar.flutter_inappwebview_forge_android.webview

import android.content.Context
import android.view.View
import android.view.ViewGroup
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.headless_in_app_webview.HeadlessInAppWebView
import com.emirkanacar.flutter_inappwebview_forge_android.headless_in_app_webview.HeadlessInAppWebViewManager
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MessageCodec
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import java.util.HashMap

open class FlutterWebViewFactory(
    private val plugin: InAppWebViewFlutterPlugin
) : PlatformViewFactory(StandardMessageCodec.INSTANCE as MessageCodec<Any?>) {
    companion object {
        @JvmField
        val VIEW_TYPE_ID = "com.emirkanacar/flutter_inappwebview"
    }

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val params = args as? HashMap<String, Any?> ?: hashMapOf()
        var flutterWebView: FlutterWebView? = null
        var viewId: Any = id

        val keepAliveId = params["keepAliveId"] as? String
        val headlessWebViewId = params["headlessWebViewId"] as? String

        val headlessManager: HeadlessInAppWebViewManager? = plugin.headlessInAppWebViewManager
        if (headlessWebViewId != null && headlessManager != null) {
            val headlessWebView: HeadlessInAppWebView? = headlessManager.webViews[headlessWebViewId]
            if (headlessWebView != null) {
                flutterWebView = headlessWebView.disposeAndGetFlutterWebView()
                flutterWebView?.keepAliveId = keepAliveId
            }
        }

        val inAppWebViewManager = plugin.inAppWebViewManager
        if (keepAliveId != null && flutterWebView == null && inAppWebViewManager != null) {
            flutterWebView = inAppWebViewManager.keepAliveWebViews[keepAliveId]
            flutterWebView?.let { viewToReuse ->
                val view: View? = viewToReuse.view
                val parent = view?.parent as? ViewGroup
                parent?.removeView(view)
            }
        }

        val shouldMakeInitialLoad = flutterWebView == null
        if (flutterWebView == null) {
            if (keepAliveId != null) {
                viewId = keepAliveId
            }
            flutterWebView = FlutterWebView(plugin, context, viewId, params)
        }

        val resultWebView = flutterWebView
            ?: error("Flutter WebView could not be created.")
        if (keepAliveId != null && inAppWebViewManager != null) {
            inAppWebViewManager.keepAliveWebViews[keepAliveId] = resultWebView
        }

        if (shouldMakeInitialLoad) {
            resultWebView.makeInitialLoad(params)
        }
        return resultWebView
    }
}
