package com.emirkanacar.flutter_inappwebview_forge_android.types

open class CustomTabsSecondaryToolbar(
    open var layout: AndroidResource,
    open var clickableIDs: MutableList<AndroidResource>
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
        fun fromMap(map: MutableMap<String, Any?>?): CustomTabsSecondaryToolbar? {
            if (map == null) return null

            val layout = AndroidResource.fromMap(asStringMap(map["layout"]))
                ?: throw IllegalArgumentException("Custom Tabs secondary toolbar layout is required.")
            val clickableIDs = (map["clickableIDs"] as? List<*>)?.mapNotNull { item ->
                val clickableID = asStringMap(item)?.let { clickableMap ->
                    AndroidResource.fromMap(asStringMap(clickableMap["id"]))
                }
                clickableID
            }?.toMutableList() ?: mutableListOf()
            return CustomTabsSecondaryToolbar(layout, clickableIDs)
        }
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as CustomTabsSecondaryToolbar
        return layout == other.layout && clickableIDs == other.clickableIDs
    }

    open override fun hashCode(): Int = 31 * layout.hashCode() + clickableIDs.hashCode()

    open override fun toString(): String =
        "CustomTabsSecondaryToolbar{" +
            "layout=$layout, " +
            "clickableIDs=$clickableIDs}"
}
