import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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
  test(
    'Linux native source contracts remain guarded',
    _runSourceContractAssertions,
  );
}

void _runSourceContractAssertions() {
  final source = _sourceFile(
    'linux/in_app_webview/in_app_webview.cc',
  ).readAsStringSync();
  final lifecycleSource = _sourceFile(
    'linux/types/web_view_lifecycle_coordinator.h',
  ).readAsStringSync();
  final softwareRenderingSource = _sourceFile(
    'linux/utils/software_rendering.cc',
  ).readAsStringSync();
  final softwareRenderingHeader = _sourceFile(
    'linux/utils/software_rendering.h',
  ).readAsStringSync();
  final cmakeSource = _sourceFile('linux/CMakeLists.txt').readAsStringSync();
  final readmeSource = _sourceFile('README.md').readAsStringSync();
  final cookieManagerSource = _sourceFile(
    'linux/cookie_manager.cc',
  ).readAsStringSync();
  final proxySource = _sourceFile('linux/proxy_manager.cc').readAsStringSync();
  final autocorrectionSource = _sourceFile(
    'linux/plugin_scripts_js/disable_autocorrection_js.h',
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
  final browserSource = _sourceFile(
    'linux/in_app_browser/in_app_browser.cc',
  ).readAsStringSync();
  _expectContains(
    browserSource,
    'FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL',
    'the explicit software-rendering fallback switch',
  );
  _expectContains(
    browserSource,
    'setupDrawingAreaFallback()',
    'the non-GL rendering path',
  );
  _expectContains(
    browserSource,
    'fallbackFromGlArea()',
    'the runtime GL failure fallback',
  );
  _expectContains(
    browserSource,
    'falling back to pixel-buffer rendering',
    'the actionable GL fallback diagnostic',
  );
  _expectContains(
    softwareRenderingSource,
    'FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL',
    'the explicit no-GL software-rendering override',
  );
  _expectContains(
    softwareRenderingSource,
    'setenv("LIBGL_ALWAYS_SOFTWARE", "1", 0)',
    'the early software-rendering environment setup',
  );
  _expectContains(
    source,
    '!software_rendering_requested && !egl_import_failed_permanently',
    'the DMA-BUF skip in the pixel-buffer path',
  );
  _expectContains(
    lifecycleSource,
    'WebViewLifecycleState',
    'the Linux internal lifecycle state model',
  );
  _expectContains(
    lifecycleSource,
    'markDetachedRetained',
    'the Linux retained ownership transition',
  );
  final channelSource = _sourceFile(
    'linux/in_app_webview/webview_channel_delegate.cc',
  ).readAsStringSync();
  _expectContains(
    channelSource,
    'canDispatchCallbacks()',
    'the Linux stale-channel callback gate',
  );
  _expectContains(
    softwareRenderingHeader,
    'software WPE buffers',
    'the software-buffer fallback documentation',
  );
  _expectContains(
    cookieManagerSource,
    'getCookieManager(FlValue* args)',
    'the WebView-scoped cookie manager lookup',
  );
  _expectContains(
    cookieManagerSource,
    'webkit_web_view_get_network_session',
    'the WebView network-session cookie scope',
  );
  _expectContains(
    proxySource,
    'applyProxySettings(WebKitNetworkSession* session',
    'the per-session proxy application path',
  );
  _expectContains(
    source,
    'DisableAutocorrectionJS::DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT',
    'the Linux autocorrection plugin registration',
  );
  final settingsSource = _sourceFile(
    'linux/in_app_webview/in_app_webview_settings.cc',
  ).readAsStringSync();
  final settingsHeader = _sourceFile(
    'linux/in_app_webview/in_app_webview_settings.h',
  ).readAsStringSync();
  final contentBlockerSource = _sourceFile(
    'linux/content_blocker/content_blocker_handler.cc',
  ).readAsStringSync();
  _expectContains(
    settingsSource,
    'const auto changed = [this, previous]',
    'the Linux property-level settings diff helper',
  );
  _expectContains(
    settingsHeader,
    'const InAppWebViewSettings* previous = nullptr',
    'the Linux settings snapshot API',
  );
  _expectContains(
    contentBlockerSource,
    'serializeContentBlockers',
    'the Linux content-blocker snapshot serializer',
  );
  _expectContains(
    source,
    'content_blockers_snapshot_',
    'the Linux duplicate content-blocker compilation guard',
  );
  _expectContains(
    autocorrectionSource,
    'UserScriptInjectionTime::atDocumentStart',
    'the Linux document-start autocorrection script',
  );
  _expectContains(
    autocorrectionSource,
    'spellcheck',
    'the Linux spelling-suggestion hint',
  );
  final headlessManagerSource = _sourceFile(
    'linux/headless_in_app_webview/headless_in_app_webview_manager.cc',
  ).readAsStringSync();
  final managerSource = _sourceFile(
    'linux/in_app_webview/in_app_webview_manager.cc',
  ).readAsStringSync();
  _expectContains(
    headlessManagerSource,
    'RemoveHeadlessWebView(id);',
    'the duplicate headless ID replacement gate',
  );
  _expectContains(
    managerSource,
    'keepAliveWebViews_.emplace(keepAliveId, std::move(view));',
    'the explicit keep-alive ownership insertion',
  );
  _expectContains(
    managerSource,
    'existingView->webview()->markReattached();',
    'the Linux keep-alive reattachment transition',
  );
  final disposeGate = source.indexOf('lifecycle_.beginDisposal()');
  final firstCleanup = source.indexOf('CleanupMonitorChangeHandlers();');
  if (disposeGate < 0 || firstCleanup < 0 || disposeGate > firstCleanup) {
    throw StateError(
      'Linux WPE disposal must enable the callback gate before cleanup starts',
    );
  }
}
