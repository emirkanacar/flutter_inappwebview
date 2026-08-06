package com.emirkanacar.flutter_inappwebview_forge_android.tracing

import androidx.webkit.TracingConfig
import androidx.webkit.TracingController
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import io.flutter.plugin.common.MethodChannel

open class TracingControllerManager(
    initialPlugin: InAppWebViewFlutterPlugin
) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG = "TracingControllerMan"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_tracingcontroller"

        @JvmField
        var tracingController: TracingController? = null

        @JvmStatic
        fun init() {
            if (tracingController == null &&
                WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
            ) {
                tracingController = TracingController.getInstance()
            }
        }

        @JvmStatic
        fun buildTracingConfig(settings: TracingSettings): TracingConfig {
            val builder = TracingConfig.Builder()
            settings.categories.forEach { category ->
                when (category) {
                    is String -> builder.addCategories(category)
                    is Int -> builder.addCategories(category)
                }
            }
            settings.tracingMode?.let { builder.setTracingMode(it) }
            return builder.build()
        }
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    @JvmField
    var channelDelegate: TracingControllerChannelDelegate? = null

    init {
        val channel = MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)
        channelDelegate = TracingControllerChannelDelegate(this, channel)
    }

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null
        plugin = null
    }
}
