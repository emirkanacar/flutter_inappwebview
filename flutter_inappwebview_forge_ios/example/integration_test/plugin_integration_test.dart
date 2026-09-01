import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_ios/flutter_inappwebview_forge_ios.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:integration_test/integration_test.dart';

const _smokePage = '''
<!doctype html>
<html>
<head><meta charset="utf-8"></head>
<body><p id="forge-smoke">ios-platform-ready</p></body>
</html>
''';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS platform WebView loads inline HTML and evaluates JavaScript',
    (tester) async {
      final controllerCompleter = Completer<IOSInAppWebViewController>();
      final loadStopCompleter = Completer<void>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => IOSInAppWebViewWidget(
                IOSInAppWebViewWidgetCreationParams(
                  initialData: InAppWebViewInitialData(
                    data: _smokePage,
                    baseUrl: WebUri('https://example.test/'),
                  ),
                  onWebViewCreated: (controller) {
                    controllerCompleter.complete(
                      controller as IOSInAppWebViewController,
                    );
                  },
                  onLoadStop: (controller, url) {
                    if (!loadStopCompleter.isCompleted) {
                      loadStopCompleter.complete();
                    }
                  },
                ),
              ).build(context),
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future.timeout(
        const Duration(seconds: 20),
      );
      for (
        var attempt = 0;
        attempt < 100 && !loadStopCompleter.isCompleted;
        attempt++
      ) {
        await tester.pump(const Duration(milliseconds: 200));
      }
      expect(loadStopCompleter.isCompleted, isTrue);

      expect(
        await controller.evaluateJavascript(
          source: 'document.getElementById("forge-smoke").textContent',
        ),
        'ios-platform-ready',
      );

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 500));
    },
    skip: !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
