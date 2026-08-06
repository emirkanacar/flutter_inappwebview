package com.emirkanacar.flutter_inappwebview_forge_android.types

open class SafeBrowsingResponse(
    open var isReport: Boolean,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): SafeBrowsingResponse? {
            if (map == null) return null

            val report = map["report"] as? Boolean
                ?: throw IllegalArgumentException("Safe Browsing report is required.")
            val action = (map["action"] as? Number)?.toInt()
            return SafeBrowsingResponse(report, action)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as SafeBrowsingResponse
        return isReport == other.isReport && action == other.action
    }

    open override fun hashCode(): Int = 31 * isReport.hashCode() + (action?.hashCode() ?: 0)

    open override fun toString(): String =
        "SafeBrowsingResponse{" +
            "report=$isReport, " +
            "action=$action}"
}
