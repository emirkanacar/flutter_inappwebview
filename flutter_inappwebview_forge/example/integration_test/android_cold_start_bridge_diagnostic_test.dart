import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_COLD_START_BRIDGE_DIAGNOSTIC',
);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>Android cold-start bridge diagnostic</body>
</html>
''';

// Opt-in profile/AOT diagnostic for #2843 and #2849. It verifies that the
// platform-view-created callback arrives and that the bridge/document-start
// registration is available before the initial page finishes loading.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2843/#2849 cold-start bridge diagnostic',
    (WidgetTester tester) async {
      final createdCompleter = Completer<InAppWebViewController>();
      final startedAt = DateTime.now();
      var created = false;
      var loaded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialUserScripts: UnmodifiableListView<UserScript>([
                UserScript(
                  source:
                      "document.documentElement.setAttribute('data-forge-bridge-at-start', typeof window.flutter_inappwebview);",
                  injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
                ),
              ]),
              onWebViewCreated: (controller) {
                created = true;
                if (!createdCompleter.isCompleted) {
                  createdCompleter.complete(controller);
                }
              },
              onLoadStop: (controller, url) {
                loaded = true;
              },
            ),
          ),
        ),
      );

      for (var i = 0; i < 100 && !created; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(created, isTrue);
      if (!created) {
        return;
      }

      final controller = await createdCompleter.future;
      for (var i = 0; i < 100 && !loaded; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      final bridgeType = await controller.evaluateJavascript(
        source: 'typeof window.flutter_inappwebview',
      );
      final bridgeAtDocumentStart = await controller.evaluateJavascript(
        source:
            "document.documentElement.getAttribute('data-forge-bridge-at-start')",
      );
      debugPrint(
        'Android #2843/#2849 diagnostic: created=$created loaded=$loaded '
        'bridgeType=$bridgeType bridgeAtDocumentStart=$bridgeAtDocumentStart '
        'createdAfterMs=${DateTime.now().difference(startedAt).inMilliseconds}',
      );

      expect(loaded, isTrue);
      expect(bridgeType, 'object');
      expect(bridgeAtDocumentStart, 'object');
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(seconds: 30)),
  );
}
