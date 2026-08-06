package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.content.Context
import android.os.Build
import android.util.Log
import android.webkit.WebResourceResponse
import androidx.webkit.WebViewAssetLoader
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayInputStream
import java.io.File
import java.util.HashMap

open class WebViewAssetLoaderExt(
    @JvmField var loader: WebViewAssetLoader?,
    @JvmField val customPathHandlers: MutableList<PathHandlerExt>
) : Disposable {
    companion object {
        @JvmStatic
        fun fromMap(
            map: MutableMap<String, Any?>?,
            plugin: InAppWebViewFlutterPlugin,
            context: Context
        ): WebViewAssetLoaderExt? {
            if (map == null) {
                return null
            }

            val builder = WebViewAssetLoader.Builder()
            val domain = map["domain"] as? String
            val httpAllowed = map["httpAllowed"] as? Boolean
            val customPathHandlers = mutableListOf<PathHandlerExt>()
            if (!domain.isNullOrEmpty()) {
                builder.setDomain(domain)
            }
            if (httpAllowed != null) {
                builder.setHttpAllowed(httpAllowed)
            }

            val pathHandlers = map["pathHandlers"] as? List<*>
            pathHandlers?.forEach { rawPathHandler ->
                val pathHandler = stringKeyedMap(rawPathHandler) ?: return@forEach
                val type = pathHandler["type"] as? String ?: return@forEach
                val path = pathHandler["path"] as? String ?: return@forEach
                when (type) {
                    "AssetsPathHandler" -> {
                        builder.addPathHandler(
                            path,
                            WebViewAssetLoader.AssetsPathHandler(context)
                        )
                    }
                    "InternalStoragePathHandler" -> {
                        val directory = pathHandler["directory"] as? String ?: return@forEach
                        builder.addPathHandler(
                            path,
                            WebViewAssetLoader.InternalStoragePathHandler(context, File(directory))
                        )
                    }
                    "ResourcesPathHandler" -> {
                        builder.addPathHandler(
                            path,
                            WebViewAssetLoader.ResourcesPathHandler(context)
                        )
                    }
                    else -> {
                        val id = pathHandler["id"] as? String ?: return@forEach
                        val customPathHandler = PathHandlerExt(id, plugin)
                        builder.addPathHandler(path, customPathHandler)
                        customPathHandlers.add(customPathHandler)
                    }
                }
            }

            return WebViewAssetLoaderExt(builder.build(), customPathHandlers)
        }
    }

    override fun dispose() {
        customPathHandlers.forEach { it.dispose() }
        customPathHandlers.clear()
    }

    open class PathHandlerExt(
        @JvmField var id: String,
        plugin: InAppWebViewFlutterPlugin
    ) : WebViewAssetLoader.PathHandler, Disposable {
        companion object {
            @JvmField
            protected val LOG_TAG = "PathHandlerExt"

            @JvmField
            val METHOD_CHANNEL_NAME_PREFIX =
                "com.emirkanacar/flutter_inappwebview_custompathhandler_"
        }

        @JvmField
        var channelDelegate: PathHandlerExtChannelDelegate? = null

        init {
            val channel = MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME_PREFIX + id)
            channelDelegate = PathHandlerExtChannelDelegate(this, channel)
        }

        override fun handle(path: String): WebResourceResponse? {
            val response = try {
                channelDelegate?.handle(path)
            } catch (error: InterruptedException) {
                Log.e(LOG_TAG, "", error)
                return null
            } ?: return null

            val inputStream = response.data?.let { ByteArrayInputStream(it) }
            val statusCode = response.statusCode
            val reasonPhrase = response.reasonPhrase
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP &&
                statusCode != null && reasonPhrase != null
            ) {
                WebResourceResponse(
                    response.contentType,
                    response.contentEncoding,
                    statusCode,
                    reasonPhrase,
                    response.headers,
                    inputStream
                )
            } else {
                WebResourceResponse(response.contentType, response.contentEncoding, inputStream)
            }
        }

        override fun dispose() {
            channelDelegate?.dispose()
            channelDelegate = null
        }
    }

    open class PathHandlerExtChannelDelegate(
        private var pathHandler: PathHandlerExt?,
        channel: MethodChannel
    ) : ChannelDelegateImpl(channel) {
        class HandleCallback : BaseCallbackResultImpl<WebResourceResponseExt>() {
            override fun decodeResult(obj: Any?): WebResourceResponseExt? =
                WebResourceResponseExt.fromMap(stringKeyedMap(obj))
        }

        fun handle(path: String, callback: HandleCallback) {
            val channel = getChannel() ?: return
            val obj = HashMap<String, Any?>()
            obj["path"] = path
            channel.invokeMethod("handle", obj, callback)
        }

        class SyncHandleCallback : SyncBaseCallbackResultImpl<WebResourceResponseExt>() {
            override fun decodeResult(obj: Any?): WebResourceResponseExt? =
                HandleCallback().decodeResult(obj)
        }

        @Throws(InterruptedException::class)
        fun handle(path: String): WebResourceResponseExt? {
            val channel = getChannel() ?: return null
            val callback = SyncHandleCallback()
            val obj = HashMap<String, Any?>()
            obj["path"] = path
            return Util.invokeMethodAndWaitResult(channel, "handle", obj, callback)
        }

        override fun dispose() {
            super.dispose()
            pathHandler = null
        }
    }
}

private fun stringKeyedMap(value: Any?): MutableMap<String, Any?>? {
    val source = value as? Map<*, *> ?: return null
    val result = mutableMapOf<String, Any?>()
    for ((key, item) in source) {
        val stringKey = key as? String ?: return null
        result[stringKey] = item
    }
    return result
}
