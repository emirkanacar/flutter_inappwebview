@file:Suppress("DEPRECATION")

package com.emirkanacar.flutter_inappwebview_forge_android.webview

import android.content.Context
import android.content.pm.PackageInfo
import android.os.Build
import android.os.Message
import android.view.View
import android.view.ViewGroup
import android.webkit.ValueCallback
import android.webkit.WebSettings
import android.webkit.WebView
import androidx.webkit.WebViewCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.plugin_scripts_js.JavaScriptBridgeJS
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.FlutterWebView
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap
import java.util.HashSet

class InAppWebViewManager(initialPlugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(
        MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)
    ) {
    companion object {
        @JvmField
        protected val LOG_TAG = "InAppWebViewManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_manager"
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    @JvmField
    val keepAliveWebViews: MutableMap<String, FlutterWebView?> = HashMap()

    @JvmField
    val windowWebViewMessages: MutableMap<Int, Message> = HashMap()

    @JvmField
    var windowAutoincrementId: Int = 0

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "getDefaultUserAgent" -> {
                result.success(plugin?.applicationContext?.let { WebSettings.getDefaultUserAgent(it) })
            }

            "clearClientCertPreferences" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    WebView.clearClientCertPreferences {
                        result.success(true)
                    }
                } else {
                    result.success(false)
                }
            }

            "getSafeBrowsingPrivacyPolicyUrl" -> {
                if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_PRIVACY_POLICY_URL)) {
                    result.success(WebViewCompat.getSafeBrowsingPrivacyPolicyUrl()?.toString())
                } else {
                    result.success(null)
                }
            }

            "setSafeBrowsingAllowlist" -> {
                val hosts = call.argument<List<String>>("hosts").orEmpty()
                if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_ALLOWLIST)) {
                    WebViewCompat.setSafeBrowsingAllowlist(
                        HashSet(hosts),
                        ValueCallback { value -> result.success(value) }
                    )
                } else if (WebViewFeature.isFeatureSupported(WebViewFeature.SAFE_BROWSING_WHITELIST)) {
                    WebViewCompat.setSafeBrowsingWhitelist(
                        hosts,
                        ValueCallback { value -> result.success(value) }
                    )
                } else {
                    result.success(false)
                }
            }

            "getCurrentWebViewPackage" -> {
                val context = plugin?.activity ?: plugin?.applicationContext
                val packageInfo = context?.let { WebViewCompat.getCurrentWebViewPackage(it) }
                result.success(packageInfo?.let { convertWebViewPackageToMap(it) })
            }

            "setWebContentsDebuggingEnabled" -> {
                val debuggingEnabled = call.argument<Boolean>("debuggingEnabled") == true
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
                    WebView.setWebContentsDebuggingEnabled(debuggingEnabled)
                }
                result.success(true)
            }

            "getVariationsHeader" -> {
                if (WebViewFeature.isFeatureSupported(WebViewFeature.GET_VARIATIONS_HEADER)) {
                    result.success(WebViewCompat.getVariationsHeader())
                } else {
                    result.success(null)
                }
            }

            "isMultiProcessEnabled" -> {
                if (WebViewFeature.isFeatureSupported(WebViewFeature.MULTI_PROCESS)) {
                    result.success(WebViewCompat.isMultiProcessEnabled())
                } else {
                    result.success(false)
                }
            }

            "disableWebView" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    WebView.disableWebView()
                }
                result.success(true)
            }

            "disposeKeepAlive" -> {
                call.argument<String>("keepAliveId")?.let { disposeKeepAlive(it) }
                result.success(true)
            }

            "clearAllCache" -> {
                val context = plugin?.activity ?: plugin?.applicationContext
                if (context != null) {
                    clearAllCache(
                        context,
                        call.argument<Boolean>("includeDiskFiles") == true
                    )
                }
                result.success(true)
            }

            "enableSlowWholeDocumentDraw" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                    WebView.enableSlowWholeDocumentDraw()
                }
                result.success(true)
            }

            "setJavaScriptBridgeName" -> {
                call.argument<String>("bridgeName")?.let {
                    JavaScriptBridgeJS.set_JAVASCRIPT_BRIDGE_NAME(it)
                }
                result.success(true)
            }

            "getJavaScriptBridgeName" -> {
                result.success(JavaScriptBridgeJS.get_JAVASCRIPT_BRIDGE_NAME())
            }

            else -> result.notImplemented()
        }
    }

    fun convertWebViewPackageToMap(webViewPackageInfo: PackageInfo): MutableMap<String, Any?> {
        return HashMap<String, Any?>().apply {
            put("versionName", webViewPackageInfo.versionName)
            put("packageName", webViewPackageInfo.packageName)
        }
    }

    fun disposeKeepAlive(keepAliveId: String) {
        val flutterWebView = keepAliveWebViews[keepAliveId]
        if (flutterWebView != null) {
            flutterWebView.keepAliveId = null
            val view: View? = flutterWebView.view
            val parent = view?.parent as? ViewGroup
            parent?.removeView(view)
            flutterWebView.dispose()
        }
        if (keepAliveWebViews.containsKey(keepAliveId)) {
            keepAliveWebViews[keepAliveId] = null
        }
    }

    fun clearAllCache(context: Context, includeDiskFiles: Boolean) {
        val tempWebView = WebView(context)
        tempWebView.clearCache(includeDiskFiles)
        tempWebView.destroy()
    }

    override fun dispose() {
        super.dispose()
        keepAliveWebViews.values.forEach { flutterWebView ->
            val keepAliveId = flutterWebView?.keepAliveId
            if (keepAliveId != null) {
                disposeKeepAlive(keepAliveId)
            }
        }
        keepAliveWebViews.clear()
        windowWebViewMessages.clear()
        plugin = null
    }
}
