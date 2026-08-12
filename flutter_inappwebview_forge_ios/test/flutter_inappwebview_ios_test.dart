import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_ios/flutter_inappwebview_forge_ios.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'iOS goBack tolerates a missing native channel during teardown',
    () async {
      final controller = IOSInAppWebViewController(
        const IOSInAppWebViewControllerCreationParams(id: 2711),
      );

      try {
        await expectLater(controller.goBack(), completes);
      } finally {
        controller.dispose();
      }
    },
  );

  test(
    'iOS native source contracts remain guarded',
    _runSourceContractAssertions,
  );
}

void _runSourceContractAssertions() {
  final source = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/InAppWebView.swift',
  ).readAsStringSync();

  _assert(
    source.contains('guard !isDisposed else { return }'),
    'iOS WebView disposal is not idempotent',
  );

  _assert(
    source.contains('keyboardDidHideNotification'),
    'keyboardDidHideNotification is not registered',
  );
  final containerManagerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/ContainerManager.swift',
  ).readAsStringSync();
  _assert(
    containerManagerSource.contains('@available(iOS 17.0, *)') &&
        containerManagerSource.contains('fetchAllDataStoreIdentifiers') &&
        containerManagerSource.contains('remove(forIdentifier: identifier)'),
    'iOS container manager is missing the guarded website-data-store lifecycle',
  );
  _assert(
    source.contains('WKWebsiteDataStore(forIdentifier: identifier)') &&
        source.contains('settings.containerId'),
    'iOS WebView configuration does not bind containerId to its data store',
  );
  _assert(
    source.contains('settings.proxySettings') &&
        source.contains('proxyConfigurations') &&
        source.contains('ProxySettings.fromMap'),
    'iOS WebView configuration does not bind proxySettings to its data store',
  );
  final cookieSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/MyCookieManager.swift',
  ).readAsStringSync();
  final managerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/InAppWebViewManager.swift',
  ).readAsStringSync();
  _assert(
    managerSource.contains('var webViews: [String: InAppWebView]'),
    'iOS WebView manager does not retain WebViews for scoped cookie routing',
  );
  _assert(
    cookieSource.contains('webViewId') &&
        cookieSource.contains('configuration.websiteDataStore.httpCookieStore'),
    'iOS cookie manager does not route scoped calls to the WebView data store',
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
    cookieSource.contains('cookie.properties?[.originURL] as? String') &&
        cookieSource.contains('websiteDataTypes as? Set<String>'),
    'iOS cookie cleanup still force-casts platform properties',
  );
  final listenerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebMessage/WebMessageListener.swift',
  ).readAsStringSync();
  _assert(
    listenerSource.contains('guard let id = map["id"] as? String') &&
        listenerSource.contains('return nil'),
    'iOS WebMessageListener does not validate creation payloads',
  );
  final channelSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebViewChannelDelegate.swift',
  ).readAsStringSync();
  _assert(
    channelSource.contains('let requestURL = URL(string: url)') &&
        channelSource.contains('invalid_arguments'),
    'iOS navigation channel does not validate URL payloads',
  );
  _assert(
    channelSource.contains('assetFilePath is required'),
    'iOS loadFile channel does not validate asset paths',
  );
  _assert(
    source.contains('navigationActionDecisionPending') &&
        source.contains('pendingNavigationActionDecisionCount') &&
        source.contains('pendingNavigationActionLoadRequests.append'),
    'iOS loadUrl does not defer requests made from navigation callbacks',
  );
  _assert(
    source.contains('flushPendingNavigationActionLoadRequests') &&
        source.contains('isLoadingPendingNavigationAction') &&
        source.contains('guard pendingNavigationActionDecisionCount == 0'),
    'iOS deferred navigation loads are not released after the decision handler',
  );
  _assert(
    source.contains('guard let url = urlRequest.url'),
    'iOS navigation loads still force-unwrap malformed URL requests',
  );
  final proxySource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/ProxyManager.swift',
  ).readAsStringSync();
  _assert(
    proxySource.contains('compactMap { ProxyRule.fromMap') &&
        proxySource.contains('guard let url = map["url"] as? String'),
    'iOS proxy payloads are still force-cast',
  );
  final messageChannelSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebMessage/WebMessageChannelChannelDelegate.swift',
  ).readAsStringSync();
  _assert(
    messageChannelSource.contains('ports.indices.contains(index)') &&
        messageChannelSource.contains('Invalid port index'),
    'iOS WebMessageChannel does not validate port indices',
  );
  _assert(
    source.contains('else {\n            return nil\n        }'),
    'iOS popup creation does not reject a missing WebView manager',
  );
  _assert(
    source.contains(
          'inAppWebViewManager?.windowWebViews.removeValue(forKey: windowId)',
        ) &&
        !source.contains('self?.loadUrl(urlRequest: navigationAction.request'),
    'iOS rejected popups must not navigate the caller WebView',
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

  _assert(
    source.contains(
          'private var _scrollViewZoomScaleBeforeKeyboard: CGFloat?',
        ) &&
        source.contains(
          'private var _scrollViewContentOffsetBeforeKeyboard: CGPoint?',
        ),
    'iOS keyboard handling does not retain the pre-keyboard WebView viewport',
  );
  final willShow = RegExp(
    r'@objc func keyboardWillShow\(notification: NSNotification\) \{'
    r'([\s\S]*?)\n    \}\n    @objc func keyboardWillHide',
  ).firstMatch(source)?.group(1);
  _assert(willShow != null, 'keyboardWillShow function could not be parsed');
  _assert(
    willShow!.contains(
          '_scrollViewZoomScaleBeforeKeyboard = scrollView.zoomScale',
        ) &&
        willShow.contains(
          '_scrollViewContentOffsetBeforeKeyboard = scrollView.contentOffset',
        ),
    'keyboardWillShow does not capture the pre-keyboard WebView viewport',
  );
  final didHide = RegExp(
    r'@objc func keyboardDidHide\(notification: NSNotification\) \{'
    r'([\s\S]*?)\n    \}\n    \r?\n    required public init',
  ).firstMatch(source)?.group(1);
  _assert(didHide != null, 'keyboardDidHide function could not be parsed');
  final viewportRestore = RegExp(
    r'private func restoreScrollViewViewportAfterKeyboard\(refreshFrame: Bool = true\) \{'
    r'([\s\S]*?)\n    \}\n\n    // Fix',
  ).firstMatch(source)?.group(1);
  _assert(
    viewportRestore != null,
    'keyboard viewport restoration helper could not be parsed',
  );
  _assert(
    didHide!.contains('restoreScrollViewViewportAfterKeyboard()') &&
        viewportRestore!.contains('setZoomScale(zoomScale, animated: false)') &&
        viewportRestore.contains(
          'setContentOffset(contentOffset, animated: false)',
        ) &&
        source.contains(
          'restoreScrollViewViewportAfterKeyboard(refreshFrame: false)',
        ) &&
        source.contains('_scrollViewZoomScaleBeforeKeyboard = nil') &&
        source.contains('_scrollViewContentOffsetBeforeKeyboard = nil'),
    'keyboardDidHide does not restore the pre-keyboard WebView viewport',
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
    source.contains('#if compiler(>=6.4)') &&
        source.contains('@available(iOS 27.0, *)') &&
        source.contains(
          'requestGeolocationPermissionFor origin: WKSecurityOrigin',
        ) &&
        source.contains('channelDelegate.onGeolocationPermissionsShowPrompt') &&
        source.contains('var decisionHandlerCalled = false') &&
        source.contains('decisionHandler(response.allow ? .grant : .deny)'),
    'iOS 27 geolocation permission requests are not bridged to Dart',
  );
  _assert(
    webViewDelegateSource.contains(
          'GeolocationPermissionsShowPromptCallback',
        ) &&
        webViewDelegateSource.contains(
          'onGeolocationPermissionsShowPrompt(origin:',
        ),
    'iOS geolocation permission callback bridge is missing',
  );
  final geolocationResponseSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/Types/'
    'GeolocationPermissionShowPromptResponse.swift',
  ).readAsStringSync();
  _assert(
    geolocationResponseSource.contains('allow') &&
        geolocationResponseSource.contains('retain') &&
        geolocationResponseSource.contains('fromMap'),
    'iOS geolocation permission response decoding is missing',
  );

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
    source.contains('windowCreated') && source.contains('guard !isDisposed'),
    'popup JavaScript is evaluated before the Flutter platform view is attached',
  );
  _assert(
    source.contains('if windowId != nil') &&
        source.contains('windowIdJSInitializationScheduled') &&
        source.contains('windowIdJSInitializationGeneration') &&
        source.contains('DispatchQueue.main.async'),
    'popup content-world compatibility guard is missing',
  );
  _assert(
    source.contains('guard !isDisposed else { return }') &&
        source.contains('observedWebView === self') &&
        source.contains('observedScrollView === scrollView'),
    'iOS KVO callbacks are not protected from stale popup/dispose objects',
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
    'pending callAsyncJavaScript callbacks are not completed on dispose',
  );
  _assert(
    source.contains(
      'finishPendingAsyncJavaScriptCalls(error: "WebView disposed")',
    ),
    'pending callAsyncJavaScript callbacks do not receive a disposal error',
  );
  _assert(
    source.contains('finishPendingAsyncJavaScriptCallsOnNavigation') &&
        source.contains(
          'finishPendingAsyncJavaScriptCalls(error: "WebView navigation started")',
        ),
    'pending callAsyncJavaScript callbacks do not complete when navigation starts',
  );
  _assert(
    source.contains('pendingCallAsyncJavaScriptResults'),
    'native callAsyncJavaScript callbacks are not tracked until completion',
  );
  _assert(
    source.contains(
      'self.pendingCallAsyncJavaScriptResults.removeValue(forKey: resultUuid)',
    ),
    'late native callAsyncJavaScript callbacks are not ignored after disposal',
  );
  _assert(
    source.contains(
      'self.callAsyncJavaScriptBelowIOS14Results.removeValue(forKey: resultUuid)',
    ),
    'late legacy callAsyncJavaScript errors are not ignored after disposal',
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
  _assert(
    authenticationSession.contains(
          '@available(iOS 13.0, *)\nprivate class WebAuthenticationPresentationContextProviding: NSObject, ASWebAuthenticationPresentationContextProviding',
        ) &&
        authenticationSession.contains(
          'public class WebAuthenticationSession: NSObject, Disposable',
        ) &&
        authenticationSession.contains('_presentationContextProvider') &&
        authenticationSession.contains(
          'session.presentationContextProvider = provider',
        ),
    'iOS authentication context provider is not isolated behind its availability boundary',
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
    source.contains('var stack: [UIView] = subviews') &&
        source.contains('view.canBecomeFirstResponder') &&
        source.contains('stack.append(contentsOf: view.subviews)') &&
        source.contains('return becomeFirstResponder()'),
    'iOS requestFocus must search the WKWebView view hierarchy',
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
