package com.emirkanacar.flutter_inappwebview_forge_android.print_job

import android.os.Build
import androidx.annotation.RequiresApi
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

@RequiresApi(api = Build.VERSION_CODES.KITKAT)
open class PrintJobChannelDelegate(
    private var printJobController: PrintJobController?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "cancel" -> {
                val controller = printJobController
                if (controller != null) {
                    controller.cancel()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "restart" -> {
                val controller = printJobController
                if (controller != null) {
                    controller.restart()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "getInfo" -> result.success(printJobController?.getInfo()?.toMap())
            "dispose" -> {
                val controller = printJobController
                if (controller != null) {
                    controller.dispose()
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            else -> result.notImplemented()
        }
    }

    fun onComplete(completed: Boolean, error: String?) {
        val channel = getChannel() ?: return
        val obj = HashMap<String, Any?>()
        obj["completed"] = completed
        obj["error"] = error
        channel.invokeMethod("onComplete", obj)
    }

    override fun dispose() {
        super.dispose()
        printJobController = null
    }
}
