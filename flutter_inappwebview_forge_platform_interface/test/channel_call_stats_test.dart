import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeController {}

void main() {
  final controller = _FakeController();

  tearDown(() {
    ChannelCallStats.enabled = false;
    ChannelCallStats.measurePayloadSize = false;
    ChannelCallStats.reset();
  });

  test('does not record while disabled', () async {
    final result = await ChannelCallStats.track(
      controller,
      const MethodCall('onScrollChanged', {'x': 1, 'y': 2}),
      (call) async => 'ok',
    );
    expect(result, 'ok');
    expect(ChannelCallStats.totalCount, 0);
    expect(ChannelCallStats.snapshot, isEmpty);
  });

  test('counts calls per controller type and method', () async {
    ChannelCallStats.enabled = true;
    for (var i = 0; i < 3; i++) {
      await ChannelCallStats.track(
        controller,
        MethodCall('onScrollChanged', {'x': i, 'y': i}),
        (call) async => null,
      );
    }
    await ChannelCallStats.track(
      controller,
      const MethodCall('onProgressChanged', {'progress': 50}),
      (call) async => null,
    );

    final stats = ChannelCallStats.snapshot;
    expect(ChannelCallStats.totalCount, 4);
    expect(stats['_FakeController.onScrollChanged']!.count, 3);
    expect(stats['_FakeController.onProgressChanged']!.count, 1);
    expect(stats['_FakeController.onScrollChanged']!.totalPayloadBytes, 0);
    expect(ChannelCallStats.report(), contains('onScrollChanged: count=3'));
  });

  test('measures encoded payload size when requested', () async {
    ChannelCallStats.enabled = true;
    ChannelCallStats.measurePayloadSize = true;
    const call = MethodCall('onConsoleMessage', {'message': 'hello'});
    await ChannelCallStats.track(controller, call, (call) async => null);

    final expected = const StandardMethodCodec()
        .encodeMethodCall(call)
        .lengthInBytes;
    expect(
      ChannelCallStats
          .snapshot['_FakeController.onConsoleMessage']!
          .totalPayloadBytes,
      expected,
    );
  });

  test('preserves handler errors and still records the call', () async {
    ChannelCallStats.enabled = true;
    await expectLater(
      ChannelCallStats.track(
        controller,
        const MethodCall('onLoadStop'),
        (call) async => throw StateError('boom'),
      ),
      throwsStateError,
    );
    expect(
      () => ChannelCallStats.track(
        controller,
        const MethodCall('onLoadStart'),
        (call) => throw ArgumentError('sync'),
      ),
      throwsArgumentError,
    );
    final stats = ChannelCallStats.snapshot;
    expect(stats['_FakeController.onLoadStop']!.count, 1);
    expect(stats['_FakeController.onLoadStart']!.count, 1);
  });

  test('snapshot is a copy and reset clears it', () async {
    ChannelCallStats.enabled = true;
    await ChannelCallStats.track(
      controller,
      const MethodCall('onTitleChanged'),
      (call) async => null,
    );
    final snapshot = ChannelCallStats.snapshot;
    snapshot['_FakeController.onTitleChanged']!.count = 99;
    expect(
      ChannelCallStats.snapshot['_FakeController.onTitleChanged']!.count,
      1,
    );
    ChannelCallStats.reset();
    expect(ChannelCallStats.totalCount, 0);
    expect(ChannelCallStats.elapsed, Duration.zero);
  });
}
