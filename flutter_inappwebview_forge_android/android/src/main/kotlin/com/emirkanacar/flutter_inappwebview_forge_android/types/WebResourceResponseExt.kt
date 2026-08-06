package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.webkit.WebResourceResponse
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import java.util.HashMap

open class WebResourceResponseExt(
    open var contentType: String?,
    open var contentEncoding: String?,
    open var statusCode: Int?,
    open var reasonPhrase: String?,
    open var headers: MutableMap<String, String>?,
    open var data: ByteArray?
) {
    companion object {
        private fun stringMap(value: Any?): MutableMap<String, String>? {
            if (value == null) return null
            val source = value as? Map<*, *>
                ?: throw IllegalArgumentException("Web resource response headers must be a map.")
            val result = mutableMapOf<String, String>()
            for ((key, item) in source) {
                val stringKey = key as? String
                    ?: throw IllegalArgumentException("Web resource response header name is invalid.")
                val stringValue = item as? String
                    ?: throw IllegalArgumentException("Web resource response header value is invalid.")
                result[stringKey] = stringValue
            }
            return result
        }

        @JvmStatic
        fun fromWebResourceResponse(response: WebResourceResponse): WebResourceResponseExt {
            var statusCode: Int? = null
            var reasonPhrase: String? = null
            var headers: MutableMap<String, String>? = null
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                statusCode = response.getStatusCode()
                reasonPhrase = response.getReasonPhrase()
                headers = response.getResponseHeaders()
            }
            return WebResourceResponseExt(
                response.getMimeType(),
                response.getEncoding(),
                statusCode,
                reasonPhrase,
                headers,
                Util.readAllBytes(response.getData())
            )
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): WebResourceResponseExt? {
            if (map == null) return null
            return WebResourceResponseExt(
                map["contentType"] as? String,
                map["contentEncoding"] as? String,
                (map["statusCode"] as? Number)?.toInt(),
                map["reasonPhrase"] as? String,
                stringMap(map["headers"]),
                map["data"] as? ByteArray
            )
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("contentType", contentType)
        put("contentEncoding", contentEncoding)
        put("statusCode", statusCode)
        put("reasonPhrase", reasonPhrase)
        put("headers", headers)
        put("data", data)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as WebResourceResponseExt
        val dataEquals = data?.contentEquals(other.data) ?: (other.data == null)
        return contentType == other.contentType &&
            contentEncoding == other.contentEncoding &&
            statusCode == other.statusCode &&
            reasonPhrase == other.reasonPhrase &&
            headers == other.headers &&
            dataEquals
    }

    open override fun hashCode(): Int {
        var result = contentType?.hashCode() ?: 0
        result = 31 * result + (contentEncoding?.hashCode() ?: 0)
        result = 31 * result + (statusCode?.hashCode() ?: 0)
        result = 31 * result + (reasonPhrase?.hashCode() ?: 0)
        result = 31 * result + (headers?.hashCode() ?: 0)
        result = 31 * result + (data?.contentHashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "WebResourceResponseExt{" +
            "contentType='$contentType', " +
            "contentEncoding='$contentEncoding', " +
            "statusCode=$statusCode, " +
            "reasonPhrase='$reasonPhrase', " +
            "headers=$headers, " +
            "data=$data}"
}
