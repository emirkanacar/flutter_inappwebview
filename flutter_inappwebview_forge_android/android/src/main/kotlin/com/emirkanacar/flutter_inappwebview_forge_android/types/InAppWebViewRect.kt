package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.graphics.Rect
import java.util.HashMap

open class InAppWebViewRect(
    open var height: Double,
    open var width: Double,
    open var x: Double,
    open var y: Double
) {
    companion object {
        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): InAppWebViewRect? {
            if (map == null) return null

            val height = (map["height"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("InAppWebViewRect height is required.")
            val width = (map["width"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("InAppWebViewRect width is required.")
            val x = (map["x"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("InAppWebViewRect x is required.")
            val y = (map["y"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("InAppWebViewRect y is required.")
            return InAppWebViewRect(height, width, x, y)
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("height", height)
        put("width", width)
        put("x", x)
        put("y", y)
    }

    open fun toRect(): Rect = Rect(x.toInt(), y.toInt(), (x + width).toInt(), (y + height).toInt())

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as InAppWebViewRect
        return height.compareTo(other.height) == 0 &&
            width.compareTo(other.width) == 0 &&
            x.compareTo(other.x) == 0 &&
            y.compareTo(other.y) == 0
    }

    open override fun hashCode(): Int {
        var result = height.hashCode()
        result = 31 * result + width.hashCode()
        result = 31 * result + x.hashCode()
        result = 31 * result + y.hashCode()
        return result
    }

    open override fun toString(): String =
        "InAppWebViewRect{" +
            "height=$height, " +
            "width=$width, " +
            "x=$x, " +
            "y=$y}"
}
