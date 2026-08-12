import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Windows pull-to-refresh state backed by Flutter's platform-view gesture
/// layer.
class WindowsPullToRefreshStateNotifier extends ValueNotifier<bool> {
  WindowsPullToRefreshStateNotifier() : super(false);

  void notifyStateChanged() {
    notifyListeners();
  }
}

class WindowsPullToRefreshController extends PlatformPullToRefreshController {
  WindowsPullToRefreshController(
    PlatformPullToRefreshControllerCreationParams params,
  ) : _enabled = params.settings.enabled != false,
      _indicatorColor = params.settings.color,
      _backgroundColor = params.settings.backgroundColor,
      super.implementation(params);

  static final WindowsPullToRefreshController _staticValue =
      WindowsPullToRefreshController(
        PlatformPullToRefreshControllerCreationParams(),
      );

  factory WindowsPullToRefreshController.static() => _staticValue;

  bool _enabled;
  bool _isRefreshing = false;
  bool _disposed = false;
  Color? _indicatorColor;
  Color? _backgroundColor;

  /// Rebuilds the platform view's refresh indicator when the state changes.
  final WindowsPullToRefreshStateNotifier refreshState =
      WindowsPullToRefreshStateNotifier();

  Color? get indicatorColor => _indicatorColor;

  Color? get backgroundColor => _backgroundColor;

  /// Whether the opt-in no-scrollbar gesture is enabled.
  bool get allowWithNoScrollbar => settings.allowWithNoScrollbar == true;

  /// The minimum downward drag, in logical pixels, required to refresh.
  double get triggerDistance => 80.0;

  /// Called by [CustomPlatformView] after it verifies the document is at its
  /// top edge and the user has crossed [triggerDistance].
  void triggerRefresh() {
    if (_disposed || !_enabled || _isRefreshing) {
      return;
    }
    _isRefreshing = true;
    refreshState.value = true;
    onRefresh?.call();
  }

  @override
  Future<void> setEnabled(bool enabled) async {
    if (_disposed) {
      return;
    }
    _enabled = enabled;
  }

  @override
  Future<bool> isEnabled() async => _enabled;

  @override
  Future<void> beginRefreshing() async {
    if (_disposed) {
      return;
    }
    _isRefreshing = true;
    refreshState.value = true;
  }

  @override
  Future<void> endRefreshing() async {
    if (_disposed) {
      return;
    }
    _isRefreshing = false;
    refreshState.value = false;
  }

  @override
  Future<bool> isRefreshing() async => _isRefreshing;

  @override
  Future<void> setColor(Color color) async {
    if (_disposed) {
      return;
    }
    _indicatorColor = color;
    refreshState.notifyStateChanged();
  }

  @override
  Future<void> setBackgroundColor(Color color) async {
    if (_disposed) {
      return;
    }
    _backgroundColor = color;
    refreshState.notifyStateChanged();
  }

  @override
  void dispose({bool isKeepAlive = false}) {
    if (!isKeepAlive && !_disposed) {
      _disposed = true;
      refreshState.dispose();
    }
  }
}
