package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.webkit.WebView
import java.util.HashMap

open class HitTestResult(
    open var type: Int,
    open var extra: String?
) {
    companion object {
        @JvmStatic
        fun fromWebViewHitTestResult(hitTestResult: WebView.HitTestResult?): HitTestResult? {
            if (hitTestResult == null) return null
            return HitTestResult(hitTestResult.getType(), hitTestResult.getExtra())
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("type", type)
        put("extra", extra)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as HitTestResult
        return type == other.type && extra == other.extra
    }

    open override fun hashCode(): Int = 31 * type + (extra?.hashCode() ?: 0)

    open override fun toString(): String =
        "HitTestResultMap{" +
            "type=$type, " +
            "extra='$extra'}"
}
