package com.emirkanacar.flutter_inappwebview_forge_android.types

open class DownloadStartResponse(
    open var handled: Boolean,
    open var action: Int?,
    open var resultFilePath: String?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): DownloadStartResponse? {
            if (map == null) return null
            val handled = map["handled"] as? Boolean ?: false
            val action = (map["action"] as? Number)?.toInt()
            val resultFilePath = map["resultFilePath"] as? String
            return DownloadStartResponse(handled, action, resultFilePath)
        }
    }
}
