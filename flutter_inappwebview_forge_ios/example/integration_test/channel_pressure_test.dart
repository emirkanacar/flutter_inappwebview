// Device measurement for the no-listener channel event filter and the
// console hook gate. Run on a physical device:
//
//   fvm flutter test integration_test/channel_pressure_test.dart -d <device>
//
// The "listener" case does the same JavaScript and native work that the
// pre-filter build did for every WebView, so it is the baseline for the
// "no listener" case.

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge_ios/flutter_inappwebview_forge_ios.dart';
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

const _hookState = '''
(function() {
  var b = window.flutter_inappwebview;
  if (b == null) { return 'no-bridge'; }
  return String(b._consoleLogHooked) + '/' + String(b._consoleMessagesEnabled);
})();
''';

// Results go to <app container>/tmp/channel_pressure.log so they can be read
// with `xcrun devicectl device copy from` when no VM service is attached.
final _logFile = File('${Directory.systemTemp.path}/channel_pressure.log');
final _clock = Stopwatch()..start();

void _log(String line) {
  final text =
      '[${(_clock.elapsedMilliseconds / 1000).toStringAsFixed(1)}s] $line';
  // ignore: avoid_print
  print(text);
  _logFile.writeAsStringSync('$text\n', mode: FileMode.append, flush: true);
}

Future<void> _step(String name, Future<void> Function() body) async {
  _log('START $name');
  try {
    await body();
    _log('PASS $name');
  } catch (error, stack) {
    _log('FAIL $name: $error');
    _log(stack.toString().split('\n').take(8).join('\n'));
    rethrow;
  }
}

class _Probe {
  IOSInAppWebViewController? controller;
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
      // UiKitView, which Flutter would otherwise reuse without a new WebView.
      body: KeyedSubtree(
        key: key ?? const ValueKey('webview'),
        child: Builder(
          builder: (context) => IOSInAppWebViewWidget(
            IOSInAppWebViewWidgetCreationParams(
              key: key,
              keepAlive: keepAlive,
              initialData: InAppWebViewInitialData(data: _html),
              onWebViewCreated: (controller) {
                probe.controller = controller as IOSInAppWebViewController;
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
  _log('  console listener=$listener: waiting for load');
  await _waitLoaded(tester, probe);
  final hook = await _eval(tester, probe, _hookState);
  _log('  console listener=$listener: loaded, hook=$hook');
  ChannelCallStats.reset();

  final times = <double>[];
  final wall = Stopwatch()..start();
  for (var round = 0; round < _rounds; round++) {
    final ms = await _eval(tester, probe, _consoleLoop);
    times.add((ms as num).toDouble());
    _log('  console listener=$listener: round $round js=${ms}ms');
  }
  // Let queued bridge messages drain before counting.
  await _settle(tester, const Duration(seconds: 3));
  wall.stop();

  times.sort();
  return {
    'hook': '$hook',
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
  _log('  scroll listener=$listener: waiting for load');
  await _waitLoaded(tester, probe);
  _log('  scroll listener=$listener: loaded');
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

  setUpAll(() {
    if (_logFile.existsSync()) _logFile.deleteSync();
    _log('BEGIN on ${Platform.operatingSystemVersion}');
    ChannelCallStats.enabled = true;
  });

  tearDownAll(() => _log('END'));

  testWidgets('console: listener vs no listener', (tester) async {
    await _step('console: listener vs no listener', () async {
      // Warm up WebKit so the first measured WebView is not penalized.
      await _measureConsole(tester, listener: true);

      final withListener = await _measureConsole(tester, listener: true);
      final withoutListener = await _measureConsole(tester, listener: false);
      _log('RESULT console listener: $withListener');
      _log('RESULT console no-listener: $withoutListener');

      expect(withListener['dartReceived'], _logCount * _rounds);
      expect(withoutListener['channelCalls'], 0);
      expect(withoutListener['hook'], 'undefined/undefined');
    });
  });

  testWidgets('scroll: listener vs no listener', (tester) async {
    await _step('scroll: listener vs no listener', () async {
      final withListener = await _measureScroll(tester, listener: true);
      final withoutListener = await _measureScroll(tester, listener: false);
      _log('RESULT scroll listener: $withListener');
      _log('RESULT scroll no-listener: $withoutListener');

      expect(withListener['dartReceived'] as int, greaterThan(0));
      expect(withoutListener['channelCalls'], 0);
    });
  });

  testWidgets('KeepAlive reattach switches the console hook', (tester) async {
    await _step('KeepAlive reattach switches the console hook', () async {
      final keepAlive = InAppWebViewKeepAlive();
      final probe = _Probe();
      final states = <String>[];

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

      Future<int> logAndCount() async {
        probe.consoleMessages = 0;
        await _eval(tester, probe, "console.log('keepalive'); 1;");
        await _settle(tester, const Duration(seconds: 1));
        return probe.consoleMessages;
      }

      // 1. No listener: the hook is not injected.
      await tester.pumpWidget(
        _webView(
          probe,
          consoleListener: false,
          scrollListener: false,
          keepAlive: keepAlive,
        ),
      );
      await _waitLoaded(tester, probe);
      states.add('start:${await _eval(tester, probe, _hookState)}');
      expect(states.last, 'start:undefined/undefined');

      // 2. Reattach with a listener: the current document gets the hook.
      await attach(listener: true);
      states.add('listener:${await _eval(tester, probe, _hookState)}');
      expect(states.last, 'listener:true/true');
      expect(await logAndCount(), 1);

      // 3. Reattach without a listener: the current document stops sending.
      await attach(listener: false);
      states.add('none:${await _eval(tester, probe, _hookState)}');
      expect(states.last, 'none:true/false');
      ChannelCallStats.reset();
      await logAndCount();
      expect(_count('onConsoleMessage'), 0);

      // 4. The next navigation has no hook at all.
      probe.loaded = Completer<void>();
      await probe.controller!.reload();
      await _waitLoaded(tester, probe);
      states.add('reload:${await _eval(tester, probe, _hookState)}');
      expect(states.last, 'reload:undefined/undefined');

      // 5. Reattach with a listener once more: hooked again, one message each.
      await attach(listener: true);
      states.add('again:${await _eval(tester, probe, _hookState)}');
      expect(states.last, 'again:true/true');
      expect(await logAndCount(), 1);

      probe.loaded = Completer<void>();
      await probe.controller!.reload();
      await _waitLoaded(tester, probe);
      states.add('reload2:${await _eval(tester, probe, _hookState)}');
      expect(states.last, 'reload2:true/undefined');
      expect(await logAndCount(), 1);

      _log('RESULT keepalive states: $states');
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    });
  });
}
