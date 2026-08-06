package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class URLAuthenticationChallenge(
    open var protectionSpace: URLProtectionSpace
) {
    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("protectionSpace", protectionSpace.toMap())
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as URLAuthenticationChallenge
        return protectionSpace == other.protectionSpace
    }

    open override fun hashCode(): Int = protectionSpace.hashCode()

    open override fun toString(): String =
        "URLAuthenticationChallenge{protectionSpace=$protectionSpace}"
}
