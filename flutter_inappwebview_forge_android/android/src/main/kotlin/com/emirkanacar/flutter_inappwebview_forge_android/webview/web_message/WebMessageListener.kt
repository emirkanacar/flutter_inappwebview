package com.emirkanacar.flutter_inappwebview_forge_android.webview.web_message

import android.net.Uri
import android.webkit.WebView
import androidx.webkit.JavaScriptReplyProxy
import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.WebMessageListenerJS
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.types.PluginScript
import com.emirkanacar.flutter_inappwebview_forge_android.types.UserScriptInjectionTime
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebMessageCompatExt
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewInterface
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList

open class WebMessageListener(
    @JvmField var id: String,
    initialWebView: InAppWebViewInterface,
    messenger: BinaryMessenger,
    @JvmField var jsObjectName: String,
    @JvmField var allowedOriginRules: MutableSet<String>
) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG: String = "WebMessageListener"

        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX: String =
            "com.emirkanacar/flutter_inappwebview_web_message_listener_"

        @JvmStatic
        fun fromMap(
            webView: InAppWebViewInterface,
            messenger: BinaryMessenger,
            map: MutableMap<String, Any?>?
        ): WebMessageListener? {
            if (map == null) return null
            val id = map["id"] as? String
                ?: throw IllegalArgumentException("Web message listener id is required.")
            val jsObjectName = map["jsObjectName"] as? String
                ?: throw IllegalArgumentException("Web message listener jsObjectName is required.")
            val originRules = (map["allowedOriginRules"] as? List<*>)?.mapIndexed { index, value ->
                value as? String
                    ?: throw IllegalArgumentException("Web message listener origin rule at index $index is invalid.")
            }?.toMutableSet()
                ?: throw IllegalArgumentException("Web message listener allowedOriginRules are required.")
            return WebMessageListener(id, webView, messenger, jsObjectName, originRules)
        }
    }

    @JvmField
    var listener: WebViewCompat.WebMessageListener? = null

    @JvmField
    var replyProxy: JavaScriptReplyProxy? = null

    @JvmField
    var webView: InAppWebViewInterface? = initialWebView

    @JvmField
    var channelDelegate: WebMessageListenerChannelDelegate? = null

    init {
        val channel = MethodChannel(
            messenger,
            METHOD_CHANNEL_NAME_PREFIX + id + "_" + jsObjectName
        )
        channelDelegate = WebMessageListenerChannelDelegate(this, channel)

        if (initialWebView is InAppWebView) {
            listener = object : WebViewCompat.WebMessageListener {
                override fun onPostMessage(
                    view: WebView,
                    message: WebMessageCompat,
                    sourceOrigin: Uri,
                    isMainFrame: Boolean,
                    javaScriptReplyProxy: JavaScriptReplyProxy
                ) {
                    replyProxy = javaScriptReplyProxy
                    channelDelegate?.onPostMessage(
                        WebMessageCompatExt.fromMapWebMessageCompat(message),
                        sourceOrigin.toString().let { if (it == "null") null else it },
                        isMainFrame
                    )
                }
            }
        }
    }

    open fun initJsInstance() {
        val currentWebView = webView ?: return
        val jsObjectNameEscaped = Util.replaceAll(jsObjectName, "'", "\\'")
        val allowedOriginRulesStringList = ArrayList<String>()
        for (allowedOriginRule in allowedOriginRules) {
            if (allowedOriginRule == "*") {
                allowedOriginRulesStringList.add("'*'")
            } else {
                val rule = Uri.parse(allowedOriginRule)
                val host = rule.getHost()?.let { "'" + Util.replaceAll(it, "'", "\\'") + "'" } ?: "null"
                allowedOriginRulesStringList.add(
                    "{scheme: '" + rule.getScheme() + "', host: " + host +
                        ", port: " + if (rule.getPort() != -1) rule.getPort() else "null" + "}"
                )
            }
        }
        val allowedOriginRulesString = allowedOriginRulesStringList.joinToString(", ")
        val source = "(function() {" +
            WebMessageListenerJS.IS_ORIGIN_ALLOWED_JS_SOURCE() +
            "  var allowedOriginRules = [" + allowedOriginRulesString + "];" +
            "  var isPageBlank = window.location.href === 'about:blank';" +
            "  var scheme = !isPageBlank ? window.location.protocol.replace(':', '') : null;" +
            "  var host = !isPageBlank ? window.location.hostname : null;" +
            "  var port = !isPageBlank ? window.location.port : null;" +
            "  if (" +
            "FlutterInAppWebViewWebMessageListenerIsOriginAllowed(allowedOriginRules, scheme, host, port)) {" +
            "      window['" + jsObjectNameEscaped + "'] = new FlutterInAppWebViewWebMessageListener('" +
            jsObjectNameEscaped + "');" +
            "  }" +
            "})();"
        currentWebView.getUserContentController().addPluginScript(
            PluginScript(
                "WebMessageListener-$jsObjectName",
                source,
                UserScriptInjectionTime.AT_DOCUMENT_START,
                null,
                false,
                currentWebView.getCustomSettings().pluginScriptsOriginAllowList,
                currentWebView.getCustomSettings().pluginScriptsForMainFrameOnly == true
            )
        )
    }

    @Throws(Exception::class)
    open fun assertOriginRulesValid() {
        var index = 0
        for (originRule in allowedOriginRules) {
            if (originRule.isEmpty()) {
                throw Exception("allowedOriginRules[$index] is empty")
            }
            if (originRule == "*") {
                index++
                continue
            }
            val url = Uri.parse(originRule)
            val scheme = url.getScheme()
            val host = url.getHost()
            val path = url.getPath()
            val port = url.getPort()
            if (scheme == null) {
                throw Exception("allowedOriginRules $originRule is invalid")
            }
            if ((scheme == "http" || scheme == "https") && host.isNullOrEmpty()) {
                throw Exception("allowedOriginRules $originRule is invalid")
            }
            if (scheme != "http" && scheme != "https" && (host != null || port != -1)) {
                throw Exception("allowedOriginRules $originRule is invalid")
            }
            if (host.isNullOrEmpty() && port != -1) {
                throw Exception("allowedOriginRules $originRule is invalid")
            }
            if (!path.isNullOrEmpty()) {
                throw Exception("allowedOriginRules $originRule is invalid")
            }
            if (host != null) {
                val distance = host.indexOf("*")
                if (distance != 0 || (distance == 0 && !host.startsWith("*."))) {
                    throw Exception("allowedOriginRules $originRule is invalid")
                }
                if (host.startsWith("[")) {
                    if (!host.endsWith("]")) {
                        throw Exception("allowedOriginRules $originRule is invalid")
                    }
                    val ipv6 = host.substring(1, host.length - 1)
                    if (!Util.isIPv6(ipv6)) {
                        throw Exception("allowedOriginRules $originRule is invalid")
                    }
                }
            }
            index++
        }
    }

    open fun postMessageForInAppWebView(message: WebMessageCompatExt, result: MethodChannel.Result) {
        val currentReplyProxy = replyProxy
        if (currentReplyProxy != null && WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_LISTENER)) {
            val data = message.data
            if (data != null) {
                if (
                    WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
                    message.type == WebMessageCompat.TYPE_ARRAY_BUFFER
                ) {
                    val arrayBuffer = data as? ByteArray
                        ?: throw IllegalArgumentException("Web message array buffer data is invalid.")
                    currentReplyProxy.postMessage(arrayBuffer)
                } else {
                    currentReplyProxy.postMessage(data.toString())
                }
            }
        }
        result.success(true)
    }

    open fun isOriginAllowed(scheme: String?, host: String?, port: Int): Boolean {
        for (allowedOriginRule in allowedOriginRules) {
            if (allowedOriginRule == "*") return true
            if (scheme.isNullOrEmpty()) continue
            if (scheme.isNullOrEmpty() && host.isNullOrEmpty() && (port == 0 || port == -1)) continue

            val rule = Uri.parse(allowedOriginRule)
            val rulePort = if (rule.getPort() == -1 || rule.getPort() == 0) {
                if (rule.getScheme() == "https") 443 else 80
            } else {
                rule.getPort()
            }
            val currentPort = if (port == 0 || port == -1) {
                if (scheme == "https") 443 else 80
            } else {
                port
            }
            val ruleHost = rule.getHost()
            val ipv6 = if (ruleHost?.startsWith("[") == true) {
                try {
                    Util.normalizeIPv6(ruleHost.substring(1, ruleHost.length - 1))
                } catch (_: Exception) {
                    null
                }
            } else {
                null
            }
            val hostIpv6 = try {
                host?.let { Util.normalizeIPv6(it) }
            } catch (_: Exception) {
                null
            }

            val schemeAllowed = rule.getScheme() == scheme
            val hostAllowed = ruleHost.isNullOrEmpty() ||
                ruleHost == host ||
                (ruleHost.startsWith("*") && host != null && host.contains(ruleHost.substringAfter("*"))) ||
                (hostIpv6 != null && ipv6 != null && hostIpv6 == ipv6)
            val portAllowed = rulePort == currentPort
            if (schemeAllowed && hostAllowed && portAllowed) return true
        }
        return false
    }

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null
        listener = null
        replyProxy = null
        webView = null
    }
}
