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
  test('legacy callAsyncJavaScript wrapper closes its parameter list', () {
    // Upstream PR #2931: below macOS 11 callAsyncJavaScript with arguments
    // produced `async function(a, b {`, a JavaScript syntax error.
    final source = _sourceFile(
      'macos/flutter_inappwebview_forge_macos/Sources/'
      'flutter_inappwebview_forge_macos/PluginScriptsJS/'
      'CallAsyncJavaScriptBelowIOS14WrapperJS.swift',
    ).readAsStringSync();
    expect(
      source,
      contains(
        r'(async function(\(PluginScriptsUtil.VAR_FUNCTION_ARGUMENT_NAMES)) {',
      ),
    );
  });
}
