package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.text.TextUtils
import android.webkit.ValueCallback
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewInterface
import com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message.WebMessageChannel
import java.util.ArrayList

open class WebMessagePort(
    @JvmField var name: String,
    @JvmField var webMessageChannel: WebMessageChannel?
) {
    @JvmField
    var isClosed: Boolean = false

    @JvmField
    var isTransferred: Boolean = false

    @JvmField
    var isStarted: Boolean = false

    @Throws(Exception::class)
    open fun setWebMessageCallback(callback: ValueCallback<Void>?) {
        if (isClosed || isTransferred) {
            throw Exception("Port is already closed or transferred")
        }
        isStarted = true
        val channel = webMessageChannel
        val webView: InAppWebViewInterface? = channel?.webView
        if (webView != null) {
            val index = if (name == "port1") 0 else 1
            webView.evaluateJavascript(
                "(function() {" +
                    "  var webMessageChannel = " + JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() +
                    "['" + channel.id + "'];" +
                    "  if (webMessageChannel != null) {" +
                    "      webMessageChannel." + name + ".onmessage = function (event) {" +
                    "          window." + JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME() +
                    ".callHandler('onWebMessagePortMessageReceived', {" +
                    "              'webMessageChannelId': '" + channel.id + "'," +
                    "              'index': " + index + "," +
                    "              'message': event.data" +
                    "          });" +
                    "      }" +
                    "  }" +
                    "})();",
                null,
                object : ValueCallback<String> {
                    override fun onReceiveValue(value: String?) {
                        callback?.onReceiveValue(null)
                    }
                }
            )
        } else {
            callback?.onReceiveValue(null)
        }
    }

    @Throws(Exception::class)
    open fun postMessage(message: WebMessage, callback: ValueCallback<Void>?) {
        if (isClosed || isTransferred) {
            throw Exception("Port is already closed or transferred")
        }
        val channel = webMessageChannel
        val webView: InAppWebViewInterface? = channel?.webView
        if (webView != null) {
            var portsString = "null"
            val ports = message.ports
            if (ports != null) {
                val portArrayString = ArrayList<String>()
                for (port in ports) {
                    if (port == this) {
                        throw Exception("Source port cannot be transferred")
                    }
                    if (port.isStarted) {
                        throw Exception("Port is already started")
                    }
                    if (port.isClosed || port.isTransferred) {
                        throw Exception("Port is already closed or transferred")
                    }
                    port.isTransferred = true
                    portArrayString.add(
                        JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() +
                            "['" + channel.id + "']." + port.name
                    )
                }
                portsString = "[" + TextUtils.join(", ", portArrayString) + "]"
            }
            val data = message.data?.let { Util.replaceAll(it, "'", "\\'") } ?: "null"
            val source = "(function() {" +
                "  var webMessageChannel = " + JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() +
                "['" + channel.id + "'];" +
                "  if (webMessageChannel != null) {" +
                "      webMessageChannel." + name + ".postMessage('" + data + "', " + portsString + ");" +
                "  }" +
                "})();"
            webView.evaluateJavascript(
                source,
                null,
                object : ValueCallback<String> {
                    override fun onReceiveValue(value: String?) {
                        callback?.onReceiveValue(null)
                    }
                }
            )
        } else {
            callback?.onReceiveValue(null)
        }
        message.dispose()
    }

    @Throws(Exception::class)
    open fun close(callback: ValueCallback<Void>?) {
        if (isTransferred) {
            throw Exception("Port is already transferred")
        }
        isClosed = true
        val channel = webMessageChannel
        val webView: InAppWebViewInterface? = channel?.webView
        if (webView != null) {
            val source = "(function() {" +
                "  var webMessageChannel = " + JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() +
                "['" + channel.id + "'];" +
                "  if (webMessageChannel != null) {" +
                "      webMessageChannel." + name + ".close();" +
                "  }" +
                "})();"
            webView.evaluateJavascript(
                source,
                null,
                object : ValueCallback<String> {
                    override fun onReceiveValue(value: String?) {
                        callback?.onReceiveValue(null)
                    }
                }
            )
        } else {
            callback?.onReceiveValue(null)
        }
    }

    open fun dispose() {
        isClosed = true
        webMessageChannel = null
    }
}
