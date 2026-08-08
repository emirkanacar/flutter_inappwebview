package com.emirkanacar.flutter_inappwebview_forge_android.chrome_custom_tabs

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import androidx.browser.customtabs.CustomTabsClient
import androidx.browser.customtabs.CustomTabsIntent
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap
import java.util.UUID

open class ChromeSafariBrowserManager(
    initialPlugin: InAppWebViewFlutterPlugin
) : ChannelDelegateImpl(
    MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)
) {
    companion object {
        @JvmField
        protected val LOG_TAG = "ChromeBrowserManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirakanacar/flutter_chromesafaribrowser"

        @JvmField
        val shared: MutableMap<String, ChromeSafariBrowserManager> = HashMap()
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    @JvmField
    var id: String = UUID.randomUUID().toString()

    @JvmField
    val browsers: MutableMap<String, ChromeCustomTabsActivity?> = HashMap()

    init {
        shared[id] = this
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val viewId = call.argument<String>("id")

        when (call.method) {
            "open" -> {
                val activity = plugin?.activity
                if (activity == null) {
                    result.success(false)
                    return
                }

                val url = call.argument<String>("url")
                val headers = call.argument<HashMap<String, Any?>>("headers")
                val referrer = call.argument<String>("referrer")
                val otherLikelyURLs = call.argument<ArrayList<String>>("otherLikelyURLs")
                val settings = call.argument<HashMap<String, Any?>>("settings") ?: hashMapOf()
                val actionButton = call.argument<HashMap<String, Any?>>("actionButton")
                val secondaryToolbar = call.argument<HashMap<String, Any?>>("secondaryToolbar")
                val menuItemList = call.argument<List<HashMap<String, Any?>>>("menuItemList")
                open(
                    activity,
                    viewId,
                    url,
                    headers,
                    referrer,
                    otherLikelyURLs,
                    settings,
                    actionButton,
                    secondaryToolbar,
                    menuItemList,
                    result
                )
            }

            "isAvailable" -> {
                val activity = plugin?.activity
                result.success(activity != null && CustomTabActivityHelper.isAvailable(activity))
            }

            "getMaxToolbarItems" -> result.success(CustomTabsIntent.getMaxToolbarItems())

            "getPackageName" -> {
                val activity = plugin?.activity
                if (activity == null) {
                    result.success(null)
                    return
                }
                val packages = call.argument<ArrayList<String>>("packages")
                val ignoreDefault = call.argument<Boolean>("ignoreDefault")
                result.success(
                    CustomTabsClient.getPackageName(activity, packages, ignoreDefault ?: false)
                )
            }

            else -> result.notImplemented()
        }
    }

    fun open(
        activity: Activity,
        viewId: String?,
        url: String?,
        headers: HashMap<String, Any?>?,
        referrer: String?,
        otherLikelyURLs: ArrayList<String>?,
        settings: HashMap<String, Any?>?,
        actionButton: HashMap<String, Any?>?,
        secondaryToolbar: HashMap<String, Any?>?,
        menuItemList: List<HashMap<String, Any?>>?,
        result: MethodChannel.Result
    ) {
        val extras = Bundle().apply {
            putString("url", url)
            putString("id", viewId)
            putString("managerId", id)
            Util.putValueExtra(this, "headers", headers)
            putString("referrer", referrer)
            Util.putValueExtra(this, "otherLikelyURLs", otherLikelyURLs)
            Util.putValueExtra(this, "settings", settings)
            Util.putValueExtra(this, "actionButton", actionButton)
            Util.putValueExtra(this, "secondaryToolbar", secondaryToolbar)
            Util.putValueExtra(this, "menuItemList", menuItemList)
        }

        val actualSettings = settings ?: hashMapOf()
        val isSingleInstance =
            Util.getOrDefault(actualSettings, "isSingleInstance", false) == true
        val isTrustedWebActivity =
            Util.getOrDefault(actualSettings, "isTrustedWebActivity", false) == true

        if (!CustomTabActivityHelper.isAvailable(activity)) {
            result.error(LOG_TAG, "ChromeCustomTabs is not available!", null)
            return
        }

        val activityClass = when {
            isSingleInstance && isTrustedWebActivity -> TrustedWebActivitySingleInstance::class.java
            isSingleInstance -> ChromeCustomTabsActivitySingleInstance::class.java
            isTrustedWebActivity -> TrustedWebActivity::class.java
            else -> ChromeCustomTabsActivity::class.java
        }
        val intent = Intent(activity, activityClass).apply {
            putExtras(extras)
            if (Util.getOrDefault(actualSettings, "noHistory", false) == true) {
                addFlags(Intent.FLAG_ACTIVITY_NO_HISTORY)
            }
        }
        activity.startActivity(intent)
        result.success(true)
    }

    override fun dispose() {
        super.dispose()
        browsers.values.forEach { browser ->
            browser?.close()
            browser?.dispose()
        }
        browsers.clear()
        shared.remove(id)
        plugin = null
    }
}
