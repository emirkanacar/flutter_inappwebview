package com.emirkanacar.flutter_inappwebview_forge_android.print_job

import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import java.util.HashMap

open class PrintJobManager : Disposable {
    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = null

    @JvmField
    val jobs: MutableMap<String, PrintJobController> = HashMap()

    constructor(plugin: InAppWebViewFlutterPlugin) {
        this.plugin = plugin
    }

    override fun dispose() {
        val ownedJobs = ArrayList(jobs.values)
        jobs.clear()
        ownedJobs.forEach { it.dispose() }
        plugin = null
    }

    companion object {
        @JvmField
        protected val LOG_TAG = "PrintJobManager"
    }
}
