import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('JavaScript handler results are parsed, never run as code', () {
    // Upstream PR #2948: a handler can return pre-encoded JSON text
    // (JavaScriptHandlerJsonResult). The result must not be spliced into
    // JavaScript source, or invalid or untrusted text would run in the page.
    final source = _sourceFile(
      'windows/in_app_webview/in_app_webview.cpp',
    ).readAsStringSync();

    expect(source, isNot(contains('].resolve(" + json + ")')));
    expect(
      source,
      contains('value = JSON.parse(" + javaScriptStringLiteral(json) + ")'),
    );
    expect(source, contains('catch (e) { handler.reject(e); return; }'));
  });
}
