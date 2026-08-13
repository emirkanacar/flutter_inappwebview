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
  test('iOS maps the Universal Link policy to WebKit raw value 3', () {
    final source = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Sources/'
      'flutter_inappwebview_forge_ios/InAppWebView/WebViewChannelDelegate.swift',
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
