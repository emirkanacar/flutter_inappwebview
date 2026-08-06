package com.emirkanacar.flutter_inappwebview_forge_android.types

import androidx.annotation.CallSuper
import java.util.concurrent.CountDownLatch

open class SyncBaseCallbackResultImpl<T> : BaseCallbackResultImpl<T>() {
    @JvmField
    val latch = CountDownLatch(1)

    @JvmField
    var result: T? = null

    @CallSuper
    override fun defaultBehaviour(result: T?) {
        latch.countDown()
    }

    override fun success(obj: Any?) {
        val decodedResult = decodeResult(obj)
        result = decodedResult
        val shouldRunDefaultBehaviour = if (decodedResult == null) {
            nullSuccess()
        } else {
            nonNullSuccess(decodedResult)
        }
        if (shouldRunDefaultBehaviour) {
            defaultBehaviour(decodedResult)
        } else {
            latch.countDown()
        }
    }

    @CallSuper
    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        latch.countDown()
    }

    @CallSuper
    override fun notImplemented() {
        defaultBehaviour(null)
    }
}
