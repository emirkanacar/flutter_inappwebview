import 'dart:io';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_web/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void _assert(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

void main() {
  final supportSource = _sourceFile(
    'lib/assets/web/web_support.js',
  ).readAsStringSync();
  final elementSource = _sourceFile(
    'lib/web/in_app_web_view_web_element.dart',
  ).readAsStringSync();
  final platformSource = _sourceFile(
    'lib/web/web_platform.dart',
  ).readAsStringSync();

  _assert(
    supportSource.contains('const getIFrameUrl = function(iframeElement)'),
    'iframe URL helper is missing',
  );
  _assert(
    supportSource.contains('return null;'),
    'cross-origin iframe URL fallback is missing',
  );
  _assert(
    supportSource.contains(
      '_nativeCommunication("onLoadStart", viewId, [url])',
    ),
    'load-start URL event is missing',
  );
  _assert(
    supportSource.contains('_nativeCommunication("onLoadStop", viewId, [url])'),
    'load-stop URL event is missing',
  );
  _assert(
    supportSource.contains('return getIFrameUrl(iframe2);'),
    'getUrl does not read the current iframe location',
  );
  _assert(
    elementSource.contains('void onLoadStart(String? url)'),
    'load-start callback is not nullable',
  );
  _assert(
    elementSource.contains('void onLoadStop(String? url)'),
    'load-stop callback is not nullable',
  );
  _assert(
    elementSource.contains('bool _hasLoadedDocument = false;'),
    'document-load state is missing',
  );
  _assert(
    elementSource.contains('if (!_hasLoadedDocument &&'),
    'getUrl still falls back to a stale source after a document loads',
  );
  _assert(
    platformSource.contains('String? url = args?[0] as String?;'),
    'native URL event decoding is not nullable',
  );
  _assert(
    supportSource.contains('return null;') &&
        supportSource.contains('getIFrameUrl'),
    'cross-origin URL reads must not reuse the iframe source',
  );
}
