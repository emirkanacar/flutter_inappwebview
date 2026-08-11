import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_COOKIE_ANR_DIAGNOSTIC',
);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>Android cookie ANR diagnostic</body>
</html>
''';

Future<T> _within<T>(Future<T> future, String operation) => future.timeout(
  const Duration(seconds: 5),
  onTimeout: () =>
      throw TimeoutException('Android #2718 operation timed out: $operation'),
);

// Opt-in runtime diagnostic for #2718. It keeps the page local so network
// availability cannot hide cookie-manager completion or UI-thread stalls.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2718 cookie mutations and explicit flush remain responsive',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      var created = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(clearCache: true),
              onWebViewCreated: (controller) {
                created = true;
                if (!controllerCompleter.isCompleted) {
                  controllerCompleter.complete(controller);
                }
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
      await controllerCompleter.future;

      final cookieManager = CookieManager.instance();
      final url = WebUri('https://example.com/');
      await _within(cookieManager.deleteAllCookies(), 'initial deleteAll');

      final durations = <String, int>{};
      for (var cycle = 0; cycle < 10; cycle++) {
        final started = DateTime.now();
        final name = 'forgeCookie$cycle';
        await _within(
          cookieManager.setCookie(url: url, name: name, value: 'value$cycle'),
          'setCookie[$cycle]',
        );
        await _within(
          cookieManager.deleteCookie(url: url, name: name),
          'deleteCookie[$cycle]',
        );
        await _within(
          cookieManager.setCookie(url: url, name: name, value: 'value$cycle'),
          'setCookie-recreate[$cycle]',
        );
        await _within(
          cookieManager.deleteCookies(url: url, domain: '.example.com'),
          'deleteCookies[$cycle]',
        );
        await _within(
          cookieManager.setCookie(url: url, name: name, value: 'value$cycle'),
          'setCookie-before-deleteAll[$cycle]',
        );
        await _within(
          cookieManager.deleteAllCookies(),
          'deleteAllCookies[$cycle]',
        );
        await _within(cookieManager.flush(), 'flush[$cycle]');
        durations['cycle$cycle'] = DateTime.now()
            .difference(started)
            .inMilliseconds;
      }

      final cookies = await _within(
        cookieManager.getCookies(url: url),
        'getCookies-final',
      );
      debugPrint(
        'Android #2718 cookie diagnostic: durations=$durations cookies=$cookies',
      );
      expect(cookies, isEmpty);
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
