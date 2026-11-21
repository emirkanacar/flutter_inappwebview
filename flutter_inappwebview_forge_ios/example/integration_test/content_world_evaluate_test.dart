// Device regression test for evaluateJavascript with an explicit content world
// on a regular (non-popup) WebView. Before the fix, the nil-frame guard added
// for #2771 rejected every such call with "Frame is nil", so the Dart future
// completed with null. Run on a physical device:
//
//   fvm flutter test integration_test/content_world_evaluate_test.dart -d <device>

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge_ios/flutter_inappwebview_forge_ios.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Results also go to <app container>/tmp/content_world.log so they can be read
// with `xcrun devicectl device copy from` when no VM service is attached.
final _logFile = File('${Directory.systemTemp.path}/content_world.log');

void _log(String line) {
  // ignore: avoid_print
  print(line);
  _logFile.writeAsStringSync('$line\n', mode: FileMode.append, flush: true);
}

Future<T> _pumpUntil<T>(WidgetTester tester, Future<T> future) async {
  T? result;
  var done = false;
  future.then((value) {
    result = value;
    done = true;
  });
  final end = DateTime.now().add(const Duration(seconds: 20));
  while (!done && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue, reason: 'timed out');
  return result as T;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    if (_logFile.existsSync()) _logFile.deleteSync();
    _log('BEGIN on ${Platform.operatingSystemVersion}');
  });

  tearDownAll(() => _log('END'));

  testWidgets('evaluateJavascript works in the page and a custom world', (
    tester,
  ) async {
    IOSInAppWebViewController? controller;
    final loaded = Completer<void>();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => IOSInAppWebViewWidget(
              IOSInAppWebViewWidgetCreationParams(
                initialData: InAppWebViewInitialData(
                  data: '<!DOCTYPE html><html><body>worlds</body></html>',
                ),
                onWebViewCreated: (c) =>
                    controller = c as IOSInAppWebViewController,
                onLoadStop: (c, url) {
                  if (!loaded.isCompleted) loaded.complete();
                },
              ),
            ).build(context),
          ),
        ),
      ),
    );
    await _pumpUntil(tester, loaded.future);

    final results = <String, dynamic>{};
    try {
      results['page'] = await _pumpUntil(
        tester,
        controller!.evaluateJavascript(
          source: 'window.__forgePage = 7; 1 + 1;',
          contentWorld: ContentWorld.PAGE,
        ),
      );
      results['custom'] = await _pumpUntil(
        tester,
        controller!.evaluateJavascript(
          source:
              "window.__forgeCustom = 5; "
              "window.__forgePage === undefined ? 'isolated' : 'shared';",
          contentWorld: ContentWorld.world(name: 'forge_test_world'),
        ),
      );
      results['customAgain'] = await _pumpUntil(
        tester,
        controller!.evaluateJavascript(
          source: 'window.__forgeCustom;',
          contentWorld: ContentWorld.world(name: 'forge_test_world'),
        ),
      );
      results['pageSeesCustom'] = await _pumpUntil(
        tester,
        controller!.evaluateJavascript(
          source: 'typeof window.__forgeCustom;',
        ),
      );
      _log('RESULT $results');

      expect(results['page'], 2);
      expect(results['custom'], 'isolated');
      expect(results['customAgain'], 5);
      expect(results['pageSeesCustom'], 'undefined');
      _log('PASS content worlds');
    } catch (error) {
      _log('FAIL $error');
      rethrow;
    }
  });
}
