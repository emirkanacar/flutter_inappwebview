package com.emirkanacar.flutter_inappwebview_forge_android.headless_in_app_webview

import android.content.Context
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class HeadlessInAppWebViewManager(
    initialPlugin: InAppWebViewFlutterPlugin
) : ChannelDelegateImpl(
    MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)
) {
    companion object {
        @JvmField
        protected val LOG_TAG = "HeadlessInAppWebViewManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_headless_inappwebview"
    }

    @JvmField
    val webViews: MutableMap<String, HeadlessInAppWebView?> = HashMap()

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id")
        if (id == null) {
            result.error("invalid_arguments", "id is required.", null)
            return
        }

        when (call.method) {
            "run" -> {
                val params = call.argument<HashMap<String, Any?>>("params") ?: hashMapOf()
                run(id, params)
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun run(id: String, params: HashMap<String, Any?>) {
        val currentPlugin = plugin ?: return
        val context: Context = currentPlugin.activity ?: currentPlugin.applicationContext ?: return
        val deferNativeOperationsUntilAttach = currentPlugin.activity != null
        val flutterWebView = FlutterWebView(
            currentPlugin,
            context,
            id,
            params,
            false
        )
        val headlessInAppWebView = HeadlessInAppWebView(currentPlugin, id, flutterWebView)
        webViews[id] = headlessInAppWebView

        headlessInAppWebView.prepare(params)
        headlessInAppWebView.onWebViewCreated()
        flutterWebView.makeInitialLoad(params, deferNativeOperationsUntilAttach)
    }

    override fun dispose() {
        super.dispose()
        webViews.values.forEach { it?.dispose() }
        webViews.clear()
        plugin = null
    }
}
