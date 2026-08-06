package com.emirkanacar.flutter_inappwebview_forge_android.webview

import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import java.util.HashMap

class ContextMenuSettings : ISettings<Any> {
    @JvmField
    var hideDefaultSystemContextMenuItems: Boolean? = false

    override fun parse(settings: MutableMap<String, Any?>): ContextMenuSettings {
        settings.forEach { (key, value) ->
            if (key == "hideDefaultSystemContextMenuItems") {
                (value as? Boolean)?.let { hideDefaultSystemContextMenuItems = it }
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("hideDefaultSystemContextMenuItems", hideDefaultSystemContextMenuItems)
    }

    override fun getRealSettings(obj: Any): MutableMap<String, Any?> = toMap()

    companion object {
        @JvmField
        val LOG_TAG = "ContextMenuOptions"
    }
}
