package com.emirkanacar.flutter_inappwebview_forge_android.content_blocker

class ContentBlockerAction(
    var type: ContentBlockerActionType,
    var selector: String?
) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ContentBlockerAction) return false
        return type == other.type && selector == other.selector
    }

    override fun hashCode(): Int = 31 * type.hashCode() + (selector?.hashCode() ?: 0)

    override fun toString(): String = "ContentBlockerAction{type=$type, selector='$selector'}"

    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>): ContentBlockerAction {
            val typeValue = map["type"] as? String
                ?: throw IllegalArgumentException("Content blocker action type is required.")
            return ContentBlockerAction(
                ContentBlockerActionType.fromValue(typeValue),
                map["selector"] as? String
            )
        }
    }
}
