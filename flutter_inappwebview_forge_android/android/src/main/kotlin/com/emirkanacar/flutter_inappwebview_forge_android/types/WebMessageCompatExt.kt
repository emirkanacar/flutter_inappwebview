package com.emirkanacar.flutter_inappwebview_forge_android.types

import androidx.webkit.WebMessageCompat
import androidx.webkit.WebViewFeature
import java.util.HashMap

open class WebMessageCompatExt(
    open var data: Any?,
    open var type: Int,
    open var ports: MutableList<WebMessagePortCompatExt>?
) {
    companion object {
        @JvmStatic
        fun fromMapWebMessageCompat(message: WebMessageCompat): WebMessageCompatExt {
            val data = if (
                WebViewFeature.isFeatureSupported(WebViewFeature.WEB_MESSAGE_ARRAY_BUFFER) &&
                message.getType() == WebMessageCompat.TYPE_ARRAY_BUFFER
            ) {
                message.getArrayBuffer()
            } else {
                message.getData()
            }
            return WebMessageCompatExt(data, message.getType(), null)
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): WebMessageCompatExt? {
            if (map == null) return null

            val type = (map["type"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Web message type is required.")
            val portMaps = map["ports"] as? List<*>
            val ports = if (portMaps.isNullOrEmpty()) {
                null
            } else {
                portMaps.mapIndexed { index, value ->
                    val portMap = value as? Map<*, *>
                        ?: throw IllegalArgumentException("Web message port at index $index is invalid.")
                    val stringMap = mutableMapOf<String, Any?>()
                    for ((key, item) in portMap) {
                        val stringKey = key as? String
                            ?: throw IllegalArgumentException("Web message port key at index $index is invalid.")
                        stringMap[stringKey] = item
                    }
                    WebMessagePortCompatExt.fromMap(stringMap)
                        ?: throw IllegalArgumentException("Web message port at index $index is invalid.")
                }.toMutableList()
            }
            return WebMessageCompatExt(map["data"], type, ports)
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("data", data)
        put("type", type)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as WebMessageCompatExt
        return data == other.data && type == other.type && ports == other.ports
    }

    open override fun hashCode(): Int {
        var result = data?.hashCode() ?: 0
        result = 31 * result + type
        result = 31 * result + (ports?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "WebMessageCompatExt{" +
            "data=$data, " +
            "type=$type, " +
            "ports=$ports}"
}
