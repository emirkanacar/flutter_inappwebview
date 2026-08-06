package com.emirkanacar.flutter_inappwebview_forge_android.types

open class HttpAuthResponse(
    open var username: String,
    open var password: String,
    open var isPermanentPersistence: Boolean,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): HttpAuthResponse? {
            if (map == null) return null

            val username = map["username"] as? String
                ?: throw IllegalArgumentException("HTTP auth username is required.")
            val password = map["password"] as? String
                ?: throw IllegalArgumentException("HTTP auth password is required.")
            val permanentPersistence = map["permanentPersistence"] as? Boolean
                ?: throw IllegalArgumentException("HTTP auth permanentPersistence is required.")
            val action = (map["action"] as? Number)?.toInt()
            return HttpAuthResponse(username, password, permanentPersistence, action)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as HttpAuthResponse
        return username == other.username &&
            password == other.password &&
            isPermanentPersistence == other.isPermanentPersistence &&
            action == other.action
    }

    open override fun hashCode(): Int {
        var result = username.hashCode()
        result = 31 * result + password.hashCode()
        result = 31 * result + isPermanentPersistence.hashCode()
        result = 31 * result + (action?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "HttpAuthResponse{" +
            "username='$username', " +
            "password='$password', " +
            "permanentPersistence=$isPermanentPersistence, " +
            "action=$action}"
}
