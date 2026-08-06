package com.emirkanacar.flutter_inappwebview_forge_android.types

import io.flutter.plugin.common.MethodChannel

interface IChannelDelegate : MethodChannel.MethodCallHandler, Disposable {
    fun getChannel(): MethodChannel?
}
