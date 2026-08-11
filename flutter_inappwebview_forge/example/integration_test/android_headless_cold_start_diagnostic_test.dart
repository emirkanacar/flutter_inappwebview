import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_HEADLESS_COLD_START_DIAGNOSTIC',
);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>Android headless cold-start diagnostic</body>
</html>
''';

// Opt-in runtime diagnostic for #2849. It creates and disposes several
// headless WebViews with an AT_DOCUMENT_START script so provider startup and
// document-start registration are exercised together.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Android #2849 headless cold-start document-start diagnostic',
    () async {
      final results = <Map<String, String?>>[];

      for (var cycle = 0; cycle < 4; cycle++) {
        final createdCompleter = Completer<InAppWebViewController>();
        final loadedCompleter = Completer<void>();
        final headlessWebView = HeadlessInAppWebView(
          initialData: InAppWebViewInitialData(
            data: _diagnosticPage,
            baseUrl: WebUri('https://example.com/'),
          ),
          initialUserScripts: UnmodifiableListView<UserScript>([
            UserScript(
              source:
                  "document.documentElement.setAttribute('data-forge-headless-bridge', typeof window.flutter_inappwebview);",
              injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
            ),
          ]),
          onWebViewCreated: (controller) {
            if (!createdCompleter.isCompleted) {
              createdCompleter.complete(controller);
            }
          },
          onLoadStop: (controller, url) {
            if (!loadedCompleter.isCompleted) {
              loadedCompleter.complete();
            }
          },
        );

        await headlessWebView.run();
        final controller = await createdCompleter.future.timeout(
          const Duration(seconds: 20),
        );
        await loadedCompleter.future.timeout(const Duration(seconds: 20));
        final bridgeType = await controller.evaluateJavascript(
          source: 'typeof window.flutter_inappwebview',
        );
        final bridgeAtDocumentStart = await controller.evaluateJavascript(
          source:
              "document.documentElement.getAttribute('data-forge-headless-bridge')",
        );
        results.add({
          'bridgeType': bridgeType?.toString(),
          'bridgeAtDocumentStart': bridgeAtDocumentStart?.toString(),
        });
        await headlessWebView.dispose();
      }

      debugPrint('Android #2849 headless diagnostic: cycles=$results');
      expect(results, hasLength(4));
      for (final result in results) {
        expect(result['bridgeType'], 'object');
        expect(result['bridgeAtDocumentStart'], 'object');
      }
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
