import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_INTERCEPT_RAPID_NAVIGATION_DIAGNOSTIC',
);

String _page(String id) => '''
<!doctype html>
<html>
<body data-page="$id">
<img src="https://example.com/pixel-$id.png" alt="pixel">
<script src="https://example.com/resource-$id.js"></script>
</body>
</html>
''';

// Opt-in diagnostic for issue #2580. It keeps the interception callback a
// no-op while issuing rapid local navigations, so the test does not depend on
// a third-party site or a particular remote WebView response.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2580 rapid interception navigation diagnostic',
    (WidgetTester tester) async {
      final interceptedUrls = <String>[];
      final loadStartUrls = <String>[];
      final loadStopUrls = <String>[];
      final controllerCompleter = Completer<InAppWebViewController>();
      final firstPageLoaded = Completer<void>();
      final finalPageLoaded = Completer<void>();
      var rapidNavigationStarted = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _page('initial'),
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(javaScriptEnabled: true),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStart: (controller, url) {
                final urlString = url?.toString();
                if (urlString != null) {
                  loadStartUrls.add(urlString);
                }
              },
              onLoadStop: (controller, url) {
                final urlString = url?.toString();
                if (urlString != null) {
                  loadStopUrls.add(urlString);
                }
                if (!firstPageLoaded.isCompleted) {
                  firstPageLoaded.complete();
                }
                if (rapidNavigationStarted && !finalPageLoaded.isCompleted) {
                  finalPageLoaded.complete();
                }
              },
              shouldInterceptRequest: (controller, request) async {
                interceptedUrls.add(request.url.toString());
                return null;
              },
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      final documentStartSupported = await WebViewFeature.isFeatureSupported(
        WebViewFeature.DOCUMENT_START_SCRIPT,
      );
      debugPrint(
        'Android #2580 diagnostic: documentStartSupported='
        '$documentStartSupported',
      );
      for (
        var second = 0;
        second < 20 && !firstPageLoaded.isCompleted;
        second++
      ) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        firstPageLoaded.isCompleted,
        isTrue,
        reason: 'Android #2580 initial page did not finish loading.',
      );

      rapidNavigationStarted = true;
      for (var index = 0; index < 24; index++) {
        unawaited(
          controller.loadData(
            data: _page('page-$index'),
            baseUrl: WebUri('https://example.com/'),
            historyUrl: WebUri('https://example.com/page-$index'),
          ),
        );
      }
      unawaited(
        controller.loadData(
          data: _page('final'),
          baseUrl: WebUri('https://example.com/'),
          historyUrl: WebUri('https://example.com/final'),
        ),
      );

      for (
        var second = 0;
        second < 30 && !finalPageLoaded.isCompleted;
        second++
      ) {
        await tester.pump(const Duration(seconds: 1));
      }
      final currentUrl = await controller.getUrl();
      final marker = await controller.evaluateJavascript(
        source: 'document.body.dataset.page',
      );
      debugPrint(
        'Android #2580 diagnostic: finalLoaded=${finalPageLoaded.isCompleted} '
        'intercepted=${interceptedUrls.length} '
        'finalMarker=$marker currentUrl=$currentUrl '
        'loadStarts=$loadStartUrls loadStops=$loadStopUrls',
      );

      expect(
        finalPageLoaded.isCompleted,
        isTrue,
        reason: 'Android #2580 final rapid-navigation page did not load.',
      );
      expect(interceptedUrls, isNotEmpty);
      expect(marker, 'final');
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
