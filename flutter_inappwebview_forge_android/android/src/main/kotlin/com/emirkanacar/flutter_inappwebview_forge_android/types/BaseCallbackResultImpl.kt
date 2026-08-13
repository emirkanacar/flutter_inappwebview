package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.concurrent.atomic.AtomicBoolean

open class BaseCallbackResultImpl<T> : ICallbackResult<T> {
    private val callbackCompleted = AtomicBoolean(false)
    private val defaultBehaviourCompleted = AtomicBoolean(false)

    protected fun beginCallbackCompletion(): Boolean =
        callbackCompleted.compareAndSet(false, true)

    override fun nonNullSuccess(result: T): Boolean = true

    override fun nullSuccess(): Boolean = true

    override fun defaultBehaviour(result: T?) {
        // Subclasses may handle the default callback behavior.
    }

    protected fun completeDefaultBehaviourAfterCallback(result: T?): Boolean {
        if (!defaultBehaviourCompleted.compareAndSet(false, true)) {
            return false
        }
        defaultBehaviour(result)
        return true
    }

    override fun completeDefaultBehaviour(result: T?): Boolean {
        if (!callbackCompleted.compareAndSet(false, true)) {
            return false
        }
        return completeDefaultBehaviourAfterCallback(result)
    }

    override fun success(obj: Any?) {
        if (!beginCallbackCompletion()) return
        val result = decodeResult(obj)
        val shouldRunDefaultBehaviour = if (result == null) {
            nullSuccess()
        } else {
            nonNullSuccess(result)
        }
        if (shouldRunDefaultBehaviour) {
            completeDefaultBehaviourAfterCallback(result)
        }
    }

    override fun decodeResult(obj: Any?): T? = null

    override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
        callbackCompleted.compareAndSet(false, true)
        // Subclasses may handle channel errors.
    }

    override fun notImplemented() {
        completeDefaultBehaviour(null)
    }
}
