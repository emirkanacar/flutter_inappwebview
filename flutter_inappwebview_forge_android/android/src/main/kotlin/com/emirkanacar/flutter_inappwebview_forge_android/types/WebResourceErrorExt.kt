package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.webkit.WebResourceError
import androidx.annotation.RequiresApi
import androidx.webkit.WebResourceErrorCompat
import androidx.webkit.WebViewFeature
import java.util.HashMap

open class WebResourceErrorExt(
    open var type: Int,
    open var description: String
) {
    companion object {
        @JvmStatic
        @RequiresApi(Build.VERSION_CODES.M)
        fun fromWebResourceError(error: WebResourceError): WebResourceErrorExt =
            WebResourceErrorExt(error.getErrorCode(), error.getDescription()?.toString() ?: "")

        @JvmStatic
        @RequiresApi(Build.VERSION_CODES.M)
        fun fromWebResourceError(error: WebResourceErrorCompat): WebResourceErrorExt {
            val type = if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_CODE)) {
                error.getErrorCode()
            } else {
                -1
            }
            val description = if (WebViewFeature.isFeatureSupported(WebViewFeature.WEB_RESOURCE_ERROR_GET_DESCRIPTION)) {
                error.getDescription()?.toString() ?: ""
            } else {
                ""
            }
            return WebResourceErrorExt(type, description)
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("type", type)
        put("description", description)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as WebResourceErrorExt
        return type == other.type && description == other.description
    }

    open override fun hashCode(): Int = 31 * type + description.hashCode()

    open override fun toString(): String =
        "WebResourceErrorExt{" +
            "type=$type, " +
            "description='$description'}"
}
