import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_macos/flutter_inappwebview_forge_macos.dart';
import 'package:flutter_inappwebview_forge_macos/src/in_app_webview/_channel_event_filter.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_macos/$relativePath'),
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
    'macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos/InAppWebView/';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('skippedChannelEvents lists only events without a listener', () {
    expect(
      skippedChannelEvents(PlatformWebViewCreationParams()),
      _allFilterable,
    );
    final skipped = skippedChannelEvents(
      PlatformWebViewCreationParams(
        onTitleChanged: (controller, title) {},
        onZoomScaleChanged: (controller, oldScale, newScale) {},
      ),
    );
    expect(skipped, isNot(contains('onTitleChanged')));
    expect(skipped, isNot(contains('onZoomScaleChanged')));
    expect(skipped, contains('onScrollChanged'));
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
      final headless = MacOSHeadlessInAppWebView(
        MacOSHeadlessInAppWebViewCreationParams(
          onConsoleMessage: (controller, message) {},
        ),
      );
      await headless.run();

      final params = (calls.single.arguments as Map)['params'] as Map;
      final skipped = params[skippedChannelEventsKey] as List;
      expect(skipped, isNot(contains('onConsoleMessage')));
      expect(skipped, contains('onProgressChanged'));
    });
  });

  group('native contract', () {
    test('native allowlist matches the Dart filterable events', () {
      final source = _sourceFile(
        '${_native}ChannelEventFilter.swift',
      ).readAsStringSync();
      expect(source, contains('static let CREATION_PARAM = "skippedEvents"'));
      expect(skippedChannelEventsKey, 'skippedEvents');
      final body = RegExp(
        r'SKIPPABLE_EVENTS: Set<String> = \[([^\]]*)\]',
      ).firstMatch(source)!.group(1)!;
      expect(
        RegExp(r'"(\w+)"').allMatches(body).map((m) => m.group(1)).toSet(),
        _allFilterable.toSet(),
      );
    });

    test('filter is checked only for fire-and-forget events', () {
      final source = _sourceFile(
        '${_native}WebViewChannelDelegate.swift',
      ).readAsStringSync();
      final fireAndForget = RegExp(
        r'private func invokeMethod\(_ method: String, arguments: Any\) \{([^}]*)\}',
      ).firstMatch(source)!.group(1)!;
      expect(fireAndForget, contains('channelEventFilter.isSkipped(method)'));
      expect(
        'channelEventFilter'.allMatches(source).length,
        1,
        reason: 'callbacks that wait for a Dart result must not be filtered',
      );
      for (final event in _allFilterable) {
        expect(
          source,
          contains('invokeMethod("$event", arguments: arguments)'),
          reason: '$event must stay a fire-and-forget event',
        );
      }
    });

    test('filter is re-applied for new, KeepAlive, and headless views', () {
      final factory = _sourceFile(
        '${_native}FlutterWebViewFactory.swift',
      ).readAsStringSync();
      final controller = _sourceFile(
        '${_native}FlutterWebViewController.swift',
      ).readAsStringSync();
      final apply = factory.indexOf(
        'updateChannelEventFilter(arguments?[ChannelEventFilter.CREATION_PARAM])',
      );
      expect(apply, greaterThan(0));
      expect(
        apply,
        lessThan(factory.indexOf('markRetainedWebViewReattached()')),
      );
      expect(
        controller,
        contains(
          'updateChannelEventFilter(params[ChannelEventFilter.CREATION_PARAM])',
        ),
      );
    });

    test('console hook is not injected without a console listener', () {
      final webView = _sourceFile(
        '${_native}InAppWebView.swift',
      ).readAsStringSync();
      final gate = webView.indexOf(
        'if !channelEventFilter.isSkipped("onConsoleMessage") {',
      );
      expect(gate, greaterThan(0));
      final add = webView.indexOf(
        'addPluginScript(ConsoleLogJS.CONSOLE_LOG_JS_PLUGIN_SCRIPT(',
      );
      expect(add, greaterThan(gate));
      expect(
        add,
        lessThan(webView.indexOf('}', gate)),
        reason: 'the initial console script must be inside the gate',
      );

      final update = RegExp(
        r'public func updateChannelEventFilter\(_ raw: Any\?\) \{([\s\S]*?)\n    \}\n',
      ).firstMatch(webView)!.group(1)!;
      expect(update, contains('channelEventFilter.update(raw)'));
      expect(update, contains('windowId == nil'));
      expect(update, contains('lifecycle.state != .creating'));
      expect(update, contains('lifecycle.acceptsCallbacks'));
      expect(update, contains('removePluginScripts(with: groupName)'));
      expect(update, contains('SET_CONSOLE_MESSAGES_ENABLED_JS_SOURCE'));
      expect(update, contains('sync(scriptMessageHandler: self)'));
    });

    test('console hook skips work when disabled and hooks once', () {
      final source = _sourceFile(
        '${_native}../PluginScriptsJS/ConsoleLogJS.swift',
      ).readAsStringSync();
      final handler = source.indexOf('function _callHandler(logLevel, args) {');
      final check = source.indexOf(
        "bridge._consoleMessagesEnabled === false) { return; }",
      );
      expect(check, greaterThan(handler));
      expect(
        check,
        lessThan(source.indexOf("var message = '';", handler)),
        reason: 'disabled messages must return before stringifying',
      );
      expect(
        source,
        contains('if (_bridge._consoleLogHooked === true) { return; }'),
      );
      expect(source, contains('_consoleMessagesEnabled = \\(enabled); }'));
    });
  });
}
