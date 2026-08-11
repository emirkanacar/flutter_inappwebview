import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_DISPLAY_SIZE_RECOVERY_DIAGNOSTIC',
);

const _webViewKey = ValueKey<String>('android-2721-display-size-webview');

const _diagnosticPage = '''
<!doctype html>
<html>
<body>
<p>Android display-size recovery diagnostic</p>
<script>
  window.__forgeResizeCount = 0;
  function recordResize() {
    window.__forgeResizeCount += 1;
    document.body.setAttribute(
      'data-forge-geometry',
      window.innerWidth + 'x' + window.innerHeight,
    );
  }
  window.addEventListener('resize', recordResize);
  recordResize();
</script>
</body>
</html>
''';

Future<Map<String, dynamic>> _readGeometry(
  InAppWebViewController controller,
) async {
  final value = await controller.evaluateJavascript(
    source: '''
      JSON.stringify({
        "width": window.innerWidth,
        "height": window.innerHeight,
        "resizeCount": window.__forgeResizeCount,
        "marker": document.body.getAttribute('data-forge-geometry')
      })
    ''',
  );

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }
  if (value is String) {
    final decoded = jsonDecode(value);
    if (decoded is String) {
      return Map<String, dynamic>.from(jsonDecode(decoded) as Map);
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
  }
  throw StateError('Unexpected geometry response: $value');
}

// Opt-in diagnostic for issue #2721. Start this test, then change and restore
// the emulator display size from the host while it waits:
//
//   adb -s emulator-5554 shell wm size 900x2000
//   adb -s emulator-5554 shell wm size reset
//
// The diagnostic requires both resize callbacks and the original geometry to
// return after the display size is restored.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2721 display-size change restores WebView geometry',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      var created = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              key: _webViewKey,
              initialData: InAppWebViewInitialData(data: _diagnosticPage),
              onWebViewCreated: (controller) {
                created = true;
                if (!controllerCompleter.isCompleted) {
                  controllerCompleter.complete(controller);
                }
              },
            ),
          ),
        ),
      );

      for (var attempt = 0; attempt < 100 && !created; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(created, isTrue);
      if (!created) {
        return;
      }
      final controller = await controllerCompleter.future;
      await tester.pump(const Duration(seconds: 2));

      final initialGeometry = await _readGeometry(controller);
      final initialFlutterSize = tester.getSize(find.byKey(_webViewKey));
      Map<String, dynamic>? finalGeometry;
      Size? finalFlutterSize;

      for (var attempt = 0; attempt < 240; attempt++) {
        await tester.pump(const Duration(milliseconds: 250));
        finalGeometry = await _readGeometry(controller);
        finalFlutterSize = tester.getSize(find.byKey(_webViewKey));
        final resizeCount =
            (finalGeometry['resizeCount'] as num?)?.toInt() ?? 0;
        if (resizeCount >= 3) {
          break;
        }
      }

      debugPrint(
        'Android #2721 diagnostic: initialGeometry=$initialGeometry '
        'finalGeometry=$finalGeometry '
        'initialFlutterSize=$initialFlutterSize '
        'finalFlutterSize=$finalFlutterSize',
      );

      final resizeCount = (finalGeometry?['resizeCount'] as num?)?.toInt() ?? 0;
      expect(
        resizeCount,
        greaterThanOrEqualTo(3),
        reason:
            'Run the diagnostic with one wm size change and a subsequent '
            'wm size reset while the test is waiting.',
      );
      expect(finalGeometry?['width'], initialGeometry['width']);
      expect(finalGeometry?['height'], initialGeometry['height']);
      expect(finalFlutterSize, initialFlutterSize);
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
