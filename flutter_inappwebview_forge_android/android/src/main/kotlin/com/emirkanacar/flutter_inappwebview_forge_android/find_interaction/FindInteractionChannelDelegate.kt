package com.emirkanacar.flutter_inappwebview_forge_android.find_interaction

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap
import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.FindSession
import com.emirkanacar.flutter_inappwebview_forge_android.webview.in_app_webview.InAppWebView

open class FindInteractionChannelDelegate(
    private var findInteractionController: FindInteractionController?,
    channel: MethodChannel
) : ChannelDelegateImpl(channel) {

    private fun canDispatchCallbacks(): Boolean {
        val webView = findInteractionController?.webView
        return getChannel() != null && webView != null &&
            (webView !is InAppWebView || webView.acceptsCallbacks())
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (!canDispatchCallbacks()) {
            result.success(null)
            return
        }
        when (call.method) {
            "findAll" -> {
                findInteractionController?.findAll(call.argument<String>("find"))
                result.success(true)
            }
            "findNext" -> {
                findInteractionController?.findNext(call.argument<Boolean>("forward") ?: false)
                result.success(true)
            }
            "clearMatches" -> {
                findInteractionController?.clearMatches()
                result.success(true)
            }
            "setSearchText" -> {
                val controller = findInteractionController
                if (controller != null) {
                    controller.searchText = call.argument<String>("searchText")
                    result.success(true)
                } else {
                    result.success(false)
                }
            }
            "getSearchText" -> {
                result.success(findInteractionController?.searchText ?: false)
            }
            "getActiveFindSession" -> {
                result.success(findInteractionController?.activeFindSession?.toMap())
            }
            else -> result.notImplemented()
        }
    }

    fun onFindResultReceived(activeMatchOrdinal: Int, numberOfMatches: Int, isDoneCounting: Boolean) {
        if (!canDispatchCallbacks()) return
        val channel = getChannel() ?: return
        val controller = findInteractionController
        if (isDoneCounting && controller?.webView != null) {
            controller.activeFindSession = FindSession(numberOfMatches, activeMatchOrdinal)
        }

        val obj = HashMap<String, Any?>()
        obj["activeMatchOrdinal"] = activeMatchOrdinal
        obj["numberOfMatches"] = numberOfMatches
        obj["isDoneCounting"] = isDoneCounting
        channel.invokeMethod("onFindResultReceived", obj)
    }

    override fun dispose() {
        super.dispose()
        findInteractionController = null
    }
}
