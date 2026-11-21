package com.emirkanacar.flutter_inappwebview_forge_android.types

import androidx.annotation.CallSuper
import com.emirkanacar.flutter_inappwebview_forge_android.Util
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

open class ChannelDelegateImpl(channel: MethodChannel) : IChannelDelegate {
    @Volatile
    private var channelValue: MethodChannel? = channel
    private val pendingSyncCallbacks = HashSet<SyncBaseCallbackResultImpl<*>>()

    init {
        channel.setMethodCallHandler(this)
    }

    override fun getChannel(): MethodChannel? = channelValue

    /**
     * Invokes [method] and blocks the calling (non-main) thread for the result,
     * like [Util.invokeMethodAndWaitResult], but registers the callback so that
     * [dispose] can release the waiting thread immediately instead of letting it
     * wait for the timeout. Returns null when the channel is already disposed.
     */
    @Throws(InterruptedException::class)
    protected fun <T> invokeMethodAndWaitResult(
        method: String,
        arguments: Any?,
        callback: SyncBaseCallbackResultImpl<T>,
        timeoutMillis: Long? = null,
        priority: Boolean = false
    ): T? {
        val channel = synchronized(pendingSyncCallbacks) {
            val current = channelValue ?: return null
            pendingSyncCallbacks.add(callback)
            current
        }
        try {
            return if (timeoutMillis == null) {
                Util.invokeMethodAndWaitResult(
                    channel, method, arguments, callback, priority = priority
                )
            } else {
                Util.invokeMethodAndWaitResult(
                    channel, method, arguments, callback, timeoutMillis, priority
                )
            }
        } finally {
            synchronized(pendingSyncCallbacks) {
                pendingSyncCallbacks.remove(callback)
            }
        }
    }

    @CallSuper
    override fun dispose() {
        val pending = synchronized(pendingSyncCallbacks) {
            channelValue?.setMethodCallHandler(null)
            channelValue = null
            val callbacks = pendingSyncCallbacks.toList()
            pendingSyncCallbacks.clear()
            callbacks
        }
        // Release threads blocked on a reply that can no longer arrive. A late
        // reply is ignored because cancelled callbacks drop success/error.
        pending.forEach { it.cancel() }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        // Subclasses handle channel methods.
    }
}
