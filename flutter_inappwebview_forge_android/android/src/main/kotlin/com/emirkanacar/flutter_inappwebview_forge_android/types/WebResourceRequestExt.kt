package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.webkit.WebResourceRequest
import androidx.webkit.WebResourceRequestCompat
import androidx.webkit.WebViewFeature
import java.util.HashMap

open class WebResourceRequestExt(
    open var url: String,
    open var headers: MutableMap<String, String>?,
    open var isRedirect: Boolean,
    open var isHasGesture: Boolean,
    open var isForMainFrame: Boolean,
    open var method: String?
) {
    companion object {
        @JvmStatic
        fun fromWebResourceRequest(request: WebResourceRequest): WebResourceRequestExt {
            val isRedirect = when {
                WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_REQUEST_IS_REDIRECT) ->
                    WebResourceRequestCompat.isRedirect(request)
                else -> request.isRedirect()
            }
            return WebResourceRequestExt(
                request.getUrl().toString(),
                request.getRequestHeaders(),
                isRedirect,
                request.hasGesture(),
                request.isForMainFrame(),
                request.getMethod()
            )
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("url", url)
        put("headers", headers)
        put("isRedirect", isRedirect)
        put("hasGesture", isHasGesture)
        put("isForMainFrame", isForMainFrame)
        put("method", method)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as WebResourceRequestExt
        return url == other.url &&
            headers == other.headers &&
            isRedirect == other.isRedirect &&
            isHasGesture == other.isHasGesture &&
            isForMainFrame == other.isForMainFrame &&
            method == other.method
    }

    open override fun hashCode(): Int {
        var result = url.hashCode()
        result = 31 * result + (headers?.hashCode() ?: 0)
        result = 31 * result + isRedirect.hashCode()
        result = 31 * result + isHasGesture.hashCode()
        result = 31 * result + isForMainFrame.hashCode()
        result = 31 * result + (method?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "WebResourceRequestExt{" +
            "url=$url, " +
            "headers=$headers, " +
            "isRedirect=$isRedirect, " +
            "hasGesture=$isHasGesture, " +
            "isForMainFrame=$isForMainFrame, " +
            "method='$method'}"
}
