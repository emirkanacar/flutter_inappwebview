import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_DISPOSAL_LIFECYCLE_DIAGNOSTIC',
);

const _lifecycleCycles = int.fromEnvironment(
  'ANDROID_DISPOSAL_LIFECYCLE_CYCLES',
  defaultValue: 100,
);
const _phaseTimeout = Duration(seconds: 20);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>
<p>Android disposal lifecycle diagnostic</p>
<script>
  window.__forgeDisposeMarker = 'loaded';
</script>
</body>
</html>
''';

Future<String> _runCycle(
  WidgetTester tester,
  int cycle, {
  required bool useHybridComposition,
}) async {
  debugPrint(
    'Android disposal diagnostic: create cycle=$cycle '
    'hybrid=$useHybridComposition',
  );
  final controllerCompleter = Completer<InAppWebViewController>();
  final webViewKey = ValueKey<String>('android-2654-disposal-webview-$cycle');

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: InAppWebView(
          key: webViewKey,
          initialSettings: InAppWebViewSettings(
            useHybridComposition: useHybridComposition,
          ),
          initialData: InAppWebViewInitialData(
            data: _diagnosticPage,
            baseUrl: WebUri('https://example.com/'),
          ),
          onWebViewCreated: controllerCompleter.complete,
        ),
      ),
    ),
  );

  final controller = await controllerCompleter.future.timeout(
    _phaseTimeout,
    onTimeout: () => throw StateError('controller timeout at cycle $cycle'),
  );
  await tester
      .pump(const Duration(seconds: 2))
      .timeout(
        _phaseTimeout,
        onTimeout: () =>
            throw StateError('initial pump timeout at cycle $cycle'),
      );
  debugPrint('Android disposal diagnostic: pending JS cycle=$cycle');

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

  debugPrint('Android disposal diagnostic: remove cycle=$cycle');
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: Center(child: Text('disposed-$cycle'))),
    ),
  );
  await tester
      .pump(const Duration(milliseconds: 300))
      .timeout(
        _phaseTimeout,
        onTimeout: () =>
            throw StateError('dispose pump timeout at cycle $cycle'),
      );

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
// repeatedly in both Android composition modes. A disposed WebView must
// complete pending callbacks and ignore late native/WebView callbacks without
// terminating the host app.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2654 WebView disposal lifecycle remains safe',
    (WidgetTester tester) async {
      final outcomes = <String>[];
      for (var cycle = 0; cycle < _lifecycleCycles; cycle++) {
        outcomes.add(
          await _runCycle(tester, cycle, useHybridComposition: cycle.isOdd),
        );
      }

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: Text('android-2654-complete'))),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));

      debugPrint('Android #2654 diagnostic: outcomes=$outcomes');
      expect(find.text('android-2654-complete'), findsOneWidget);
      expect(outcomes, hasLength(_lifecycleCycles));
      expect(outcomes, everyElement('WebView disposed'));
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 15)),
  );
}
