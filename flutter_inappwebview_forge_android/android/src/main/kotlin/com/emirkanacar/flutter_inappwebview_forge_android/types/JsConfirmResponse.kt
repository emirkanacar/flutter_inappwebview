package com.emirkanacar.flutter_inappwebview_forge_android.types

open class JsConfirmResponse(
    open var message: String,
    open var confirmButtonTitle: String,
    open var cancelButtonTitle: String,
    open var isHandledByClient: Boolean,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): JsConfirmResponse? {
            if (map == null) return null

            val message = map["message"] as? String
                ?: throw IllegalArgumentException("JS confirm message is required.")
            val confirmButtonTitle = map["confirmButtonTitle"] as? String
                ?: throw IllegalArgumentException("JS confirm confirmButtonTitle is required.")
            val cancelButtonTitle = map["cancelButtonTitle"] as? String
                ?: throw IllegalArgumentException("JS confirm cancelButtonTitle is required.")
            val handledByClient = map["handledByClient"] as? Boolean
                ?: throw IllegalArgumentException("JS confirm handledByClient is required.")
            val action = (map["action"] as? Number)?.toInt()
            return JsConfirmResponse(
                message,
                confirmButtonTitle,
                cancelButtonTitle,
                handledByClient,
                action
            )
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as JsConfirmResponse
        return message == other.message &&
            confirmButtonTitle == other.confirmButtonTitle &&
            cancelButtonTitle == other.cancelButtonTitle &&
            isHandledByClient == other.isHandledByClient &&
            action == other.action
    }

    open override fun hashCode(): Int {
        var result = message.hashCode()
        result = 31 * result + confirmButtonTitle.hashCode()
        result = 31 * result + cancelButtonTitle.hashCode()
        result = 31 * result + isHandledByClient.hashCode()
        result = 31 * result + (action?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "JsConfirmResponse{" +
            "message='$message', " +
            "confirmButtonTitle='$confirmButtonTitle', " +
            "cancelButtonTitle='$cancelButtonTitle', " +
            "handledByClient=$isHandledByClient, " +
            "action=$action}"
}
