package com.emirkanacar.flutter_inappwebview_forge_android.print_job

import android.os.Build
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import java.util.HashMap

@RequiresApi(Build.VERSION_CODES.KITKAT)
open class PrintJobManager : Disposable {
    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = null

    @JvmField
    val jobs: MutableMap<String, PrintJobController?> = HashMap()

    constructor(plugin: InAppWebViewFlutterPlugin) {
        this.plugin = plugin
    }

    override fun dispose() {
        jobs.values.forEach { it?.dispose() }
        jobs.clear()
        plugin = null
    }

    companion object {
        @JvmField
        protected val LOG_TAG = "PrintJobManager"
    }
}
