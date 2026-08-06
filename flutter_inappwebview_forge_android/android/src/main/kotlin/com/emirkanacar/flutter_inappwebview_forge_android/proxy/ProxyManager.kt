package com.emirkanacar.flutter_inappwebview_forge_android.proxy

import androidx.webkit.ProxyConfig
import androidx.webkit.ProxyController
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executor

open class ProxyManager(initialPlugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)) {
    companion object {
        @JvmField
        protected val LOG_TAG = "ProxyManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_proxycontroller"

        @JvmField
        var proxyController: ProxyController? = null

        @JvmStatic
        fun init() {
            if (proxyController == null &&
                WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE)
            ) {
                proxyController = ProxyController.getInstance()
            }
        }
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        init()
        when (call.method) {
            "setProxyOverride" -> {
                val controller = proxyController
                if (controller == null) {
                    result.success(false)
                } else {
                    val settings = ProxySettings().parse(
                        call.argument<MutableMap<String, Any?>>("settings") ?: mutableMapOf()
                    )
                    setProxyOverride(controller, settings, result)
                }
            }
            "clearProxyOverride" -> {
                val controller = proxyController
                if (controller == null) {
                    result.success(false)
                } else {
                    clearProxyOverride(controller, result)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun setProxyOverride(
        controller: ProxyController,
        settings: ProxySettings,
        result: MethodChannel.Result
    ) {
        val builder = ProxyConfig.Builder()
        settings.bypassRules.forEach { builder.addBypassRule(it) }
        settings.directs.forEach { builder.addDirect(it) }
        settings.proxyRules.forEach { proxyRule ->
            val schemeFilter = proxyRule.schemeFilter
            if (schemeFilter != null) {
                builder.addProxyRule(proxyRule.url, schemeFilter)
            } else {
                builder.addProxyRule(proxyRule.url)
            }
        }
        if (settings.bypassSimpleHostnames == true) {
            builder.bypassSimpleHostnames()
        }
        if (settings.removeImplicitRules == true) {
            builder.removeImplicitRules()
        }
        if (settings.reverseBypassEnabled != null &&
            WebViewFeature.isFeatureSupported(WebViewFeature.PROXY_OVERRIDE_REVERSE_BYPASS)
        ) {
            builder.setReverseBypassEnabled(settings.reverseBypassEnabled == true)
        }
        controller.setProxyOverride(
            builder.build(),
            Executor { command -> command.run() },
            Runnable { result.success(true) }
        )
    }

    private fun clearProxyOverride(controller: ProxyController, result: MethodChannel.Result) {
        controller.clearProxyOverride(
            Executor { command -> command.run() },
            Runnable { result.success(true) }
        )
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }
}
