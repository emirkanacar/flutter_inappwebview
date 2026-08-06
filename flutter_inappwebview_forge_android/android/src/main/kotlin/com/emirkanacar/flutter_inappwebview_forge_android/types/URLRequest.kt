package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class URLRequest(
    open var url: String?,
    open var method: String?,
    open var body: ByteArray?,
    open var headers: MutableMap<String, String>?
) {
    companion object {
        private fun stringMap(value: Any?): MutableMap<String, String>? {
            if (value == null) return null
            val source = value as? Map<*, *>
                ?: throw IllegalArgumentException("URL request headers must be a map.")
            val result = mutableMapOf<String, String>()
            for ((key, item) in source) {
                val stringKey = key as? String
                    ?: throw IllegalArgumentException("URL request header name is invalid.")
                val stringValue = item as? String
                    ?: throw IllegalArgumentException("URL request header value is invalid.")
                result[stringKey] = stringValue
            }
            return result
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): URLRequest? {
            if (map == null) return null
            return URLRequest(
                (map["url"] as? String) ?: "about:blank",
                map["method"] as? String,
                map["body"] as? ByteArray,
                stringMap(map["headers"])
            )
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("url", url)
        put("method", method)
        put("headers", headers)
        put("body", body)
        put("allowsCellularAccess", null)
        put("allowsConstrainedNetworkAccess", null)
        put("allowsExpensiveNetworkAccess", null)
        put("cachePolicy", null)
        put("httpShouldHandleCookies", null)
        put("httpShouldUsePipelining", null)
        put("networkServiceType", null)
        put("timeoutInterval", null)
        put("mainDocumentURL", null)
        put("assumesHTTP3Capable", null)
        put("attribution", null)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as URLRequest
        val bodyEquals = body?.contentEquals(other.body) ?: (other.body == null)
        return url == other.url && method == other.method && bodyEquals && headers == other.headers
    }

    open override fun hashCode(): Int {
        var result = url?.hashCode() ?: 0
        result = 31 * result + (method?.hashCode() ?: 0)
        result = 31 * result + (body?.contentHashCode() ?: 0)
        result = 31 * result + (headers?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "URLRequest{" +
            "url='$url', " +
            "method='$method', " +
            "body=$body, " +
            "headers=$headers}"
}
