import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_android/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('Android resource interception has bounded synchronous backpressure', () {
    final clientSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();
    final delegateSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/WebViewChannelDelegate.kt',
    ).readAsStringSync();

    expect(clientSource, contains('MAX_CONCURRENT_SYNC_INTERCEPT_REQUESTS'));
    expect(clientSource, contains('synchronousInterceptRequestsInFlight'));
    expect(
      clientSource,
      contains('Too many synchronous shouldInterceptRequest callbacks'),
    );
    expect(delegateSource, contains('SYNC_INTERCEPT_REQUEST_TIMEOUT_MILLIS'));
  });

  test(
    'Android cookie clearing does not flush synchronously after async deletion',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'MyCookieManager.kt',
      ).readAsStringSync();
      final deleteAllCookies = RegExp(
        r'fun deleteAllCookies\(result: MethodChannel\.Result\) \{([\s\S]*?)\n    \}\n\n    fun removeSessionCookies',
      ).firstMatch(source)?.group(1);

      expect(deleteAllCookies, isNotNull);
      expect(deleteAllCookies, isNot(contains('manager.flush()')));
    },
  );

  test(
    'Android IME lifecycle code requires an attached window before touching input state',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'webview/in_app_webview/InputAwareWebView.kt',
      ).readAsStringSync();

      expect(source, contains('isAttachedToWindow'));
      expect(source, contains('windowToken'));
      expect(source, contains('isViewReady'));
    },
  );

  test('Android HTTP navigation keeps the native navigation context', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();

    expect(source, contains('isHttpOrHttpsUrl'));
    expect(source, contains('nativeNavigationContinues'));
    expect(source, contains('webView.stopLoading()'));
  });

  test('Android 15 skips the deprecated status-bar color API', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'in_app_browser/InAppBrowserActivity.kt',
    ).readAsStringSync();

    expect(
      source,
      contains('WindowCompat.setDecorFitsSystemWindows(window, false)'),
    );
    expect(source, isNot(contains('statusBarColor')));
  });
}
