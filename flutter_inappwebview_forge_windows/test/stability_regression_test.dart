import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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
  test(
    'Windows native source contracts remain guarded',
    _runSourceContractAssertions,
  );
}

void _runSourceContractAssertions() {
  final platformUtilSource = _sourceFile(
    'windows/platform_util.cpp',
  ).readAsStringSync();
  final nativeViewSource = _sourceFile(
    'windows/in_app_webview/in_app_webview.cpp',
  ).readAsStringSync();
  final cmakeSource = _sourceFile('windows/CMakeLists.txt').readAsStringSync();
  final settingsSource = _sourceFile(
    'windows/in_app_webview/in_app_webview_settings.cpp',
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

  _expectContains(
    nativeViewSource,
    'SetVirtualHostNameToFolderMapping',
    'the WebView2 virtual asset origin',
  );
  _expectContains(
    nativeViewSource,
    'COREWEBVIEW2_HOST_RESOURCE_ACCESS_KIND_DENY_CORS',
    'the restricted virtual asset mapping',
  );
  _expectContains(
    nativeViewSource,
    'kFlutterAssetsHostName',
    'the stable virtual asset host',
  );
  _expectContains(
    nativeViewSource,
    'std::wstring(L"https://")',
    'the virtual HTTPS asset URL',
  );
  _expectContains(
    nativeViewSource,
    'isSafeFlutterAssetPath',
    'the relative asset path validation',
  );
  _expectContains(
    nativeViewSource,
    'disposed_.store(true, std::memory_order_release)',
    'the WebView disposal gate',
  );
  _expectContains(
    nativeViewSource,
    'std::lock_guard<std::mutex> controllerLock(controllerMutex_)',
    'the serialized WebView2 controller lifetime calls',
  );
  _expectContains(
    nativeViewSource,
    'put_ZoomFactor',
    'the WebView2 page zoom setter',
  );
  _expectContains(
    nativeViewSource,
    'put_AdditionalBrowserArguments',
    'the WebView2 proxy environment arguments',
  );
  _expectContains(
    settingsSource,
    'proxyServer',
    'the WebView2 proxy settings parser',
  );
  _expectContains(
    settingsSource,
    'get_ZoomFactor',
    'the WebView2 page zoom getter',
  );
  _expectContains(
    nativeViewSource,
    'get_DocumentTitle',
    'the WebView2 document title getter',
  );
  _expectContains(
    _sourceFile('windows/in_app_browser/in_app_browser.cpp').readAsStringSync(),
    'webView && webView->webViewController',
    'the guarded browser resize callback',
  );
  final headlessSource = _sourceFile(
    'windows/headless_in_app_webview/headless_in_app_webview.cpp',
  ).readAsStringSync();
  _expectContains(
    headlessSource,
    '!webView || !webView->webViewController',
    'the headless WebView controller lifetime guard',
  );

  final findDispose = nativeViewSource.indexOf(
    'findInteractionController->dispose();',
  );
  final stopWebView = nativeViewSource.lastIndexOf(
    'failedLog(webView->Stop());',
  );
  final closeWebView = nativeViewSource.lastIndexOf(
    'failedLog(webViewController->Close());',
  );
  if (findDispose < 0 ||
      stopWebView < 0 ||
      closeWebView < 0 ||
      findDispose > stopWebView ||
      findDispose > closeWebView) {
    throw StateError(
      'FindInteractionController must detach before WebView2 Stop/Close',
    );
  }

  _expectContains(
    cmakeSource,
    'set(WIL_VERSION "1.0.260126.7")',
    'the MSVC 14.5-compatible WIL package version',
  );
  _expectContains(
    cmakeSource,
    r'target_compile_options(${TARGET} PRIVATE /FS)',
    'the serialized MSVC PDB write option',
  );
  _expectContains(
    cmakeSource,
    '_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS',
    'the MSVC experimental coroutine compatibility definition',
  );
}
