package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.os.Build
import android.print.PrintAttributes
import androidx.annotation.RequiresApi
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
open class MediaSizeExt(
    open var id: String,
    open var label: String?,
    open var widthMils: Int,
    open var heightMils: Int
) {
    companion object {
        @JvmStatic
        fun fromMediaSize(mediaSize: PrintAttributes.MediaSize?): MediaSizeExt? {
            if (mediaSize == null) return null
            return MediaSizeExt(
                mediaSize.getId(),
                null,
                mediaSize.getHeightMils(),
                mediaSize.getWidthMils()
            )
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): MediaSizeExt? {
            if (map == null) return null

            val id = map["id"] as? String
                ?: throw IllegalArgumentException("Media size id is required.")
            val widthMils = (map["widthMils"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Media size widthMils is required.")
            val heightMils = (map["heightMils"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("Media size heightMils is required.")
            return MediaSizeExt(id, map["label"] as? String, widthMils, heightMils)
        }
    }

    open fun toMediaSize(): PrintAttributes.MediaSize =
        PrintAttributes.MediaSize(id, "Custom", widthMils, heightMils)

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("id", id)
        put("label", label)
        put("heightMils", heightMils)
        put("widthMils", widthMils)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as MediaSizeExt
        return id == other.id &&
            label == other.label &&
            widthMils == other.widthMils &&
            heightMils == other.heightMils
    }

    open override fun hashCode(): Int {
        var result = id.hashCode()
        result = 31 * result + (label?.hashCode() ?: 0)
        result = 31 * result + widthMils
        result = 31 * result + heightMils
        return result
    }

    open override fun toString(): String =
        "MediaSizeExt{" +
            "id='$id', " +
            "label='$label', " +
            "widthMils=$widthMils, " +
            "heightMils=$heightMils}"
}
