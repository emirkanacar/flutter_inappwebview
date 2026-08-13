import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_IOS_DISPOSAL_LIFECYCLE_DIAGNOSTIC',
);

const _lifecycleCycles = 100;

const _diagnosticPage = '''
<!doctype html>
<html>
<body>
<p>iOS disposal lifecycle diagnostic</p>
<script>
  window.__forgeDisposeMarker = 'loaded';
</script>
</body>
</html>
''';

Future<String> _runCycle(WidgetTester tester, int cycle) async {
  final controllerCompleter = Completer<InAppWebViewController>();
  final pageLoaded = Completer<void>();
  final webViewKey = ValueKey<String>('ios-2654-disposal-webview-$cycle');

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: InAppWebView(
          key: webViewKey,
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
        ),
      ),
    ),
  );

  final controller = await controllerCompleter.future;
  await pageLoaded.future;
  await tester.pump(const Duration(milliseconds: 150));

  final pendingAsyncJavaScript = controller.callAsyncJavaScript(
    functionBody: '''
      var p = new Promise(function(resolve) {
        window.setTimeout(function() { resolve('completed'); }, 1500);
      });
      await p;
      return p;
    ''',
  );
  unawaited(
    controller.loadUrl(urlRequest: URLRequest(url: WebUri('about:blank'))),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: Text('disposed-$cycle'))),
    ),
  );
  await tester.pump(const Duration(milliseconds: 300));

  try {
    final result = await pendingAsyncJavaScript.timeout(
      const Duration(seconds: 3),
    );
    return result?.error ?? 'completed';
  } catch (error) {
    return 'exception:${error.runtimeType}';
  }
}

// Opt-in diagnostic for issue #2654. It starts a pending async JavaScript
// callback, begins navigate-away, removes the platform view, and recreates it
// repeatedly. A disposed WebView must complete pending callbacks and ignore
// late native/WebKit callbacks without terminating the host app.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS #2654 WebView disposal lifecycle remains safe',
    (WidgetTester tester) async {
      final outcomes = <String>[];
      for (var cycle = 0; cycle < _lifecycleCycles; cycle++) {
        outcomes.add(await _runCycle(tester, cycle));
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('ios-2654-complete'))),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      debugPrint('iOS #2654 diagnostic: outcomes=$outcomes');
      expect(find.text('ios-2654-complete'), findsOneWidget);
      expect(outcomes, hasLength(_lifecycleCycles));
      expect(
        outcomes,
        everyElement(anyOf('WebView disposed', 'WebView navigation started')),
      );
    },
    skip: !_runDiagnostic || !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
