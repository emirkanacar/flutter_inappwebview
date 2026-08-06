package com.emirkanacar.flutter_inappwebview_forge_android.types

open class CustomSchemeResponse(
    open var data: ByteArray,
    open var contentType: String,
    open var contentEncoding: String
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): CustomSchemeResponse? {
            if (map == null) return null

            val data = map["data"] as? ByteArray
                ?: throw IllegalArgumentException("Custom scheme response data is required.")
            val contentType = map["contentType"] as? String
                ?: throw IllegalArgumentException("Custom scheme response contentType is required.")
            val contentEncoding = map["contentEncoding"] as? String
                ?: throw IllegalArgumentException("Custom scheme response contentEncoding is required.")
            return CustomSchemeResponse(data, contentType, contentEncoding)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as CustomSchemeResponse
        return data.contentEquals(other.data) &&
            contentType == other.contentType &&
            contentEncoding == other.contentEncoding
    }

    open override fun hashCode(): Int {
        var result = data.contentHashCode()
        result = 31 * result + contentType.hashCode()
        result = 31 * result + contentEncoding.hashCode()
        return result
    }

    open override fun toString(): String =
        "CustomSchemeResponse{" +
            "data=${data.contentToString()}, " +
            "contentType='$contentType', " +
            "contentEncoding='$contentEncoding'}"
}
