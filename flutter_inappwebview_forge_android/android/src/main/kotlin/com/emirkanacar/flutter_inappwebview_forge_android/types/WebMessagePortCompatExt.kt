package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class WebMessagePortCompatExt(
    open var index: Int,
    open var webMessageChannelId: String
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): WebMessagePortCompatExt? {
            if (map == null) return null

            val index = (map["index"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Web message port index is required.")
            val webMessageChannelId = map["webMessageChannelId"] as? String
                ?: throw IllegalArgumentException("Web message channel id is required.")
            return WebMessagePortCompatExt(index, webMessageChannelId)
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("index", index)
        put("webMessageChannelId", webMessageChannelId)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as WebMessagePortCompatExt
        return index == other.index && webMessageChannelId == other.webMessageChannelId
    }

    open override fun hashCode(): Int = 31 * index + webMessageChannelId.hashCode()

    open override fun toString(): String =
        "WebMessagePortCompatExt{" +
            "index=$index, " +
            "webMessageChannelId='$webMessageChannelId'}"
}
