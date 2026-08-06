package com.emirkanacar.flutter_inappwebview_forge_android.types

open class ShowFileChooserResponse(
    open var isHandledByClient: Boolean,
    open var filePaths: MutableList<String>?
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): ShowFileChooserResponse? {
            if (map == null) return null

            val handledByClient = map["handledByClient"] as? Boolean
                ?: throw IllegalArgumentException("File chooser handledByClient is required.")
            val filePaths = (map["filePaths"] as? List<*>)?.mapIndexed { index, path ->
                path as? String
                    ?: throw IllegalArgumentException("File chooser path at index $index is invalid.")
            }?.toMutableList()
            return ShowFileChooserResponse(handledByClient, filePaths)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as ShowFileChooserResponse
        return isHandledByClient == other.isHandledByClient && filePaths == other.filePaths
    }

    open override fun hashCode(): Int {
        var result = isHandledByClient.hashCode()
        result = 31 * result + (filePaths?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "ShowFileChooserResponse{" +
            "handledByClient=$isHandledByClient, " +
            "filePaths=$filePaths}"
}
