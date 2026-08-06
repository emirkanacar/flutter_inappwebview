import 'dart:io';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void _expectContains(String source, String expected, String description) {
  if (!source.contains(expected)) {
    throw StateError('Missing $description: $expected');
  }
}

void main() {
  final platformUtilSource = _sourceFile(
    'windows/platform_util.cpp',
  ).readAsStringSync();
  final nativeViewSource = _sourceFile(
    'windows/in_app_webview/in_app_webview.cpp',
  ).readAsStringSync();
  final dartViewSource = _sourceFile(
    'lib/src/in_app_webview/custom_platform_view.dart',
  ).readAsStringSync();

  _expectContains(
    platformUtilSource,
    'onWindowMinimize',
    'the native minimize event',
  );
  _expectContains(
    platformUtilSource,
    'onWindowRestore',
    'the native restore event',
  );
  _expectContains(
    nativeViewSource,
    'setVisibility',
    'the native visibility API',
  );
  _expectContains(
    nativeViewSource,
    'SW_HIDE',
    'the hidden WebView2 window path',
  );
  _expectContains(
    dartViewSource,
    '_setVisibility(false)',
    'the minimize callback',
  );
  _expectContains(
    dartViewSource,
    '_setVisibility(true)',
    'the restore callback',
  );
}
