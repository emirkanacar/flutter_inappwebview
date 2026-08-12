import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_USER_AGENT_METADATA_DIAGNOSTIC',
);

const _page = '''
<!doctype html>
<html><body><p>Android user-agent metadata diagnostic</p></body></html>
''';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android user-agent metadata reaches User-Agent Client Hints',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final resultCompleter = Completer<Object?>();
      var loaded = false;
      final settings = InAppWebViewSettings();
      settings.userAgentMetadata = {
        'brandVersionList': [
          {
            'brand': 'ForgeBrowser',
            'majorVersion': '99',
            'fullVersion': '99.0.0.0',
          },
        ],
        'fullVersion': '99.0.0.0',
        'platform': 'ForgeOS',
        'platformVersion': '99.0.0',
        'model': 'ForgeDevice',
        'mobile': true,
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _page,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: settings,
              onWebViewCreated: (controller) {
                controller.addJavaScriptHandler(
                  handlerName: 'uaMetadataDiagnostic',
                  callback: (args) {
                    if (!resultCompleter.isCompleted) {
                      resultCompleter.complete(
                        args.isEmpty ? null : args.first,
                      );
                    }
                  },
                );
                controllerCompleter.complete(controller);
              },
              onLoadStop: (controller, url) {
                loaded = true;
              },
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      for (var attempt = 0; attempt < 100 && !loaded; attempt++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(loaded, isTrue);

      final bridgeName = await InAppWebViewController.getJavaScriptBridgeName();
      await controller.evaluateJavascript(
        source:
            '''
(function () {
  if (!navigator.userAgentData ||
      typeof navigator.userAgentData.getHighEntropyValues !== 'function') {
    window[${jsonEncode(bridgeName)}].callHandler(
      'uaMetadataDiagnostic', {supported: false});
    return;
  }
  navigator.userAgentData.getHighEntropyValues([
    'platform', 'platformVersion', 'model', 'fullVersionList', 'mobile'
  ]).then(function (values) {
    window[${jsonEncode(bridgeName)}].callHandler(
      'uaMetadataDiagnostic', values);
  });
})();
''',
      );

      final result = await resultCompleter.future.timeout(
        const Duration(seconds: 10),
      );
      expect(result, isA<Map>());
      final metadata = (result as Map).cast<String, dynamic>();
      expect(metadata['platform'], 'ForgeOS');
      expect(metadata['platformVersion'], '99.0.0');
      expect(metadata['model'], 'ForgeDevice');
      expect(metadata['mobile'], true);
      expect(metadata['fullVersionList'], isA<List>());
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 1)),
  );
}
