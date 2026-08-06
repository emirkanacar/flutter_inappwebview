package com.emirkanacar.flutter_inappwebview_forge_android.types

import android.annotation.TargetApi
import android.os.Build
import android.webkit.WebChromeClient
import java.util.HashMap

open class ShowFileChooserRequest(
    open var mode: Int,
    open var acceptTypes: MutableList<String>,
    open var isCaptureEnabled: Boolean,
    open var title: String?,
    open var filenameHint: String?
) {
    companion object {
        @JvmStatic
        @TargetApi(Build.VERSION_CODES.LOLLIPOP)
        fun fromFileChooserParams(fileChooserParams: WebChromeClient.FileChooserParams): ShowFileChooserRequest {
            val acceptTypes = fileChooserParams.getAcceptTypes()?.toMutableList() ?: mutableListOf()
            val title = fileChooserParams.getTitle()?.toString()
            return ShowFileChooserRequest(
                fileChooserParams.getMode(),
                acceptTypes,
                fileChooserParams.isCaptureEnabled(),
                title,
                fileChooserParams.getFilenameHint()
            )
        }

        @JvmStatic
        fun fromMap(map: MutableMap<String, Any?>?): ShowFileChooserRequest? {
            if (map == null) return null

            val mode = (map["mode"] as? Number)?.toInt()
                ?: throw IllegalArgumentException("File chooser mode is required.")
            val acceptTypes = (map["acceptTypes"] as? List<*>)?.mapIndexed { index, type ->
                type as? String
                    ?: throw IllegalArgumentException("File chooser accept type at index $index is invalid.")
            }?.toMutableList()
                ?: throw IllegalArgumentException("File chooser acceptTypes are required.")
            val isCaptureEnabled = map["isCaptureEnabled"] as? Boolean
                ?: throw IllegalArgumentException("File chooser isCaptureEnabled is required.")
            return ShowFileChooserRequest(
                mode,
                acceptTypes,
                isCaptureEnabled,
                map["title"] as? String,
                map["filenameHint"] as? String
            )
        }
    }

    open fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("mode", mode)
        put("acceptTypes", acceptTypes)
        put("isCaptureEnabled", isCaptureEnabled)
        put("title", title)
        put("filenameHint", filenameHint)
    }

    open override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (other == null || javaClass != other.javaClass) return false
        other as ShowFileChooserRequest
        return mode == other.mode &&
            acceptTypes == other.acceptTypes &&
            isCaptureEnabled == other.isCaptureEnabled &&
            title == other.title &&
            filenameHint == other.filenameHint
    }

    open override fun hashCode(): Int {
        var result = mode
        result = 31 * result + acceptTypes.hashCode()
        result = 31 * result + isCaptureEnabled.hashCode()
        result = 31 * result + (title?.hashCode() ?: 0)
        result = 31 * result + (filenameHint?.hashCode() ?: 0)
        return result
    }

    open override fun toString(): String =
        "ShowFileChooserRequest{" +
            "mode=$mode, " +
            "acceptTypes=$acceptTypes, " +
            "isCaptureEnabled=$isCaptureEnabled, " +
            "title='$title', " +
            "filenameHint='$filenameHint'}"
}
