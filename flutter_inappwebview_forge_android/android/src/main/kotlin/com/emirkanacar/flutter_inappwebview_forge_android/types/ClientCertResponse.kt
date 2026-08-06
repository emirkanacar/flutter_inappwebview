package com.emirkanacar.flutter_inappwebview_forge_android.types

open class ClientCertResponse(
    open var certificatePath: String,
    open var certificatePassword: String?,
    open var keyStoreType: String,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): ClientCertResponse? {
            if (map == null) return null

            val certificatePath = map["certificatePath"] as? String
                ?: throw IllegalArgumentException("Client certificate path is required.")
            val keyStoreType = map["keyStoreType"] as? String
                ?: throw IllegalArgumentException("Client certificate key store type is required.")
            val certificatePassword = map["certificatePassword"] as? String
            val action = (map["action"] as? Number)?.toInt()
            return ClientCertResponse(
                certificatePath,
                certificatePassword,
                keyStoreType,
                action
            )
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as ClientCertResponse
        return certificatePath == other.certificatePath &&
            certificatePassword == other.certificatePassword &&
            keyStoreType == other.keyStoreType &&
            action == other.action
    }

    open override fun hashCode(): Int {
        var result = certificatePath.hashCode()
        result = 31 * result + (certificatePassword?.hashCode() ?: 0)
        result = 31 * result + keyStoreType.hashCode()
        result = 31 * result + (action?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "ClientCertResponse{" +
            "certificatePath='$certificatePath', " +
            "certificatePassword='$certificatePassword', " +
            "keyStoreType='$keyStoreType', " +
            "action=$action}"
}
