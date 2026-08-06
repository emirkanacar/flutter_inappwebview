package com.emirkanacar.flutter_inappwebview_forge_android.pull_to_refresh

import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import java.util.HashMap

class PullToRefreshSettings : ISettings<PullToRefreshLayout> {
    @JvmField
    var enabled: Boolean = true

    @JvmField
    var color: String? = null

    @JvmField
    var backgroundColor: String? = null

    @JvmField
    var distanceToTriggerSync: Int? = null

    @JvmField
    var slingshotDistance: Int? = null

    @JvmField
    var size: Int? = null

    override fun parse(settings: MutableMap<String, Any?>): PullToRefreshSettings {
        settings.forEach { (key, value) ->
            when (key) {
                "enabled" -> (value as? Boolean)?.let { enabled = it }
                "color" -> (value as? String)?.let { color = it }
                "backgroundColor" -> (value as? String)?.let { backgroundColor = it }
                "distanceToTriggerSync" -> (value as? Int)?.let { distanceToTriggerSync = it }
                "slingshotDistance" -> (value as? Int)?.let { slingshotDistance = it }
                "size" -> (value as? Int)?.let { size = it }
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("enabled", enabled)
        put("color", color)
        put("backgroundColor", backgroundColor)
        put("distanceToTriggerSync", distanceToTriggerSync)
        put("slingshotDistance", slingshotDistance)
        put("size", size)
    }

    override fun getRealSettings(obj: PullToRefreshLayout): MutableMap<String, Any?> = toMap()

    companion object {
        @JvmField
        val LOG_TAG = "PullToRefreshSettings"
    }
}
