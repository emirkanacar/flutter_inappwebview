import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

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
    source.contains('guard let presentingViewController') &&
        source.contains('visibleViewController'),
    'iOS prompt presentation path does not guard missing presenters',
  );
  final customSchemeSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/CustomSchemeHandler.swift',
  ).readAsStringSync();
  _assert(
    customSchemeSource.contains('webView as? InAppWebView') &&
        customSchemeSource.contains('didFailWithError'),
    'custom scheme handler does not guard non-plugin WebViews',
  );
  _assert(
    source.contains('else {\n            return nil\n        }'),
    'iOS popup creation does not reject a missing WebView manager',
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
  final webViewDelegateSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebViewChannelDelegate.swift',
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
  _assert(
    source.contains('if frame == nil'),
    'evaluateJavaScript does not guard a nil frame',
  );
  _assert(
    source.contains('Frame is nil'),
    'nil-frame evaluateJavaScript does not return a structured error',
  );

  final asyncWrapper = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PluginScriptsJS/'
    'CallAsyncJavaScriptBelowIOS14WrapperJS.swift',
  ).readAsStringSync();
  _assert(
    asyncWrapper.contains('RESULT_MESSAGE_HANDLER_NAME'),
    'legacy callAsyncJavaScript result handler is not registered',
  );
  _assert(
    asyncWrapper.contains('windowId'),
    'legacy callAsyncJavaScript result does not preserve the window id',
  );
  _assert(
    source.contains(
      'removeScriptMessageHandler(\n                forName: CallAsyncJavaScriptBelowIOS14WrapperJS.RESULT_MESSAGE_HANDLER_NAME',
    ),
    'legacy callAsyncJavaScript result handler is not removed on dispose',
  );
  _assert(
    source.contains(
      'message.name == CallAsyncJavaScriptBelowIOS14WrapperJS.RESULT_MESSAGE_HANDLER_NAME',
    ),
    'legacy callAsyncJavaScript result messages are not handled natively',
  );
  _assert(
    source.contains('finishPendingAsyncJavaScriptCallsOnDispose'),
    'pending legacy callAsyncJavaScript callbacks are not completed on dispose',
  );
  _assert(
    source.contains('"error": "WebView disposed"'),
    'pending legacy callAsyncJavaScript callbacks do not receive a disposal error',
  );
  _assert(
    source.contains('_lastReportedProgress'),
    'iOS progress callbacks are not deduplicated before crossing the channel',
  );
  _assert(
    source.contains('scheduleContentSizeChangedUpdate'),
    'iOS content-size callbacks are not coalesced on the main queue',
  );
  _assert(
    source.contains('_contentSizeChangedUpdatePending'),
    'iOS content-size pending state is missing',
  );
  _assert(
    webViewDelegateSource.contains('contentWorldName == "page"'),
    'iOS 15-17 page-world callAsyncJavaScript fallback is missing',
  );
  _assert(
    webViewDelegateSource.contains(
      'Custom content worlds are not supported by callAsyncJavaScript on iOS 16.0.x',
    ),
    'iOS 16.0 custom content-world failure is not explicit',
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
