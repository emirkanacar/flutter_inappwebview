package com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message

import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessageCompatExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class WebMessageChannelChannelDelegate(
    private var webMessageChannel: WebMessageChannel?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setWebMessageCallback" -> {
                val channel = webMessageChannel
                if (channel?.webView is InAppWebView) {
                    val index = call.argument<Int>("index")
                    if (index == null) {
                        result.error("invalid_arguments", "Web message port index is required.", null)
                    } else {
                        channel.setWebMessageCallbackForInAppWebView(index, result)
                    }
                } else {
                    result.success(false)
                }
            }

            "postMessage" -> {
                val channel = webMessageChannel
                if (channel?.webView is InAppWebView) {
                    val index = call.argument<Int>("index")
                    val message = WebMessageCompatExt.fromMap(
                        call.argument<MutableMap<String, Any?>>("message")
                    )
                    if (index == null || message == null) {
                        result.error("invalid_arguments", "Web message index and message are required.", null)
                    } else {
                        channel.postMessageForInAppWebView(index, message, result)
                    }
                } else {
                    result.success(false)
                }
            }

            "close" -> {
                val channel = webMessageChannel
                if (channel?.webView is InAppWebView) {
                    val index = call.argument<Int>("index")
                    if (index == null) {
                        result.error("invalid_arguments", "Web message port index is required.", null)
                    } else {
                        channel.closeForInAppWebView(index, result)
                    }
                } else {
                    result.success(false)
                }
            }

            else -> result.notImplemented()
        }
    }

    open fun onMessage(index: Int, message: WebMessageCompatExt?) {
        val channel = getChannel() ?: return
        val obj = HashMap<String, Any?>()
        obj["index"] = index
        obj["message"] = message?.toMap()
        channel.invokeMethod("onMessage", obj)
    }

    override fun dispose() {
        super.dispose()
        webMessageChannel = null
    }
}
