package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class ProxyRuleExt(
    open var schemeFilter: String?,
    open var url: String
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, String>?): ProxyRuleExt? {
            if (map == null) return null

            val url = map["url"]
                ?: throw IllegalArgumentException("Proxy rule url is required.")
            return ProxyRuleExt(map["schemeFilter"], url)
        }
    }

    open fun toMap(): MutableMap<String, String?> = HashMap<String, String?>().apply {
        put("url", url)
        put("schemeFilter", schemeFilter)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as ProxyRuleExt
        return schemeFilter == other.schemeFilter && url == other.url
    }

    open override fun hashCode(): Int = 31 * (schemeFilter?.hashCode() ?: 0) + url.hashCode()

    open override fun toString(): String =
        "ProxyRuleExt{" +
            "schemeFilter='$schemeFilter', " +
            "url='$url'}"
}
