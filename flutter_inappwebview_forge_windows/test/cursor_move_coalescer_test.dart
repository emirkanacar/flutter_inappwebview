import 'dart:ui';

import 'package:flutter_inappwebview_forge_windows/src/in_app_webview/cursor_move_coalescer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Upstream PR #2938: one setCursorPos platform message per hover sample is
  // coalesced to the last sample of each frame. Button, touch and wheel input
  // use the native last cursor position, so they must flush a pending move
  // first, and dispose must drop it.
  late List<Offset> sent;
  late List<VoidCallback> frames;
  late CursorMoveCoalescer coalescer;

  setUp(() {
    sent = [];
    frames = [];
    coalescer = CursorMoveCoalescer(send: sent.add, scheduleFrame: frames.add);
  });

  test('sends only the last move of a frame', () {
    coalescer.move(const Offset(1, 1));
    coalescer.move(const Offset(2, 2));
    coalescer.move(const Offset(3, 3));
    expect(sent, isEmpty);
    expect(frames, hasLength(1));

    frames.single();
    expect(sent, [const Offset(3, 3)]);

    coalescer.move(const Offset(4, 4));
    expect(frames, hasLength(2));
    frames.last();
    expect(sent, [const Offset(3, 3), const Offset(4, 4)]);
  });

  test('flush sends the pending move before other pointer input', () {
    coalescer.move(const Offset(5, 5));
    coalescer.flush();
    expect(sent, [const Offset(5, 5)]);

    frames.single();
    expect(sent, [const Offset(5, 5)]);
    coalescer.flush();
    expect(sent, hasLength(1));
  });

  test('discard drops the pending move', () {
    coalescer.move(const Offset(6, 6));
    coalescer.discard();
    frames.single();
    coalescer.flush();
    expect(sent, isEmpty);
  });
}
