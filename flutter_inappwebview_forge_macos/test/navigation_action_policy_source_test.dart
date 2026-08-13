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
  test('macOS maps the Universal Link policy to WebKit raw value 3', () {
    final source = _sourceFile(
      'macos/flutter_inappwebview_forge_macos/Sources/'
      'flutter_inappwebview_forge_macos/InAppWebView/WebViewChannelDelegate.swift',
    ).readAsStringSync();

    expect(
      source,
      contains('action == WKNavigationActionPolicy.allow.rawValue + 2'),
    );
    expect(
      source,
      contains('rawValue: WKNavigationActionPolicy.allow.rawValue + 2'),
    );
    expect(source, contains('?? WKNavigationActionPolicy.allow'));
  });
}
