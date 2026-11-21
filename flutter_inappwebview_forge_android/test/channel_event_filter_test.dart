import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_android/src/in_app_webview/_channel_event_filter.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_android/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

const _allFilterable = [
  'onConsoleMessage',
  'onScrollChanged',
  'onProgressChanged',
  'onTitleChanged',
  'onOverScrolled',
  'onZoomScaleChanged',
];

const _native =
    'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('skippedChannelEvents', () {
    test('lists every filterable event when no callback is set', () {
      expect(
        skippedChannelEvents(PlatformWebViewCreationParams()),
        _allFilterable,
      );
    });

    test('keeps events that have a listener', () {
      final skipped = skippedChannelEvents(
        PlatformWebViewCreationParams(
          onConsoleMessage: (controller, message) {},
          onScrollChanged: (controller, x, y) {},
        ),
      );
      expect(skipped, isNot(contains('onConsoleMessage')));
      expect(skipped, isNot(contains('onScrollChanged')));
      expect(skipped, contains('onProgressChanged'));
    });

    test('the deprecated androidOnScaleChanged keeps onZoomScaleChanged', () {
      final skipped = skippedChannelEvents(
        PlatformWebViewCreationParams(
          // ignore: deprecated_member_use
          androidOnScaleChanged: (controller, oldScale, newScale) {},
        ),
      );
      expect(skipped, isNot(contains('onZoomScaleChanged')));
    });
  });

  group('headless run', () {
    const channel = MethodChannel(
      'com.emirkanacar/flutter_headless_inappwebview',
    );
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final calls = <MethodCall>[];

    setUp(() {
      calls.clear();
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });
    });
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    test('sends skippedEvents in the native creation params', () async {
      final headless = AndroidHeadlessInAppWebView(
        AndroidHeadlessInAppWebViewCreationParams(
          onProgressChanged: (controller, progress) {},
        ),
      );
      await headless.run();

      final params = (calls.single.arguments as Map)['params'] as Map;
      final skipped = params[skippedChannelEventsKey] as List;
      expect(skipped, isNot(contains('onProgressChanged')));
      expect(skipped, contains('onConsoleMessage'));
    });
  });

  group('native contract', () {
    test('native allowlist matches the Dart filterable events', () {
      final source = _sourceFile(
        '${_native}webview/ChannelEventFilter.kt',
      ).readAsStringSync();
      expect(source, contains('const val CREATION_PARAM = "skippedEvents"'));
      expect(skippedChannelEventsKey, 'skippedEvents');
      for (final event in _allFilterable) {
        expect(source, contains('"$event"'), reason: event);
      }
      final quoted = RegExp(r'setOf\(([^)]*)\)').firstMatch(source)!.group(1)!;
      expect(
        RegExp(r'"(\w+)"').allMatches(quoted).map((m) => m.group(1)).toSet(),
        _allFilterable.toSet(),
      );
    });

    test('filter is checked only for fire-and-forget events', () {
      final source = _sourceFile(
        '${_native}webview/WebViewChannelDelegate.kt',
      ).readAsStringSync();
      final invokeEvent = RegExp(
        r'private fun invokeEvent\([^{]*\{([^}]*)\}',
      ).firstMatch(source)!.group(1)!;
      expect(invokeEvent, contains('channelEventFilter?.isSkipped(method)'));
      final invokeCallback = RegExp(
        r'private fun invokeCallback\([^{]*\{(.*?)\n  \}',
        dotAll: true,
      ).firstMatch(source)!.group(1)!;
      expect(invokeCallback, isNot(contains('channelEventFilter')));
      for (final event in _allFilterable) {
        expect(
          source,
          contains('invokeEvent("$event"'),
          reason: '$event must stay a fire-and-forget event',
        );
      }
    });

    test('skipped scroll events do not schedule a frame dispatch', () {
      final source = _sourceFile(
        '${_native}webview/in_app_webview/InAppWebView.kt',
      ).readAsStringSync();
      final skip = source.indexOf(
        'if (channelEventFilter.isSkipped("onScrollChanged")) return',
      );
      expect(skip, greaterThan(0));
      expect(skip, lessThan(source.indexOf('pendingScrollX = x')));
    });

    test('filter is re-applied for new, KeepAlive, and headless views', () {
      final factory = _sourceFile(
        '${_native}webview/FlutterWebViewFactory.kt',
      ).readAsStringSync();
      final flutterWebView = _sourceFile(
        '${_native}webview/in_app_webview/FlutterWebView.kt',
      ).readAsStringSync();
      final applyInFactory = factory.indexOf('channelEventFilter?.update(');
      expect(applyInFactory, greaterThan(0));
      expect(
        applyInFactory,
        lessThan(factory.indexOf('markRetainedWebViewReattached()')),
      );
      expect(
        flutterWebView,
        contains(
          'channelEventFilter.update(params[ChannelEventFilter.CREATION_PARAM])',
        ),
      );
    });
  });
}
