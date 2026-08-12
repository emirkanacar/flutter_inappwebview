import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import '../platform_util.dart';
import '_static_channel.dart';
import '../pull_to_refresh_controller.dart';

const Map<String, SystemMouseCursor> _cursors = {
  'none': SystemMouseCursors.none,
  'basic': SystemMouseCursors.basic,
  'click': SystemMouseCursors.click,
  'forbidden': SystemMouseCursors.forbidden,
  'wait': SystemMouseCursors.wait,
  'progress': SystemMouseCursors.progress,
  'contextMenu': SystemMouseCursors.contextMenu,
  'help': SystemMouseCursors.help,
  'text': SystemMouseCursors.text,
  'verticalText': SystemMouseCursors.verticalText,
  'cell': SystemMouseCursors.cell,
  'precise': SystemMouseCursors.precise,
  'move': SystemMouseCursors.move,
  'grab': SystemMouseCursors.grab,
  'grabbing': SystemMouseCursors.grabbing,
  'noDrop': SystemMouseCursors.noDrop,
  'alias': SystemMouseCursors.alias,
  'copy': SystemMouseCursors.copy,
  'disappearing': SystemMouseCursors.disappearing,
  'allScroll': SystemMouseCursors.allScroll,
  'resizeLeftRight': SystemMouseCursors.resizeLeftRight,
  'resizeUpDown': SystemMouseCursors.resizeUpDown,
  'resizeUpLeftDownRight': SystemMouseCursors.resizeUpLeftDownRight,
  'resizeUpRightDownLeft': SystemMouseCursors.resizeUpRightDownLeft,
  'resizeUp': SystemMouseCursors.resizeUp,
  'resizeDown': SystemMouseCursors.resizeDown,
  'resizeLeft': SystemMouseCursors.resizeLeft,
  'resizeRight': SystemMouseCursors.resizeRight,
  'resizeUpLeft': SystemMouseCursors.resizeUpLeft,
  'resizeUpRight': SystemMouseCursors.resizeUpRight,
  'resizeDownLeft': SystemMouseCursors.resizeDownLeft,
  'resizeDownRight': SystemMouseCursors.resizeDownRight,
  'resizeColumn': SystemMouseCursors.resizeColumn,
  'resizeRow': SystemMouseCursors.resizeRow,
  'zoomIn': SystemMouseCursors.zoomIn,
  'zoomOut': SystemMouseCursors.zoomOut,
};

SystemMouseCursor _getCursorByName(String name) =>
    _cursors[name] ?? SystemMouseCursors.basic;

/// Pointer button type
// Order must match InAppWebViewPointerEventKind (see in_app_webview.h)
enum PointerButton { none, primary, secondary, tertiary }

/// Pointer Event kind
// Order must match InAppWebViewPointerEventKind (see in_app_webview.h)
enum InAppWebViewPointerEventKind {
  activate,
  down,
  enter,
  leave,
  up,
  update,
  cancel,
}

/// Attempts to translate a button constant such as [kPrimaryMouseButton]
/// to a [PointerButton]
PointerButton _getButton(int value) {
  switch (value) {
    case kPrimaryMouseButton:
      return PointerButton.primary;
    case kSecondaryMouseButton:
      return PointerButton.secondary;
    case kTertiaryButton:
      return PointerButton.tertiary;
    default:
      return PointerButton.none;
  }
}

const MethodChannel _pluginChannel = IN_APP_WEBVIEW_STATIC_CHANNEL;

class CustomFlutterViewControllerValue {
  const CustomFlutterViewControllerValue({required this.isInitialized});

  final bool isInitialized;

  CustomFlutterViewControllerValue copyWith({bool? isInitialized}) {
    return CustomFlutterViewControllerValue(
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  CustomFlutterViewControllerValue.uninitialized() : this(isInitialized: false);
}

/// Controls a WebView and provides streams for various change events.
class CustomPlatformViewController
    extends ValueNotifier<CustomFlutterViewControllerValue> {
  Completer<void> _creatingCompleter = Completer<void>();
  int _textureId = 0;
  bool _isDisposed = false;

  Future<void> get ready => _creatingCompleter.future;

  late MethodChannel _methodChannel;
  late EventChannel _eventChannel;
  StreamSubscription? _eventStreamSubscription;

  final StreamController<SystemMouseCursor> _cursorStreamController =
      StreamController<SystemMouseCursor>.broadcast();

  /// A stream reflecting the current cursor style.
  Stream<SystemMouseCursor> get _cursor => _cursorStreamController.stream;

  CustomPlatformViewController()
    : super(CustomFlutterViewControllerValue.uninitialized());

  /// Initializes the underlying platform view.
  Future<void> initialize({
    Function(int id)? onPlatformViewCreated,
    dynamic arguments,
  }) async {
    if (_isDisposed) {
      return;
    }
    _textureId = (await _pluginChannel.invokeMethod<int>(
      'createInAppWebView',
      arguments,
    ))!;

    _methodChannel = MethodChannel(
      'com.emirkanacar/custom_platform_view_$_textureId',
    );
    _eventChannel = EventChannel(
      'com.emirkanacar/custom_platform_view_${_textureId}_events',
    );
    _eventStreamSubscription = _eventChannel.receiveBroadcastStream().listen((
      event,
    ) {
      final map = event as Map<dynamic, dynamic>;
      switch (map['type']) {
        case 'cursorChanged':
          _cursorStreamController.add(_getCursorByName(map['value']));
          break;
      }
    });

    _methodChannel.setMethodCallHandler((call) {
      throw MissingPluginException('Unknown method ${call.method}');
    });

    value = value.copyWith(isInitialized: true);

    _creatingCompleter.complete();

    onPlatformViewCreated?.call(_textureId);
  }

  @override
  Future<void> dispose() async {
    await _creatingCompleter.future;
    if (!_isDisposed) {
      _isDisposed = true;
      await _eventStreamSubscription?.cancel();
      await _pluginChannel.invokeMethod('dispose', {"id": _textureId});
    }
    super.dispose();
  }

  /// Limits the number of frames per second to the given value.
  Future<void> setFpsLimit([int? maxFps = 0]) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setFpsLimit', maxFps);
  }

  /// Sends a Pointer (Touch) update
  Future<void> _setPointerUpdate(
    InAppWebViewPointerEventKind kind,
    int pointer,
    Offset position,
    double size,
    double pressure,
  ) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerUpdate', [
      pointer,
      kind.index,
      position.dx,
      position.dy,
      size,
      pressure,
    ]);
  }

  /// Moves the virtual cursor to [position].
  Future<void> _setCursorPos(Offset position) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setCursorPos', [
      position.dx,
      position.dy,
    ]);
  }

  /// Indicates whether the specified [button] is currently down.
  Future<void> _setPointerButtonState(
    InAppWebViewPointerEventKind kind,
    PointerButton button,
  ) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPointerButton', <String, dynamic>{
      'kind': kind.index,
      'button': button.index,
    });
  }

  /// Sets the horizontal and vertical scroll delta.
  Future<void> _setScrollDelta(double dx, double dy) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setScrollDelta', [dx, dy]);
  }

  /// Sets the surface size to the provided [size].
  Future<void> _setSize(Size size, double scaleFactor) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setSize', [
      size.width,
      size.height,
      scaleFactor,
    ]);
  }

  /// Sets the surface size to the provided [size].
  Future<void> _setPosition(Offset position, double scaleFactor) async {
    if (_isDisposed) {
      return;
    }
    assert(value.isInitialized);
    return _methodChannel.invokeMethod('setPosition', [
      position.dx,
      position.dy,
      scaleFactor,
    ]);
  }

  Future<void> _setVisibility(bool visible) async {
    if (_isDisposed || !value.isInitialized) {
      return;
    }
    return _methodChannel.invokeMethod('setVisibility', visible);
  }
}

class CustomPlatformView extends StatefulWidget {
  /// An optional scale factor. Defaults to [FlutterView.devicePixelRatio] for
  /// rendering in native resolution.
  /// Setting this to 1.0 will disable high-DPI support.
  /// This should only be needed to mimic old behavior before high-DPI support
  /// was available.
  final double? scaleFactor;

  /// The [FilterQuality] used for scaling the texture's contents.
  /// Defaults to [FilterQuality.none] as this renders in native resolution
  /// unless specifying a [scaleFactor].
  final FilterQuality filterQuality;

  final dynamic creationParams;

  final Function(int id)? onPlatformViewCreated;

  final PlatformPullToRefreshController? pullToRefreshController;

  final Future<bool> Function()? canStartPullToRefresh;

  const CustomPlatformView({
    this.creationParams,
    this.onPlatformViewCreated,
    this.pullToRefreshController,
    this.canStartPullToRefresh,
    this.scaleFactor,
    this.filterQuality = FilterQuality.none,
  });

  @override
  _CustomPlatformViewState createState() => _CustomPlatformViewState();
}

class _CustomPlatformViewState extends State<CustomPlatformView>
    with PlatformUtilListener {
  final GlobalKey _key = GlobalKey();
  final _downButtons = <int, PointerButton>{};

  int? _pullPointer;
  int _pullGestureGeneration = 0;
  Offset? _pullStartPosition;
  double _pullDistance = 0;
  bool _pullTopConfirmed = false;

  PointerDeviceKind _pointerKind = PointerDeviceKind.unknown;

  MouseCursor _cursor = SystemMouseCursors.basic;

  final _controller = CustomPlatformViewController();
  final _focusNode = FocusNode();

  StreamSubscription? _cursorSubscription;

  late final AppLifecycleListener _listener;

  PlatformUtil _platformUtil = PlatformUtil.instance();

  @override
  void initState() {
    super.initState();

    _platformUtil.addListener(this);

    _controller.initialize(
      onPlatformViewCreated: (id) {
        widget.onPlatformViewCreated?.call(id);
        if (mounted) {
          setState(() {});
        }
      },
      arguments: widget.creationParams,
    );

    _listener = AppLifecycleListener(
      onStateChange: (state) {
        if ([
          AppLifecycleState.resumed,
          AppLifecycleState.hidden,
        ].contains(state)) {
          _reportSurfaceSize();
          _reportWidgetPosition();
        }
      },
    );

    // Report initial surface size and widget position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _reportSurfaceSize();
      _reportWidgetPosition();
    });

    _cursorSubscription = _controller._cursor.listen((cursor) {
      setState(() {
        _cursor = cursor;
      });
    });
  }

  @override
  void onWindowMove() {
    _reportSurfaceSize();
    _reportWidgetPosition();
  }

  @override
  void onWindowMinimize() {
    unawaited(_controller._setVisibility(false));
  }

  @override
  void onWindowRestore() {
    unawaited(_controller._setVisibility(true));
    _reportSurfaceSize();
    _reportWidgetPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: true,
      focusNode: _focusNode,
      canRequestFocus: true,
      debugLabel: "flutter_inappwebview_forge_windows_custom_platform_view",
      onFocusChange: (focused) {},
      child: SizedBox.expand(key: _key, child: _buildInner()),
    );
  }

  Widget _buildInner() {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (notification) {
        _reportSurfaceSize();
        _reportWidgetPosition();
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: _controller.value.isInitialized
            ? Listener(
                onPointerHover: (ev) {
                  // ev.kind is for whatever reason not set to touch
                  // even on touch input
                  if (_pointerKind == PointerDeviceKind.touch) {
                    // Ignoring hover events on touch for now
                    return;
                  }
                  _controller._setCursorPos(ev.localPosition);
                },
                onPointerDown: (ev) {
                  _reportSurfaceSize();
                  _reportWidgetPosition();

                  if (!_focusNode.hasFocus) {
                    _focusNode.requestFocus();
                    Future.delayed(const Duration(milliseconds: 50), () {
                      if (!_focusNode.hasFocus) {
                        _focusNode.requestFocus();
                      }
                    });
                  }

                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    _startPullToRefreshCandidate(ev);
                    _controller._setPointerUpdate(
                      InAppWebViewPointerEventKind.down,
                      ev.pointer,
                      ev.localPosition,
                      ev.size,
                      ev.pressure,
                    );
                    return;
                  }
                  final button = _getButton(ev.buttons);
                  _downButtons[ev.pointer] = button;
                  _controller._setPointerButtonState(
                    InAppWebViewPointerEventKind.down,
                    button,
                  );
                },
                onPointerUp: (ev) {
                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    _resetPullToRefreshCandidate(ev.pointer);
                    _controller._setPointerUpdate(
                      InAppWebViewPointerEventKind.up,
                      ev.pointer,
                      ev.localPosition,
                      ev.size,
                      ev.pressure,
                    );
                    return;
                  }
                  final button = _downButtons.remove(ev.pointer);
                  if (button != null) {
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.up,
                      button,
                    );
                  }
                },
                onPointerCancel: (ev) {
                  _pointerKind = ev.kind;
                  _resetPullToRefreshCandidate(ev.pointer);
                  final button = _downButtons.remove(ev.pointer);
                  if (button != null) {
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.cancel,
                      button,
                    );
                  }
                },
                onPointerMove: (ev) {
                  _pointerKind = ev.kind;
                  if (ev.kind == PointerDeviceKind.touch) {
                    _updatePullToRefreshCandidate(ev);
                    _controller._setPointerUpdate(
                      InAppWebViewPointerEventKind.update,
                      ev.pointer,
                      ev.localPosition,
                      ev.size,
                      ev.pressure,
                    );
                  } else {
                    _controller._setCursorPos(ev.localPosition);
                  }
                },
                onPointerSignal: (signal) {
                  if (signal is PointerScrollEvent) {
                    _controller._setScrollDelta(
                      -signal.scrollDelta.dx,
                      -signal.scrollDelta.dy,
                    );
                  }
                },
                onPointerPanZoomUpdate: (ev) {
                  _controller._setScrollDelta(ev.panDelta.dx, ev.panDelta.dy);
                },
                child: MouseRegion(
                  cursor: _cursor,
                  onEnter: (ev) {
                    final button = _getButton(ev.buttons);
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.enter,
                      button,
                    );
                  },
                  onExit: (ev) {
                    final button = _getButton(ev.buttons);
                    _controller._setPointerButtonState(
                      InAppWebViewPointerEventKind.leave,
                      button,
                    );
                  },
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Texture(
                        textureId: _controller._textureId,
                        filterQuality: widget.filterQuality,
                      ),
                      _buildRefreshIndicator(),
                    ],
                  ),
                ),
              )
            : const SizedBox(),
      ),
    );
  }

  void _startPullToRefreshCandidate(PointerDownEvent event) {
    final controller = widget.pullToRefreshController;
    final canStart = widget.canStartPullToRefresh;
    if (controller is! WindowsPullToRefreshController ||
        !controller.allowWithNoScrollbar ||
        controller.settings.enabled == false ||
        canStart == null) {
      return;
    }

    final generation = ++_pullGestureGeneration;
    _pullPointer = event.pointer;
    _pullStartPosition = event.localPosition;
    _pullDistance = 0;
    _pullTopConfirmed = false;

    unawaited(
      canStart().then((atTop) {
        if (!mounted ||
            generation != _pullGestureGeneration ||
            _pullPointer != event.pointer) {
          return;
        }
        _pullTopConfirmed = atTop;
      }),
    );
  }

  void _updatePullToRefreshCandidate(PointerMoveEvent event) {
    final controller = widget.pullToRefreshController;
    final startPosition = _pullStartPosition;
    if (controller is! WindowsPullToRefreshController ||
        !_pullTopConfirmed ||
        _pullPointer != event.pointer ||
        startPosition == null) {
      return;
    }

    final distance = event.localPosition.dy - startPosition.dy;
    if (distance <= _pullDistance) {
      return;
    }
    _pullDistance = distance;
    if (_pullDistance >= controller.triggerDistance) {
      _pullTopConfirmed = false;
      controller.triggerRefresh();
    }
  }

  void _resetPullToRefreshCandidate(int pointer) {
    if (_pullPointer != pointer) {
      return;
    }
    _pullGestureGeneration++;
    _pullPointer = null;
    _pullStartPosition = null;
    _pullDistance = 0;
    _pullTopConfirmed = false;
  }

  Widget _buildRefreshIndicator() {
    final controller = widget.pullToRefreshController;
    if (controller is! WindowsPullToRefreshController) {
      return const SizedBox.shrink();
    }
    return Positioned(
      top: 12,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: ValueListenableBuilder<bool>(
          valueListenable: controller.refreshState,
          builder: (context, refreshing, child) {
            if (!refreshing) {
              return const SizedBox.shrink();
            }
            return Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: controller.backgroundColor ?? Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: controller.indicatorColor,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _reportSurfaceSize() async {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached) {
      await _controller.ready;
      if (!mounted || !box.attached) {
        return;
      }
      unawaited(
        _controller._setSize(
          box.size,
          widget.scaleFactor ?? window.devicePixelRatio,
        ),
      );
    }
  }

  void _reportWidgetPosition() async {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.attached) {
      await _controller.ready;
      if (!mounted || !box.attached) {
        return;
      }
      final position = box.localToGlobal(Offset.zero);
      unawaited(
        _controller._setPosition(
          position,
          widget.scaleFactor ?? window.devicePixelRatio,
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _platformUtil.removeListener(this);
    _cursorSubscription?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _listener.dispose();
  }
}
