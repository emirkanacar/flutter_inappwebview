package com.emirkanacar.flutter_inappwebview_forge_android.types

open class CustomTabsActionButton(
    open var id: Int,
    open var icon: ByteArray,
    open var description: String,
    open var isShouldTint: Boolean
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): CustomTabsActionButton? {
            if (map == null) return null

            val id = (map["id"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Custom Tabs action button id is required.")
            val icon = map["icon"] as? ByteArray
                ?: throw IllegalArgumentException("Custom Tabs action button icon is required.")
            val description = map["description"] as? String
                ?: throw IllegalArgumentException("Custom Tabs action button description is required.")
            val shouldTint = map["shouldTint"] as? Boolean
                ?: throw IllegalArgumentException("Custom Tabs action button shouldTint is required.")
            return CustomTabsActionButton(id, icon, description, shouldTint)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as CustomTabsActionButton
        return id == other.id &&
            icon.contentEquals(other.icon) &&
            description == other.description &&
            isShouldTint == other.isShouldTint
    }

    open override fun hashCode(): Int {
        var result = id
        result = 31 * result + icon.contentHashCode()
        result = 31 * result + description.hashCode()
        result = 31 * result + isShouldTint.hashCode()
        return result
    }

    open override fun toString(): String =
        "CustomTabsActionButton{" +
            "id=$id, " +
            "icon=${icon.contentToString()}, " +
            "description='$description', " +
            "shouldTint=$isShouldTint}"
}
