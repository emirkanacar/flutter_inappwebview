import Foundation

/// Internal lifecycle state for one native WebView.
///
/// This type is intentionally private to the iOS implementation. It provides
/// one disposal boundary for WebKit callbacks and asynchronous work without
/// changing the public Dart API or MethodChannel contract.
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

    private let stateLock = NSLock()
    private(set) var state: State = .creating
    private(set) var operationID: UInt64 = 0
    private(set) var pendingAsyncOperations = 0
    private(set) var callbackCompletionCount: UInt64 = 0
    private var activeOperationIDs = Set<UInt64>()
#if DEBUG
    private var lifecycleTraceStorage: [String] = []
    var lifecycleTrace: [String] {
        stateLock.lock()
        defer { stateLock.unlock() }
        return lifecycleTraceStorage
    }
#endif

    func beginPreparing() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard state == .creating else { return false }
        state = .preparing
        record("preparing")
        return true
    }

    func markAttached() {
        stateLock.lock()
        defer { stateLock.unlock() }
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
        stateLock.lock()
        defer { stateLock.unlock() }
        switch state {
        case .preparing, .attached, .reattached:
            state = .ready
            record("ready")
        default:
            break
        }
    }

    func markDetachedRetained() {
        stateLock.lock()
        defer { stateLock.unlock() }
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
        stateLock.lock()
        defer { stateLock.unlock() }
        guard acceptsCallbacksLocked else { return false }
        state = .rendererLost
        record("rendererLost")
        return true
    }

    @discardableResult
    func beginAsyncOperation() -> UInt64? {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard acceptsCallbacksLocked else { return nil }
        pendingAsyncOperations += 1
        operationID += 1
        activeOperationIDs.insert(operationID)
        return operationID
    }

    @discardableResult
    func completeAsyncOperation(_ operationID: UInt64) -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard activeOperationIDs.remove(operationID) != nil else { return false }
        pendingAsyncOperations -= 1
        callbackCompletionCount += 1
        return true
    }

    @discardableResult
    func beginDisposal() -> Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        guard state != .disposing, state != .disposed else { return false }
        state = .disposing
        operationID += 1
        record("disposing")
        return true
    }

    func finishDisposal() {
        stateLock.lock()
        defer { stateLock.unlock() }
        activeOperationIDs.removeAll()
        pendingAsyncOperations = 0
        state = .disposed
        record("disposed")
    }

    var acceptsCallbacks: Bool {
        stateLock.lock()
        defer { stateLock.unlock() }
        return acceptsCallbacksLocked
    }

    private var acceptsCallbacksLocked: Bool {
        state != .disposing && state != .disposed
    }

    private func record(_ event: String) {
#if DEBUG
        lifecycleTraceStorage.append(event)
#endif
    }
}
