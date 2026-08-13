import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_LIFECYCLE_TRANSFER_DIAGNOSTIC',
);
const _diagnosticCycles = int.fromEnvironment(
  'ANDROID_LIFECYCLE_TRANSFER_CYCLES',
  defaultValue: 50,
);
const _phaseTimeout = Duration(seconds: 20);

const _diagnosticPage = '''
<!doctype html>
<html>
<body>
<p>Android lifecycle transfer diagnostic</p>
<script>
  window.__forgeLifecycleMarker = 'retained';
</script>
</body>
</html>
''';

Future<dynamic> _readMarker(InAppWebViewController controller) {
  return controller
      .evaluateJavascript(source: 'window.__forgeLifecycleMarker')
      .timeout(const Duration(seconds: 2));
}

Future<void> _waitForMarker(
  WidgetTester tester,
  InAppWebViewController controller, {
  required String phase,
}) async {
  for (var attempt = 0; attempt < 20; attempt++) {
    try {
      if (await _readMarker(controller) == 'retained') {
        return;
      }
    } catch (_) {
      // The platform view can still be attaching while the page is loading.
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
  throw StateError('$phase marker timeout');
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android keepAlive and headless ownership survive repeated transfer',
    (WidgetTester tester) async {
      final keepAlive = InAppWebViewKeepAlive();
      InAppWebViewController? retainedController;

      for (var cycle = 0; cycle < _diagnosticCycles; cycle++) {
        debugPrint('Android lifecycle transfer: keepAlive cycle=$cycle');
        final controllerCompleter = Completer<InAppWebViewController>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InAppWebView(
                key: ValueKey<String>('android-retained-$cycle'),
                keepAlive: keepAlive,
                initialData: cycle == 0
                    ? InAppWebViewInitialData(
                        data: _diagnosticPage,
                        baseUrl: WebUri('https://example.com/'),
                      )
                    : null,
                onWebViewCreated: controllerCompleter.complete,
              ),
            ),
          ),
        );
        retainedController = await controllerCompleter.future.timeout(
          _phaseTimeout,
          onTimeout: () =>
              throw StateError('keepAlive controller timeout at cycle $cycle'),
        );
        await _waitForMarker(
          tester,
          retainedController,
          phase: 'keepAlive cycle $cycle',
        );
        await tester.pump(const Duration(milliseconds: 25));
        expect(await _readMarker(retainedController), 'retained');
      }

      await InAppWebViewController.disposeKeepAlive(keepAlive);
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump(const Duration(milliseconds: 100));

      for (var cycle = 0; cycle < _diagnosticCycles; cycle++) {
        debugPrint('Android lifecycle transfer: headless cycle=$cycle');
        final headlessControllerCompleter = Completer<InAppWebViewController>();
        final headless = HeadlessInAppWebView(
          initialData: InAppWebViewInitialData(
            data: _diagnosticPage,
            baseUrl: WebUri('https://example.com/'),
          ),
          onWebViewCreated: headlessControllerCompleter.complete,
        );
        await headless.run().timeout(
          _phaseTimeout,
          onTimeout: () =>
              throw StateError('headless run timeout at cycle $cycle'),
        );
        final headlessController = await headlessControllerCompleter.future
            .timeout(
              _phaseTimeout,
              onTimeout: () => throw StateError(
                'headless controller timeout at cycle $cycle',
              ),
            );
        await _waitForMarker(
          tester,
          headlessController,
          phase: 'headless cycle $cycle',
        );

        final normalControllerCompleter = Completer<InAppWebViewController>();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: InAppWebView(
                key: ValueKey<String>('android-headless-$cycle'),
                headlessWebView: headless,
                onWebViewCreated: normalControllerCompleter.complete,
              ),
            ),
          ),
        );
        final normalController = await normalControllerCompleter.future.timeout(
          _phaseTimeout,
          onTimeout: () => throw StateError(
            'normal transfer controller timeout at cycle $cycle',
          ),
        );
        await tester.pump(const Duration(milliseconds: 25));
        await _waitForMarker(
          tester,
          normalController,
          phase: 'normal transfer cycle $cycle',
        );
        expect(await _readMarker(normalController), 'retained');

        await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
        await tester.pump(const Duration(milliseconds: 50));
      }
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 10)),
  );
}
