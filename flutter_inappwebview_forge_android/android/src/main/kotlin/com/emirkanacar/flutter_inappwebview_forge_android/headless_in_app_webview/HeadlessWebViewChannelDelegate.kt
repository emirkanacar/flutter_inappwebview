package com.emirkanacar.flutter_inappwebview_forge_android.headless_in_app_webview

import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.Size2D
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class HeadlessWebViewChannelDelegate(
    private var headlessWebView: HeadlessInAppWebView?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val webView = headlessWebView
        if (call.method != "dispose" && (webView == null || !webView.acceptsCallbacks())) {
            result.success(false)
            return
        }
        when (call.method) {
            "dispose" -> {
                if (webView != null) {
                    webView.dispose()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "setSize" -> {
                val webView = headlessWebView
                if (webView != null) {
                    val size = Size2D.fromMap(call.argument<MutableMap<String, Any?>>("size"))
                    if (size != null) {
                        webView.setSize(size)
                    }
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "getSize" -> result.success(headlessWebView?.getSize()?.toMap())
            else -> result.notImplemented()
        }
    }

    fun onWebViewCreated() {
        if (headlessWebView?.acceptsCallbacks() != true) return
        val channel = getChannel() ?: return
        channel.invokeMethod("onWebViewCreated", HashMap<String, Any?>())
    }

    override fun dispose() {
        super.dispose()
        headlessWebView = null
    }
}
