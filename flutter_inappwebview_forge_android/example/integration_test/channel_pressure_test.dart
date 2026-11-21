// Device measurement for the no-listener channel event filter. Run on a
// physical device:
//
//   fvm flutter test integration_test/channel_pressure_test.dart -d <device>
//
// Android console messages come from WebChromeClient, so there is no
// JavaScript hook to check; the filter only removes the channel traffic. The
// "listener" case does the same native work that the pre-filter build did for
// every WebView, so it is the baseline for the "no listener" case.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _logCount = 5000;
const _rounds = 5;

const _html = '''
<!DOCTYPE html>
<html><head><meta name="viewport" content="width=device-width"></head>
<body style="height: 20000px; margin: 0;">channel pressure</body></html>
''';

const _consoleLoop =
    '''
(function() {
  var start = performance.now();
  for (var i = 0; i < $_logCount; i++) {
    console.log('message', i, {index: i, text: 'payload'});
  }
  return performance.now() - start;
})();
''';

void _log(String line) {
  // ignore: avoid_print
  print('[channel_pressure] $line');
}

class _Probe {
  AndroidInAppWebViewController? controller;
  Completer<void> loaded = Completer<void>();
  int consoleMessages = 0;
  int scrollEvents = 0;
}

Widget _webView(
  _Probe probe, {
  required bool consoleListener,
  required bool scrollListener,
  InAppWebViewKeepAlive? keepAlive,
  Key? key,
}) {
  return MaterialApp(
    home: Scaffold(
      // The key must be on a widget in the tree: build() returns an unkeyed
      // platform view, which Flutter would otherwise reuse.
      body: KeyedSubtree(
        key: key ?? const ValueKey('webview'),
        child: Builder(
          builder: (context) => AndroidInAppWebViewWidget(
            AndroidInAppWebViewWidgetCreationParams(
              key: key,
              keepAlive: keepAlive,
              initialData: InAppWebViewInitialData(data: _html),
              onWebViewCreated: (controller) {
                probe.controller = controller as AndroidInAppWebViewController;
              },
              onLoadStop: (controller, url) {
                if (!probe.loaded.isCompleted) probe.loaded.complete();
              },
              onConsoleMessage: consoleListener
                  ? (controller, message) => probe.consoleMessages++
                  : null,
              onScrollChanged: scrollListener
                  ? (controller, x, y) => probe.scrollEvents++
                  : null,
            ),
          ).build(context),
        ),
      ),
    ),
  );
}

Future<void> _settle(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<void> _waitLoaded(WidgetTester tester, _Probe probe) async {
  final end = DateTime.now().add(const Duration(seconds: 20));
  while (!probe.loaded.isCompleted && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  expect(probe.loaded.isCompleted, isTrue, reason: 'page did not load');
}

Future<dynamic> _eval(WidgetTester tester, _Probe probe, String source) async {
  final future = probe.controller!.evaluateJavascript(source: source);
  dynamic result;
  var done = false;
  future.then((value) {
    result = value;
    done = true;
  });
  final end = DateTime.now().add(const Duration(seconds: 60));
  while (!done && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue, reason: 'evaluateJavascript timed out');
  return result;
}

int _count(String method) => ChannelCallStats.snapshot.values
    .where((s) => s.method == method)
    .fold(0, (sum, s) => sum + s.count);

Future<Map<String, Object>> _measureConsole(
  WidgetTester tester, {
  required bool listener,
}) async {
  final probe = _Probe();
  await tester.pumpWidget(
    _webView(
      probe,
      consoleListener: listener,
      scrollListener: false,
      key: UniqueKey(),
    ),
  );
  await _waitLoaded(tester, probe);
  ChannelCallStats.reset();

  final times = <double>[];
  final wall = Stopwatch()..start();
  for (var round = 0; round < _rounds; round++) {
    final ms = await _eval(tester, probe, _consoleLoop);
    times.add((ms as num).toDouble());
  }
  // Let queued channel messages drain before counting.
  final drain = DateTime.now().add(const Duration(seconds: 30));
  while (listener &&
      probe.consoleMessages < _logCount * _rounds &&
      DateTime.now().isBefore(drain)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
  wall.stop();
  await _settle(tester, const Duration(seconds: 1));

  times.sort();
  return {
    'jsMedianMs': times[times.length ~/ 2],
    'jsMinMs': times.first,
    'channelCalls': _count('onConsoleMessage'),
    'dartReceived': probe.consoleMessages,
    'wallMs': wall.elapsedMilliseconds,
  };
}

Future<Map<String, Object>> _measureScroll(
  WidgetTester tester, {
  required bool listener,
}) async {
  final probe = _Probe();
  await tester.pumpWidget(
    _webView(
      probe,
      consoleListener: false,
      scrollListener: listener,
      key: UniqueKey(),
    ),
  );
  await _waitLoaded(tester, probe);
  ChannelCallStats.reset();
  for (var y = 0; y <= 15000; y += 50) {
    await probe.controller!.scrollTo(x: 0, y: y);
    await tester.pump(const Duration(milliseconds: 8));
  }
  await _settle(tester, const Duration(seconds: 2));
  return {
    'channelCalls': _count('onScrollChanged'),
    'dartReceived': probe.scrollEvents,
  };
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => ChannelCallStats.enabled = true);

  testWidgets('console: listener vs no listener', (tester) async {
    // Warm up the WebView so the first measured instance is not penalized.
    await _measureConsole(tester, listener: true);

    final withListener = await _measureConsole(tester, listener: true);
    final withoutListener = await _measureConsole(tester, listener: false);
    _log('RESULT console listener: $withListener');
    _log('RESULT console no-listener: $withoutListener');

    expect(withListener['dartReceived'], _logCount * _rounds);
    expect(withoutListener['channelCalls'], 0);
  });

  testWidgets('scroll: listener vs no listener', (tester) async {
    final withListener = await _measureScroll(tester, listener: true);
    final withoutListener = await _measureScroll(tester, listener: false);
    _log('RESULT scroll listener: $withListener');
    _log('RESULT scroll no-listener: $withoutListener');

    expect(withListener['dartReceived'] as int, greaterThan(0));
    expect(withoutListener['channelCalls'], 0);
  });

  testWidgets('KeepAlive reattach follows the new console listener', (
    tester,
  ) async {
    final keepAlive = InAppWebViewKeepAlive();
    final probe = _Probe();
    final results = <String>[];

    Future<void> attach({required bool listener}) async {
      // Detach first so the next build reattaches the retained WebView.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      await _settle(tester, const Duration(milliseconds: 500));
      probe.controller = null;
      await tester.pumpWidget(
        _webView(
          probe,
          consoleListener: listener,
          scrollListener: false,
          keepAlive: keepAlive,
          key: UniqueKey(),
        ),
      );
      final end = DateTime.now().add(const Duration(seconds: 10));
      while (probe.controller == null && DateTime.now().isBefore(end)) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      await _settle(tester, const Duration(milliseconds: 500));
    }

    Future<String> logAndCount(String label) async {
      probe.consoleMessages = 0;
      ChannelCallStats.reset();
      await _eval(tester, probe, "console.log('keepalive'); 1;");
      await _settle(tester, const Duration(seconds: 1));
      final result =
          '$label:dart=${probe.consoleMessages},'
          'channel=${_count('onConsoleMessage')}';
      results.add(result);
      return result;
    }

    await tester.pumpWidget(
      _webView(
        probe,
        consoleListener: false,
        scrollListener: false,
        keepAlive: keepAlive,
      ),
    );
    await _waitLoaded(tester, probe);
    expect(await logAndCount('start'), 'start:dart=0,channel=0');

    await attach(listener: true);
    expect(await logAndCount('listener'), 'listener:dart=1,channel=1');

    await attach(listener: false);
    expect(await logAndCount('none'), 'none:dart=0,channel=0');

    await attach(listener: true);
    expect(await logAndCount('again'), 'again:dart=1,channel=1');

    _log('RESULT keepalive: $results');
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  });
}
