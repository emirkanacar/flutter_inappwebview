import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_IOS_GEOLOCATION_PERMISSION_DIAGNOSTIC',
);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>
<p>iOS geolocation permission diagnostic</p>
<script>
  navigator.geolocation.getCurrentPosition(
    function() {
      document.body.setAttribute('data-forge-geolocation-result', 'granted');
    },
    function(error) {
      document.body.setAttribute(
        'data-forge-geolocation-result',
        'error:' + error.code,
      );
    },
  );
</script>
</body>
</html>
''';

bool _isIos27OrLater() {
  final match = RegExp(r'(\d+)').firstMatch(Platform.operatingSystemVersion);
  final majorVersion = int.tryParse(match?.group(1) ?? '') ?? 0;
  return majorVersion >= 27;
}

// Opt-in diagnostic for issue #2831. It deliberately denies the request from
// Dart so the test validates the iOS 27 public decision-handler bridge without
// depending on an interactive system location prompt. iOS 26 has no public
// WebKit decision callback, so its prompt behavior is tracked as a host
// boundary and this bridge diagnostic is skipped there.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS #2831 geolocation permission decision diagnostic',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      String? callbackOrigin;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage,
                baseUrl: WebUri('https://example.com/'),
              ),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStop: (controller, url) {
                if (!pageLoaded.isCompleted) {
                  pageLoaded.complete();
                }
              },
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                callbackOrigin = origin;
                return GeolocationPermissionShowPromptResponse(
                  origin: origin,
                  allow: false,
                  retain: false,
                );
              },
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      await pageLoaded.future;

      String? result;
      for (var attempt = 0; attempt < 30; attempt++) {
        result =
            await controller.evaluateJavascript(
                  source:
                      "document.body.getAttribute('data-forge-geolocation-result')",
                )
                as String?;
        if (result != null && result != 'pending') {
          break;
        }
        await tester.pump(const Duration(milliseconds: 250));
      }

      final runtimeState = await controller.evaluateJavascript(
        source: '''
          ({
            "href": location.href,
            "protocol": location.protocol,
            "isSecureContext": window.isSecureContext,
            "geolocationType": typeof navigator.geolocation,
            "body": document.body.innerHTML
          })
        ''',
      );
      debugPrint(
        'iOS #2831 diagnostic: callbackOrigin=$callbackOrigin '
        'result=$result runtimeState=$runtimeState',
      );

      expect(callbackOrigin, startsWith('https://example.com'));
      expect(result, 'error:1');
    },
    skip: !_runDiagnostic || !Platform.isIOS || !_isIos27OrLater(),
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
