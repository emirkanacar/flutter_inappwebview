package com.emirkanacar.flutter_inappwebview_forge_android.types

open class BaseCallbackResultImpl<T> : ICallbackResult<T> {
    override fun nonNullSuccess(result: T): Boolean = true

    override fun nullSuccess(): Boolean = true

    override fun defaultBehaviour(result: T?) {
        // Subclasses may handle the default callback behavior.
    }

    override fun success(obj: Any?) {
        val result = decodeResult(obj)
        val shouldRunDefaultBehaviour = if (result == null) {
            nullSuccess()
        } else {
            nonNullSuccess(result)
        }
        if (shouldRunDefaultBehaviour) {
            defaultBehaviour(result)
        }
    }

    override fun decodeResult(obj: Any?): T? = null

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        // Subclasses may handle channel errors.
    }

    override fun notImplemented() {
        defaultBehaviour(null)
    }
}
