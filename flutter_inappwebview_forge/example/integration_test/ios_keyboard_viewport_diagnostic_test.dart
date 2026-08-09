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
            // The reported regression requires the keyboard inset to be routed
            // to WKWebView instead of being absorbed by Flutter.
            resizeToAvoidBottomInset: false,
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

      void logFlutterGeometry(String phase) {
        final renderBox = tester.renderObject<RenderBox>(
          find.byKey(_webViewKey),
        );
        final view = WidgetsBinding.instance.platformDispatcher.views.first;
        debugPrint(
          'iOS #2787 Flutter geometry ($phase): '
          'origin=${renderBox.localToGlobal(Offset.zero)} '
          'size=${renderBox.size} '
          'viewInsets=${view.viewInsets} '
          'padding=${view.padding} '
          'physicalSize=${view.physicalSize} '
          'devicePixelRatio=${view.devicePixelRatio}',
        );
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
      logFlutterGeometry('before');

      final webViewRenderBox = tester.renderObject<RenderBox>(
        find.byKey(_webViewKey),
      );
      final webViewOrigin = webViewRenderBox.localToGlobal(Offset.zero);
      debugPrint(
        'iOS #2787 WebView frame: origin=$webViewOrigin size=${webViewRenderBox.size}',
      );
      final inputTapPoint =
          webViewOrigin + Offset(webViewRenderBox.size.width / 2, 220);
      await tester.tapAt(inputTapPoint);
      // Flutter's synthetic platform-view pointer does not always reach the
      // native WKWebView in an integration test. Keep the user-tap attempt,
      // then focus the same DOM input through WebKit before asking UIKit to
      // present the keyboard so the viewport transition can still be measured.
      await controller.evaluateJavascript(
        source: "document.getElementById('keyboard-input')?.focus()",
      );
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
      await tester.pump(const Duration(milliseconds: 900));

      final withKeyboard = await readViewportMetrics();
      debugPrint('iOS #2787 with keyboard: $withKeyboard');
      logFlutterGeometry('with keyboard');
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

      // Blur the native WebKit input as a real keyboard dismissal would do;
      // TextInput.hide alone can leave the HTML input focused on iOS.
      await controller.evaluateJavascript(
        source: "document.getElementById('keyboard-input')?.blur()",
      );
      await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
      await tester.pump(const Duration(milliseconds: 1200));
      // The native keyboard notification and the Flutter platform-view layout
      // run on separate clocks in a drive test; allow the delayed native
      // viewport refresh to complete before sampling the DOM.
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await tester.pump();

      final after = await readViewportMetrics();
      debugPrint('iOS #2787 after keyboard: $after');
      logFlutterGeometry('after keyboard');

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
