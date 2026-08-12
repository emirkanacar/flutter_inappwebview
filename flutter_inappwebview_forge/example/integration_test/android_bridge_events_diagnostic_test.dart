import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_BRIDGE_EVENTS_DIAGNOSTIC',
);

const _page = '''
<!doctype html>
<html><body><p>Android bridge events diagnostic</p></body></html>
''';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android typed bridge events and handlers work at runtime',
    (WidgetTester tester) async {
      final controllerCompleter = Completer<InAppWebViewController>();
      final dartEvent = Completer<Object?>();
      var loaded = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _page,
                baseUrl: WebUri('https://example.com/'),
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
      final bridgeName = await InAppWebViewController.getJavaScriptBridgeName();

      await controller.bridgeEvents.on('android.runtime', (data) {
        if (!dartEvent.isCompleted) dartEvent.complete(data);
      });

      await controller.evaluateJavascript(
        source:
            'window[${jsonEncode(bridgeName)}].bridgeEvents.emit('
            "'android.runtime', {\"count\": 2});",
      );
      expect(await dartEvent.future.timeout(const Duration(seconds: 10)), {
        'count': 2,
      });

      await controller.evaluateJavascript(
        source:
            'window[${jsonEncode(bridgeName)}].bridgeEvents.on('
            "'dart.runtime', function(data) { "
            "document.body.dataset.dartRuntime = JSON.stringify(data); });",
      );
      await controller.bridgeEvents.emit('dart.runtime', {'count': 3});

      Object? jsEvent;
      for (var attempt = 0; attempt < 20; attempt++) {
        jsEvent = await controller.evaluateJavascript(
          source: 'document.body.dataset.dartRuntime || null',
        );
        if (jsEvent != null) break;
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(jsonDecode(jsEvent as String), {'count': 3});

      controller.bridgeEvents.addJsonJavaScriptHandler<int, String>(
        handlerName: 'androidDouble',
        decodeRequest: (value) => (value as Map)['value'] as int,
        callback: (value) => 'value=${value * 2}',
        encodeResponse: (value) => {'message': value},
      );
      await controller.evaluateJavascript(
        source:
            'window[${jsonEncode(bridgeName)}].callHandler('
            "'androidDouble', {\"value\": 4}).then(function(value) { "
            "document.body.dataset.androidDouble = JSON.stringify(value); });",
      );
      String? serializedHandlerResult;
      for (var attempt = 0; attempt < 20; attempt++) {
        final result = await controller.evaluateJavascript(
          source: 'document.body.dataset.androidDouble || null',
        );
        if (result is String) {
          serializedHandlerResult = result;
          break;
        }
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(jsonDecode(serializedHandlerResult!), {'message': 'value=8'});
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
