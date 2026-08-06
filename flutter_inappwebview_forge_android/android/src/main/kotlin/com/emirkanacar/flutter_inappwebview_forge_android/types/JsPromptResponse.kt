package com.emirkanacar.flutter_inappwebview_forge_android.types

open class JsPromptResponse(
    open var message: String,
    open var defaultValue: String,
    open var confirmButtonTitle: String,
    open var cancelButtonTitle: String,
    open var isHandledByClient: Boolean,
    open var value: String?,
    open var action: Int?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): JsPromptResponse? {
            if (map == null) return null

            val message = map["message"] as? String
                ?: throw IllegalArgumentException("JS prompt message is required.")
            val defaultValue = map["defaultValue"] as? String
                ?: throw IllegalArgumentException("JS prompt defaultValue is required.")
            val confirmButtonTitle = map["confirmButtonTitle"] as? String
                ?: throw IllegalArgumentException("JS prompt confirmButtonTitle is required.")
            val cancelButtonTitle = map["cancelButtonTitle"] as? String
                ?: throw IllegalArgumentException("JS prompt cancelButtonTitle is required.")
            val handledByClient = map["handledByClient"] as? Boolean
                ?: throw IllegalArgumentException("JS prompt handledByClient is required.")
            val value = map["value"] as? String
            val action = (map["action"] as? Number)?.toInt()
            return JsPromptResponse(
                message,
                defaultValue,
                confirmButtonTitle,
                cancelButtonTitle,
                handledByClient,
                value,
                action
            )
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as JsPromptResponse
        return message == other.message &&
            defaultValue == other.defaultValue &&
            confirmButtonTitle == other.confirmButtonTitle &&
            cancelButtonTitle == other.cancelButtonTitle &&
            isHandledByClient == other.isHandledByClient &&
            value == other.value &&
            action == other.action
    }

    open override fun hashCode(): Int {
        var result = message.hashCode()
        result = 31 * result + defaultValue.hashCode()
        result = 31 * result + confirmButtonTitle.hashCode()
        result = 31 * result + cancelButtonTitle.hashCode()
        result = 31 * result + isHandledByClient.hashCode()
        result = 31 * result + (value?.hashCode() ?: 0)
        result = 31 * result + (action?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "JsPromptResponse{" +
            "message='$message', " +
            "defaultValue='$defaultValue', " +
            "confirmButtonTitle='$confirmButtonTitle', " +
            "cancelButtonTitle='$cancelButtonTitle', " +
            "handledByClient=$isHandledByClient, " +
            "value='$value', " +
            "action=$action}"
}
