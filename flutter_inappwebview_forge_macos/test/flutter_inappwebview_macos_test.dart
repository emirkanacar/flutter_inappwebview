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
  test(
    'macOS native source contracts remain guarded',
    _runSourceContractAssertions,
  );
}

void _runSourceContractAssertions() {
  final settings = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/WebAuthenticationSession/'
    'WebAuthenticationSessionSettings.swift',
  ).readAsStringSync();
  final session = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/WebAuthenticationSession/'
    'WebAuthenticationSession.swift',
  ).readAsStringSync();

  if (!settings.contains('additionalHeaderFields')) {
    throw StateError(
      'macOS authentication settings do not expose additional headers',
    );
  }
  if (!session.contains('session.additionalHeaderFields')) {
    throw StateError(
      'macOS authentication session does not apply additional headers',
    );
  }
  if (!session.contains('NSApp.keyWindow')) {
    throw StateError(
      'macOS authentication session does not prefer the active key window',
    );
  }
  if (!session.contains(
        '@available(macOS 10.15, *)\nprivate class WebAuthenticationPresentationContextProviding: NSObject, ASWebAuthenticationPresentationContextProviding',
      ) ||
      !session.contains(
        'public class WebAuthenticationSession: NSObject, Disposable',
      ) ||
      !session.contains('_presentationContextProvider') ||
      !session.contains('session.presentationContextProvider = provider')) {
    throw StateError(
      'macOS authentication context provider is not isolated behind its availability boundary',
    );
  }

  final webViewSource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/InAppWebView/InAppWebView.swift',
  ).readAsStringSync();
  final settingsSource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/InAppWebView/InAppWebViewSettings.swift',
  ).readAsStringSync();
  if (!webViewSource.contains('if #available(macOS 11.3, *)')) {
    throw StateError(
      'macOS upgradeKnownHostsToHTTPS is not guarded in WebView settings',
    );
  }
  if (!settingsSource.contains('if #available(macOS 11.3, *)')) {
    throw StateError(
      'macOS upgradeKnownHostsToHTTPS is not guarded in real settings',
    );
  }
  if (!settingsSource.contains('var proxySettings: [String: Any?]? = nil') ||
      !webViewSource.contains('settings.proxySettings') ||
      !webViewSource.contains('webViews[String(describing: id)] = self')) {
    throw StateError(
      'macOS container proxy settings are not bound to the WebView store',
    );
  }
  final cookieManagerSource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/MyCookieManager.swift',
  ).readAsStringSync();
  if (!cookieManagerSource.contains('cookieStore(for webViewId: String?)') ||
      !cookieManagerSource.contains('cookieStore: cookieStore')) {
    throw StateError(
      'macOS cookie operations do not select the WebView cookie store',
    );
  }
  if (!webViewSource.contains('override func willOpenMenu')) {
    throw StateError('macOS custom context menu hook is missing');
  }
  if (!webViewSource.contains('NSMenuItem')) {
    throw StateError('macOS custom context menu items are not created');
  }
  if (!webViewSource.contains('contextMenuActionTargets')) {
    throw StateError('macOS custom context menu targets are not retained');
  }
  final customSchemeSource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/InAppWebView/CustomSchemeHandler.swift',
  ).readAsStringSync();
  if (!customSchemeSource.contains('webView as? InAppWebView') ||
      !customSchemeSource.contains('didFailWithError')) {
    throw StateError(
      'macOS custom scheme handler does not guard WebView ownership',
    );
  }
  final storageSource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/MyWebStorageManager.swift',
  ).readAsStringSync();
  if (!storageSource.contains('dataTypes is required') ||
      !storageSource.contains('displayName = r["displayName"] as? String')) {
    throw StateError('macOS WebStorage payloads are not validated');
  }
  if (!webViewSource.contains('onCreateContextMenu') ||
      !webViewSource.contains('onHideContextMenu')) {
    throw StateError(
      'macOS context menu lifecycle callbacks are not forwarded',
    );
  }
  if (!webViewSource.contains('HitTestResult(type: .unknownType')) {
    throw StateError(
      'macOS context menu creation callback has no hit-test fallback',
    );
  }
  final controllerSource = _sourceFile(
    'lib/src/in_app_webview/in_app_webview_controller.dart',
  ).readAsStringSync();
  if (!controllerSource.contains("setContextMenu', args")) {
    throw StateError(
      'macOS Dart controller does not send context menu updates',
    );
  }
  if (!controllerSource.contains(
    '_inAppBrowser?.setContextMenu(contextMenu)',
  )) {
    throw StateError(
      'macOS InAppBrowser context menu updates are not retained',
    );
  }
  if (!controllerSource.contains('_contextMenuWasSet = true') ||
      !controllerSource.contains('if (_contextMenuWasSet)')) {
    throw StateError(
      'macOS context menu clearing does not override initial settings',
    );
  }
  final factorySource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/InAppWebView/FlutterWebViewController.swift',
  ).readAsStringSync();
  if (!factorySource.contains('params["contextMenu"]') ||
      !factorySource.contains('webView!.contextMenu = contextMenu')) {
    throw StateError(
      'macOS initial context menu is not passed to the native WebView',
    );
  }
  if (!factorySource.contains('webView!.autoresizingMask = []') ||
      !factorySource.contains('self.autoresizesSubviews = false') ||
      !factorySource.contains('self.autoresizingMask = []') ||
      !factorySource.contains('public override func layout()') ||
      !factorySource.contains(
        'public override func setFrameSize(_ newSize: NSSize)',
      ) ||
      !factorySource.contains(
        'public override func setBoundsSize(_ newSize: NSSize)',
      ) ||
      !factorySource.contains(
        'public override func resizeSubviews(withOldSize oldSize: NSSize)',
      ) ||
      !factorySource.contains('private func syncWebViewFrameToBounds()') ||
      !factorySource.contains('bounds.width.isFinite') ||
      !factorySource.contains('webView.frame != bounds') ||
      !factorySource.contains('webView.frame = bounds')) {
    throw StateError(
      'macOS platform-view frame synchronization is not guarded',
    );
  }
  final delegateSource = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/InAppWebView/WebViewChannelDelegate.swift',
  ).readAsStringSync();
  if (!delegateSource.contains('case let id as NSNumber')) {
    throw StateError(
      'macOS context menu item identifiers are not normalized safely',
    );
  }

  final ownershipRemoval = webViewSource.indexOf(
    'plugin?.inAppWebViewManager?.windowWebViews.removeValue(forKey: wId)',
  );
  final pluginRelease = webViewSource.indexOf('plugin = nil', ownershipRemoval);
  if (ownershipRemoval < 0 || pluginRelease <= ownershipRemoval) {
    throw StateError(
      'macOS WebView disposal must remove popup ownership before releasing the plugin',
    );
  }

  final printScript = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/PluginScriptsJS/PrintJS.swift',
  ).readAsStringSync();
  if (!printScript.contains('window.location.href);\n        };')) {
    throw StateError(
      'macOS print override is missing its terminating semicolon',
    );
  }
}
