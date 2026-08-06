package com.emirkanacar.flutter_inappwebview_forge_android.types

open class ServerTrustAuthResponse(
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): ServerTrustAuthResponse? {
            if (map == null) return null
            return ServerTrustAuthResponse((map["action"] as? Number)?.toInt())
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as ServerTrustAuthResponse
        return action == other.action
    }

    open override fun hashCode(): Int = action?.hashCode() ?: 0

    open override fun toString(): String = "ServerTrustAuthResponse{action=$action}"
}
