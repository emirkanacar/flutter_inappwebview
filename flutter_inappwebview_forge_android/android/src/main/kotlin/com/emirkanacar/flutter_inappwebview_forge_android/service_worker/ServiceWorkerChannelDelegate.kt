package com.emirkanacar.flutter_inappwebview_forge_android.service_worker

import android.os.Build
import android.util.Log
import android.webkit.WebResourceRequest
import android.webkit.WebResourceResponse
import androidx.annotation.RequiresApi
import androidx.webkit.ServiceWorkerControllerCompat
import androidx.webkit.ServiceWorkerWebSettingsCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.types.BaseCallbackResultImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.SyncBaseCallbackResultImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceRequestExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.WebResourceResponseExt
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

private fun stringKeyedMap(value: Any?): MutableMap<String, Any?>? {
    val source = value as? Map<*, *> ?: return null
    val result = mutableMapOf<String, Any?>()
    for ((key, item) in source) {
        val stringKey = key as? String ?: return null
        result[stringKey] = item
    }
    return result
}

@RequiresApi(api = Build.VERSION_CODES.N)
open class ServiceWorkerChannelDelegate(
    private var serviceWorkerManager: ServiceWorkerManager?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        ServiceWorkerManager.init()
        val serviceWorkerController: ServiceWorkerControllerCompat? = ServiceWorkerManager.serviceWorkerController
        val serviceWorkerWebSettings: ServiceWorkerWebSettingsCompat? =
            serviceWorkerController?.serviceWorkerWebSettings

        when (call.method) {
            "setServiceWorkerClient" -> {
                val manager = serviceWorkerManager
                val isNull = call.argument<Boolean>("isNull")
                if (manager == null) {
                    result.success(false)
                } else if (isNull == null) {
                    result.error("invalid_arguments", "isNull is required.", null)
                } else {
                    manager.setServiceWorkerClient(isNull)
                    result.success(true)
                }
            }
            "getAllowContentAccess" -> {
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)
                ) {
                    result.success(serviceWorkerWebSettings.allowContentAccess)
                } else {
                    result.success(false)
                }
            }
            "getAllowFileAccess" -> {
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)
                ) {
                    result.success(serviceWorkerWebSettings.allowFileAccess)
                } else {
                    result.success(false)
                }
            }
            "getBlockNetworkLoads" -> {
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)
                ) {
                    result.success(serviceWorkerWebSettings.blockNetworkLoads)
                } else {
                    result.success(false)
                }
            }
            "getCacheMode" -> {
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)
                ) {
                    result.success(serviceWorkerWebSettings.cacheMode)
                } else {
                    result.success(null)
                }
            }
            "setAllowContentAccess" -> {
                val allow = call.argument<Boolean>("allow")
                if (allow == null) {
                    result.error("invalid_arguments", "allow is required.", null)
                    return
                }
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CONTENT_ACCESS)
                ) {
                    serviceWorkerWebSettings.allowContentAccess = allow
                }
                result.success(true)
            }
            "setAllowFileAccess" -> {
                val allow = call.argument<Boolean>("allow")
                if (allow == null) {
                    result.error("invalid_arguments", "allow is required.", null)
                    return
                }
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_FILE_ACCESS)
                ) {
                    serviceWorkerWebSettings.allowFileAccess = allow
                }
                result.success(true)
            }
            "setBlockNetworkLoads" -> {
                val flag = call.argument<Boolean>("flag")
                if (flag == null) {
                    result.error("invalid_arguments", "flag is required.", null)
                    return
                }
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_BLOCK_NETWORK_LOADS)
                ) {
                    serviceWorkerWebSettings.blockNetworkLoads = flag
                }
                result.success(true)
            }
            "setCacheMode" -> {
                val mode = call.argument<Int>("mode")
                if (mode == null) {
                    result.error("invalid_arguments", "mode is required.", null)
                    return
                }
                if (serviceWorkerWebSettings != null &&
                    WebViewFeature.isFeatureSupported(WebViewFeature.SERVICE_WORKER_CACHE_MODE)
                ) {
                    serviceWorkerWebSettings.cacheMode = mode
                }
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    class ShouldInterceptRequestCallback : BaseCallbackResultImpl<WebResourceResponseExt>() {
        override fun decodeResult(obj: Any?): WebResourceResponseExt? =
            WebResourceResponseExt.fromMap(stringKeyedMap(obj))
    }

    fun shouldInterceptRequest(request: WebResourceRequestExt, callback: ShouldInterceptRequestCallback) {
        val channel = getChannel() ?: return
        channel.invokeMethod("shouldInterceptRequest", request.toMap(), callback)
    }

    class SyncShouldInterceptRequestCallback : SyncBaseCallbackResultImpl<WebResourceResponseExt>() {
        override fun decodeResult(obj: Any?): WebResourceResponseExt? =
            ShouldInterceptRequestCallback().decodeResult(obj)
    }

    @Throws(InterruptedException::class)
    fun shouldInterceptRequest(request: WebResourceRequestExt): WebResourceResponseExt? {
        val channel = getChannel() ?: return null
        val callback = SyncShouldInterceptRequestCallback()
        return Util.invokeMethodAndWaitResult(channel, "shouldInterceptRequest", request.toMap(), callback)
    }

    override fun dispose() {
        super.dispose()
        serviceWorkerManager = null
    }
}
