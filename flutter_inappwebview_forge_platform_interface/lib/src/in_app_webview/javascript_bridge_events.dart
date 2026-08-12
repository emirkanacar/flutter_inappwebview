import 'dart:async';
import 'dart:convert';

import 'platform_inappwebview_controller.dart';

/// A callback invoked when JavaScript emits an event through
/// [JavaScriptBridgeEvents].
typedef JavaScriptBridgeEventCallback = FutureOr<void> Function(Object? data);

/// Decodes a value received from JavaScript into an application type.
typedef JavaScriptBridgeRequestDecoder<T> = T Function(Object? value);

/// Encodes a typed Dart response for the JavaScript side.
typedef JavaScriptBridgeResponseEncoder<T> = Object? Function(T value);

/// A typed, additive event and handler layer built on the existing JavaScript
/// bridge.
///
/// JavaScript can publish an event with:
///
/// ```javascript
/// bridge.bridgeEvents.emit('cart.updated', { count: 2 });
/// ```
///
/// where `bridge` is the object returned by
/// [PlatformInAppWebViewController.getJavaScriptBridgeName]. Dart listeners
/// registered with [on] receive that event. Dart can dispatch an event to
/// JavaScript listeners with [emit]. The existing `addJavaScriptHandler` API
/// and bridge security model are unchanged.
class JavaScriptBridgeEvents {
  /// Creates an event helper for [controller].
  JavaScriptBridgeEvents({required PlatformInAppWebViewController controller})
    : _controller = controller;

  static const String _handlerName =
      '__flutter_inappwebview_forge_bridge_events__';

  final PlatformInAppWebViewController _controller;
  final Map<String, List<JavaScriptBridgeEventCallback>> _listeners = {};
  Future<void>? _installFuture;
  String? _bridgeName;

  /// Registers a Dart listener for events emitted by JavaScript.
  ///
  /// Call this after the WebView is ready to evaluate JavaScript, such as in
  /// `onLoadStop`. The existing platform-ready event is still required before
  /// page JavaScript calls the bridge.
  Future<void> on(
    String eventName,
    JavaScriptBridgeEventCallback callback,
  ) async {
    _validateEventName(eventName);
    final listeners = _listeners.putIfAbsent(eventName, () => []);
    if (!listeners.contains(callback)) {
      listeners.add(callback);
    }
    await _ensureInstalled();
  }

  /// Removes one listener, or all Dart listeners for [eventName] when
  /// [callback] is omitted.
  Future<void> off(
    String eventName, [
    JavaScriptBridgeEventCallback? callback,
  ]) async {
    _validateEventName(eventName);
    final listeners = _listeners[eventName];
    if (listeners == null) return;
    if (callback == null) {
      _listeners.remove(eventName);
    } else {
      listeners.remove(callback);
      if (listeners.isEmpty) _listeners.remove(eventName);
    }
  }

  /// Returns whether Dart has a listener for [eventName].
  bool hasListener(String eventName) =>
      _listeners[eventName]?.isNotEmpty ?? false;

  /// Dispatches an event to JavaScript listeners without echoing it back to
  /// Dart.
  Future<void> emit(String eventName, [Object? data]) async {
    _validateEventName(eventName);
    await _ensureInstalled();
    final bridgeName = _bridgeName!;
    final source =
        'window[${jsonEncode(bridgeName)}].bridgeEvents.__dispatch('
        '${jsonEncode(eventName)}, ${jsonEncode(data)});';
    await _controller.evaluateJavascript(source: source);
  }

  /// Adds a handler whose request and response values are converted through
  /// explicit JSON-compatible codecs.
  void addJsonJavaScriptHandler<TRequest, TResponse>({
    required String handlerName,
    required JavaScriptBridgeRequestDecoder<TRequest> decodeRequest,
    required FutureOr<TResponse> Function(TRequest request) callback,
    required JavaScriptBridgeResponseEncoder<TResponse> encodeResponse,
  }) {
    _controller.addJavaScriptHandler(
      handlerName: handlerName,
      callback: (args) async {
        final rawRequest = args.length == 1 ? args.first : args;
        final request = decodeRequest(rawRequest);
        final response = await callback(request);
        return encodeResponse(response);
      },
    );
  }

  /// Adds a handler for a JSON string payload and serializes its response.
  ///
  /// This is useful when an existing page contract sends one serialized JSON
  /// argument rather than a structured JavaScript object.
  void addSerializedJavaScriptHandler<TRequest, TResponse>({
    required String handlerName,
    required TRequest Function(Object? value) decodeRequest,
    required FutureOr<TResponse> Function(TRequest request) callback,
    required Object? Function(TResponse response) encodeResponse,
  }) {
    addJsonJavaScriptHandler<TRequest, TResponse>(
      handlerName: handlerName,
      decodeRequest: (rawRequest) {
        final serialized = rawRequest is String
            ? rawRequest
            : jsonEncode(rawRequest);
        return decodeRequest(jsonDecode(serialized));
      },
      callback: callback,
      encodeResponse: (response) => jsonEncode(encodeResponse(response)),
    );
  }

  Future<void> _ensureInstalled() async {
    final existing = _installFuture;
    if (existing != null) {
      await existing;
      return;
    }
    final future = _install();
    _installFuture = future;
    try {
      await future;
    } catch (_) {
      if (identical(_installFuture, future)) {
        _installFuture = null;
      }
      rethrow;
    }
  }

  Future<void> _install() async {
    if (_controller.hasJavaScriptHandler(handlerName: _handlerName)) {
      throw StateError(
        'The JavaScript handler name "$_handlerName" is reserved by '
        'JavaScriptBridgeEvents.',
      );
    }

    _controller.addJavaScriptHandler(
      handlerName: _handlerName,
      callback: (args) async {
        if (args.length != 1 || args.first is! Map) return null;
        final event = args.first as Map;
        final eventName = event['eventName'];
        if (eventName is! String) return null;
        final listeners = List<JavaScriptBridgeEventCallback>.of(
          _listeners[eventName] ?? const [],
        );
        for (final listener in listeners) {
          await listener(event['data']);
        }
        return null;
      },
    );

    _bridgeName = await _controller.getJavaScriptBridgeName();
    final result = await _controller.evaluateJavascript(
      source: _installationScript(_bridgeName!),
    );
    if (result == false) {
      _controller.removeJavaScriptHandler(handlerName: _handlerName);
      throw StateError(
        'The JavaScript bridge object already has a bridgeEvents property.',
      );
    }
  }

  String _installationScript(String bridgeName) =>
      '''
(function () {
  const bridge = window[${jsonEncode(bridgeName)}];
  if (!bridge || typeof bridge.callHandler !== 'function') return false;
  if (bridge.bridgeEvents && bridge.bridgeEvents.__forgeBridgeEvents) return true;
  if (bridge.bridgeEvents) return false;
  const listeners = Object.create(null);
  const dispatch = function (eventName, data) {
    const callbacks = (listeners[eventName] || []).slice();
    callbacks.forEach(function (callback) {
      try { callback(data); } catch (_) {}
    });
  };
  const eventApi = {
    __forgeBridgeEvents: true,
    on: function (eventName, callback) {
      if (typeof eventName !== 'string' || typeof callback !== 'function') return;
      (listeners[eventName] || (listeners[eventName] = [])).push(callback);
    },
    off: function (eventName, callback) {
      if (!listeners[eventName]) return;
      if (typeof callback !== 'function') { delete listeners[eventName]; return; }
      listeners[eventName] = listeners[eventName].filter(function (item) {
        return item !== callback;
      });
      if (!listeners[eventName].length) delete listeners[eventName];
    },
    hasListener: function (eventName) {
      return !!(listeners[eventName] && listeners[eventName].length);
    },
    emit: function (eventName, data) {
      dispatch(eventName, data);
      return bridge.callHandler(${jsonEncode(_handlerName)}, {
        eventName: eventName,
        data: data
      });
    },
    __dispatch: dispatch
  };
  Object.defineProperty(bridge, 'bridgeEvents', {
    value: eventApi,
    configurable: false,
    enumerable: false,
    writable: false
  });
  return true;
})();
''';

  void _validateEventName(String eventName) {
    if (eventName.trim().isEmpty) {
      throw ArgumentError.value(eventName, 'eventName', 'must not be empty');
    }
  }
}
