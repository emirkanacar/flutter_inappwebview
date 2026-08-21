import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('iOS prewarmConnections keeps the URLs channel payload key', () {
    final dartSource = _sourceFile(
      'lib/src/chrome_safari_browser/chrome_safari_browser.dart',
    ).readAsStringSync();
    final nativeSource = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Sources/'
      'flutter_inappwebview_forge_ios/SafariViewController/'
      'ChromeSafariBrowserManager.swift',
    ).readAsStringSync();

    expect(dartSource, contains('prewarmConnections(List<WebUri> urls)'));
    expect(dartSource, contains("putIfAbsent('URLs'"));
    expect(nativeSource, contains('arguments!["URLs"]'));
  });
}
