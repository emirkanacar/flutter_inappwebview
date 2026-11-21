import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

String _body(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature is missing');
  final end = source.indexOf('\n  }\n', start);
  expect(end, greaterThan(start), reason: '$signature has no end');
  return source.substring(start, end);
}

void main() {
  final webView = _sourceFile(
    'windows/in_app_webview/in_app_webview.cpp',
  ).readAsStringSync();

  test('host window destruction closes WebView2 first (#2884)', () {
    // At application quit the Flutter view window and the child host window
    // are destroyed before the plugin, so the destructor alone ran against a
    // controller WebView2 had already closed (ERROR_INVALID_STATE).
    final proc = _body(
      webView,
      'LRESULT CALLBACK InAppWebView::hostWindowProc',
    );
    expect(proc, contains('message == WM_DESTROY'));
    expect(proc, contains('view->hostWindow_ == hwnd'));
    expect(proc, contains('view->closeBeforeHostDestroyed()'));

    final close = _body(
      webView,
      'void InAppWebView::closeBeforeHostDestroyed()',
    );
    expect(close.indexOf('detachHostWindow();'), isNonNegative);
    expect(close, contains('if (nativeClosed_ ||'));
    expect(
      close.indexOf('findInteractionController->dispose()'),
      lessThan(close.indexOf('webViewController->Close()')),
    );
    expect(close, contains('userContentController->detachWebView()'));
    expect(close, contains('webView->Stop()'));
  });

  test('destructor does not repeat the close sequence', () {
    final destructor = _body(webView, 'InAppWebView::~InAppWebView()');
    final guard = destructor.indexOf('if (!nativeClosed_) {');
    expect(guard, isNonNegative);
    expect(guard, lessThan(destructor.indexOf('webViewController->Close()')));
    // The property is removed before the destructor's DestroyWindow, so the
    // WM_DESTROY path cannot run for a view that is already going away.
    expect(
      destructor.indexOf('detachHostWindow();'),
      lessThan(destructor.indexOf('DestroyWindow(parentWindow)')),
    );
    final header = _sourceFile(
      'windows/in_app_webview/in_app_webview.h',
    ).readAsStringSync();
    expect(header, contains('!nativeClosed_ && lifecycle_.acceptsCallbacks()'));
  });

  test('plugin channels use a messenger detached at teardown (#2957)', () {
    final plugin = _sourceFile(
      'windows/flutter_inappwebview_windows_plugin.cpp',
    ).readAsStringSync();
    final destructor = _body(
      plugin,
      'FlutterInappwebviewWindowsPlugin::~FlutterInappwebviewWindowsPlugin()',
    );
    expect(
      destructor.indexOf('messenger_->Detach()'),
      lessThan(destructor.indexOf('inAppWebViewManager = nullptr')),
    );
    expect(plugin, contains('class PluginMessenger final'));

    // Only the wrapper itself may hold the registrar's messenger.
    final offenders = <String>[];
    for (final entity in Directory(
      _sourceFile('windows/CMakeLists.txt').parent.path,
    ).listSync(recursive: true).whereType<File>()) {
      final path = entity.path.replaceAll('\\', '/');
      if (!(path.endsWith('.cpp') || path.endsWith('.cc')) ||
          path.contains('/test/') ||
          path.endsWith('flutter_inappwebview_windows_plugin.cpp')) {
        continue;
      }
      if (entity.readAsStringSync().contains('registrar->messenger()')) {
        offenders.add(path);
      }
    }
    expect(offenders, isEmpty);
  });
}
