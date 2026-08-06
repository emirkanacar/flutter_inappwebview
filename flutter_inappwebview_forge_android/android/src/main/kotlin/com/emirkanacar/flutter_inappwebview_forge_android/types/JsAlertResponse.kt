package com.emirkanacar.flutter_inappwebview_forge_android.types

open class JsAlertResponse(
    open var message: String,
    open var confirmButtonTitle: String,
    open var isHandledByClient: Boolean,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): JsAlertResponse? {
            if (map == null) return null

            val message = map["message"] as? String
                ?: throw IllegalArgumentException("JS alert message is required.")
            val confirmButtonTitle = map["confirmButtonTitle"] as? String
                ?: throw IllegalArgumentException("JS alert confirmButtonTitle is required.")
            val handledByClient = map["handledByClient"] as? Boolean
                ?: throw IllegalArgumentException("JS alert handledByClient is required.")
            val action = (map["action"] as? Number)?.toInt()
            return JsAlertResponse(message, confirmButtonTitle, handledByClient, action)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as JsAlertResponse
        return message == other.message &&
            confirmButtonTitle == other.confirmButtonTitle &&
            isHandledByClient == other.isHandledByClient &&
            action == other.action
    }

    open override fun hashCode(): Int {
        var result = message.hashCode()
        result = 31 * result + confirmButtonTitle.hashCode()
        result = 31 * result + isHandledByClient.hashCode()
        result = 31 * result + (action?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "JsAlertResponse{" +
            "message='$message', " +
            "confirmButtonTitle='$confirmButtonTitle', " +
            "handledByClient=$isHandledByClient, " +
            "action=$action}"
}
