package com.emirkanacar.flutter_inappwebview_forge_android.types

/**
 * Internal lifecycle state for one native WebView.
 *
 * This is deliberately not exposed through the Flutter API. It gives native
 * callbacks and asynchronous operations one shared disposal boundary while
 * preserving the existing channel contract.
 */
internal enum class WebViewLifecycleState {
    CREATING,
    PREPARING,
    ATTACHED,
    READY,
    DETACHED_RETAINED,
    REATTACHED,
    RENDERER_LOST,
    DISPOSING,
    DISPOSED
}

internal class WebViewLifecycleCoordinator {
    private var debugTrace: MutableList<String>? = null
    private val activeOperationIds: MutableSet<Long> = HashSet()

    @Volatile
    var state: WebViewLifecycleState = WebViewLifecycleState.CREATING
        private set

    @Volatile
    var operationId: Long = 0
        private set

    @Volatile
    var pendingAsyncOperations: Int = 0
        private set

    @Volatile
    var callbackCompletionCount: Long = 0
        private set

    @Synchronized
    fun beginPreparing(): Boolean {
        if (state != WebViewLifecycleState.CREATING) return false
        state = WebViewLifecycleState.PREPARING
        record("preparing")
        return true
    }

    @Synchronized
    fun markAttached() {
        when (state) {
            WebViewLifecycleState.PREPARING -> {
                state = WebViewLifecycleState.ATTACHED
                record("attached")
            }
            WebViewLifecycleState.DETACHED_RETAINED,
            WebViewLifecycleState.RENDERER_LOST -> {
                state = WebViewLifecycleState.REATTACHED
                record("reattached")
            }
            else -> Unit
        }
    }

    @Synchronized
    fun markReady() {
        if (state == WebViewLifecycleState.ATTACHED ||
            state == WebViewLifecycleState.PREPARING ||
            state == WebViewLifecycleState.REATTACHED
        ) {
            state = WebViewLifecycleState.READY
            record("ready")
        }
    }

    @Synchronized
    fun markDetachedRetained() {
        if (state == WebViewLifecycleState.READY ||
            state == WebViewLifecycleState.ATTACHED ||
            state == WebViewLifecycleState.REATTACHED
        ) {
            state = WebViewLifecycleState.DETACHED_RETAINED
            record("detachedRetained")
        }
    }

    @Synchronized
    fun markRendererLost(): Boolean {
        if (!acceptsCallbacksLocked()) return false
        state = WebViewLifecycleState.RENDERER_LOST
        record("rendererLost")
        return true
    }

    @Synchronized
    fun beginAsyncOperation(): Long? {
        if (!acceptsCallbacksLocked()) return null
        pendingAsyncOperations += 1
        operationId += 1
        activeOperationIds.add(operationId)
        return operationId
    }

    @Synchronized
    fun completeAsyncOperation(operationId: Long): Boolean {
        if (!activeOperationIds.remove(operationId)) return false
        pendingAsyncOperations -= 1
        callbackCompletionCount += 1
        return true
    }

    @Synchronized
    fun beginDisposal(): Boolean {
        if (state == WebViewLifecycleState.DISPOSING ||
            state == WebViewLifecycleState.DISPOSED
        ) {
            return false
        }
        state = WebViewLifecycleState.DISPOSING
        operationId += 1
        record("disposing")
        return true
    }

    @Synchronized
    fun finishDisposal() {
        activeOperationIds.clear()
        pendingAsyncOperations = 0
        state = WebViewLifecycleState.DISPOSED
        record("disposed")
    }

    @Synchronized
    fun acceptsCallbacks(): Boolean = acceptsCallbacksLocked()

    private fun acceptsCallbacksLocked(): Boolean =
        state != WebViewLifecycleState.DISPOSING &&
            state != WebViewLifecycleState.DISPOSED

    @Synchronized
    internal fun enableDebugTrace() {
        debugTrace = mutableListOf()
    }

    @Synchronized
    internal fun lifecycleTrace(): List<String> = debugTrace?.toList() ?: emptyList()

    private fun record(event: String) {
        debugTrace?.add(event)
    }
}
