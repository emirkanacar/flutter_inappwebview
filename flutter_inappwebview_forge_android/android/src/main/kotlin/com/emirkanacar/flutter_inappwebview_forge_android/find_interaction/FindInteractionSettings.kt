package com.emirkanacar.flutter_inappwebview_forge_android.find_interaction

import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import java.util.HashMap

class FindInteractionSettings : ISettings<FindInteractionController> {
    override fun parse(settings: MutableMap<String, Any?>): FindInteractionSettings = this

    override fun toMap(): MutableMap<String, Any?> = HashMap()

    override fun getRealSettings(obj: FindInteractionController): MutableMap<String, Any?> = toMap()

    companion object {
        @JvmField
        val LOG_TAG = "FindInteractionSettings"
    }
}
