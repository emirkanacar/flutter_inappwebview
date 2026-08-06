import 'dart:io';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void _assert(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

void main() {
  final source = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/InAppWebView.swift',
  ).readAsStringSync();

  _assert(
    source.contains('keyboardDidHideNotification'),
    'keyboardDidHideNotification is not registered',
  );
  _assert(
    source.contains('func keyboardDidHide'),
    'keyboardDidHide restoration is missing',
  );
  _assert(
    source.contains('name: UIResponder.keyboardDidHideNotification'),
    'keyboardDidHide observer is missing',
  );

  final willHide = RegExp(
    r'@objc func keyboardWillHide\(notification: NSNotification\) \{'
    r'([\s\S]*?)\n    \}\n\n    @objc func keyboardDidHide',
  ).firstMatch(source)?.group(1);
  _assert(willHide != null, 'keyboardWillHide function could not be parsed');
  _assert(
    !willHide!.contains('resetScrollViewContentInset'),
    'keyboardWillHide restores the inset before UIKit finishes its layout pass',
  );

  final windowSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/UIApplication/VisibleViewController.swift',
  ).readAsStringSync();
  final pluginSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebViewFlutterPlugin.swift',
  ).readAsStringSync();

  _assert(
    windowSource.contains('activeKeyWindow'),
    'active window helper is missing',
  );
  _assert(
    windowSource.contains('UIWindowScene'),
    'scene-aware window lookup is missing',
  );
  _assert(
    pluginSource.contains('registrar.addSceneDelegate(instance)'),
    'Flutter scene delegate registration is missing',
  );
  _assert(
    !windowSource.contains('UIApplication.shared.delegate?.window'),
    'legacy AppDelegate window lookup is still present',
  );

  _assert(
    source.contains('guard windowCreated else { return }'),
    'popup JavaScript is evaluated before the Flutter platform view is attached',
  );
  _assert(
    source.contains('if #unavailable(iOS 18.0), windowId != nil'),
    'popup content-world compatibility guard is missing',
  );
  _assert(
    source.contains('super.evaluateJavaScript(javaScript) { result, error in'),
    'popup JavaScript does not use the page-world fallback',
  );
  _assert(
    source.contains(
      'in: WKContentWorld.page, completionHandler: completionHandler',
    ),
    'popup async JavaScript does not use the page content world fallback',
  );

  final consoleScript = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PluginScriptsJS/ConsoleLogJS.swift',
  ).readAsStringSync();
  _assert(
    consoleScript.contains('value instanceof Error'),
    'console logging does not preserve Error values',
  );
  _assert(
    consoleScript.contains(
      "value.stack || (value.name + ': ' + value.message)",
    ),
    'console logging does not preserve Error stack/message data',
  );
  _assert(
    consoleScript.contains('argument = JSON.stringify(value)'),
    'console logging does not serialize object arguments',
  );

  final authenticationSettings = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/WebAuthenticationSession/'
    'WebAuthenticationSessionSettings.swift',
  ).readAsStringSync();
  final authenticationSession = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/WebAuthenticationSession/'
    'WebAuthenticationSession.swift',
  ).readAsStringSync();
  _assert(
    authenticationSettings.contains('additionalHeaderFields'),
    'iOS authentication settings do not expose additional headers',
  );
  _assert(
    authenticationSession.contains('session.additionalHeaderFields'),
    'iOS authentication session does not apply additional headers',
  );

  final printScript = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PluginScriptsJS/PrintJS.swift',
  ).readAsStringSync();
  _assert(
    printScript.contains('window.location.href);\n        };'),
    'iOS print override is missing its terminating semicolon',
  );

  _assert(
    source.contains('IOSFullscreenVideoJS.messageHandlerName'),
    'iOS 26 fullscreen video message handler is not wired',
  );
  _assert(
    source.contains('beginNativeFullscreenContainer'),
    'iOS 26 native fullscreen handoff is missing',
  );
  _assert(
    source.contains(
      'closeAllMediaPresentations(completionHandler: presentContainer)',
    ),
    'iOS 26 handoff does not close the WebKit media presentation',
  );
  _assert(
    source.contains('useNativeFullscreenContainer'),
    'iOS 26 fullscreen opt-out setting is not consumed by the native implementation',
  );

  final fullscreenScript = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PluginScriptsJS/IOSFullscreenVideoJS.swift',
  ).readAsStringSync();
  _assert(
    fullscreenScript.contains('webkitEnterFullscreen'),
    'iOS fullscreen interception script is missing the video API hook',
  );
  _assert(
    fullscreenScript.contains('MutationObserver'),
    'iOS fullscreen interception script does not handle dynamically added videos',
  );
  _assert(
    fullscreenScript.contains('messageSecret'),
    'iOS fullscreen interception script is missing its private message secret',
  );

  final fullscreenController = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/IOSFullscreenWebViewController.swift',
  ).readAsStringSync();
  _assert(
    fullscreenController.contains('restoreWebView'),
    'native fullscreen controller does not restore the Flutter web view',
  );
  _assert(
    fullscreenController.contains('modalPresentationStyle = .fullScreen'),
    'native fullscreen controller is not presented full screen',
  );
}
