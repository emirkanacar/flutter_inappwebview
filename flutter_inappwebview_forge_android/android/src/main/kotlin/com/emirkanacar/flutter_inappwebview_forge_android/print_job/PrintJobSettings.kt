package com.emirkanacar.flutter_inappwebview_forge_android.print_job

import android.os.Build
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.ISettings
import com.emirkanacar.flutter_inappwebview_forge_android.types.MediaSizeExt
import com.emirkanacar.flutter_inappwebview_forge_android.types.ResolutionExt
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
class PrintJobSettings : ISettings<PrintJobController> {
    @JvmField
    var handledByClient: Boolean? = false

    @JvmField
    var jobName: String? = null

    @JvmField
    var orientation: Int? = null

    @JvmField
    var mediaSize: MediaSizeExt? = null

    @JvmField
    var colorMode: Int? = null

    @JvmField
    var duplexMode: Int? = null

    @JvmField
    var resolution: ResolutionExt? = null

    override fun parse(settings: MutableMap<String, Any?>): PrintJobSettings {
        settings.forEach { (key, value) ->
            when (key) {
                "handledByClient" -> handledByClient = value as? Boolean
                "jobName" -> jobName = value as? String
                "orientation" -> orientation = (value as? Number)?.toInt()
                "mediaSize" -> mediaSize = asStringObjectMap(value)?.let { MediaSizeExt.fromMap(it) }
                "colorMode" -> colorMode = (value as? Number)?.toInt()
                "duplexMode" -> duplexMode = (value as? Number)?.toInt()
                "resolution" -> resolution = asStringObjectMap(value)?.let { ResolutionExt.fromMap(it) }
            }
        }
        return this
    }

    override fun toMap(): MutableMap<String, Any?> = HashMap<String, Any?>().apply {
        put("handledByClient", handledByClient)
        put("jobName", jobName)
        put("orientation", orientation)
        put("mediaSize", mediaSize?.toMap())
        put("colorMode", colorMode)
        put("duplexMode", duplexMode)
        put("resolution", resolution?.toMap())
    }

    override fun getRealSettings(obj: PrintJobController): MutableMap<String, Any?> = toMap()

    companion object {
        @JvmField
        val LOG_TAG = "PrintJobSettings"
    }
}

private fun asStringObjectMap(value: Any?): MutableMap<String, Any?>? {
    val source = value as? Map<*, *> ?: return null
    return HashMap<String, Any?>().apply {
        source.forEach { (key, entryValue) ->
            if (key is String) put(key, entryValue)
        }
    }
}
