import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_macos/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

const _sources =
    'macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos/';

String _body(String source, String signature, String end) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature is missing');
  final stop = source.indexOf(end, start);
  expect(stop, greaterThan(start), reason: '$signature has no end');
  return source.substring(start, stop);
}

void main() {
  // Upstream PR #2952: Tab and VoiceOver could not get into the page because
  // nothing made the web view AppKit's first responder. Forge ports it behind
  // InAppWebViewSettings.enableAccessibilityFocus (default false).
  final keyboardFocus = _sourceFile(
    '${_sources}InAppWebView/InAppWebView+KeyboardFocus.swift',
  ).readAsStringSync();

  test('accessibility focus setting defaults to off natively', () {
    final settings = _sourceFile(
      '${_sources}InAppWebView/InAppWebViewSettings.swift',
    ).readAsStringSync();
    expect(settings, contains('var enableAccessibilityFocus = false'));
  });

  test('focusPage and releasePage are no-ops while the setting is off', () {
    expect(
      _body(keyboardFocus, 'func focusPage(direction:', 'func releasePage'),
      contains('guard isAccessibilityFocusEnabled'),
    );
    expect(
      _body(keyboardFocus, 'func releasePage()', '@objc(_webView:takeFocus:)'),
      contains('guard isAccessibilityFocusEnabled'),
    );
  });

  test('takeFocus keeps the WebKit key view loop while the setting is off', () {
    final takeFocus = _body(
      keyboardFocus,
      '@objc(_webView:takeFocus:)',
      '\n    }\n}',
    );
    final guardIndex = takeFocus.indexOf('guard isAccessibilityFocusEnabled');
    expect(guardIndex, isNonNegative);
    final offBranch = takeFocus.substring(
      guardIndex,
      takeFocus.indexOf('return', guardIndex),
    );
    expect(offBranch, contains('selectKeyView(following: self)'));
    expect(offBranch, contains('selectKeyView(preceding: self)'));
    expect(offBranch, isNot(contains('_onTakeFocus')));
  });

  test('becomeFirstResponder reports only while the setting is on', () {
    final webView = _sourceFile(
      '${_sources}InAppWebView/InAppWebView.swift',
    ).readAsStringSync();
    final become = _body(
      webView,
      'func becomeFirstResponder()',
      '\n    }\n',
    );
    expect(become, contains('became && isAccessibilityFocusEnabled'));
    expect(webView, contains('_onMouseDown(accessibilityFocus:'));
  });

  test('channel methods are registered and use optional webView', () {
    final methods = _sourceFile(
      '${_sources}InAppWebView/WebViewChannelDelegateMethods.swift',
    ).readAsStringSync();
    expect(methods, contains('case focusPage = "_focusPage"'));
    expect(methods, contains('case releasePage = "_releasePage"'));
    final delegate = _sourceFile(
      '${_sources}InAppWebView/WebViewChannelDelegate.swift',
    ).readAsStringSync();
    expect(delegate, contains('webView?.focusPage(direction:'));
    expect(delegate, contains('webView?.releasePage()'));
    expect(delegate, contains('as? String'));
  });

  test('Dart keeps the unfocus workaround unless the native flag is set', () {
    final controller = _sourceFile(
      'lib/src/in_app_webview/in_app_webview_controller.dart',
    ).readAsStringSync();
    final mouseDown = _body(
      controller,
      'if (call.method == "_onMouseDown")',
      'if (call.method == "_onTakeFocus")',
    );
    expect(mouseDown, contains('arguments["accessibilityFocus"] == true'));
    expect(
      mouseDown,
      contains('FocusManager.instance.primaryFocus?.unfocus()'),
    );
    expect(
      _body(controller, 'void dispose({bool isKeepAlive = false})', '\n  }\n'),
      contains('internalOnTakeFocus = null'),
    );
    final widget = _sourceFile(
      'lib/src/in_app_webview/in_app_webview.dart',
    ).readAsStringSync();
    expect(widget, contains('canRequestFocus: false'));
    expect(widget, contains('skipTraversal: true'));
  });
}
