package com.emirkanacar.flutter_inappwebview_forge_android.process_global_config

import androidx.webkit.ProcessGlobalConfig
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

open class ProcessGlobalConfigManager(
    initialPlugin: InAppWebViewFlutterPlugin
) : ChannelDelegateImpl(
    MethodChannel(
        initialPlugin.requireMessenger(),
        METHOD_CHANNEL_NAME
    )
) {
    companion object {
        @JvmField
        protected val LOG_TAG: String = "ProcessGlobalConfigM"

        @JvmField
        val METHOD_CHANNEL_NAME: String =
            "com.emirkanacar/flutter_inappwebview_processglobalconfig"
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "apply" -> {
                val currentPlugin = plugin
                val activity = currentPlugin?.activity
                if (currentPlugin != null && activity != null) {
                    val settings = ProcessGlobalConfigSettings().parse(
                        call.argument<MutableMap<String, Any?>>("settings") ?: mutableMapOf()
                    )
                    try {
                        ProcessGlobalConfig.apply(settings.toProcessGlobalConfig(activity))
                        result.success(true)
                    } catch (e: Exception) {
                        result.error(LOG_TAG, "", e)
                    }
                } else {
                    result.success(false)
                }
            }

            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }
}
