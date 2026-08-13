/// Internal lifecycle state machine for an iframe-backed WebView.
///
/// This type is intentionally not exported from the package library. It keeps
/// ownership and callback admission rules in one place without changing the
/// public Dart API or the platform channel contract.
enum WebViewLifecycleState {
  creating,
  preparing,
  attached,
  ready,
  detachedRetained,
  reattached,
  rendererLost,
  disposing,
  disposed,
}

class WebViewLifecycleCoordinator {
  WebViewLifecycleState state = WebViewLifecycleState.creating;

  int _operationId = 0;
  int _pendingAsyncOperations = 0;
  int _callbackCompletionCount = 0;
  final Set<int> _activeOperationIds = <int>{};
  List<String>? _debugTrace;

  bool get isDisposed => state == WebViewLifecycleState.disposed;

  bool get acceptsCallbacks =>
      state != WebViewLifecycleState.disposing && !isDisposed;

  bool beginPreparing() {
    if (!acceptsCallbacks || state == WebViewLifecycleState.ready) {
      return false;
    }
    if (state != WebViewLifecycleState.creating &&
        state != WebViewLifecycleState.reattached &&
        state != WebViewLifecycleState.detachedRetained) {
      return false;
    }
    state = WebViewLifecycleState.preparing;
    _record('preparing');
    return true;
  }

  void markAttached() {
    if (!acceptsCallbacks) {
      return;
    }
    if (state == WebViewLifecycleState.detachedRetained ||
        state == WebViewLifecycleState.rendererLost) {
      state = WebViewLifecycleState.reattached;
    } else if (state == WebViewLifecycleState.creating ||
        state == WebViewLifecycleState.preparing) {
      state = WebViewLifecycleState.attached;
    }
    _record('attached');
  }

  void markReady() {
    if (acceptsCallbacks &&
        (state == WebViewLifecycleState.attached ||
            state == WebViewLifecycleState.reattached ||
            state == WebViewLifecycleState.preparing)) {
      state = WebViewLifecycleState.ready;
      _record('ready');
    }
  }

  void markDetachedRetained() {
    if (acceptsCallbacks) {
      state = WebViewLifecycleState.detachedRetained;
      _record('detachedRetained');
    }
  }

  void markReattached() {
    if (acceptsCallbacks) {
      state = WebViewLifecycleState.reattached;
      _record('reattached');
    }
  }

  bool markRendererLost() {
    if (!acceptsCallbacks) {
      return false;
    }
    state = WebViewLifecycleState.rendererLost;
    _record('rendererLost');
    return true;
  }

  int get operationId => _operationId;

  int get pendingAsyncOperations => _pendingAsyncOperations;

  int get callbackCompletionCount => _callbackCompletionCount;

  int? beginAsyncOperation() {
    if (!acceptsCallbacks) {
      return null;
    }
    _pendingAsyncOperations++;
    _operationId++;
    _activeOperationIds.add(_operationId);
    return _operationId;
  }

  bool completeAsyncOperation(int operationId) {
    if (!_activeOperationIds.remove(operationId)) {
      return false;
    }
    _pendingAsyncOperations--;
    _callbackCompletionCount++;
    return true;
  }

  bool beginDisposal() {
    if (state == WebViewLifecycleState.disposing || isDisposed) {
      return false;
    }
    state = WebViewLifecycleState.disposing;
    _operationId++;
    _record('disposing');
    return true;
  }

  void finishDisposal() {
    _activeOperationIds.clear();
    _pendingAsyncOperations = 0;
    state = WebViewLifecycleState.disposed;
    _record('disposed');
  }

  void _record(String event) {
    assert(() {
      (_debugTrace ??= <String>[]).add(event);
      return true;
    }());
  }
}
