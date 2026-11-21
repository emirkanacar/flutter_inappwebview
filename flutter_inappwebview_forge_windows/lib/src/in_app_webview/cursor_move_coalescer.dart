import 'dart:ui';

/// Coalesces virtual cursor moves to one platform message per frame.
///
/// Flutter delivers one hover event per mouse sample (hundreds per second on a
/// fast mouse); WebView2 only needs the latest position before it paints. The
/// native button, touch and wheel handlers use the last cursor position, so
/// callers must [flush] before sending any other pointer input.
class CursorMoveCoalescer {
  CursorMoveCoalescer({required this.send, required this.scheduleFrame});

  /// Sends a move to the native view.
  final void Function(Offset position) send;

  /// Runs the callback once before the next frame.
  final void Function(VoidCallback callback) scheduleFrame;

  Offset? _pending;
  bool _frameScheduled = false;

  /// Records [position]; the last one recorded in a frame is sent.
  void move(Offset position) {
    _pending = position;
    if (_frameScheduled) {
      return;
    }
    _frameScheduled = true;
    scheduleFrame(() {
      _frameScheduled = false;
      flush();
    });
  }

  /// Sends the pending move now, if any.
  void flush() {
    final pending = _pending;
    _pending = null;
    if (pending != null) {
      send(pending);
    }
  }

  /// Drops the pending move without sending it.
  void discard() {
    _pending = null;
  }
}
