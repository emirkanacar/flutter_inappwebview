package com.emirkanacar.flutter_inappwebview_forge_android.download_job

import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import java.util.HashMap

open class DownloadJobManager(plugin: InAppWebViewFlutterPlugin) : Disposable {
    @JvmField
    var plugin: InAppWebViewFlutterPlugin? = plugin

    @JvmField
    val jobs: MutableMap<String, DownloadJobController> = HashMap()

    override fun dispose() {
        val ownedJobs = ArrayList(jobs.values)
        jobs.clear()
        ownedJobs.forEach { it.dispose() }
        plugin = null
    }

    companion object {
        @JvmField
        protected val LOG_TAG = "DownloadJobManager"
    }
}
