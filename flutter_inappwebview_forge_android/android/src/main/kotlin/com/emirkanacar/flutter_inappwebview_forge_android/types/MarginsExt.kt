package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.print.PrintAttributes
import androidx.annotation.RequiresApi
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
open class MarginsExt {
    open var top: Double = 0.0
    open var right: Double = 0.0
    open var bottom: Double = 0.0
    open var left: Double = 0.0

    constructor()

    constructor(top: Double, right: Double, bottom: Double, left: Double) {
        this.top = top
        this.right = right
        this.bottom = bottom
        this.left = left
    }

    companion object {
        @JvmStatic
        fun fromMargins(margins: PrintAttributes.Margins?): MarginsExt? {
            if (margins == null) return null
            return MarginsExt(
                milsToPixels(margins.getTopMils()),
                milsToPixels(margins.getRightMils()),
                milsToPixels(margins.getBottomMils()),
                milsToPixels(margins.getLeftMils())
            )
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): MarginsExt? {
            if (map == null) return null

            val top = (map["top"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("Margins top is required.")
            val right = (map["right"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("Margins right is required.")
            val bottom = (map["bottom"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("Margins bottom is required.")
            val left = (map["left"] as? Number)?.toDouble()
                ?: throw IllegalArgumentException("Margins left is required.")
            return MarginsExt(top, right, bottom, left)
        }

        private fun milsToPixels(mils: Int): Double = mils * 0.09600001209449

        private fun pixelsToMils(pixels: Double): Int =
            kotlin.math.round(pixels * 10.416665354331).toInt()
    }

    open fun toMargins(): PrintAttributes.Margins =
        PrintAttributes.Margins(
            pixelsToMils(left),
            pixelsToMils(top),
            pixelsToMils(right),
            pixelsToMils(bottom)
        )

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("top", top)
        put("right", right)
        put("bottom", bottom)
        put("left", left)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as MarginsExt
        return top.compareTo(other.top) == 0 &&
            right.compareTo(other.right) == 0 &&
            bottom.compareTo(other.bottom) == 0 &&
            left.compareTo(other.left) == 0
    }

    open override fun hashCode(): Int {
        var result = top.hashCode()
        result = 31 * result + right.hashCode()
        result = 31 * result + bottom.hashCode()
        result = 31 * result + left.hashCode()
        return result
    }

    open override fun toString(): String =
        "MarginsExt{" +
            "top=$top, " +
            "right=$right, " +
            "bottom=$bottom, " +
            "left=$left}"
}
