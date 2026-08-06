package com.emirkanacar.flutter_inappwebview_forge_android.types

open class CreateWindowAction(
    request: URLRequest,
    isForMainFrame: Boolean,
    hasGesture: Boolean,
    isRedirect: Boolean,
    open var windowId: Int,
    open var isDialog: Boolean
) : NavigationAction(request, isForMainFrame, hasGesture, isRedirect) {
    open override fun toMap(): MutableMap<String, Any?> = super.toMap().apply {
        put("windowId", windowId)
        put("isDialog", isDialog)
        put("windowFeatures", null)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        if (!super.equals(other)) return false
        other as CreateWindowAction
        return windowId == other.windowId && isDialog == other.isDialog
    }

    open override fun hashCode(): Int {
        var result = super.hashCode()
        result = 31 * result + windowId
        result = 31 * result + isDialog.hashCode()
        return result
    }

    open override fun toString(): String =
        "CreateWindowAction{" +
            "windowId=$windowId, " +
            "isDialog=$isDialog, " +
            "request=$request, " +
            "isForMainFrame=$isForMainFrame, " +
            "hasGesture=$isHasGesture, " +
            "isRedirect=$isRedirect}"
}
