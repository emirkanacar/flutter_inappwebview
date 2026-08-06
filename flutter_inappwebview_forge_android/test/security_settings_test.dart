import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android never enables universal access from file URLs', () {
    final sourceFile = [
      File(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'webview/in_app_webview/InAppWebView.kt',
      ),
      File(
        'flutter_inappwebview_forge_android/android/src/main/kotlin/'
        'com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/'
        'InAppWebView.kt',
      ),
    ].firstWhere((file) => file.existsSync());

    expect(sourceFile.existsSync(), isTrue);
    final source = sourceFile.readAsStringSync();

    expect(
      RegExp(r'settings\.allowUniversalAccessFromFileURLs\s*=').hasMatch(source),
      isFalse,
    );
    expect(source, contains('Ignoring allowUniversalAccessFromFileURLs on Android'));
  });
}
