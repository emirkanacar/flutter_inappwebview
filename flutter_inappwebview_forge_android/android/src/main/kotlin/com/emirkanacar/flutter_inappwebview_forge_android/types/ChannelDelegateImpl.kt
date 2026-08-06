package com.emirkanacar.flutter_inappwebview_forge_android.types

import androidx.annotation.CallSuper
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

open class ChannelDelegateImpl(channel: MethodChannel) : IChannelDelegate {
    private var channelValue: MethodChannel? = channel

    init {
        channel.setMethodCallHandler(this)
    }

    override fun getChannel(): MethodChannel? = channelValue

    @CallSuper
    override fun dispose() {
        channelValue?.setMethodCallHandler(null)
        channelValue = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Subclasses handle channel methods.
    }
}
