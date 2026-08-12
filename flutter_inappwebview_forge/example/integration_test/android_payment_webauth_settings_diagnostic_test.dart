import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_PAYMENT_WEBAUTH_SETTINGS_DIAGNOSTIC',
);

const _page = '''
<!doctype html>
<html><body><p>Android payment and WebAuthn settings diagnostic</p></body></html>
''';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android payment and WebAuthn settings round-trip through WebView',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      var loaded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _page,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(
                paymentRequestEnabled: true,
                webAuthenticationSupport: WebAuthenticationSupport.FOR_APP,
              ),
              onWebViewCreated: controllerCompleter.complete,
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

      final paymentSupported = await WebViewFeature.isFeatureSupported(
        WebViewFeature.PAYMENT_REQUEST,
      );
      final webAuthenticationSupported =
          await WebViewFeature.isFeatureSupported(
            WebViewFeature.WEB_AUTHENTICATION,
          );
      final settings = await controller.getSettings();

      debugPrint(
        'Android payment/WebAuthn diagnostic: '
        'paymentSupported=$paymentSupported '
        'paymentEnabled=${settings?.paymentRequestEnabled} '
        'webAuthenticationSupported=$webAuthenticationSupported '
        'webAuthenticationSupport='
        '${settings?.webAuthenticationSupport?.toValue()}',
      );

      if (paymentSupported) {
        expect(settings?.paymentRequestEnabled, true);
      } else {
        expect(settings?.paymentRequestEnabled, isNull);
      }
      if (webAuthenticationSupported) {
        expect(
          settings?.webAuthenticationSupport?.toValue(),
          WebAuthenticationSupport.FOR_APP.toValue(),
        );
      } else {
        expect(settings?.webAuthenticationSupport, isNull);
      }
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 1)),
  );
}
