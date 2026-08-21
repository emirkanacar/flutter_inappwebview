import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_platform_interface/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('saveFormData deprecation names Autofill and has no Dart replacement', () {
    final source = _sourceFile(
      'lib/src/in_app_webview/in_app_webview_settings.dart',
    ).readAsStringSync();

    expect(source, isNot(contains("@Deprecated('')")));
    expect(
      source,
      contains(
        'Android Autofill replaced WebView form-data saving; this setting is a no-op on API 26+ and has no Dart replacement',
      ),
    );
  });
}
