import Foundation

/// Internal lifecycle state for one macOS WebKit view.
///
/// This coordinator is intentionally private to the platform implementation;
/// it does not change the public Dart API or MethodChannel contract.
final class WebViewLifecycleCoordinator {
    enum State {
        case creating
        case preparing
        case attached
        case ready
        case detachedRetained
        case reattached
        case rendererLost
        case disposing
        case disposed
    }

    private(set) var state: State = .creating
    private(set) var operationID: UInt64 = 0
    private(set) var pendingAsyncOperations = 0
    private(set) var callbackCompletionCount: UInt64 = 0
    private var activeOperationIDs = Set<UInt64>()
#if DEBUG
    private(set) var lifecycleTrace: [String] = []
#endif

    func beginPreparing() -> Bool {
        guard state == .creating else { return false }
        state = .preparing
        record("preparing")
        return true
    }

    func markAttached() {
        switch state {
        case .preparing:
            state = .attached
            record("attached")
        case .detachedRetained:
            state = .reattached
            record("reattached")
        case .rendererLost:
            state = .reattached
            record("reattached")
        default:
            break
        }
    }

    func markReady() {
        switch state {
        case .preparing, .attached, .reattached:
            state = .ready
            record("ready")
        default:
            break
        }
    }

    func markDetachedRetained() {
        switch state {
        case .ready, .attached, .reattached:
            state = .detachedRetained
            record("detachedRetained")
        default:
            break
        }
    }

    @discardableResult
    func markRendererLost() -> Bool {
        guard acceptsCallbacks else { return false }
        state = .rendererLost
        record("rendererLost")
        return true
    }

    @discardableResult
    func beginAsyncOperation() -> UInt64? {
        guard acceptsCallbacks else { return nil }
        pendingAsyncOperations += 1
        operationID += 1
        activeOperationIDs.insert(operationID)
        return operationID
    }

    @discardableResult
    func completeAsyncOperation(_ operationID: UInt64) -> Bool {
        guard activeOperationIDs.remove(operationID) != nil else { return false }
        pendingAsyncOperations -= 1
        callbackCompletionCount += 1
        return true
    }

    @discardableResult
    func beginDisposal() -> Bool {
        guard state != .disposing, state != .disposed else { return false }
        state = .disposing
        operationID += 1
        record("disposing")
        return true
    }

    func finishDisposal() {
        activeOperationIDs.removeAll()
        pendingAsyncOperations = 0
        state = .disposed
        record("disposed")
    }

    var acceptsCallbacks: Bool {
        state != .disposing && state != .disposed
    }

    private func record(_ event: String) {
#if DEBUG
        lifecycleTrace.append(event)
#endif
    }
}
