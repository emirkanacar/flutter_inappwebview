package com.emirkanacar.flutter_inappwebview_forge_android.tracing

import androidx.webkit.TracingController
import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import java.util.ArrayList
import java.util.HashMap

class TracingSettings : ISettings<TracingController> {
    @JvmField
    var categories: MutableList<Any?> = ArrayList()

    @JvmField
    var tracingMode: Int? = null

    override fun parse(settings: MutableMap<String, Any?>): TracingSettings {
        settings.forEach { (key, value) ->
            when (key) {
                "categories" -> {
                    if (value is List<*>) {
                        categories = value.toMutableList()
                    }
                }
                "tracingMode" -> tracingMode = value as? Int
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("categories", categories)
        put("tracingMode", tracingMode)
    }

    override fun getRealSettings(obj: TracingController): MutableMap<String, Any?> = toMap()

    companion object {
        @JvmField
        val LOG_TAG = "TracingSettings"
    }
}
