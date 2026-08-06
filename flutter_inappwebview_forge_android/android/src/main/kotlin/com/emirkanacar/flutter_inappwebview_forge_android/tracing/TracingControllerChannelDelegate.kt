package com.emirkanacar.flutter_inappwebview_forge_android.tracing

import androidx.webkit.TracingConfig
import androidx.webkit.TracingController
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.FileNotFoundException
import java.io.FileOutputStream
import java.util.HashMap
import java.util.concurrent.Executors

open class TracingControllerChannelDelegate(
    private var tracingControllerManager: TracingControllerManager?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        TracingControllerManager.init()
        val tracingController: TracingController? = TracingControllerManager.tracingController

        when (call.method) {
            "isTracing" -> result.success(tracingController?.isTracing() ?: false)
            "start" -> {
                if (tracingController != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
                ) {
                    val settingsMap = call.argument<MutableMap<String, Any?>>("settings") ?: mutableMapOf()
                    val settings = TracingSettings().parse(settingsMap)
                    val config: TracingConfig = TracingControllerManager.buildTracingConfig(settings)
                    tracingController.start(config)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "stop" -> {
                if (tracingController != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.TRACING_CONTROLLER_BASIC_USAGE)
                ) {
                    val filePath = call.argument<String>("filePath")
                    try {
                        result.success(
                            tracingController.stop(
                                filePath?.let { FileOutputStream(it) },
                                Executors.newSingleThreadExecutor()
                            )
                        )
                    } catch (error: FileNotFoundException) {
                        error.printStackTrace()
                        result.success(false)
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
        tracingControllerManager = null
    }
}
