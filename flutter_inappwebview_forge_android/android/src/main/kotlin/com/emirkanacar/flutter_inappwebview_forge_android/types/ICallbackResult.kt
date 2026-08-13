package com.emirkanacar.flutter_inappwebview_forge_android.types

import io.flutter.plugin.common.MethodChannel

interface ICallbackResult<T> : MethodChannel.Result {
    fun nonNullSuccess(result: T): Boolean

    fun nullSuccess(): Boolean

    fun defaultBehaviour(result: T?)

    fun completeDefaultBehaviour(result: T?): Boolean

    fun decodeResult(obj: Any?): T?
}
