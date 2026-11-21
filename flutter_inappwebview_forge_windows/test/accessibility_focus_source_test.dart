import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

String _body(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature is missing');
  final end = source.indexOf('\n  }\n', start);
  expect(end, greaterThan(start), reason: '$signature has no end');
  return source.substring(start, end);
}

void main() {
  // Upstream PR #2953: with visual hosting the WebView2 accessibility tree is
  // not attached to any window and Tab never reaches the page. Forge ports it
  // behind InAppWebViewSettings.enableAccessibilityFocus (default false).
  final webView = _sourceFile(
    'windows/in_app_webview/in_app_webview.cpp',
  ).readAsStringSync();

  test('accessibility focus setting defaults to off natively', () {
    final header = _sourceFile(
      'windows/in_app_webview/in_app_webview_settings.h',
    ).readAsStringSync();
    expect(header, contains('bool enableAccessibilityFocus = false;'));
    final settings = _sourceFile(
      'windows/in_app_webview/in_app_webview_settings.cpp',
    ).readAsStringSync();
    expect(settings, contains('"enableAccessibilityFocus"'));
  });

  test('UI Automation provider is exposed only while the setting is on', () {
    final proc = _body(
      webView,
      'LRESULT CALLBACK InAppWebView::hostWindowProc',
    );
    expect(proc, contains('view->isAccessibilityFocusEnabled()'));
    expect(
      proc,
      contains('return DefWindowProc(hwnd, message, wparam, lparam);'),
    );
    final manager = _sourceFile(
      'windows/in_app_webview/in_app_webview_manager.cpp',
    ).readAsStringSync();
    expect(manager, contains('lpfnWndProc = &InAppWebView::hostWindowProc'));
    final cmake = _sourceFile('windows/CMakeLists.txt').readAsStringSync();
    expect(
      'uiautomationcore'.allMatches(cmake).length,
      greaterThanOrEqualTo(2),
    );
  });

  test('MoveFocus and MoveFocusRequested are gated by the setting', () {
    expect(
      _body(webView, 'void InAppWebView::moveFocus(bool next)'),
      contains('!isAccessibilityFocusEnabled()'),
    );
    final handlers = _body(
      webView,
      'void InAppWebView::registerSurfaceEventHandlers()',
    );
    final moveFocusRequested = handlers.substring(
      handlers.indexOf('add_MoveFocusRequested'),
    );
    final gate = moveFocusRequested.indexOf('!isAccessibilityFocusEnabled()');
    final handled = moveFocusRequested.indexOf('put_Handled(TRUE)');
    expect(gate, isNonNegative);
    expect(handled, greaterThan(gate));
  });

  test('the host window property is removed before disposal', () {
    final destructor = _body(webView, 'InAppWebView::~InAppWebView()');
    final detach = destructor.indexOf('detachHostWindow();');
    expect(detach, isNonNegative);
    expect(detach, lessThan(destructor.indexOf('lifecycle_.beginDisposal()')));
    expect(
      _body(webView, 'void InAppWebView::detachHostWindow()'),
      contains('GetPropW(hostWindow_, kHostWindowViewProp) == this'),
    );
    final view = _sourceFile(
      'windows/custom_platform_view/custom_platform_view.cc',
    ).readAsStringSync();
    expect(
      _body(view, 'CustomPlatformView::~CustomPlatformView()'),
      contains('view->onMoveFocusRequested(nullptr)'),
    );
  });

  test('Dart moves focus into the page only after Tab traversal', () {
    final dart = _sourceFile(
      'lib/src/in_app_webview/custom_platform_view.dart',
    ).readAsStringSync();
    expect(dart, contains('_TabKeyTracker.recentTraversal()'));
    expect(dart, contains("invokeMethod('moveFocus', next)"));
    expect(dart, contains("case 'moveFocusRequested':"));
    expect(dart, contains('_moveFocusRequestedSubscription?.cancel()'));
  });
}
