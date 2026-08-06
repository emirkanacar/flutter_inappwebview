package com.emirkanacar.flutter_inappwebview_forge_android

import android.webkit.ValueCallback
import android.webkit.WebStorage
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap

class MyWebStorage(plugin: InAppWebViewFlutterPlugin) :
    ChannelDelegateImpl(MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME)) {

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = plugin

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        init()

        when (call.method) {
            "getOrigins" -> getOrigins(result)
            "deleteAllData" -> {
                val manager = webStorageManager
                if (manager != null) {
                    manager.deleteAllData()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "deleteOrigin" -> {
                val manager = webStorageManager
                if (manager != null) {
                    val origin = call.argument<String>("origin")
                    if (origin == null) {
                        result.error("invalid_arguments", "The 'origin' argument is required.", null)
                        return
                    }
                    manager.deleteOrigin(origin)
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "getQuotaForOrigin" -> {
                val origin = call.argument<String>("origin")
                if (origin == null) {
                    result.error("invalid_arguments", "The 'origin' argument is required.", null)
                } else {
                    getQuotaForOrigin(origin, result)
                }
            }
            "getUsageForOrigin" -> {
                val origin = call.argument<String>("origin")
                if (origin == null) {
                    result.error("invalid_arguments", "The 'origin' argument is required.", null)
                } else {
                    getUsageForOrigin(origin, result)
                }
            }
            else -> result.notImplemented()
        }
    }

    fun getOrigins(result: MethodChannel.Result) {
        val manager = webStorageManager
        if (manager == null) {
            result.success(ArrayList<Any>())
            return
        }

        manager.getOrigins(object : ValueCallback<Map<*, *>> {
            override fun onReceiveValue(value: Map<*, *>?) {
                val origins = ArrayList<Map<String, Any?>>()
                value?.keys?.forEach { key ->
                    val originObject = value[key] as WebStorage.Origin
                    val originInfo = HashMap<String, Any?>()
                    originInfo["origin"] = originObject.origin
                    originInfo["quota"] = originObject.quota
                    originInfo["usage"] = originObject.usage
                    origins.add(originInfo)
                }
                result.success(origins)
            }
        })
    }

    fun getQuotaForOrigin(origin: String, result: MethodChannel.Result) {
        val manager = webStorageManager
        if (manager == null) {
            result.success(0)
            return
        }
        manager.getQuotaForOrigin(origin, object : ValueCallback<Long> {
            override fun onReceiveValue(value: Long?) {
                result.success(value)
            }
        })
    }

    fun getUsageForOrigin(origin: String, result: MethodChannel.Result) {
        val manager = webStorageManager
        if (manager == null) {
            result.success(0)
            return
        }
        manager.getUsageForOrigin(origin, object : ValueCallback<Long> {
            override fun onReceiveValue(value: Long?) {
                result.success(value)
            }
        })
    }

    override fun dispose() {
        super.dispose()
        plugin = null
    }

    companion object {
        private const val LOG_TAG = "MyWebStorage"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappwebview_webstoragemanager"

        @JvmField
        var webStorageManager: WebStorage? = null

        @JvmStatic
        fun init() {
            if (webStorageManager == null) {
                webStorageManager = WebStorage.getInstance()
            }
        }
    }
}
