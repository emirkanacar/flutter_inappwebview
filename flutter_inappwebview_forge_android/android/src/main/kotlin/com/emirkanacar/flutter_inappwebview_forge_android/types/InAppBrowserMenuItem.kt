package com.emirkanacar.flutter_inappwebview_forge_android.types

open class InAppBrowserMenuItem(
    open var id: Int,
    open var title: String,
    open var order: Int?,
    open var icon: Any?,
    open var iconColor: String?,
    open var isShowAsAction: Boolean
) {
    companion object {
        private fun asStringMap(value: Any?): MutableMap<String, Any?>? {
            val source = value as? Map<*, *> ?: return null
            val result = mutableMapOf<String, Any?>()
            for ((key, item) in source) {
                val stringKey = key as? String ?: return null
                result[stringKey] = item
            }
            return result
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): InAppBrowserMenuItem? {
            if (map == null) return null

            val id = (map["id"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("In-app browser menu item id is required.")
            val title = map["title"] as? String
                ?: throw IllegalArgumentException("In-app browser menu item title is required.")
            val rawIcon = map["icon"]
            val icon = when (rawIcon) {
                is ByteArray -> rawIcon
                is Map<*, *> -> AndroidResource.fromMap(asStringMap(rawIcon))
                else -> null
            }
            val showAsAction = map["showAsAction"] as? Boolean ?: false
            return InAppBrowserMenuItem(
                id,
                title,
                (map["order"] as? Number)?.toInt(),
                icon,
                map["iconColor"] as? String,
                showAsAction
            )
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as InAppBrowserMenuItem
        return id == other.id &&
            title == other.title &&
            order == other.order &&
            icon == other.icon &&
            iconColor == other.iconColor &&
            isShowAsAction == other.isShowAsAction
    }

    open override fun hashCode(): Int {
        var result = id
        result = 31 * result + title.hashCode()
        result = 31 * result + (order?.hashCode() ?: 0)
        result = 31 * result + (icon?.hashCode() ?: 0)
        result = 31 * result + (iconColor?.hashCode() ?: 0)
        result = 31 * result + isShowAsAction.hashCode()
        return result
    }

    open override fun toString(): String =
        "InAppBrowserMenuItem{" +
            "id=$id, " +
            "title='$title', " +
            "order=$order, " +
            "icon=$icon, " +
            "iconColor='$iconColor', " +
            "showAsAction=$isShowAsAction}"
}
