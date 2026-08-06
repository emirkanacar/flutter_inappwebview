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
}
