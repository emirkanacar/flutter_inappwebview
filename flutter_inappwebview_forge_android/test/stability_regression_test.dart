import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_android/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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

  test('Android file chooser does not consume unrelated activity results', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewChromeClient.kt',
    ).readAsStringSync();
    final callbackSource = source.substring(
      source.indexOf('override fun onActivityResult('),
      source.indexOf('private fun getSelectedFiles('),
    );

    expect(
      callbackSource,
      contains(
        'if (filePathCallback == null && filePathCallbackLegacy == null) {',
      ),
    );
    expect(callbackSource, contains('return false'));
    expect(callbackSource, contains('requestCode != PICKER'));
    expect(callbackSource, contains('requestCode != PICKER_LEGACY'));
  });

  test('Android file chooser supports audio capture independently of camera', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewChromeClient.kt',
    ).readAsStringSync();

    expect(source, contains('MediaStore.Audio.Media.RECORD_SOUND_ACTION'));
    expect(source, contains('private fun acceptsAudio(types: String)'));
    expect(source, contains('private fun acceptsAudio(types: Array<String>)'));
    expect(
      source,
      contains(
        'audio && !images && !video -> getAudioIntent().takeIf(::canResolveIntent)',
      ),
    );
    expect(
      source,
      contains('getAudioIntent().takeIf { audio && canResolveIntent(it) }'),
    );
    expect(source, contains('private fun canResolveIntent(intent: Intent)'));
  });

  test('Android WebAuthn setting is feature-gated and round-trips', () {
    final settingsSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewSettings.kt',
    ).readAsStringSync();
    final webViewSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(
      settingsSource,
      contains('var webAuthenticationSupport: Int? = null'),
    );
    expect(
      settingsSource,
      contains(
        '"webAuthenticationSupport" -> webAuthenticationSupport = (value as Number).toInt()',
      ),
    );
    expect(
      settingsSource,
      contains('put("webAuthenticationSupport", webAuthenticationSupport)'),
    );
    expect(settingsSource, contains('WebViewFeature.WEB_AUTHENTICATION'));
    expect(
      settingsSource,
      contains('WebSettingsCompat.getWebAuthenticationSupport(settings)'),
    );
    expect(
      webViewSource,
      contains('customSettings.webAuthenticationSupport?.let'),
    );
    expect(
      webViewSource,
      contains(
        'WebSettingsCompat.setWebAuthenticationSupport(settings, support)',
      ),
    );
  });

  test('Android Payment Request setting is feature-gated and manifest-ready', () {
    final settingsSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewSettings.kt',
    ).readAsStringSync();
    final webViewSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();
    final manifestSource = _sourceFile(
      'android/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(
      settingsSource,
      contains('var paymentRequestEnabled: Boolean? = null'),
    );
    expect(
      settingsSource,
      contains(
        '"paymentRequestEnabled" -> paymentRequestEnabled = value as Boolean',
      ),
    );
    expect(
      settingsSource,
      contains('put("paymentRequestEnabled", paymentRequestEnabled)'),
    );
    expect(settingsSource, contains('WebViewFeature.PAYMENT_REQUEST'));
    expect(
      settingsSource,
      contains('WebSettingsCompat.getPaymentRequestEnabled(settings)'),
    );
    expect(
      webViewSource,
      contains('customSettings.paymentRequestEnabled?.let'),
    );
    expect(
      webViewSource,
      contains('WebSettingsCompat.setPaymentRequestEnabled(settings, enabled)'),
    );
    expect(manifestSource, contains('org.chromium.intent.action.PAY'));
    expect(
      manifestSource,
      contains('org.chromium.intent.action.IS_READY_TO_PAY'),
    );
    expect(
      manifestSource,
      contains('org.chromium.intent.action.UPDATE_PAYMENT_DETAILS'),
    );
  });

  test('Android User-Agent metadata is feature-gated and null-tolerant', () {
    final settingsSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewSettings.kt',
    ).readAsStringSync();
    final webViewSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();

    expect(
      settingsSource,
      contains('var userAgentMetadata: MutableMap<String, Any?>? = null'),
    );
    expect(
      settingsSource,
      contains('"userAgentMetadata" -> userAgentMetadata ='),
    );
    expect(
      settingsSource,
      contains('put("userAgentMetadata", userAgentMetadata)'),
    );
    expect(webViewSource, contains('customSettings.userAgentMetadata?.let'));
    expect(
      webViewSource,
      contains(
        'WebSettingsCompat.setUserAgentMetadata(settings, metadataBuilder.build())',
      ),
    );
    expect(webViewSource, contains('mapNotNull'));
  });

  test('Android container profiles bind before WebView state initialization', () {
    final settingsSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewSettings.kt',
    ).readAsStringSync();
    final webViewSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebView.kt',
    ).readAsStringSync();
    final managerSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'container/ContainerManager.kt',
    ).readAsStringSync();

    expect(settingsSource, contains('var containerId: String? = null'));
    expect(
      settingsSource,
      contains('"containerId" -> containerId = value as? String'),
    );
    expect(settingsSource, contains('put("containerId", containerId)'));
    expect(webViewSource, contains('WebViewFeature.MULTI_PROFILE'));
    expect(
      webViewSource,
      contains('WebViewCompat.setProfile(this, containerId)'),
    );
    expect(webViewSource, contains('customSettings.incognito != true'));
    expect(
      webViewSource.indexOf('WebViewCompat.setProfile(this, containerId)'),
      lessThan(webViewSource.indexOf('CookieManager.getInstance()')),
    );
    expect(managerSource, contains('ProfileStore.getInstance()'));
    expect(managerSource, contains('getAllContainerNames'));
    expect(managerSource, contains('deleteProfile(containerId)'));
  });

  test('Android cookie APIs forward the WebView id for container routing', () {
    final dartSource = _sourceFile(
      'lib/src/cookie_manager.dart',
    ).readAsStringSync();
    final nativeSource = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'MyCookieManager.kt',
    ).readAsStringSync();

    expect(
      dartSource,
      contains("'webViewId', () => webViewController?.params.id"),
    );
    expect(nativeSource, contains('ProfileStore.getInstance()'));
    expect(nativeSource, contains('getCookieManager(webViewId)'));
    expect(
      nativeSource,
      contains('inAppWebViewManager?.webViews?.get(webViewId)'),
    );
    expect(nativeSource, contains('?.getCookieManager()'));
    expect(
      nativeSource,
      contains('if (webViewId == null) cookieManager = manager'),
    );
  });

  test('Android Gradle scripts do not force KGP on AGP 9', () {
    final rootExampleFile = [
      File(
        '../flutter_inappwebview_forge/example/android/app/build.gradle.kts',
      ),
      File('flutter_inappwebview_forge/example/android/app/build.gradle.kts'),
    ].firstWhere((file) => file.existsSync());
    final buildFiles = [
      _sourceFile('android/build.gradle.kts'),
      _sourceFile('example/android/app/build.gradle.kts'),
      rootExampleFile,
    ];

    for (final file in buildFiles) {
      final source = file.readAsStringSync();
      expect(
        source,
        contains(
          'val agpMajor = com.android.Version.ANDROID_GRADLE_PLUGIN_VERSION',
        ),
      );
      expect(source, contains('if (agpMajor < 9)'));
      expect(
        source,
        contains('apply(plugin = "org.jetbrains.kotlin.android")'),
      );
      expect(source, contains('KotlinAndroidProjectExtension'));
      expect(source, isNot(contains('id("org.jetbrains.kotlin.android")')));
    }
  });

  test('Android file chooser rejects private sandbox file URIs', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'webview/in_app_webview/InAppWebViewChromeClient.kt',
    ).readAsStringSync();
    final chooserSource = source.substring(
      source.indexOf('override fun onActivityResult('),
      source.indexOf('private fun isFileNotEmpty('),
    );

    expect(chooserSource, contains('isPrivateSandboxFileUri'));
    expect(chooserSource, contains('filterSandboxFileUris'));
    expect(chooserSource, contains('File(path).canonicalPath'));
    expect(chooserSource, contains('applicationInfo?.dataDir'));
    expect(chooserSource, contains('normalizedPath.startsWith("/data/")'));
    expect(chooserSource, contains('data?.clipData'));
    expect(chooserSource, contains('if (isPrivateSandboxFileUri(candidate))'));
    expect(chooserSource, contains('filterSandboxFileUris('));
  });

  test(
    'Android internal storage path handler serializes its base fields once',
    () {
      final handler = AndroidInternalStoragePathHandler(
        PlatformInternalStoragePathHandlerCreationParams(
          const PlatformPathHandlerCreationParams(path: '/internal/'),
          directory: '/data/user/0/example/files',
        ),
      );

      expect(handler.toMap(), containsPair('path', '/internal/'));
      expect(
        handler.toMap(),
        containsPair('type', 'InternalStoragePathHandler'),
      );
      expect(
        handler.toMap(),
        containsPair('directory', '/data/user/0/example/files'),
      );

      handler.dispose();
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
    'Android startup coordinator cannot block the first load indefinitely',
    () {
      final source = _sourceFile(
        'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
        'WebViewStartupCoordinator.kt',
      ).readAsStringSync();

      expect(source, contains('STARTUP_TIMEOUT_MS'));
      expect(source, contains('mainHandler.postDelayed'));
      expect(source, contains('complete(generation, timedOut = true)'));
      expect(source, contains('bounded native registration retries'));
    },
  );

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

  test('Android cookie mutations do not flush synchronously after async updates', () {
    final source = _sourceFile(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'MyCookieManager.kt',
    ).readAsStringSync();

    final setCookie = RegExp(
      r'fun setCookie\([\s\S]*?\) \{([\s\S]*?)\n    \}\n\n    fun getCookies',
    ).firstMatch(source)?.group(1);
    final deleteCookie = RegExp(
      r'fun deleteCookie\([\s\S]*?\) \{([\s\S]*?)\n    \}\n\n    @Suppress\("DEPRECATION"\)\n    fun deleteCookies',
    ).firstMatch(source)?.group(1);
    final deleteCookies = RegExp(
      r'fun deleteCookies\([\s\S]*?\) \{([\s\S]*?)\n    \}\n\n    @Suppress\("DEPRECATION"\)\n    fun deleteAllCookies',
    ).firstMatch(source)?.group(1);
    final deleteAllCookies = RegExp(
      r'fun deleteAllCookies\(result: MethodChannel\.Result\) \{([\s\S]*?)\n    \}\n\n    (?:@Suppress\("DEPRECATION"\)\n    )?fun removeSessionCookies',
    ).firstMatch(source)?.group(1);
    final explicitFlush = RegExp(
      r'fun flush\(result: MethodChannel\.Result\) \{([\s\S]*?)\n    \}\n\n    override fun dispose',
    ).firstMatch(source)?.group(1);

    expect(setCookie, isNotNull);
    expect(deleteCookie, isNotNull);
    expect(deleteCookies, isNotNull);
    expect(deleteAllCookies, isNotNull);
    expect(explicitFlush, isNotNull);
    expect(setCookie, isNot(contains('manager.flush()')));
    expect(deleteCookie, isNot(contains('manager.flush()')));
    expect(deleteCookies, contains('ValueCallback<Boolean>'));
    expect(deleteCookies, contains('remaining.decrementAndGet()'));
    expect(deleteCookies, isNot(contains('manager.flush()')));
    expect(deleteAllCookies, isNot(contains('manager.flush()')));
    expect(explicitFlush, contains('manager.flush()'));
    expect(explicitFlush, contains('result.success(true)'));
  });

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

  test('Android legacy APIs declare explicit native deprecation boundaries', () {
    const compatibilitySources = [
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/MyCookieManager.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/PlatformUtil.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/chrome_custom_tabs/ChromeCustomTabsActivity.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/InAppWebViewManager.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/WebViewChannelDelegate.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewChromeClient.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewClient.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewClientCompat.kt',
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
    ];

    for (final relativePath in compatibilitySources) {
      final source = _sourceFile(relativePath).readAsStringSync();
      expect(
        source,
        startsWith('@file:Suppress("DEPRECATION"'),
        reason: relativePath,
      );
    }
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
    expect(source, contains('catch (exception: RuntimeException)'));
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
