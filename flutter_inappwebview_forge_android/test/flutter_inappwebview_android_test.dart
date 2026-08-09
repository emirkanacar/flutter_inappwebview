import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('FileProvider paths expose only capture and legacy media directories', () {
    final providerPaths =
        [
          File('android/src/main/res/xml/provider_paths.xml'),
          File(
            'flutter_inappwebview_forge_android/android/src/main/res/xml/provider_paths.xml',
          ),
        ].firstWhere(
          (file) => file.existsSync(),
          orElse: () => File('android/src/main/res/xml/provider_paths.xml'),
        );

    expect(providerPaths.existsSync(), isTrue);
    final content = providerPaths.readAsStringSync();

    expect(
      content,
      contains('<external-files-path name="app_captures" path="Captures/"/>'),
    );
    expect(
      content,
      contains('<external-path name="pictures" path="Pictures/"/>'),
    );
    expect(content, contains('<external-path name="movies" path="Movies/"/>'));
    expect(
      RegExp(r'<external-path\b[^>]*path="\."\s*/>').hasMatch(content),
      isFalse,
    );
  });

  test('native WebView background color uses a dedicated channel method', () {
    final controller =
        File(
          'lib/src/in_app_webview/in_app_webview_controller.dart',
        ).existsSync()
        ? File('lib/src/in_app_webview/in_app_webview_controller.dart')
        : File(
            'flutter_inappwebview_forge_android/lib/src/in_app_webview/in_app_webview_controller.dart',
          );
    final delegate =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/WebViewChannelDelegate.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/WebViewChannelDelegate.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/WebViewChannelDelegate.kt',
          );

    expect(
      controller.readAsStringSync(),
      contains("invokeMethod('setBackgroundColor'"),
    );
    expect(
      delegate.readAsStringSync(),
      contains('WebViewChannelDelegateMethods.setBackgroundColor'),
    );
    expect(delegate.readAsStringSync(), contains('view.setBackgroundColor'));
  });

  test('Android release builds use the available optimized ProGuard file', () {
    final buildFile = File('android/build.gradle.kts').existsSync()
        ? File('android/build.gradle.kts')
        : File('flutter_inappwebview_forge_android/android/build.gradle.kts');
    final source = buildFile.readAsStringSync();

    expect(source, contains('proguard-android-optimize.txt'));
    expect(source, isNot(contains('proguard-android.txt')));
  });

  test('Android allow-list parsing filters malformed channel values', () {
    final source =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
          );
    final content = source.readAsStringSync();

    expect(content, contains('filterIsInstance<String>()'));
    expect(content, isNot(contains('HashSet(value as List<String>)')));
  });

  test('Android provider-specific force-dark casts fail open', () {
    final webViewSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          );
    final settingsSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewSettings.kt',
          );

    final webViewContent = webViewSource.readAsStringSync();
    final settingsContent = settingsSource.readAsStringSync();
    expect(
      webViewContent,
      contains(
        'Unable to apply forceDarkStrategy for the active WebView provider.',
      ),
    );
    expect(
      webViewContent,
      contains(
        'Unable to update forceDarkStrategy for the active WebView provider.',
      ),
    );
    expect(
      settingsContent,
      contains(
        'Unable to read forceDarkStrategy from the active WebView provider.',
      ),
    );
    expect(webViewContent, contains('catch (e: Exception)'));
    expect(settingsContent, contains('catch (e: Exception)'));
  });

  test('Android IME callbacks tolerate stale or detached views', () {
    final inputAwareSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InputAwareWebView.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InputAwareWebView.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InputAwareWebView.kt',
          );
    final webViewSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          );

    final inputAwareContent = inputAwareSource.readAsStringSync();
    final webViewContent = webViewSource.readAsStringSync();
    expect(inputAwareContent, contains('catch (error: RuntimeException)'));
    expect(inputAwareContent, contains('isViewReady(postedContainerView)'));
    expect(webViewContent, contains('postedContainerView.isAttachedToWindow'));
    expect(
      webViewContent,
      contains('Unable to hide the input method after a stale WebView focus.'),
    );
  });

  test('Android WebView disposal is idempotent after fullscreen teardown', () {
    final webViewSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          );
    final flutterWebViewSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/FlutterWebView.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/FlutterWebView.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/FlutterWebView.kt',
          );

    expect(
      webViewSource.readAsStringSync(),
      contains('if (isDisposed) return'),
    );
    final flutterWebViewContent = flutterWebViewSource.readAsStringSync();
    expect(
      flutterWebViewContent,
      contains('currentWebView.inAppWebViewChromeClient?.onHideCustomView()'),
    );
    expect(
      flutterWebViewContent,
      contains('currentWebView.channelDelegate?.onExitFullscreen()'),
    );
    expect(
      webViewSource.readAsStringSync(),
      contains('finishPendingAsyncJavaScriptCallbacksOnDispose()'),
    );
  });

  test('Android renderer loss clears stale fullscreen state before callbacks', () {
    final webViewSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebView.kt',
          );
    final clientSource =
        File(
          'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewClient.kt',
        ).existsSync()
        ? File(
            'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewClient.kt',
          )
        : File(
            'flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/webview/in_app_webview/InAppWebViewClient.kt',
          );

    final webViewContent = webViewSource.readAsStringSync();
    expect(
      webViewContent,
      contains('internal fun restoreFullscreenStateAfterRendererGone()'),
    );
    expect(webViewContent, contains('if (!isInFullscreen()) return'));
    expect(webViewContent, contains('channelDelegate?.onExitFullscreen()'));

    final clientContent = clientSource.readAsStringSync();
    expect(
      clientContent,
      contains('webView.restoreFullscreenStateAfterRendererGone()'),
    );
    final rendererCallback = clientContent.substring(
      clientContent.indexOf('override fun onRenderProcessGone'),
    );
    expect(
      rendererCallback.indexOf('restoreFullscreenStateAfterRendererGone'),
      lessThan(rendererCallback.indexOf('val channelDelegate')),
    );
  });
}
