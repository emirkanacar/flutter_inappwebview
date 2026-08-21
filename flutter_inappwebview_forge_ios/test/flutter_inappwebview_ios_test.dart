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
    source.contains('guard lifecycle.acceptsCallbacks else { return }'),
    'iOS WebView disposal callbacks are not lifecycle-gated',
  );
  _assert(
    source.contains('registeredKVOObservers') &&
        source.contains('registerKVOObserver(') &&
        source.contains('removeKVOObserver('),
    'iOS KVO observer cleanup is not registration-aware',
  );
  final lifecycleSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/WebViewLifecycleCoordinator.swift',
  ).readAsStringSync();
  _assert(
    lifecycleSource.contains('.disposing') &&
        lifecycleSource.contains('.disposed') &&
        lifecycleSource.contains('beginAsyncOperation') &&
        lifecycleSource.contains('operationID') &&
        lifecycleSource.contains('activeOperationIDs') &&
        lifecycleSource.contains(
          'completeAsyncOperation(_ operationID: UInt64)',
        ) &&
        lifecycleSource.contains('callbackCompletionCount') &&
        lifecycleSource.contains('lifecycleTrace') &&
        lifecycleSource.contains('NSLock') &&
        lifecycleSource.contains('acceptsCallbacksLocked') &&
        lifecycleSource.contains('record("rendererLost")'),
    'iOS native lifecycle coordinator does not define the disposal boundary',
  );
  _assert(
    source.contains('guard lifecycle.beginPreparing() else { return }') &&
        source.contains('guard lifecycle.beginDisposal() else { return }') &&
        source.contains('defer { lifecycle.finishDisposal() }') &&
        source.contains('lifecycle.finishDisposal()'),
    'iOS WebView lifecycle transitions are not connected to prepare/dispose',
  );
  _assert(
    source.contains('guard lifecycle.acceptsCallbacks else') &&
        source.contains('disposedJavaScriptResult()') &&
        source.contains('webViewDisposedError()') &&
        source.contains('nativeCallAsyncJavaScriptResults') &&
        source.contains('consumeNativeCallAsyncJavaScriptResult'),
    'iOS async JavaScript calls are accepted after disposal',
  );
  _assert(
    source.contains('guard lifecycle.markRendererLost() else { return }'),
    'iOS WebKit content-process loss is not connected to lifecycle state',
  );
  _assert(
    source.contains('guard lifecycle.acceptsCallbacks else') &&
        source.contains('decisionHandler(.deny)') &&
        source.contains('decisionHandler(.cancel)') &&
        source.contains(
          'guard lifecycle.acceptsCallbacks else { return nil }',
        ) &&
        source.contains('completionHandler(.performDefaultHandling, nil)'),
    'iOS WebKit decision, authentication, and popup callbacks are not lifecycle-gated',
  );
  final channelDelegateSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebViewChannelDelegate.swift',
  ).readAsStringSync();
  _assert(
    channelDelegateSource.contains('handleJavaScriptMethod(method: method') &&
        channelDelegateSource.contains('handleSettingsMethod(method: method') &&
        channelDelegateSource.contains(
          'handleWebMessageMethod(method: method',
        ) &&
        channelDelegateSource.contains('private func canDispatchCallbacks()') &&
        channelDelegateSource.contains(
          'private func invokeMethod(_ method: String',
        ) &&
        channelDelegateSource.contains('callback.success(nil)') &&
        channelDelegateSource.contains('result(nil)') &&
        !channelDelegateSource.contains('channel?.invokeMethod'),
    'iOS channel callbacks are not routed through the lifecycle gate',
  );
  _assert(
    channelDelegateSource.contains('handleLifecycleMethod(method: method'),
    'iOS lifecycle channel operations are not feature-grouped',
  );
  _assert(
    channelDelegateSource.contains('private func handleJavaScriptMethod') &&
        channelDelegateSource.contains('private func handleWebMessageMethod'),
    'iOS JavaScript/WebMessage feature handlers are missing',
  );

  final webMessageChannelDelegateSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebMessage/'
    'WebMessageChannelChannelDelegate.swift',
  ).readAsStringSync();
  final webMessageListenerDelegateSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/WebMessage/'
    'WebMessageListenerChannelDelegate.swift',
  ).readAsStringSync();
  final findInteractionDelegateSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/FindInteraction/'
    'FindInteractionChannelDelegate.swift',
  ).readAsStringSync();
  _assert(
    webMessageChannelDelegateSource.contains(
          'private func canDispatchCallbacks()',
        ) &&
        webMessageChannelDelegateSource.contains('pendingResults') &&
        webMessageChannelDelegateSource.contains(
          r'results.forEach { $0(nil) }',
        ) &&
        webMessageListenerDelegateSource.contains(
          'private func canDispatchCallbacks()',
        ) &&
        webMessageListenerDelegateSource.contains('pendingResults') &&
        findInteractionDelegateSource.contains(
          'private func canDispatchCallbacks()',
        ) &&
        findInteractionDelegateSource.contains(
          'guard canDispatchCallbacks() else { return }',
        ),
    'iOS WebMessage/FindInteraction delegates can dispatch stale callbacks after disposal',
  );
  final pullToRefreshDelegateSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PullToRefresh/'
    'PullToRefreshChannelDelegate.swift',
  ).readAsStringSync();
  _assert(
    pullToRefreshDelegateSource.contains(
          'private func canDispatchCallbacks()',
        ) &&
        pullToRefreshDelegateSource.contains('webView.acceptsCallbacks()'),
    'iOS pull-to-refresh can dispatch an event after WebView disposal',
  );
  _assert(
    source.contains('pendingNavigationActionDecisionHandlers') &&
        source.contains('finishPendingNavigationActionDecisionsOnDispose') &&
        source.contains('completeDecision(.cancel)'),
    'iOS navigation decisions are not completed during disposal',
  );

  _assert(
    source.contains('let contentBlockersChanged: Bool = {') &&
        source.contains('newSettingsMap["contentBlockers"] != nil') &&
        source.contains('if #available(iOS 11.0, *), contentBlockersChanged'),
    'iOS content blockers are rebuilt for unchanged settings',
  );
  _assert(
    source.contains('let verticalScrollSettingChanged =') &&
        source.contains('let horizontalScrollSettingChanged =') &&
        source.contains(
          'let disableVerticalScroll = newSettingsMap["disableVerticalScroll"] != nil',
        ),
    'iOS partial scroll settings can overwrite the other axis',
  );
  _assert(
    source.contains('newSettingsMap["mediaType"] != nil &&') &&
        source.contains('settings?.mediaType != newSettings.mediaType'),
    'iOS mediaType is applied without checking whether it was supplied',
  );

  final userContentControllerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/Types/WKUserContentController.swift',
  ).readAsStringSync();
  _assert(
    userContentControllerSource.contains(
          'guard !userOnlyScripts[userOnlyScript.injectionTime]!.contains(userOnlyScript)',
        ) &&
        userContentControllerSource.contains(
          'guard !pluginScripts[pluginScript.injectionTime]!.contains(pluginScript)',
        ),
    'iOS user and plugin script registration does not reject duplicates',
  );

  final headlessManagerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/HeadlessInAppWebView/'
    'HeadlessInAppWebViewManager.swift',
  ).readAsStringSync();
  final headlessSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/HeadlessInAppWebView/'
    'HeadlessInAppWebView.swift',
  ).readAsStringSync();
  _assert(
    headlessManagerSource.contains(
          'var webViews: [String: HeadlessInAppWebView]',
        ) &&
        headlessManagerSource.contains(
          'webViews.removeValue(forKey: id)?.dispose()',
        ) &&
        headlessManagerSource.contains(
          'plugin.inAppWebViewManager?.webViews.removeValue(forKey: id)',
        ) &&
        headlessManagerSource.contains('previousWebView.dispose()'),
    'iOS headless manager does not replace duplicate ids atomically',
  );
  final factorySource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/FlutterWebViewFactory.swift',
  ).readAsStringSync();
  _assert(
    factorySource.contains(
          'headlessInAppWebViewManager?.webViews.removeValue(forKey: headlessWebViewId)',
        ) &&
        factorySource.contains('headlessWebView.dispose()') &&
        factorySource.contains('transferredFromHeadless') &&
        factorySource.contains(
          'inAppWebViewManager?.webViews[String(describing: transferredWebViewID)]',
        ),
    'iOS headless ownership is not detached atomically during transfer',
  );
  _assert(
    headlessSource.contains(
          'guard let currentFlutterWebView = flutterWebView',
        ) &&
        headlessSource.contains('let view = currentFlutterWebView.myView') &&
        headlessSource.contains('dispose()\n            return nil'),
    'iOS stale headless entries are not disposed when no native view exists',
  );
  _assert(
    headlessSource.contains(
          'private let lifecycle = WebViewLifecycleCoordinator()',
        ) &&
        headlessSource.contains(
          'guard lifecycle.beginDisposal() else { return }',
        ) &&
        headlessSource.contains('defer { lifecycle.finishDisposal() }') &&
        headlessSource.contains('lifecycle.finishDisposal()') &&
        headlessSource.contains(
          'plugin?.headlessInAppWebViewManager?.webViews[id] === self',
        ) &&
        headlessSource.contains(
          'manager.webViews[String(describing: webViewID)] === webView',
        ) &&
        headlessSource.contains(
          'manager.webViews.removeValue(forKey: String(describing: webViewID))',
        ) &&
        headlessSource.contains('markRetainedWebViewDetached()'),
    'iOS headless disposal is not idempotent and map-backed',
  );

  final settingsSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppWebView/InAppWebViewSettings.swift',
  ).readAsStringSync();
  _assert(
    settingsSource.contains('writingToolsBehavior') &&
        settingsSource.contains('if #available(iOS 18.0, *)'),
    'iOS Writing Tools readback is not availability guarded',
  );
  _assert(
    source.contains('configuration.writingToolsBehavior') &&
        source.contains(
          'UIWritingToolsBehavior(rawValue: writingToolsBehavior)',
        ),
    'iOS Writing Tools behavior is not applied to the initial WKWebView configuration',
  );
  _assert(
    source.contains('reloadInputViewsForWebViewHierarchy') &&
        source.contains('inputAccessoryViewSettingChanged') &&
        source.contains('keyboardWillShow'),
    'iOS input accessory changes are not refreshed for WebKit responders',
  );
  _assert(
    settingsSource.contains('disableAutocorrection') &&
        source.contains(
          'DisableAutocorrectionJS.DISABLE_AUTOCORRECTION_JS_PLUGIN_SCRIPT',
        ),
    'iOS autocorrection setting is not wired to the document-start script',
  );
  final autocorrectionSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PluginScriptsJS/DisableAutocorrectionJS.swift',
  ).readAsStringSync();
  _assert(
    autocorrectionSource.contains('autocorrect') &&
        autocorrectionSource.contains('spellcheck') &&
        autocorrectionSource.contains('MutationObserver') &&
        autocorrectionSource.contains('ENABLE_AUTOCORRECTION_JS_SOURCE'),
    'iOS autocorrection script does not cover editable and dynamic elements',
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
  _assert(
    containerManagerSource.contains('clearContainerData') &&
        containerManagerSource.contains('removeData') &&
        containerManagerSource.contains('allWebsiteDataTypes'),
    'iOS container manager does not clear website data in place',
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
    managerSource.contains(
          'var keepAliveWebViews: [String:FlutterWebViewController]',
        ) &&
        managerSource.contains('func registerKeepAlive(keepAliveId: String') &&
        managerSource.contains(
          'let activeWebViewValues = Array(webViews.values)',
        ) &&
        managerSource.contains('webView.dispose()'),
    'iOS keep-alive manager does not enforce a single owner per id',
  );
  _assert(
    cookieSource.contains('webViewId') &&
        cookieSource.contains('configuration.websiteDataStore.httpCookieStore'),
    'iOS cookie manager does not route scoped calls to the WebView data store',
  );

  final printJobManagerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PrintJob/PrintJobManager.swift',
  ).readAsStringSync();
  final printJobSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/PrintJob/PrintJobController.swift',
  ).readAsStringSync();
  final webAuthenticationManagerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/WebAuthenticationSession/'
    'WebAuthenticationSessionManager.swift',
  ).readAsStringSync();
  final webAuthenticationSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/WebAuthenticationSession/'
    'WebAuthenticationSession.swift',
  ).readAsStringSync();
  final inAppBrowserManagerSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppBrowser/InAppBrowserManager.swift',
  ).readAsStringSync();
  final inAppBrowserSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/InAppBrowser/'
    'InAppBrowserWebViewController.swift',
  ).readAsStringSync();
  _assert(
    printJobManagerSource.contains('var jobs: [String: PrintJobController]') &&
        printJobManagerSource.contains('let jobValues = Array(jobs.values)') &&
        printJobManagerSource.contains('jobs.removeAll()') &&
        !printJobManagerSource.contains('PrintJobController?') &&
        printJobSource.contains('jobs.removeValue(forKey: id)'),
    'iOS print-job manager retains nullable ownership placeholders',
  );
  _assert(
    webAuthenticationManagerSource.contains(
          'var sessions: [String: WebAuthenticationSession]',
        ) &&
        webAuthenticationManagerSource.contains(
          'let sessionValues = Array(sessions.values)',
        ) &&
        webAuthenticationManagerSource.contains('sessions.removeAll()') &&
        !webAuthenticationManagerSource.contains('WebAuthenticationSession?') &&
        webAuthenticationSource.contains('sessions.removeValue(forKey: id)'),
    'iOS authentication-session manager retains nullable ownership placeholders',
  );
  _assert(
    inAppBrowserManagerSource.contains(
          'var navControllers: [String: InAppBrowserNavigationController]',
        ) &&
        inAppBrowserManagerSource.contains(
          'let navControllersValues = Array(navControllers.values)',
        ) &&
        inAppBrowserManagerSource.contains('navControllers.removeAll()') &&
        !inAppBrowserManagerSource.contains(
          'InAppBrowserNavigationController?',
        ) &&
        inAppBrowserSource.contains('navControllers.removeValue(forKey: id)'),
    'iOS in-app-browser manager retains nullable ownership placeholders',
  );
  _assert(
    inAppBrowserManagerSource.contains(
          'guard let absoluteUrl = URL(string: url)?.absoluteURL',
        ) &&
        inAppBrowserManagerSource.contains(
          'open(absoluteUrl, options:',
        ) &&
        inAppBrowserManagerSource.contains('result(true)') &&
        inAppBrowserManagerSource.contains('cannot be opened!') &&
        !inAppBrowserManagerSource.contains('canOpenURL') &&
        !inAppBrowserManagerSource.contains('openURL(') &&
        !inAppBrowserManagerSource.contains('URL(string: url)!'),
    'iOS openWithSystemBrowser still uses canOpenURL or force-unwraps the URL',
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
    source.contains('windowCreated') &&
        source.contains('lifecycle.acceptsCallbacks'),
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
    source.contains('guard lifecycle.acceptsCallbacks else { return }') &&
        source.contains('observedWebView === self') &&
        source.contains('observedScrollView === scrollView'),
    'iOS KVO callbacks are not protected from stale popup/dispose objects',
  );
  _assert(
    source.contains('self.lifecycle.acceptsCallbacks') &&
        source.contains('guard lifecycle.acceptsCallbacks else { return }') &&
        source.contains('scheduleScrollChangedUpdate'),
    'iOS delayed gesture, keyboard, and scroll callbacks are not lifecycle-gated',
  );
  _assert(
    source.contains('requestFocusNodeHref') &&
        source.contains('requestImageRef') &&
        source.contains(
          'DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self]',
        ) &&
        source.contains('self.lifecycle.acceptsCallbacks'),
    'iOS delayed focus/image callbacks are not lifecycle-gated',
  );
  _assert(
    source.contains('scrollView.isPagingEnabled = newSettings.isPagingEnabled'),
    'iOS settings diff applies isPagingEnabled to the wrong UIScrollView property',
  );
  _assert(
    source.contains('pendingNativeLifecycleCallbacks') &&
        source.contains('registerNativeLifecycleCallback') &&
        source.contains('finishPendingAsyncJavaScriptCallsOnDispose()'),
    'iOS native snapshot/PDF/archive callbacks are not lifecycle-tracked',
  );
  _assert(
    source.contains(
          'windowIdJSInitializationGeneration == initializationGeneration',
        ) &&
        source.contains('self.lifecycle.acceptsCallbacks') &&
        source.contains('presentNativeFullscreenContainer'),
    'iOS deferred popup/fullscreen UI callbacks are not lifecycle-gated',
  );
  _assert(
    source.contains('super.evaluateJavaScript(javaScript) { result, error in'),
    'popup JavaScript does not use the page-world fallback',
  );
  _assert(
    source.contains('in: WKContentWorld.page') &&
        source.contains('completionHandler: wrappedCompletionHandler'),
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
    source.contains('pendingEvaluateJavaScriptResults') &&
        source.contains('evaluateJavaScriptOperationIDs') &&
        source.contains('consumeEvaluateJavaScriptResult') &&
        source.contains('pendingEvaluateCallbacks.forEach') &&
        source.contains('callback(nil)'),
    'iOS evaluateJavascript callbacks are not tracked and completed exactly once',
  );
  final callbackResultSource = _sourceFile(
    'ios/flutter_inappwebview_forge_ios/Sources/'
    'flutter_inappwebview_forge_ios/Types/CallbackResult.swift',
  ).readAsStringSync();
  _assert(
    callbackResultSource.contains('resultLock') &&
        callbackResultSource.contains('callbackCompleted') &&
        callbackResultSource.contains('defaultBehaviourCompleted') &&
        callbackResultSource.contains('defaultBehaviourAllowedDuringHandler') &&
        callbackResultSource.contains(
          'callbackCompleted && !defaultBehaviourAllowedDuringHandler',
        ) &&
        callbackResultSource.contains('completeSuccess') &&
        callbackResultSource.contains('completeError') &&
        callbackResultSource.contains('completeDefaultBehaviour') &&
        callbackResultSource.contains('if defaultBehaviourCompleted'),
    'iOS native callback defaults are not guarded against duplicate completion',
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
    source.contains('with["compressFormat"] as? String ?? "PNG"') &&
        source.contains('(with["quality"] as? NSNumber)?.doubleValue'),
    'iOS screenshot options still force-cast nullable channel values',
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
