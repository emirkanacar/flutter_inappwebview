package com.emirkanacar.flutter_inappwebview_forge_android.find_interaction

import com.emirkanacar.flutter_inappwebview_forge_android.InAppWebViewFlutterPlugin
import com.emirkanacar.flutter_inappwebview_forge_android.types.Disposable
import com.emirkanacar.flutter_inappwebview_forge_android.types.FindSession
import com.emirkanacar.flutter_inappwebview_forge_android.webview.InAppWebViewInterface
import io.flutter.plugin.common.MethodChannel

open class FindInteractionController(
    webViewInitial: InAppWebViewInterface,
    plugin: InAppWebViewFlutterPlugin,
    id: Any,
    @JvmField var settings: FindInteractionSettings?
) : Disposable {
    companion object {
        @JvmField
        val LOG_TAG = "FindInteractionController"

        @JvmField
        val METHOD_CHANNEL_NAME_PREFIX =
            "com.emirkanacar/flutter_inappwebview_find_interaction_"
    }

    @JvmField
    var webView: InAppWebViewInterface? = webViewInitial

    @JvmField
    var activeFindSession: FindSession? = null

    @JvmField
    var channelDelegate: FindInteractionChannelDelegate?

    @JvmField
    var searchText: String? = null

    init {
        val channel = MethodChannel(plugin.requireMessenger(), METHOD_CHANNEL_NAME_PREFIX + id)
        channelDelegate = FindInteractionChannelDelegate(this, channel)
    }

    fun prepare() {
        // Reserved for future controller setup.
    }

    fun findAll(find: String?) {
        val value = find ?: searchText
        if (find != null) {
            searchText = find
        }
        if (webView != null && value != null) {
            webView?.findAllAsync(value)
        }
    }

    fun findNext(forward: Boolean) {
        webView?.findNext(forward)
    }

    fun clearMatches() {
        webView?.clearMatches()
    }

    override fun dispose() {
        channelDelegate?.dispose()
        channelDelegate = null
        webView = null
        activeFindSession = null
        searchText = null
    }
}
