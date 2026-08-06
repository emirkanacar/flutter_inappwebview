package com.emirkanacar.flutter_inappwebview_forge_android.types

class ContentWorld private constructor(var name: String) {
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other !is ContentWorld) return false
        return name == other.name
    }

    override fun hashCode(): Int = name.hashCode()

    override fun toString(): String = "ContentWorld{name='$name'}"

    companion object {
        @JvmField
        val PAGE = ContentWorld("page")

        @JvmField
        val DEFAULT_CLIENT = ContentWorld("defaultClient")

        @JvmStatic
        fun world(name: String): ContentWorld = ContentWorld(name)

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): ContentWorld? {
            if (map == null) return null

            val name = map["name"] as? String
                ?: throw IllegalArgumentException("Content world name is required.")
            return ContentWorld(name)
        }
    }
}
