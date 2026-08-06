package com.emirkanacar.flutter_inappwebview_forge_android.in_app_browser

import com.emirkanacar.flutter_inappwebview_forge_android.types.ChannelDelegateImpl
import com.emirkanacar.flutter_inappwebview_forge_android.types.InAppBrowserMenuItem
import io.flutter.plugin.common.MethodChannel
import java.util.HashMap

open class InAppBrowserChannelDelegate(channel: MethodChannel) : ChannelDelegateImpl(channel) {

    fun onBrowserCreated() {
        val channel = getChannel() ?: return
        channel.invokeMethod("onBrowserCreated", HashMap<String, Any?>())
    }

    fun onMenuItemClicked(menuItem: InAppBrowserMenuItem) {
        val channel = getChannel() ?: return
        val obj = HashMap<String, Any?>()
        obj["id"] = menuItem.id
        channel.invokeMethod("onMenuItemClicked", obj)
    }

    fun onExit() {
        val channel = getChannel() ?: return
        channel.invokeMethod("onExit", HashMap<String, Any?>())
    }
}
