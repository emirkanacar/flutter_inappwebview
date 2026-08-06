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
}
