import 'dart:async';

import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ScreenshotCancellationSignal.guard', () {
    test('an already-cancelled signal never starts the capture', () async {
      final signal = ScreenshotCancellationSignal()..cancel('early');
      var started = false;
      final result = await signal.guard<int>(() {
        started = true;
        return Future<int?>.value(1);
      });
      expect(result, isNull);
      expect(started, isFalse);
      expect(signal.reason, 'early');
    });

    test('cancel completes with null and discards the late result', () async {
      final signal = ScreenshotCancellationSignal();
      final pending = Completer<int?>();
      String? forwarded;
      var onCancelCalls = 0;
      final future = signal.guard<int>(
        () => pending.future,
        onCancel: (reason) {
          onCancelCalls++;
          forwarded = reason;
        },
      );
      signal.cancel('gone');
      signal.cancel('again');
      expect(await future, isNull);
      pending.complete(42);
      await Future<void>.delayed(Duration.zero);
      expect(onCancelCalls, 1);
      expect(forwarded, 'gone');
    });

    test('a late error after cancel is swallowed', () async {
      final signal = ScreenshotCancellationSignal();
      final pending = Completer<int?>();
      final future = signal.guard<int>(() => pending.future);
      signal.cancel();
      expect(await future, isNull);
      pending.completeError(StateError('late'));
      await Future<void>.delayed(Duration.zero);
    });

    test('result, error and null channel pass through', () async {
      final signal = ScreenshotCancellationSignal();
      expect(await signal.guard<int>(() => Future<int?>.value(7)), 7);
      await expectLater(
        signal.guard<int>(() => Future<int?>.error(StateError('x'))),
        throwsStateError,
      );
      expect(await signal.guard<int>(() => null), isNull);
      await expectLater(
        signal.guard<int>(() => throw StateError('sync')),
        throwsStateError,
      );
    });

    test('completed captures detach their listener', () async {
      final signal = ScreenshotCancellationSignal();
      var onCancelCalls = 0;
      await signal.guard<int>(
        () => Future<int?>.value(1),
        onCancel: (_) => onCancelCalls++,
      );
      signal.cancel();
      expect(onCancelCalls, 0);
    });

    test('one signal cancels every concurrent capture', () async {
      final signal = ScreenshotCancellationSignal();
      final a = signal.guard<int>(() => Completer<int?>().future);
      final b = signal.guard<int>(() => Completer<int?>().future);
      signal.cancel();
      expect(await Future.wait([a, b]), [null, null]);
    });
  });

  test('ScreenshotConfiguration maps drawScaled and usePixelCopy', () {
    final defaults = ScreenshotConfiguration().toMap();
    expect(defaults['drawScaled'], false);
    expect(defaults['usePixelCopy'], false);
    final config = ScreenshotConfiguration.fromMap(
      ScreenshotConfiguration(drawScaled: true, usePixelCopy: true).toMap(),
    )!;
    expect(config.drawScaled, isTrue);
    expect(config.usePixelCopy, isTrue);
  });
}
