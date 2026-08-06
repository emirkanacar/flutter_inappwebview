package com.emirkanacar.flutter_inappwebview_forge_android.print_job

import android.os.Build
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.types.PrintJobInfoExt
import io.flutter.plugin.common.MethodChannel

@RequiresApi(api = Build.VERSION_CODES.KITKAT)
open class PrintJobController(
    @JvmField var id: String,
    @JvmField var settings: PrintJobSettings?,
    @JvmField var plugin: InAppWebViewFlutterPlugin?
) : Disposable {
    companion object {
        @JvmField
        protected val LOG_TAG = "PrintJob"

        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX =
            "com.emirkanacar/flutter_inappwebview_printjobcontroller_"
    }

    @JvmField
    var channelDelegate: PrintJobChannelDelegate? = null

    @JvmField
    var job: android.print.PrintJob? = null

    init {
        val currentPlugin = plugin
            ?: error("A plugin instance is required to create a print job controller.")
        val channel = MethodChannel(
            currentPlugin.requireMessenger(),
            METHOD_CHANNEL_NAME_PREFIX + id
        )
        channelDelegate = PrintJobChannelDelegate(this, channel)
    }

    fun setJob(job: android.print.PrintJob?) {
        this.job = job
    }

    fun cancel() {
        job?.cancel()
    }

    fun restart() {
        job?.restart()
    }

    fun getInfo(): PrintJobInfoExt? = job?.let { PrintJobInfoExt.fromPrintJobInfo(it.info) }

    fun disposeNoCancel() {
        channelDelegate?.dispose()
        channelDelegate = null
        plugin?.printJobManager?.jobs?.let { jobs ->
            if (jobs.containsKey(id)) {
                jobs[id] = null
            }
        }
        job = null
        plugin = null
    }

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null
        plugin?.printJobManager?.jobs?.let { jobs ->
            if (jobs.containsKey(id)) {
                jobs[id] = null
            }
        }
        job?.cancel()
        job = null
        plugin = null
    }

    fun onComplete(completed: Boolean, error: String?) {
        channelDelegate?.onComplete(completed, error)
    }
}
