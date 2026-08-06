package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class JavaScriptHandlerFunctionData(
    open var origin: String,
    open var requestUrl: String,
    open var isMainFrame: Boolean,
    open var args: String
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): JavaScriptHandlerFunctionData? {
            if (map == null) return null

            val origin = map["origin"] as? String
                ?: throw IllegalArgumentException("JavaScript handler origin is required.")
            val requestUrl = map["requestUrl"] as? String
                ?: throw IllegalArgumentException("JavaScript handler requestUrl is required.")
            val isMainFrame = map["isMainFrame"] as? Boolean
                ?: throw IllegalArgumentException("JavaScript handler isMainFrame is required.")
            val args = map["args"] as? String
                ?: throw IllegalArgumentException("JavaScript handler args are required.")
            return JavaScriptHandlerFunctionData(origin, requestUrl, isMainFrame, args)
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("origin", origin)
        put("requestUrl", requestUrl)
        put("isMainFrame", isMainFrame)
        put("args", args)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as JavaScriptHandlerFunctionData
        return origin == other.origin &&
            requestUrl == other.requestUrl &&
            isMainFrame == other.isMainFrame &&
            args == other.args
    }

    open override fun hashCode(): Int {
        var result = origin.hashCode()
        result = 31 * result + requestUrl.hashCode()
        result = 31 * result + isMainFrame.hashCode()
        result = 31 * result + args.hashCode()
        return result
    }

    open override fun toString(): String =
        "JavaScriptHandlerFunctionData{" +
            "origin='$origin', " +
            "requestUrl='$requestUrl', " +
            "isMainFrame=$isMainFrame, " +
            "args='$args'}"
}
