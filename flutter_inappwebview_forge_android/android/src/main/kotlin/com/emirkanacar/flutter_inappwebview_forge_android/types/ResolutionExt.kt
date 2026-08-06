package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.print.PrintAttributes
import androidx.annotation.RequiresApi
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
open class ResolutionExt(
    open var id: String,
    open var label: String,
    open var verticalDpi: Int,
    open var horizontalDpi: Int
) {
    companion object {
        @JvmStatic
        fun fromResolution(resolution: PrintAttributes.Resolution?): ResolutionExt? {
            if (resolution == null) return null
            return ResolutionExt(
                resolution.getId(),
                resolution.getLabel(),
                resolution.getVerticalDpi(),
                resolution.getHorizontalDpi()
            )
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): ResolutionExt? {
            if (map == null) return null

            val id = map["id"] as? String
                ?: throw IllegalArgumentException("Resolution id is required.")
            val label = map["label"] as? String
                ?: throw IllegalArgumentException("Resolution label is required.")
            val verticalDpi = (map["verticalDpi"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Resolution verticalDpi is required.")
            val horizontalDpi = (map["horizontalDpi"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Resolution horizontalDpi is required.")
            return ResolutionExt(id, label, verticalDpi, horizontalDpi)
        }
    }

    open fun toResolution(): PrintAttributes.Resolution =
        PrintAttributes.Resolution(id, label, horizontalDpi, verticalDpi)

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("id", id)
        put("label", label)
        put("verticalDpi", verticalDpi)
        put("horizontalDpi", horizontalDpi)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as ResolutionExt
        return id == other.id &&
            label == other.label &&
            verticalDpi == other.verticalDpi &&
            horizontalDpi == other.horizontalDpi
    }

    open override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + label.hashCode()
        result = 31 * result + verticalDpi
        result = 31 * result + horizontalDpi
        return result
    }

    open override fun toString(): String =
        "ResolutionExt{" +
            "id='$id', " +
            "label='$label', " +
            "verticalDpi=$verticalDpi, " +
            "horizontalDpi=$horizontalDpi}"
}
