package com.emirkanacar.flutter_inappwebview_forge_android.types

open class CustomTabsMenuItem(
    open var id: Int,
    open var label: String
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): CustomTabsMenuItem? {
            if (map == null) return null

            val id = (map["id"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Custom Tabs menu item id is required.")
            val label = map["label"] as? String
                ?: throw IllegalArgumentException("Custom Tabs menu item label is required.")
            return CustomTabsMenuItem(id, label)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as CustomTabsMenuItem
        return id == other.id && label == other.label
    }

    open override fun hashCode(): Int = 31 * id + label.hashCode()

    open override fun toString(): String =
        "CustomTabsMenuItem{" +
            "id=$id, " +
            "label='$label'}"
}
