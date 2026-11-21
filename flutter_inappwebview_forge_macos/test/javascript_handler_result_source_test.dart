import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_macos/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('JavaScript handler results are parsed, never run as code', () {
    // Upstream PR #2948: a handler can return pre-encoded JSON text
    // (JavaScriptHandlerJsonResult). The result must not be spliced into
    // JavaScript source, or invalid or untrusted text would run in the page.
    final source = _sourceFile(
      'macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos/'
      'InAppWebView/InAppWebView.swift',
    ).readAsStringSync();

    expect(source, isNot(contains(r'].resolve(\(json));')));
    expect(
      source,
      contains(r'value = JSON.parse(\(Util.javaScriptStringLiteral(json)));'),
    );
    expect(source, contains('catch (e) { handler.reject(e); return; }'));
  });
}
