package com.emirkanacar.flutter_inappwebview_forge_android.types

open class GeolocationPermissionShowPromptResponse(
    open var origin: String,
    open var isAllow: Boolean,
    open var isRetain: Boolean
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): GeolocationPermissionShowPromptResponse? {
            if (map == null) return null

            val origin = map["origin"] as? String
                ?: throw IllegalArgumentException("Geolocation origin is required.")
            val allow = map["allow"] as? Boolean
                ?: throw IllegalArgumentException("Geolocation allow is required.")
            val retain = map["retain"] as? Boolean
                ?: throw IllegalArgumentException("Geolocation retain is required.")
            return GeolocationPermissionShowPromptResponse(origin, allow, retain)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as GeolocationPermissionShowPromptResponse
        return origin == other.origin && isAllow == other.isAllow && isRetain == other.isRetain
    }

    open override fun hashCode(): Int {
        var result = origin.hashCode()
        result = 31 * result + isAllow.hashCode()
        result = 31 * result + isRetain.hashCode()
        return result
    }

    open override fun toString(): String =
        "GeolocationPermissionShowPromptResponse{" +
            "origin='$origin', " +
            "allow=$isAllow, " +
            "retain=$isRetain}"
}
