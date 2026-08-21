package com.emirkanacar.flutter_inappwebview_forge_android.download_job

import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

open class DownloadJobChannelDelegate(
    private var downloadJobController: DownloadJobController?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "cancel" -> {
                downloadJobController?.cancel()
                result.success(true)
            }
            "getInfo" -> result.success(downloadJobController?.getInfo())
            "dispose" -> {
                downloadJobController?.dispose()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun onProgressChanged(progress: Double) {
        getChannel()?.invokeMethod(
            "onProgressChanged",
            hashMapOf("progress" to progress)
        )
    }

    fun onComplete(completed: Boolean, error: String?) {
        getChannel()?.invokeMethod(
            "onComplete",
            hashMapOf("completed" to completed, "error" to error)
        )
    }

    override fun dispose() {
        super.dispose()
        downloadJobController = null
    }
}
