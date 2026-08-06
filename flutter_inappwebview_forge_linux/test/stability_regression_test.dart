import 'dart:io';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_linux/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void _expectContains(String source, String expected, String description) {
  if (!source.contains(expected)) {
    throw StateError('Missing $description: $expected');
  }
}

void main() {
  final source = _sourceFile(
    'linux/in_app_webview/in_app_webview.cc',
  ).readAsStringSync();
  final cmakeSource = _sourceFile('linux/CMakeLists.txt').readAsStringSync();
  final readmeSource = _sourceFile(
    'flutter_inappwebview_forge_linux/README.md',
  ).readAsStringSync();

  _expectContains(
    source,
    '#if WEBKIT_CHECK_VERSION(2, 50, 0)',
    'the WebKit theme-color version guard',
  );
  _expectContains(
    source,
    'webkit_web_view_get_theme_color',
    'the supported WebKit theme-color call',
  );
  _expectContains(
    source,
    'return std::nullopt;',
    'the older-WebKit theme-color fallback',
  );
  _expectContains(
    cmakeSource,
    'WPE_BACKEND_DOC',
    'the backend-specific CMake documentation path',
  );
  _expectContains(
    cmakeSource,
    'wpe-webkit-2.0, wpe-webkit-1.1, and wpe-webkit-1.0',
    'the supported WebKit pkg-config names',
  );
  _expectContains(
    cmakeSource,
    'pkg-config --list-all',
    'the WPE dependency diagnostic command',
  );
  _expectContains(
    readmeSource,
    'WPE_BACKEND.md',
    'the Linux prerequisite documentation link',
  );
}
