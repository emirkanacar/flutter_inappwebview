import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_BUNDLE_CODEC_DIAGNOSTIC',
);

// Opt-in Android API 35 activity-handoff diagnostic for issue #2536. The
// payload deliberately exercises nested maps/lists in plugin-owned activity
// extras. It validates the launch, native decode, WebView load, and close
// callback path; malformed foreign extras still require an instrumentation
// test that can inject an external Intent.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Android #2536 Bundle codec activity handoff diagnostic',
    () async {
      final browserCreated = Completer<void>();
      final firstPageLoaded = Completer<void>();
      final browserClosed = Completer<void>();
      final browser = _DiagnosticInAppBrowser(
        onBrowserCreatedCallback: () {
          if (!browserCreated.isCompleted) browserCreated.complete();
        },
        onLoadStopCallback: () {
          if (!firstPageLoaded.isCompleted) firstPageLoaded.complete();
        },
        onExitCallback: () {
          if (!browserClosed.isCompleted) browserClosed.complete();
        },
      );

      browser.addMenuItem(
        InAppBrowserMenuItem(
          id: 2536,
          title: 'Bundle codec diagnostic',
          order: 1,
          showAsAction: true,
        ),
      );

      await browser.openData(
        data: '''
<!doctype html>
<html><head><meta name="viewport" content="width=device-width"></head>
<body><p id="bundle-codec">Android #2536</p></body></html>
''',
        mimeType: 'text/html',
        encoding: 'utf-8',
        baseUrl: WebUri('https://example.com/'),
        historyUrl: WebUri('https://example.com/history'),
        settings: InAppBrowserClassSettings(
          browserSettings: InAppBrowserSettings(
            hideDefaultMenuItems: true,
            toolbarTopFixedTitle: 'Bundle codec diagnostic',
          ),
          webViewSettings: InAppWebViewSettings(javaScriptEnabled: true),
        ),
      );

      await browserCreated.future.timeout(const Duration(seconds: 20));
      await firstPageLoaded.future.timeout(const Duration(seconds: 30));
      expect(browser.isOpened(), isTrue);
      expect(browser.webViewController, isNotNull);

      final loadedUrl = await browser.webViewController!.getUrl();
      expect(loadedUrl, WebUri('https://example.com/history'));

      await browser.close();
      await browserClosed.future.timeout(const Duration(seconds: 20));
      expect(browser.isOpened(), isFalse);

      debugPrint(
        jsonEncode({
          'issue': 2536,
          'platform': Platform.operatingSystem,
          'nestedBundlePayload': true,
          'browserCreated': browserCreated.isCompleted,
          'firstPageLoaded': firstPageLoaded.isCompleted,
          'browserClosed': browserClosed.isCompleted,
          'loadedUrl': loadedUrl.toString(),
        }),
      );
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );

  test(
    'Android #2536 Bundle codec Custom Tabs handoff diagnostic',
    () async {
      final opened = Completer<void>();
      final loaded = Completer<bool?>();
      final closed = Completer<void>();
      final browser = _DiagnosticChromeSafariBrowser(
        onOpenedCallback: () {
          if (!opened.isCompleted) opened.complete();
        },
        onCompletedInitialLoadCallback: (didLoadSuccessfully) {
          if (!loaded.isCompleted) loaded.complete(didLoadSuccessfully);
        },
        onClosedCallback: () {
          if (!closed.isCompleted) closed.complete();
        },
      );

      browser.addMenuItem(
        ChromeSafariBrowserMenuItem(id: 2536, label: 'Bundle codec diagnostic'),
      );

      await browser.open(
        url: WebUri('https://example.com/'),
        headers: {'x-android-2536': 'bundle-codec'},
        referrer: WebUri('android-app://bundle-codec-diagnostic'),
        otherLikelyURLs: [WebUri('https://www.example.com/')],
        settings: ChromeSafariBrowserSettings(
          showTitle: true,
          keepAliveEnabled: true,
        ),
      );

      await opened.future.timeout(const Duration(seconds: 20));
      final didLoadSuccessfully = await loaded.future.timeout(
        const Duration(seconds: 30),
      );
      expect(browser.isOpened(), isTrue);
      expect(didLoadSuccessfully, isNot(false));

      await browser.close();
      await closed.future.timeout(const Duration(seconds: 20));
      expect(browser.isOpened(), isFalse);

      debugPrint(
        jsonEncode({
          'issue': 2536,
          'platform': Platform.operatingSystem,
          'customTabs': true,
          'nestedBundlePayload': true,
          'opened': opened.isCompleted,
          'loaded': loaded.isCompleted,
          'closed': closed.isCompleted,
          'didLoadSuccessfully': didLoadSuccessfully,
        }),
      );
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

class _DiagnosticInAppBrowser extends InAppBrowser {
  _DiagnosticInAppBrowser({
    required this.onBrowserCreatedCallback,
    required this.onLoadStopCallback,
    required this.onExitCallback,
  }) : super(
         initialUserScripts: UnmodifiableListView([
           UserScript(
             source: "document.documentElement.dataset.bundleCodec = 'ok';",
             injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
             allowedOriginRules: {'*'},
           ),
         ]),
       );

  final void Function() onBrowserCreatedCallback;
  final void Function() onLoadStopCallback;
  final void Function() onExitCallback;

  @override
  Future<void> onBrowserCreated() async => onBrowserCreatedCallback();

  @override
  void onLoadStop(WebUri? url) {
    super.onLoadStop(url);
    onLoadStopCallback();
  }

  @override
  void onExit() => onExitCallback();
}

class _DiagnosticChromeSafariBrowser extends ChromeSafariBrowser {
  _DiagnosticChromeSafariBrowser({
    required this.onOpenedCallback,
    required this.onCompletedInitialLoadCallback,
    required this.onClosedCallback,
  });

  final void Function() onOpenedCallback;
  final void Function(bool?) onCompletedInitialLoadCallback;
  final void Function() onClosedCallback;

  @override
  void onOpened() => onOpenedCallback();

  @override
  void onCompletedInitialLoad(bool? didLoadSuccessfully) =>
      onCompletedInitialLoadCallback(didLoadSuccessfully);

  @override
  void onClosed() => onClosedCallback();
}
