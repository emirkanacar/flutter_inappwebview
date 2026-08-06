package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class NavigationAction(
    open var request: URLRequest,
    open var isForMainFrame: Boolean,
    open var isHasGesture: Boolean,
    open var isRedirect: Boolean
) {
    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("request", request.toMap())
        put("isForMainFrame", isForMainFrame)
        put("hasGesture", isHasGesture)
        put("isRedirect", isRedirect)
        put("navigationType", null)
        put("sourceFrame", null)
        put("targetFrame", null)
        put("shouldPerformDownload", null)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as NavigationAction
        return request == other.request &&
            isForMainFrame == other.isForMainFrame &&
            isHasGesture == other.isHasGesture &&
            isRedirect == other.isRedirect
    }

    open override fun hashCode(): Int {
        var result = request.hashCode()
        result = 31 * result + isForMainFrame.hashCode()
        result = 31 * result + isHasGesture.hashCode()
        result = 31 * result + isRedirect.hashCode()
        return result
    }

    open override fun toString(): String =
        "NavigationAction{" +
            "request=$request, " +
            "isForMainFrame=$isForMainFrame, " +
            "hasGesture=$isHasGesture, " +
            "isRedirect=$isRedirect}"
}
