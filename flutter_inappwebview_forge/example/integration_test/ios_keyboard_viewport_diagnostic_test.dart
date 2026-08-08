import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_IOS_KEYBOARD_VIEWPORT_DIAGNOSTIC',
);

const _webViewKey = ValueKey<String>('ios-keyboard-viewport-diagnostic');

const _diagnosticPage = '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; min-height: 1200px; font-family: sans-serif; }
    body { padding: 0; box-sizing: border-box; }
    #keyboard-input { display: block; margin: 0; width: 100%; height: 400px; font-size: 24px; }
    h1, p { margin-left: 24px; margin-right: 24px; }
    #fixed-footer {
      position: fixed;
      left: 0;
      right: 0;
      bottom: 0;
      height: 64px;
      padding: 16px;
      box-sizing: border-box;
      background: #1565c0;
      color: white;
    }
  </style>
</head>
<body>
  <h1>Keyboard viewport diagnostic</h1>
  <p>This page intentionally keeps a fixed element at the bottom.</p>
  <input id="keyboard-input" type="text" enterkeyhint="done">
  <div id="fixed-footer">fixed footer</div>
</body>
</html>
''';

// Opt-in diagnostic for issue #2787. Run it with
// --dart-define=RUN_IOS_KEYBOARD_VIEWPORT_DIAGNOSTIC=true on an iOS runtime
// where the software keyboard can be opened through the native platform view.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS #2787 keyboard viewport diagnostic',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            resizeToAvoidBottomInset: true,
            body: SafeArea(
              child: InAppWebView(
                key: _webViewKey,
                initialData: InAppWebViewInitialData(data: _diagnosticPage),
                onWebViewCreated: controllerCompleter.complete,
                onLoadStop: (controller, url) {
                  if (!pageLoaded.isCompleted) {
                    pageLoaded.complete();
                  }
                },
              ),
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await pageLoaded.future;

      Future<Map<String, dynamic>> readViewportMetrics() async {
        final result = await controller.evaluateJavascript(
          source: '''
            (() => {
              const viewport = window.visualViewport;
              return {
                "innerHeight": window.innerHeight,
                "clientHeight": document.documentElement.clientHeight,
                "visualViewportHeight": viewport?.height,
                "visualViewportOffsetTop": viewport?.offsetTop,
                "visualViewportPageTop": viewport?.pageTop,
                "scrollY": window.scrollY,
                "visualViewportScale": viewport?.scale,
                "activeElementId": document.activeElement?.id
              };
            })();
          ''',
        );
        return Map<String, dynamic>.from(result as Map);
      }

      Future<Map<String, dynamic>> waitForViewportLayout() async {
        for (var attempt = 0; attempt < 20; attempt++) {
          final metrics = await readViewportMetrics();
          if ((metrics['innerHeight'] as num).toDouble() > 0 &&
              (metrics['visualViewportHeight'] as num).toDouble() > 0) {
            return metrics;
          }
          await tester.pump(const Duration(milliseconds: 250));
        }
        throw StateError(
          'WKWebView did not report non-zero viewport metrics after loading.',
        );
      }

      final before = await waitForViewportLayout();
      debugPrint('iOS #2787 before keyboard: $before');

      final webViewRenderBox = tester.renderObject<RenderBox>(
        find.byKey(_webViewKey),
      );
      final webViewOrigin = webViewRenderBox.localToGlobal(Offset.zero);
      debugPrint(
        'iOS #2787 WebView frame: origin=$webViewOrigin size=${webViewRenderBox.size}',
      );
      final inputTapPoint = webViewOrigin +
          Offset(webViewRenderBox.size.width / 2, 220);
      await tester.tapAt(inputTapPoint);
      await tester.pump(const Duration(milliseconds: 900));

      final withKeyboard = await readViewportMetrics();
      debugPrint('iOS #2787 with keyboard: $withKeyboard');
      final keyboardDelta =
          (before['visualViewportHeight'] as num).toDouble() -
          (withKeyboard['visualViewportHeight'] as num).toDouble();
      expect(
        keyboardDelta,
        greaterThan(20),
        reason:
            'The diagnostic could not observe the keyboard. Run it on a '
            'physical iOS device or a simulator with the software keyboard '
            'enabled and a native platform-view tap path. '
            'before=$before withKeyboard=$withKeyboard',
      );

      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await tester.pump(const Duration(milliseconds: 1200));

      final after = await readViewportMetrics();
      debugPrint('iOS #2787 after keyboard: $after');

      expect(
        (after['visualViewportHeight'] as num).toDouble(),
        closeTo((before['visualViewportHeight'] as num).toDouble(), 1),
        reason:
            'visualViewport.height did not recover: before=$before after=$after',
      );
      expect(
        (after['visualViewportOffsetTop'] as num).toDouble(),
        closeTo(0, 1),
        reason:
            'visualViewport.offsetTop remained displaced: before=$before after=$after',
      );
    },
    skip: !_runDiagnostic || !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
