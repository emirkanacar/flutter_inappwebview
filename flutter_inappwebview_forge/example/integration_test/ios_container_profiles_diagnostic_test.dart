import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _page = '<!doctype html><html><body>container profile test</body></html>';

Future<void> _waitForLoad(WidgetTester tester, Completer<void> loaded) async {
  for (var attempt = 0; attempt < 100 && !loaded.isCompleted; attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(loaded.isCompleted, isTrue);
}

bool _isIOS17OrNewer() {
  final match = RegExp(r'^(\d+)').firstMatch(Platform.operatingSystemVersion);
  return int.tryParse(match?.group(1) ?? '') != null &&
      int.parse(match!.group(1)!) >= 17;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS container profiles isolate local storage',
    (WidgetTester tester) async {
      final firstLoaded = Completer<void>();
      final secondLoaded = Completer<void>();
      final firstController = Completer<InAppWebViewController>();
      final secondController = Completer<InAppWebViewController>();
      final nonce = DateTime.now().microsecondsSinceEpoch;
      final firstSuffix = nonce.toRadixString(16).padLeft(12, '0');
      final secondSuffix = (nonce + 1).toRadixString(16).padLeft(12, '0');
      final firstContainer = '00000000-0000-4000-8000-$firstSuffix';
      final secondContainer = '00000000-0000-4000-8000-$secondSuffix';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                SizedBox(
                  height: 240,
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: _page,
                      baseUrl: WebUri('https://forge-container.test/'),
                    ),
                    initialSettings: InAppWebViewSettings(
                      containerId: firstContainer,
                    ),
                    onWebViewCreated: firstController.complete,
                    onLoadStop: (controller, url) {
                      if (!firstLoaded.isCompleted) firstLoaded.complete();
                    },
                  ),
                ),
                SizedBox(
                  height: 240,
                  child: InAppWebView(
                    initialData: InAppWebViewInitialData(
                      data: _page,
                      baseUrl: WebUri('https://forge-container.test/'),
                    ),
                    initialSettings: InAppWebViewSettings(
                      containerId: secondContainer,
                    ),
                    onWebViewCreated: secondController.complete,
                    onLoadStop: (controller, url) {
                      if (!secondLoaded.isCompleted) secondLoaded.complete();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await _waitForLoad(tester, firstLoaded);
      await _waitForLoad(tester, secondLoaded);
      final first = await firstController.future;
      final second = await secondController.future;

      await first.evaluateJavascript(
        source: "localStorage.setItem('forge-value', 'first');",
      );
      expect(
        await second.evaluateJavascript(
          source: "localStorage.getItem('forge-value');",
        ),
        isNull,
      );

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 200));

      final containers = ContainerController.instance();
      expect(await containers.hasContainer(firstContainer), isTrue);
      expect(await containers.hasContainer(secondContainer), isTrue);
      expect(await containers.deleteContainer(firstContainer), isTrue);
      expect(await containers.deleteContainer(secondContainer), isTrue);
    },
    skip: !Platform.isIOS || !_isIOS17OrNewer(),
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
