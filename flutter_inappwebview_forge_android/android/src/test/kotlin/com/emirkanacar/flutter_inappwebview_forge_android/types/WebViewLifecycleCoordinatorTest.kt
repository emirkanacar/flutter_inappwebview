package com.emirkanacar.flutter_inappwebview_forge_android.types

import java.util.Collections
import java.util.concurrent.atomic.AtomicInteger
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class WebViewLifecycleCoordinatorTest {
    @Test
    fun lifecycleTransitionsSupportRetainAndReattach() {
        val coordinator = WebViewLifecycleCoordinator()
        coordinator.enableDebugTrace()

        assertEquals(WebViewLifecycleState.CREATING, coordinator.state)
        assertTrue(coordinator.beginPreparing())
        assertFalse(coordinator.beginPreparing())

        coordinator.markAttached()
        coordinator.markReady()
        coordinator.markDetachedRetained()
        assertEquals(WebViewLifecycleState.DETACHED_RETAINED, coordinator.state)

        coordinator.markAttached()
        coordinator.markReady()
        assertEquals(WebViewLifecycleState.READY, coordinator.state)
        assertEquals(
            listOf("preparing", "attached", "ready", "detachedRetained", "reattached", "ready"),
            coordinator.lifecycleTrace(),
        )
    }

    @Test
    fun asyncOperationsCompleteExactlyOnce() {
        val coordinator = WebViewLifecycleCoordinator()
        val operationId = coordinator.beginAsyncOperation()

        assertNotNull(operationId)
        assertEquals(1, coordinator.pendingAsyncOperations)
        assertTrue(coordinator.completeAsyncOperation(operationId!!))
        assertFalse(coordinator.completeAsyncOperation(operationId))
        assertEquals(0, coordinator.pendingAsyncOperations)
        assertEquals(1, coordinator.callbackCompletionCount)
    }

    @Test
    fun disposalIsIdempotentAndDrainsPendingOperations() {
        val coordinator = WebViewLifecycleCoordinator()
        val operationId = coordinator.beginAsyncOperation()

        assertNotNull(operationId)
        assertTrue(coordinator.beginDisposal())
        assertFalse(coordinator.beginDisposal())
        assertFalse(coordinator.acceptsCallbacks())
        assertNull(coordinator.beginAsyncOperation())

        coordinator.finishDisposal()
        coordinator.finishDisposal()
        assertEquals(WebViewLifecycleState.DISPOSED, coordinator.state)
        assertEquals(0, coordinator.pendingAsyncOperations)
        assertFalse(coordinator.completeAsyncOperation(operationId!!))
    }

    @Test
    fun rendererLossCanReattach() {
        val coordinator = WebViewLifecycleCoordinator()
        assertTrue(coordinator.beginPreparing())
        coordinator.markAttached()
        coordinator.markReady()
        assertTrue(coordinator.markRendererLost())
        assertEquals(WebViewLifecycleState.RENDERER_LOST, coordinator.state)

        coordinator.markAttached()
        coordinator.markReady()
        assertEquals(WebViewLifecycleState.READY, coordinator.state)
    }

    @Test
    fun onlyOneConcurrentDisposalWins() {
        val coordinator = WebViewLifecycleCoordinator()
        val winners = AtomicInteger(0)
        val failures = Collections.synchronizedList(mutableListOf<Throwable>())

        val threads = (0 until 32).map {
            Thread {
                try {
                    if (coordinator.beginDisposal()) winners.incrementAndGet()
                } catch (throwable: Throwable) {
                    failures.add(throwable)
                }
            }
        }
        threads.forEach(Thread::start)
        threads.forEach(Thread::join)

        assertTrue(failures.isEmpty())
        assertEquals(1, winners.get())
        assertEquals(WebViewLifecycleState.DISPOSING, coordinator.state)
    }
}
