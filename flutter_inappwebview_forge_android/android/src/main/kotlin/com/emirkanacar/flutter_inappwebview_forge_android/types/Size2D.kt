package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.HashMap

open class Size2D(
    open var width: Double,
    open var height: Double
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): Size2D? {
            if (map == null) return null

            val width = (map["width"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("Size2D width is required.")
            val height = (map["height"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("Size2D height is required.")
            return Size2D(width, height)
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("width", width)
        put("height", height)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as Size2D
        return width.compareTo(other.width) == 0 && height.compareTo(other.height) == 0
    }

    open override fun hashCode(): Int {
        var result = width.hashCode()
        result = 31 * result + height.hashCode()
        return result
    }

    open override fun toString(): String =
        "Size{" +
            "width=$width, " +
            "height=$height}"
}
