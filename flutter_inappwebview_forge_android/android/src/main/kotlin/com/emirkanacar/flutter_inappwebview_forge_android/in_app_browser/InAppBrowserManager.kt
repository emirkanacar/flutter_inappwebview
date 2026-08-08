package com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.os.Parcelable
import android.provider.Browser
import android.util.Log
import android.webkit.MimeTypeMap
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.ArrayList
import java.util.HashMap
import java.util.UUID

open class InAppBrowserManager(
    initialPlugin: InAppWebViewFlutterPlugin
) : ChannelDelegateImpl(
    MethodChannel(initialPlugin.requireMessenger(), METHOD_CHANNEL_NAME)
) {
    companion object {
        @JvmField
        protected val LOG_TAG = "InAppBrowserManager"

        @JvmField
        val METHOD_CHANNEL_NAME = "com.emirkanacar/flutter_inappbrowser"

        @JvmField
        val shared: MutableMap<String, InAppBrowserManager> = HashMap()

        @JvmStatic
        fun getMimeType(url: String): String? {
            val extension = MimeTypeMap.getFileExtensionFromUrl(url)
            return extension?.let(MimeTypeMap.getSingleton()::getMimeTypeFromExtension)
        }
    }

    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = initialPlugin

    @JvmField
    var id: String = UUID.randomUUID().toString()

    init {
        shared[id] = this
    }

    @Suppress("UNCHECKED_CAST")
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "open" -> {
                val activity = plugin?.activity
                if (activity == null) {
                    result.success(false)
                    return
                }
                val arguments = call.arguments as? Map<String, Any?> ?: hashMapOf()
                open(activity, arguments)
                result.success(true)
            }

            "openWithSystemBrowser" -> {
                val activity = plugin?.activity
                if (activity == null) {
                    result.success(false)
                    return
                }
                openWithSystemBrowser(activity, call.argument<String>("url"), result)
            }

            else -> result.notImplemented()
        }
    }

    fun openWithSystemBrowser(
        activity: Activity,
        url: String?,
        result: MethodChannel.Result
    ) {
        val urlString = url
        if (urlString == null) {
            result.error(LOG_TAG, "URL is required!", null)
            return
        }

        try {
            val intent = Intent(Intent.ACTION_VIEW)
            // Omitting the MIME type for file: URLs causes "No Activity found to handle Intent".
            // Adding the MIME type to http: URLs causes them to not be handled by the downloader.
            val uri = Uri.parse(urlString)
            if (uri.scheme == "file") {
                intent.setDataAndType(uri, getMimeType(urlString))
            } else {
                intent.data = uri
            }
            intent.putExtra(Browser.EXTRA_APPLICATION_ID, activity.packageName)
            // CB-10795: Avoid circular loops by preventing it from opening in the current app.
            openExternalExcludeCurrentApp(activity, intent)
            result.success(true)
            // Do not catch FileUriExposedException explicitly because buildtools < 24
            // does not know about it.
        } catch (error: RuntimeException) {
            Log.d(LOG_TAG, "$urlString cannot be opened: $error")
            result.error(LOG_TAG, "$urlString cannot be opened!", null)
        }
    }

    fun openExternalExcludeCurrentApp(activity: Activity, intent: Intent) {
        val currentPackage = activity.packageName
        var hasCurrentPackage = false
        val packageManager: PackageManager = activity.packageManager
        val activities = packageManager.queryIntentActivities(intent, 0)
        val targetIntents = ArrayList<Intent>()

        for (resolveInfo in activities) {
            if (currentPackage != resolveInfo.activityInfo.packageName) {
                val targetIntent = Intent(intent)
                targetIntent.setPackage(resolveInfo.activityInfo.packageName)
                targetIntents.add(targetIntent)
            } else {
                hasCurrentPackage = true
            }
        }

        // If the current app package is not a target for this URL, use normal launch behavior.
        if (!hasCurrentPackage || targetIntents.isEmpty()) {
            activity.startActivity(intent)
        } else if (targetIntents.size == 1) {
            // If there is only one possible intent, launch it directly.
            activity.startActivity(targetIntents[0])
        } else {
            // Otherwise, show a custom chooser without the current app listed.
            val chooser = Intent.createChooser(targetIntents.removeAt(targetIntents.lastIndex), null)
            chooser.putExtra(
                Intent.EXTRA_INITIAL_INTENTS,
                targetIntents.map { it as Parcelable }.toTypedArray()
            )
            activity.startActivity(chooser)
        }
    }

    @Suppress("UNCHECKED_CAST")
    fun open(activity: Activity, arguments: Map<String, Any?>) {
        val id = arguments["id"] as? String
        val urlRequest = arguments["urlRequest"] as? Map<String, Any?>
        val assetFilePath = arguments["assetFilePath"] as? String
        val data = arguments["data"] as? String
        val mimeType = arguments["mimeType"] as? String
        val encoding = arguments["encoding"] as? String
        val baseUrl = arguments["baseUrl"] as? String
        val historyUrl = arguments["historyUrl"] as? String
        val settings = arguments["settings"] as? Map<String, Any?>
        val contextMenu = arguments["contextMenu"] as? Map<String, Any?>
        val windowId = (arguments["windowId"] as? Number)?.toInt() ?: -1
        val initialUserScripts = arguments["initialUserScripts"] as? List<Map<String, Any?>>
        val pullToRefreshInitialSettings =
            arguments["pullToRefreshSettings"] as? Map<String, Any?>
        val menuItems = arguments["menuItems"] as? List<Map<String, Any?>>

        val extras = Bundle().apply {
            putString("fromActivity", activity.javaClass.name)
            Util.putValueExtra(this, "initialUrlRequest", urlRequest)
            putString("initialFile", assetFilePath)
            putString("initialData", data)
            putString("initialMimeType", mimeType)
            putString("initialEncoding", encoding)
            putString("initialBaseUrl", baseUrl)
            putString("initialHistoryUrl", historyUrl)
            putString("id", id)
            putString("managerId", this@InAppBrowserManager.id)
            Util.putValueExtra(this, "settings", settings)
            Util.putValueExtra(this, "contextMenu", contextMenu)
            putInt("windowId", windowId)
            Util.putValueExtra(this, "initialUserScripts", initialUserScripts)
            Util.putValueExtra(this, "pullToRefreshInitialSettings", pullToRefreshInitialSettings)
            Util.putValueExtra(this, "menuItems", menuItems)
        }
        startInAppBrowserActivity(activity, extras)
    }

    fun startInAppBrowserActivity(activity: Activity, extras: Bundle?) {
        val intent = Intent(activity, InAppBrowserActivity::class.java)
        if (extras != null) {
            intent.putExtras(extras)
        }
        activity.startActivity(intent)
    }

    override fun dispose() {
        super.dispose()
        shared.remove(id)
        plugin = null
    }
}
