import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_android/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('Android resource interception has bounded synchronous backpressure', () {
    final clientSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();
    final delegateSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/WebViewChannelDelegate.kt',
    ).readAsStringSync();

    expect(clientSource, contains('MAX_CONCURRENT_SYNC_INTERCEPT_REQUESTS'));
    expect(clientSource, contains('synchronousInterceptRequestsInFlight'));
    expect(
      clientSource,
      contains('Too many synchronous shouldInterceptRequest callbacks'),
    );
    expect(delegateSource, contains('SYNC_INTERCEPT_REQUEST_TIMEOUT_MILLIS'));
  });

  test('Android JavaScript injection calls the platform WebView overload', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();
    final injectionSource = source.substring(
      source.indexOf('fun injectDeferredObject('),
      source.indexOf('override fun evaluateJavascript('),
    );

    expect(injectionSource, contains('super.evaluateJavascript('));
    expect(
      injectionSource,
      isNot(contains('\n      evaluateJavascript(\n        generatedScript')),
    );
  });

  test(
    'Android activity result dispatch tolerates listener removal during callbacks',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'in_app_browser/InAppBrowserActivity.kt',
      ).readAsStringSync();

      expect(source, contains('activityResultListeners.toList()'));
    },
  );

  test(
    'Android popup creation rejects missing managers before storing a result message',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'webview/in_app_webview/InAppWebViewChromeClient.kt',
      ).readAsStringSync();
      expect(source, contains('if (manager == null) {'));
      expect(source, contains('return false'));
      expect(source, isNot(contains('windowId = 0')));
    },
  );

  test(
    'Android client certificate callbacks reject non-plugin WebViews safely',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'webview/in_app_webview/InAppWebViewClient.kt',
      ).readAsStringSync();
      expect(source, contains('val webView = view as? InAppWebView'));
      expect(source, contains('request.cancel()'));
    },
  );

  test(
    'Android startup coordinator clears pending callbacks during disposal',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'WebViewStartupCoordinator.kt',
      ).readAsStringSync();
      expect(source, contains('private var disposed = false'));
      expect(source, contains('pendingCallbacks.clear()'));
      expect(source, contains('executor.shutdownNow()'));
    },
  );

  test('Android startup coordinator can restart after engine reattachment', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'WebViewStartupCoordinator.kt',
    ).readAsStringSync();

    expect(source, contains('private var startupGeneration = 0L'));
    expect(source, contains('if (disposed) {'));
    expect(
      source,
      contains('backgroundExecutor = Executors.newSingleThreadExecutor()'),
    );
    expect(source, contains('generation != startupGeneration'));
    expect(
      source,
      contains('requestStartup(context.applicationContext, requestGeneration)'),
    );
  });

  test(
    'Android WebStorage origin callbacks ignore malformed provider entries',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/MyWebStorage.kt',
      ).readAsStringSync();
      expect(source, contains('value[key] as? WebStorage.Origin'));
      expect(source, contains('return@forEach'));
    },
  );

  test('Android compat callbacks reject non-plugin WebViews safely', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClientCompat.kt',
    ).readAsStringSync();
    expect(source, contains('view as? InAppWebView ?: return'));
    expect(source, contains('callback.showInterstitial(false)'));
  });

  test('Android URL callbacks ignore non-plugin WebViews safely', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();
    expect(
      source,
      contains('val webView = view as? InAppWebView ?: return false'),
    );
  });

  test('Android page lifecycle callbacks ignore non-plugin WebViews safely', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();
    expect(source, contains('override fun onPageStarted'));
    expect(source, contains('override fun onPageFinished'));
    expect(source, contains('view as? InAppWebView ?: return'));
  });

  test('Android Chrome callbacks ignore non-plugin WebViews safely', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewChromeClient.kt',
    ).readAsStringSync();
    expect(source, contains('view as? InAppWebView ?: return'));
    expect(source, contains('(view as? InAppWebView)?.channelDelegate'));
  });

  test('Android file chooser callbacks use nullable callback casts', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewChromeClient.kt',
    ).readAsStringSync();
    expect(source, contains('filePathsCallback as? ValueCallback'));
    expect(source, isNot(contains('filePathsCallback as ValueCallback')));
  });

  test('Android renderer callbacks ignore non-plugin WebView instances', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewRenderProcessClient.kt',
    ).readAsStringSync();

    expect(source, contains('view as? InAppWebView ?: return'));
    expect(source, isNot(contains('view as InAppWebView')));
  });

  test('Android synchronous channel callbacks share bounded dispatch capacity', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'Util.kt',
    ).readAsStringSync();
    final callbackSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'types/SyncBaseCallbackResultImpl.kt',
    ).readAsStringSync();

    expect(source, contains('MAX_CONCURRENT_SYNC_METHOD_CHANNEL_CALLS'));
    expect(source, contains('synchronousMethodChannelCallsInFlight'));
    expect(
      source,
      contains(
        'private val mainLooperHandler = Handler(Looper.getMainLooper())',
      ),
    );
    expect(source, contains('mainLooperHandler.post'));
    expect(source, contains('mainLooperHandler.postAtFrontOfQueue'));
    expect(source, contains('val dispatchRunnable = Runnable'));
    expect(
      source,
      contains('mainLooperHandler.removeCallbacks(dispatchRunnable)'),
    );
    expect(source, contains('callback.cancel()'));
    expect(source, contains('callback.latch.await'));
    expect(source, contains('TimeUnit.MILLISECONDS'));
    expect(callbackSource, contains('fun cancel()'));
    expect(callbackSource, contains('if (cancelled)'));
    final delegateSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/WebViewChannelDelegate.kt',
    ).readAsStringSync();
    final serviceWorkerSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'service_worker/ServiceWorkerChannelDelegate.kt',
    ).readAsStringSync();
    expect(delegateSource, contains('SYNC_INTERCEPT_REQUEST_TIMEOUT_MILLIS'));
    expect(
      delegateSource,
      contains('SYNC_INTERCEPT_REQUEST_TIMEOUT_MILLIS,\n      true'),
    );
    expect(serviceWorkerSource, contains('priority = true'));
    expect(
      source,
      isNot(contains('val handler = Handler(Looper.getMainLooper())')),
    );
  });

  test('Android browser activity extras avoid Java serialization', () {
    final activitySource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'in_app_browser/InAppBrowserActivity.kt',
    ).readAsStringSync();
    final browserManagerSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'in_app_browser/InAppBrowserManager.kt',
    ).readAsStringSync();
    final chromeActivitySource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'chrome_custom_tabs/ChromeCustomTabsActivity.kt',
    ).readAsStringSync();
    final chromeManagerSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'chrome_custom_tabs/ChromeSafariBrowserManager.kt',
    ).readAsStringSync();
    final utilSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'Util.kt',
    ).readAsStringSync();

    for (final source in [
      activitySource,
      browserManagerSource,
      chromeActivitySource,
      chromeManagerSource,
    ]) {
      expect(source, isNot(contains('getSerializable')));
      expect(source, isNot(contains('putSerializable')));
      expect(source, isNot(contains('java.io.Serializable')));
    }
    expect(utilSource, contains('fun putValueExtra'));
    expect(utilSource, contains('bundle.putBundle'));
    expect(utilSource, contains('bundle.getBundle'));
  });

  test(
    'Android Chrome Custom Tabs manager matches the Dart channel namespace',
    () {
      final nativeSource = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'chrome_custom_tabs/ChromeSafariBrowserManager.kt',
      ).readAsStringSync();
      final dartSource = _sourceFile(
        'lib/src/chrome_safari_browser/chrome_safari_browser.dart',
      ).readAsStringSync();

      expect(
        nativeSource,
        contains('com.emirkanacar/flutter_chromesafaribrowser'),
      );
      expect(
        nativeSource,
        isNot(contains('com.emirakanacar/flutter_chromesafaribrowser')),
      );
      expect(
        dartSource,
        contains('com.emirkanacar/flutter_chromesafaribrowser'),
      );
    },
  );

  test(
    'Android Custom Tabs keeps the service session while the tab is foreground',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'chrome_custom_tabs/ChromeCustomTabsActivity.kt',
      ).readAsStringSync();
      final onStop = RegExp(
        r'override fun onStop\(\) \{([\s\S]*?)\n  \}',
      ).firstMatch(source)?.group(1);
      final onDestroy = RegExp(
        r'override fun onDestroy\(\) \{([\s\S]*?)\n  \}',
      ).firstMatch(source)?.group(1);

      expect(onStop, isNotNull);
      expect(onStop, isNot(contains('unbindCustomTabsService')));
      expect(onDestroy, contains('unbindCustomTabsService'));
    },
  );

  test(
    'Android dynamic JavaScript evaluation remains an explicit API boundary',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'plugin_scripts_js/PluginScriptsUtil.kt',
      ).readAsStringSync();

      expect(
        source,
        contains('EVALUATE_JAVASCRIPT_WITH_CONTENT_WORLD_WRAPPER_JS_SOURCE'),
      );
      expect(source, contains('VAR_PLACEHOLDER_VALUE'));
      expect(RegExp(r'\beval\s*\(').allMatches(source), hasLength(1));
    },
  );

  test(
    'Android cookie clearing does not flush synchronously after async deletion',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'MyCookieManager.kt',
      ).readAsStringSync();
      final deleteAllCookies = RegExp(
        r'fun deleteAllCookies\(result: MethodChannel\.Result\) \{([\s\S]*?)\n    \}\n\n    (?:@Suppress\("DEPRECATION"\)\n    )?fun removeSessionCookies',
      ).firstMatch(source)?.group(1);

      expect(deleteAllCookies, isNotNull);
      expect(deleteAllCookies, isNot(contains('manager.flush()')));
    },
  );

  test('Android callback handler is explicitly bound to the main looper', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(source, contains('val mHandler = Handler(Looper.getMainLooper())'));
    expect(source, isNot(contains('val mHandler = Handler()')));
  });

  test('Android legacy cookie APIs are isolated behind compatibility paths', () {
    final cookieSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'MyCookieManager.kt',
    ).readAsStringSync();
    final webViewSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();
    final clientSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();

    expect(cookieSource, contains('@Suppress("DEPRECATION")'));
    expect(
      cookieSource,
      contains('if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)'),
    );
    expect(cookieSource, contains('manager.removeSessionCookies'));
    expect(webViewSource, contains('private fun clearSessionCookies()'));
    expect(webViewSource, contains('manager.removeSessionCookies(null)'));
    expect(
      webViewSource,
      isNot(contains('CookieManager.getInstance().removeSessionCookie()')),
    );
    expect(clientSource, contains('@Suppress("DEPRECATION")'));
  });

  test(
    'Android IME lifecycle code requires an attached window before touching input state',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'webview/in_app_webview/InputAwareWebView.kt',
      ).readAsStringSync();

      expect(source, contains('isAttachedToWindow'));
      expect(source, contains('windowToken'));
      expect(source, contains('isViewReady'));
    },
  );

  test('Android HTTP navigation keeps the native navigation context', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();

    expect(source, contains('isHttpOrHttpsUrl'));
    expect(source, contains('nativeNavigationContinues'));
    expect(source, contains('webView.stopLoading()'));
  });

  test('Android 15 skips the deprecated status-bar color API', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'in_app_browser/InAppBrowserActivity.kt',
    ).readAsStringSync();

    expect(
      source,
      contains('WindowCompat.setDecorFitsSystemWindows(window, false)'),
    );
    expect(source, isNot(contains('statusBarColor')));
  });

  test('Android action mode does not render OEM icon-only placeholders', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(source, contains('startNativeActionMode'));
    expect(source, contains('Resources.NotFoundException'));
    expect(source, contains('equals("false", ignoreCase = true)'));
    expect(source, contains('setCompoundDrawablesRelative'));
    expect(source, contains('if (!hasMeaningfulTitle && itemIcon == null)'));
  });

  test('Android invalidates the WebView after window visibility returns', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(source, contains('override fun onWindowVisibilityChanged'));
    expect(source, contains('postInvalidateOnAnimation()'));
    expect(source, contains('requestLayout()'));
  });

  test('Android refreshes WebView geometry after display-size changes', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(source, contains('override fun onSizeChanged'));
    expect(source, contains('if (w != oldw || h != oldh)'));
    expect(source, contains('refreshGeometryAfterLayoutChange()'));
  });

  test('Android progress callbacks do not re-inject document-start scripts', () {
    final chromeClientSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewChromeClient.kt',
    ).readAsStringSync();
    final webViewClientSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewClient.kt',
    ).readAsStringSync();

    expect(chromeClientSource, contains('lastProgress'));
    expect(
      chromeClientSource,
      isNot(contains('loadCustomJavaScriptOnPageStarted')),
    );
    expect(
      webViewClientSource,
      contains('loadCustomJavaScriptOnPageStarted(webView)'),
    );
  });

  test('Android native registration retries clear their scheduled state', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(source, contains('private var isDisposed = false'));
    expect(source, contains('if (isDisposed || nativeRegistrationsRegistered'));
    expect(source, contains('nativeRegistrationRequestScheduled = false'));
    expect(source, contains('nativeRegistrationCallbacks.clear()'));
  });

  test(
    'Android startup registration keeps failed document-start scripts retryable',
    () {
      final controllerSource = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'types/UserContentController.kt',
      ).readAsStringSync();
      final webViewSource = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'webview/in_app_webview/InAppWebView.kt',
      ).readAsStringSync();

      expect(controllerSource, contains('catch (e: RuntimeException)'));
      expect(
        controllerSource,
        contains('pendingPluginScriptRegistrations.add'),
      );
      expect(controllerSource, contains('retryPendingScriptRegistrations'));
      expect(webViewSource, contains('whenNativeRegistrationsReady'));
      expect(webViewSource, contains('onPlatformViewAttached'));
    },
  );

  test('Android scroll callbacks skip unchanged positions', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(source, contains('if (x != oldX || y != oldY)'));
    expect(source, contains('pendingScrollX = x'));
    expect(source, contains('pendingScrollY = y'));
    expect(source, contains('postOnAnimation(dispatchPendingScrollChanged)'));
    expect(source, contains('if (isAttachedToWindow)'));
    expect(
      source,
      contains('mainLooperHandler.post(dispatchPendingScrollChanged)'),
    );
    expect(
      source,
      contains(
        'mainLooperHandler.removeCallbacks(dispatchPendingScrollChanged)',
      ),
    );
    expect(source, contains('removeCallbacks(dispatchPendingScrollChanged)'));
  });

  test('Android WebMessageListener falls back when WebKit lacks the native API', () {
    final listenerSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/web_message/WebMessageListener.kt',
    ).readAsStringSync();
    final webViewSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();
    final bridgeSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/JavaScriptBridgeInterface.kt',
    ).readAsStringSync();
    final scriptSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'plugin_scripts_js/JavaScriptBridgeJS.kt',
    ).readAsStringSync();

    expect(webViewSource, contains('webMessageListener.initJsInstance()'));
    expect(listenerSource, contains('IS_ORIGIN_ALLOWED_JS_SOURCE()'));
    expect(listenerSource, contains('FlutterInAppWebViewWebMessageListener'));
    expect(scriptSource, contains('WEB_MESSAGE_LISTENER_JS_SOURCE()'));
    expect(bridgeSource, contains('onWebMessageListenerPostMessageReceived'));
    expect(bridgeSource, contains('TYPE_ARRAY_BUFFER'));
  });
}
