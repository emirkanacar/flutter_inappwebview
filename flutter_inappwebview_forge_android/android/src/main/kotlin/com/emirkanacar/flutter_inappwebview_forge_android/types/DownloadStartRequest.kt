package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class DownloadStartRequest(
    open var url: String,
    open var userAgent: String,
    open var contentDisposition: String,
    open var mimeType: String,
    open var contentLength: Long,
    open var suggestedFilename: String?,
    open var textEncodingName: String?,
    open var downloadId: String? = null
) {
    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("url", url)
        put("userAgent", userAgent)
        put("contentDisposition", contentDisposition)
        put("mimeType", mimeType)
        put("contentLength", contentLength)
        put("suggestedFilename", suggestedFilename)
        put("textEncodingName", textEncodingName)
        put("downloadId", downloadId)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as DownloadStartRequest
        return url == other.url &&
            userAgent == other.userAgent &&
            contentDisposition == other.contentDisposition &&
            mimeType == other.mimeType &&
            contentLength == other.contentLength &&
            suggestedFilename == other.suggestedFilename &&
            textEncodingName == other.textEncodingName
    }

    open override fun hashCode(): Int {
        var result = url.hashCode()
        result = 31 * result + userAgent.hashCode()
        result = 31 * result + contentDisposition.hashCode()
        result = 31 * result + mimeType.hashCode()
        result = 31 * result + contentLength.hashCode()
        result = 31 * result + (suggestedFilename?.hashCode() ?: 0)
        result = 31 * result + (textEncodingName?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "DownloadStartRequest{" +
            "url='$url', " +
            "userAgent='$userAgent', " +
            "contentDisposition='$contentDisposition', " +
            "mimeType='$mimeType', " +
            "contentLength=$contentLength, " +
            "suggestedFilename='$suggestedFilename', " +
            "textEncodingName='$textEncodingName'}"
}
