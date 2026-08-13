package com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message

import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessageCompatExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class WebMessageListenerChannelDelegate(
    private var webMessageListener: WebMessageListener?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {
    private fun canDispatchCallbacks(): Boolean {
        return getChannel() != null &&
            (webMessageListener?.webView as? InAppWebView)?.acceptsCallbacks() == true
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!canDispatchCallbacks()) {
            result.success(null)
            return
        }
        when (call.method) {
            "postMessage" -> {
                val listener = webMessageListener
                if (listener?.webView is InAppWebView) {
                    val message = WebMessageCompatExt.fromMap(
                        call.argument<MutableMap<String, Any?>>("message")
                    )
                    if (message == null) {
                        result.error("invalid_arguments", "Web message is required.", null)
                    } else {
                        listener.postMessageForInAppWebView(message, result)
                    }
                } else {
                    result.success(false)
                }
            }

            else -> result.notImplemented()
        }
    }

    open fun onPostMessage(message: WebMessageCompatExt?, sourceOrigin: String?, isMainFrame: Boolean) {
        if (!canDispatchCallbacks()) return
        val channel = getChannel() ?: return
        val obj = HashMap<String, Any?>()
        obj["message"] = message?.toMap()
        obj["sourceOrigin"] = sourceOrigin
        obj["isMainFrame"] = isMainFrame
        channel.invokeMethod("onPostMessage", obj)
    }

    override fun dispose() {
        super.dispose()
        webMessageListener = null
    }
}
