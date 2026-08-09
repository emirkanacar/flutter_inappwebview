import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_IOS_POPUP_DEFAULT_HANDLING_DIAGNOSTIC',
);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>
<p>iOS popup default-handling diagnostic</p>
</body>
</html>
''';

// Opt-in diagnostic for issue #2763. The callback deliberately returns false
// to verify that the rejected popup does not navigate the caller WebView.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS #2763 rejected popup does not navigate caller diagnostic',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      final popupCompleter = Completer<CreateWindowAction>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptCanOpenWindowsAutomatically: true,
                supportMultipleWindows: true,
              ),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStop: (controller, url) {
                if (!pageLoaded.isCompleted) {
                  pageLoaded.complete();
                }
              },
              onCreateWindow: (controller, action) async {
                if (!popupCompleter.isCompleted) {
                  popupCompleter.complete(action);
                }
                return false;
              },
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await pageLoaded.future;

      await controller.evaluateJavascript(
        source: "window.open('https://example.com/popup', '_blank')",
      );
      final action = await popupCompleter.future.timeout(
        const Duration(seconds: 20),
      );

      final callerUrl = await controller.evaluateJavascript(
        source: 'location.href',
      );
      debugPrint(
        'iOS #2763 diagnostic: popupUrl=${action.request.url} '
        'callerUrl=$callerUrl',
      );

      expect(action.request.url.toString(), 'https://example.com/popup');
      expect(callerUrl, 'https://example.com/');
    },
    skip: !_runDiagnostic || !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
