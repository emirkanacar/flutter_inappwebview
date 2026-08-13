import Foundation

@main
struct WebViewLifecycleCoordinatorTests {
    static func main() {
        testLifecycleTransitionsSupportRetainAndReattach()
        testAsyncOperationsCompleteExactlyOnce()
        testDisposalIsIdempotentAndDrainsPendingOperations()
        testRendererLossCanReattach()
        testOnlyOneConcurrentDisposalWins()
        print("iOS native lifecycle tests passed (5)")
    }

    private static func testLifecycleTransitionsSupportRetainAndReattach() {
        let coordinator = WebViewLifecycleCoordinator()
        expect(coordinator.beginPreparing(), "first prepare must be accepted")
        expect(!coordinator.beginPreparing(), "duplicate prepare must be rejected")
        coordinator.markAttached()
        coordinator.markReady()
        coordinator.markDetachedRetained()
        coordinator.markAttached()
        coordinator.markReady()

        expect(coordinator.state == .ready, "reattached WebView must become ready")
#if DEBUG
        expect(
            coordinator.lifecycleTrace == [
                "preparing", "attached", "ready", "detachedRetained", "reattached", "ready",
            ],
            "lifecycle trace must preserve the retain/reattach sequence"
        )
#endif
    }

    private static func testAsyncOperationsCompleteExactlyOnce() {
        let coordinator = WebViewLifecycleCoordinator()
        guard let operationID = coordinator.beginAsyncOperation() else {
            fatalError("async operation must be accepted before disposal")
        }

        expect(coordinator.pendingAsyncOperations == 1, "pending operation count must increment")
        expect(coordinator.completeAsyncOperation(operationID), "first completion must win")
        expect(!coordinator.completeAsyncOperation(operationID), "duplicate completion must be ignored")
        expect(coordinator.pendingAsyncOperations == 0, "pending operation count must drain")
        expect(coordinator.callbackCompletionCount == 1, "callback must complete exactly once")
    }

    private static func testDisposalIsIdempotentAndDrainsPendingOperations() {
        let coordinator = WebViewLifecycleCoordinator()
        guard let operationID = coordinator.beginAsyncOperation() else {
            fatalError("async operation must be accepted before disposal")
        }

        expect(coordinator.beginDisposal(), "first disposal must be accepted")
        expect(!coordinator.beginDisposal(), "duplicate disposal must be rejected")
        expect(!coordinator.acceptsCallbacks, "disposing WebView must reject callbacks")
        expect(coordinator.beginAsyncOperation() == nil, "new work must be rejected after disposal")

        coordinator.finishDisposal()
        coordinator.finishDisposal()
        expect(coordinator.state == .disposed, "disposal must reach terminal state")
        expect(coordinator.pendingAsyncOperations == 0, "disposal must drain pending operations")
        expect(!coordinator.completeAsyncOperation(operationID), "drained operation must not complete later")
    }

    private static func testRendererLossCanReattach() {
        let coordinator = WebViewLifecycleCoordinator()
        expect(coordinator.beginPreparing(), "prepare must be accepted")
        coordinator.markAttached()
        coordinator.markReady()
        expect(coordinator.markRendererLost(), "renderer loss must be recorded")
        expect(coordinator.state == .rendererLost, "renderer loss must change lifecycle state")
        coordinator.markAttached()
        coordinator.markReady()
        expect(coordinator.state == .ready, "renderer-loss reattach must become ready")
    }

    private static func testOnlyOneConcurrentDisposalWins() {
        let coordinator = WebViewLifecycleCoordinator()
        let lock = NSLock()
        var winners = 0
        let group = DispatchGroup()

        for _ in 0..<32 {
            group.enter()
            DispatchQueue.global().async {
                if coordinator.beginDisposal() {
                    lock.lock()
                    winners += 1
                    lock.unlock()
                }
                group.leave()
            }
        }

        group.wait()
        expect(winners == 1, "exactly one concurrent disposal must win")
        expect(coordinator.state == .disposing, "the winning disposal must own the boundary")
    }

    private static func expect(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else { fatalError(message) }
    }
}
