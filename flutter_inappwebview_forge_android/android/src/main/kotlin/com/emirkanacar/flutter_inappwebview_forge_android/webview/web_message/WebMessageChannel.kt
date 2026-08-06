package com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message

import android.webkit.ValueCallback
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebMessagePortCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessage
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessageCompatExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessagePort
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessagePortCompatExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewInterface
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.Arrays
import java.util.HashMap

open class WebMessageChannel(
    @JvmField var id: String,
    initialWebView: InAppWebViewInterface
) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG: String = "WebMessageChannel"

        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX: String =
            "com.emirkanacar/flutter_inappwebview_web_message_channel_"
    }

    @JvmField
    var channelDelegate: WebMessageChannelChannelDelegate? = null

    @JvmField
    val compatPorts: MutableList<WebMessagePortCompat>

    @JvmField
    val ports: MutableList<WebMessagePort>

    @JvmField
    var webView: InAppWebViewInterface? = initialWebView

    init {
        val channel = MethodChannel(
            initialWebView.getPlugin().requireMessenger(),
            METHOD_CHANNEL_NAME_PREFIX + id
        )
        channelDelegate = WebMessageChannelChannelDelegate(this, channel)
        if (initialWebView is InAppWebView) {
            compatPorts = ArrayList(
                Arrays.asList(*WebViewCompat.createWebMessageChannel(initialWebView))
            )
            ports = ArrayList()
        } else {
            ports = ArrayList(
                Arrays.asList(WebMessagePort("port1", this), WebMessagePort("port2", this))
            )
            compatPorts = ArrayList()
        }
    }

    open fun initJsInstance(
        webView: InAppWebViewInterface?,
        callback: ValueCallback<WebMessageChannel>?
    ) {
        if (webView != null) {
            val webMessageChannel = this
            webView.evaluateJavascript(
                "(function() {" +
                    com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS.WEB_MESSAGE_CHANNELS_VARIABLE_NAME() +
                    "['" + webMessageChannel.id + "'] = new MessageChannel();" +
                    "})();",
                null,
                object : ValueCallback<String> {
                    override fun onReceiveValue(value: String?) {
                        callback?.onReceiveValue(webMessageChannel)
                    }
                }
            )
        } else {
            callback?.onReceiveValue(this)
        }
    }

    open fun setWebMessageCallbackForInAppWebView(
        index: Int,
        result: MethodChannel.Result
    ) {
        if (webView != null && compatPorts.isNotEmpty() &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_SET_MESSAGE_CALLBACK)
        ) {
            val webMessagePort = compatPorts[index]
            val webMessageChannel = this
            try {
                webMessagePort.setWebMessageCallback(object : WebMessagePortCompat.WebMessageCallbackCompat() {
                    override fun onMessage(port: WebMessagePortCompat, message: WebMessageCompat?) {
                        super.onMessage(port, message)
                        webMessageChannel.onMessage(
                            index,
                            message?.let { WebMessageCompatExt.fromMapWebMessageCompat(it) }
                        )
                    }
                })
                result.success(true)
            } catch (e: Exception) {
                result.error(LOG_TAG, e.message, null)
            }
        } else {
            result.success(true)
        }
    }

    open fun postMessageForInAppWebView(
        index: Int?,
        message: WebMessageCompatExt,
        result: MethodChannel.Result
    ) {
        if (webView != null && compatPorts.isNotEmpty() &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_POST_MESSAGE)
        ) {
            val portIndex = index ?: throw IllegalArgumentException("Web message port index is required.")
            val port = compatPorts[portIndex]
            val webMessagePorts = ArrayList<WebMessagePortCompat>()
            val portsExt = message.ports
            if (portsExt != null) {
                for (portExt in portsExt) {
                    val webMessageChannel = webView?.getWebMessageChannels()?.get(portExt.webMessageChannelId)
                    if (webMessageChannel != null) {
                        webMessagePorts.add(webMessageChannel.compatPorts[portExt.index])
                    }
                }
            }
            val data = message.data
            try {
                if (
                    WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
                    data != null && message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
                ) {
                    val arrayBuffer = data as? ByteArray
                        ?: throw IllegalArgumentException("Web message array buffer data is invalid.")
                    port.postMessage(
                        WebMessageCompat(arrayBuffer, webMessagePorts.toTypedArray())
                    )
                } else {
                    port.postMessage(
                        WebMessageCompat(data?.toString(), webMessagePorts.toTypedArray())
                    )
                }
                result.success(true)
            } catch (e: Exception) {
                result.error(LOG_TAG, e.message, null)
            }
        } else {
            result.success(true)
        }
    }

    open fun closeForInAppWebView(index: Int, result: MethodChannel.Result) {
        if (webView != null && compatPorts.isNotEmpty() &&
            WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)
        ) {
            val port = compatPorts[index]
            try {
                port.close()
                result.success(true)
            } catch (e: Exception) {
                result.error(LOG_TAG, e.message, null)
            }
        } else {
            result.success(true)
        }
    }

    open fun onMessage(index: Int, message: WebMessageCompatExt?) {
        channelDelegate?.onMessage(index, message)
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("id", id)
    }

    override fun dispose() {
        if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_PORT_CLOSE)) {
            for (port in compatPorts) {
                try {
                    port.close()
                } catch (_: Exception) {
                }
            }
        }
        channelDelegate?.dispose()
        channelDelegate = null
        compatPorts.clear()
        webView = null
    }
}
