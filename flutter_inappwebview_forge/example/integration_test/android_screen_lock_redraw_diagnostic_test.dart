import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_SCREEN_LOCK_REDRAW_DIAGNOSTIC',
);
const _useHybridComposition = bool.fromEnvironment(
  'ANDROID_2837_USE_HYBRID_COMPOSITION',
  defaultValue: true,
);

const _diagnosticPage = '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; height: 100%; background: #123456; }
    body { display: grid; place-items: center; font-family: sans-serif; }
    #marker { color: white; font-size: 28px; font-weight: 700; }
  </style>
</head>
<body>
  <div id="marker">ANDROID_SCREEN_LOCK_MARKER</div>
</body>
</html>
''';

// Opt-in diagnostic for issue #2837. Start the test, then lock and unlock the
// connected Android device while it is waiting at the screen-lock checkpoint:
//
//   adb -s emulator-5554 shell input keyevent 26
//   adb -s emulator-5554 shell input keyevent 26
//
// The DOM marker and URL are checked after the visibility transition. This
// confirms that the WebView document survives the lock/unlock redraw path;
// screenshot capture remains a host-side visual check because the Flutter
// integration screenshot bridge can block with hybrid composition.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2837 screen-lock redraw diagnostic',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(
                useHybridComposition: _useHybridComposition,
              ),
              onWebViewCreated: (controller) {
                if (!controllerCompleter.isCompleted) {
                  controllerCompleter.complete(controller);
                }
              },
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future.timeout(
        const Duration(seconds: 30),
      );

      Future<String?> readMarker() async {
        return await controller.evaluateJavascript(
              source: "document.getElementById('marker')?.textContent",
            )
            as String?;
      }

      String? markerBefore;
      for (var attempt = 0; attempt < 30; attempt++) {
        markerBefore = await readMarker();
        if (markerBefore == 'ANDROID_SCREEN_LOCK_MARKER') {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 250));
        await tester.pump();
      }
      final urlBefore = await controller.getUrl();
      debugPrint(
        'Android #2837 ready: composition=${_useHybridComposition ? 'hybrid' : 'virtual'} '
        'markerBefore=$markerBefore urlBefore=$urlBefore; '
        'lock/unlock the device now; checkpoint is open for 12 seconds',
      );

      await Future<void>.delayed(const Duration(seconds: 12));
      await tester.pump();
      await tester.pump(const Duration(seconds: 2));

      final markerAfter = await readMarker();
      final urlAfter = await controller.getUrl();
      debugPrint(
        'Android #2837 result: composition=${_useHybridComposition ? 'hybrid' : 'virtual'} '
        'markerAfter=$markerAfter urlAfter=$urlAfter',
      );

      expect(markerBefore, 'ANDROID_SCREEN_LOCK_MARKER');
      expect(markerAfter, 'ANDROID_SCREEN_LOCK_MARKER');
      expect(urlAfter, urlBefore);
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
