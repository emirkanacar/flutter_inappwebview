import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_IOS_MULTI_WINDOW_NAVIGATION_DIAGNOSTIC',
);

const _parentPage = '''
<!doctype html>
<html>
<body>
<p>iOS multi-window navigation diagnostic</p>
</body>
</html>
''';

class _PopupDiagnosticHarness extends StatefulWidget {
  const _PopupDiagnosticHarness({
    required this.parentController,
    required this.parentLoaded,
    required this.popupActions,
    required this.navigationUrls,
    super.key,
  });

  final Completer<InAppWebViewController> parentController;
  final Completer<void> parentLoaded;
  final List<CreateWindowAction> popupActions;
  final List<String> navigationUrls;

  @override
  State<_PopupDiagnosticHarness> createState() =>
      _PopupDiagnosticHarnessState();
}

class _PopupDiagnosticHarnessState extends State<_PopupDiagnosticHarness> {
  int? _popupWindowId;
  Completer<InAppWebViewController>? _popupController;
  Completer<void>? _popupLoaded;

  Future<InAppWebViewController> prepareForPopup() {
    if (_popupWindowId != null) {
      throw StateError('A popup is already attached.');
    }
    _popupController = Completer<InAppWebViewController>();
    _popupLoaded = Completer<void>();
    return _popupController!.future;
  }

  Future<void> waitForPopupLoaded() {
    final popupLoaded = _popupLoaded;
    if (popupLoaded == null) {
      throw StateError('prepareForPopup must be called first.');
    }
    return popupLoaded.future;
  }

  void closePopup() {
    if (!mounted) {
      return;
    }
    setState(() {
      _popupWindowId = null;
      _popupController = null;
      _popupLoaded = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: InAppWebView(
                key: const ValueKey('ios-2867-parent'),
                initialData: InAppWebViewInitialData(
                  data: _parentPage,
                  baseUrl: WebUri('https://example.com/'),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptCanOpenWindowsAutomatically: true,
                  supportMultipleWindows: true,
                ),
                onWebViewCreated: (controller) {
                  if (!widget.parentController.isCompleted) {
                    widget.parentController.complete(controller);
                  }
                },
                onLoadStop: (controller, url) {
                  if (!widget.parentLoaded.isCompleted) {
                    widget.parentLoaded.complete();
                  }
                },
                shouldOverrideUrlLoading: (controller, action) {
                  widget.navigationUrls.add(
                    action.request.url?.toString() ?? '<null>',
                  );
                  return NavigationActionPolicy.ALLOW;
                },
                onCreateWindow: (controller, action) async {
                  widget.popupActions.add(action);
                  if (mounted) {
                    setState(() {
                      _popupWindowId = action.windowId;
                    });
                  }
                  return true;
                },
              ),
            ),
            if (_popupWindowId != null)
              Positioned.fill(
                child: InAppWebView(
                  key: ValueKey('ios-2867-popup-$_popupWindowId'),
                  windowId: _popupWindowId,
                  onWebViewCreated: (controller) {
                    final popupController = _popupController;
                    if (popupController != null &&
                        !popupController.isCompleted) {
                      popupController.complete(controller);
                    }
                  },
                  onLoadStop: (controller, url) {
                    final popupLoaded = _popupLoaded;
                    if (popupLoaded != null && !popupLoaded.isCompleted) {
                      popupLoaded.complete();
                    }
                  },
                  shouldOverrideUrlLoading: (controller, action) {
                    widget.navigationUrls.add(
                      action.request.url?.toString() ?? '<null>',
                    );
                    return NavigationActionPolicy.ALLOW;
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Opt-in diagnostic for issue #2867 and the related popup evaluation fix in
// #2776. It repeatedly attaches a windowId WebView, exercises page/custom
// world evaluation while shouldOverrideUrlLoading is installed, races an
// async call with navigation, and disposes the popup between cycles.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS #2867 multi-window navigation and evaluation diagnostic',
    (WidgetTester tester) async {
      final parentController = Completer<InAppWebViewController>();
      final parentLoaded = Completer<void>();
      final popupActions = <CreateWindowAction>[];
      final navigationUrls = <String>[];
      final harnessKey = GlobalKey<_PopupDiagnosticHarnessState>();

      await tester.pumpWidget(
        _PopupDiagnosticHarness(
          key: harnessKey,
          parentController: parentController,
          parentLoaded: parentLoaded,
          popupActions: popupActions,
          navigationUrls: navigationUrls,
        ),
      );

      final parent = await parentController.future.timeout(
        const Duration(seconds: 20),
      );
      await parentLoaded.future.timeout(const Duration(seconds: 20));

      final completedCycles = <int>[];
      for (var cycle = 0; cycle < 3; cycle++) {
        final popupFuture = harnessKey.currentState!.prepareForPopup();
        await parent.evaluateJavascript(
          source: "window.open('https://example.com/popup-$cycle', '_blank')",
        );
        await tester.pump(const Duration(milliseconds: 100));

        final popup = await popupFuture.timeout(const Duration(seconds: 20));
        await harnessKey.currentState!.waitForPopupLoaded().timeout(
          const Duration(seconds: 20),
        );

        final pageWorldResult = await popup.evaluateJavascript(
          source: "'popup-page-world-$cycle'",
        );
        final customWorldResult = await popup.evaluateJavascript(
          source: "window.__forge2867 = 'popup-custom-world-$cycle';",
          contentWorld: ContentWorld.world(name: 'forge2867'),
        );
        final asyncResult = await popup.callAsyncJavaScript(
          functionBody: "return await Promise.resolve('popup-async-$cycle');",
          contentWorld: ContentWorld.world(name: 'forge2867'),
        );

        expect(pageWorldResult, 'popup-page-world-$cycle');
        expect(customWorldResult, 'popup-custom-world-$cycle');
        expect(asyncResult, isNotNull);
        expect(asyncResult!.error, isNull);
        expect(asyncResult.value, 'popup-async-$cycle');

        final navigationRace = popup.callAsyncJavaScript(
          functionBody: '''
            return await new Promise(function(resolve) {
              window.setTimeout(function() { resolve('navigation-race'); }, 250);
            });
          ''',
          contentWorld: ContentWorld.world(name: 'forge2867'),
        );
        unawaited(
          popup.loadUrl(urlRequest: URLRequest(url: WebUri('about:blank'))),
        );
        final navigationRaceResult = await navigationRace.timeout(
          const Duration(seconds: 20),
        );
        expect(navigationRaceResult, isNotNull);

        completedCycles.add(cycle);
        harnessKey.currentState!.closePopup();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
      }

      debugPrint(
        'iOS #2867 diagnostic: cycles=$completedCycles '
        'popupActions=${popupActions.length} navigationUrls=$navigationUrls',
      );
      expect(completedCycles, [0, 1, 2]);
      expect(popupActions, hasLength(3));
    },
    skip: !_runDiagnostic || !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
