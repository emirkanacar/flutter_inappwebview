package com.emirkanacar.flutter_inappwebview_forge_android

import android.util.Log
import android.webkit.ValueCallback
import android.webkit.WebStorage
import androidx.webkit.WebStorageCompat
import androidx.webkit.WebViewFeature
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap
import java.util.concurrent.atomic.AtomicBoolean

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
            "deleteBrowsingData" -> deleteBrowsingData(result)
            "deleteBrowsingDataForSite" -> {
                val site = call.argument<String>("site")
                if (site.isNullOrBlank()) {
                    result.error("invalid_arguments", "The 'site' argument is required.", null)
                } else {
                    deleteBrowsingDataForSite(site, result)
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
                    val originObject = value[key] as? WebStorage.Origin ?: return@forEach
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

    /**
     * Deletes the complete browsing data set (cookies, cache, storage, service
     * workers) through AndroidX WebKit. Replies `false` when the installed
     * WebView provider does not expose [WebViewFeature.DELETE_BROWSING_DATA].
     * The completion runnable is posted by WebView on the main looper; the
     * reply is guarded so a provider that invokes it more than once cannot
     * reply twice on the same [MethodChannel.Result].
     */
    fun deleteBrowsingData(result: MethodChannel.Result) {
        val manager = webStorageManager
        if (manager == null || !WebViewFeature.isFeatureSupported(WebViewFeature.DELETE_BROWSING_DATA)) {
            result.success(false)
            return
        }
        val replied = AtomicBoolean(false)
        try {
            WebStorageCompat.deleteBrowsingData(manager) {
                if (replied.compareAndSet(false, true)) {
                    result.success(true)
                }
            }
        } catch (e: Exception) {
            Log.e(LOG_TAG, "deleteBrowsingData failed", e)
            if (replied.compareAndSet(false, true)) {
                result.error(LOG_TAG, e.message, null)
            }
        }
    }

    /**
     * Deletes the browsing data of the site (eTLD+1) that [site] belongs to.
     * Replies with the site WebView computed, or `null` when the provider does
     * not expose [WebViewFeature.DELETE_BROWSING_DATA].
     */
    fun deleteBrowsingDataForSite(site: String, result: MethodChannel.Result) {
        val manager = webStorageManager
        if (manager == null || !WebViewFeature.isFeatureSupported(WebViewFeature.DELETE_BROWSING_DATA)) {
            result.success(null)
            return
        }
        // Reply only after both the computed site is returned and the
        // completion runnable has run, whichever happens last, so the reply
        // never carries a site that has not been assigned yet.
        val replied = AtomicBoolean(false)
        val lock = Any()
        var deletedSite: String? = null
        var returned = false
        var completed = false
        fun replyIfReady() {
            val ready = synchronized(lock) { returned && completed }
            if (ready && replied.compareAndSet(false, true)) {
                result.success(synchronized(lock) { deletedSite })
            }
        }
        try {
            val computedSite = WebStorageCompat.deleteBrowsingDataForSite(manager, site) {
                synchronized(lock) { completed = true }
                replyIfReady()
            }
            synchronized(lock) {
                deletedSite = computedSite
                returned = true
            }
            replyIfReady()
        } catch (e: Exception) {
            Log.e(LOG_TAG, "deleteBrowsingDataForSite failed", e)
            if (replied.compareAndSet(false, true)) {
                result.error(LOG_TAG, e.message, null)
            }
        }
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
