package com.emirkanacar.flutter_inappwebview_forge_android

import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class WebViewFeatureManager(plugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME)) {

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = plugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isFeatureSupported" -> {
                val feature = call.argument<String>("feature")
                if (feature == null) {
                    result.error("invalid_arguments", "The 'feature' argument is required.", null)
                } else {
                    result.success(WebViewFeature.isFeatureSupported(feature))
                }
            }
            "isStartupFeatureSupported" -> {
                val activity = plugin?.activity
                if (activity == null) {
                    result.error("activity_unavailable", "An attached Activity is required.", null)
                    return
                }
                val startupFeature = call.argument<String>("startupFeature")
                if (startupFeature == null) {
                    result.error("invalid_arguments", "The 'startupFeature' argument is required.", null)
                } else {
                    result.success(WebViewFeature.isStartupFeatureSupported(activity, startupFeature))
                }
            }
            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }

    companion object {
        private const val LOG_TAG = "WebViewFeatureManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_webviewfeature"
    }
}
