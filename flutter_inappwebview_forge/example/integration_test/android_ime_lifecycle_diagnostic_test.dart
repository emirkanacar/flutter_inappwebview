import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_IME_LIFECYCLE_DIAGNOSTIC',
);

const _diagnosticPage = '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; padding: 0; }
    body { font-family: sans-serif; }
    input { box-sizing: border-box; font-size: 24px; margin: 24px; padding: 12px; width: calc(100% - 48px); }
  </style>
</head>
<body>
  <input id="ime-input" type="text" value="focus me">
</body>
</html>
''';

double _bottomInset() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  return view.viewInsets.bottom / view.devicePixelRatio;
}

Widget _webViewScreen({
  required Completer<InAppWebViewController> controller,
  required FocusNode focusNode,
  required ValueKey<String> inputKey,
  required bool useHybridComposition,
}) {
  return MaterialApp(
    home: Scaffold(
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage,
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                useHybridComposition: useHybridComposition,
              ),
              onWebViewCreated: (value) {
                if (!controller.isCompleted) {
                  controller.complete(value);
                }
              },
            ),
          ),
          TextField(
            key: inputKey,
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Flutter input after WebView disposal',
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _flutterInputScreen({
  required FocusNode focusNode,
  required ValueKey<String> inputKey,
}) {
  return MaterialApp(
    home: Scaffold(
      resizeToAvoidBottomInset: true,
      body: TextField(
        key: inputKey,
        focusNode: focusNode,
        decoration: const InputDecoration(
          labelText: 'Flutter input after WebView disposal',
        ),
      ),
    ),
  );
}

Future<Map<String, dynamic>> _runCycle(
  WidgetTester tester, {
  required bool useHybridComposition,
}) async {
  final controllerCompleter = Completer<InAppWebViewController>();
  final focusNode = FocusNode();
  final inputKey = ValueKey<String>(
    'android-2555-flutter-input-$useHybridComposition',
  );
  addTearDown(focusNode.dispose);

  await tester.pumpWidget(
    _webViewScreen(
      controller: controllerCompleter,
      focusNode: focusNode,
      inputKey: inputKey,
      useHybridComposition: useHybridComposition,
    ),
  );
  final controller = await controllerCompleter.future;
  await tester.pump(const Duration(seconds: 2));

  final webViewFinder = find.byType(InAppWebView);
  final webViewBox = tester.renderObject<RenderBox>(webViewFinder);
  await tester.tapAt(webViewBox.localToGlobal(const Offset(80, 48)));
  await tester.pump(const Duration(milliseconds: 500));
  await controller.evaluateJavascript(
    source: "document.getElementById('ime-input').focus()",
  );
  await SystemChannels.textInput.invokeMethod<void>('TextInput.show');
  await tester.pump(const Duration(milliseconds: 500));

  final activeElement = await controller.evaluateJavascript(
    source: 'document.activeElement.id',
  );
  await controller.clearFocus();
  await tester.pump(const Duration(milliseconds: 250));

  await tester.pumpWidget(
    _flutterInputScreen(focusNode: focusNode, inputKey: inputKey),
  );
  await tester.pump(const Duration(milliseconds: 500));
  focusNode.requestFocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.show');

  double? keyboardInset;
  for (var attempt = 0; attempt < 20; attempt++) {
    await tester.pump(const Duration(milliseconds: 250));
    final inset = _bottomInset();
    if (inset > 20) {
      keyboardInset = inset;
      break;
    }
  }

  return <String, dynamic>{
    'useHybridComposition': useHybridComposition,
    'activeElement': activeElement,
    'keyboardInsetAfterDispose': keyboardInset,
    'flutterInputFocused': focusNode.hasFocus,
  };
}

// Opt-in diagnostic for issue #2555. It exercises the old virtual-display
// InputAwareWebView proxy path and the hybrid path, then verifies that a
// separate Flutter input can still create an IME connection after the WebView
// is cleared and disposed. Run it on an Android device or AVD with the
// software keyboard enabled.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2555 IME lifecycle survives WebView disposal',
    (WidgetTester tester) async {
      final virtualDisplay = await _runCycle(
        tester,
        useHybridComposition: false,
      );
      final hybrid = await _runCycle(tester, useHybridComposition: true);

      debugPrint(
        'Android #2555 diagnostic: virtualDisplay=$virtualDisplay '
        'hybrid=$hybrid',
      );
      expect(virtualDisplay['activeElement'], 'ime-input');
      expect(hybrid['activeElement'], 'ime-input');
      expect(virtualDisplay['keyboardInsetAfterDispose'], isNotNull);
      expect(hybrid['keyboardInsetAfterDispose'], isNotNull);
      expect(virtualDisplay['flutterInputFocused'], isTrue);
      expect(hybrid['flutterInputFocused'], isTrue);
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
