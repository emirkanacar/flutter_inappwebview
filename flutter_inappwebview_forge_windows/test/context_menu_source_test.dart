import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('ContextMenu capability metadata lists Windows', () {
    expect(
      PlatformWebViewCreationParams(
        controllerFromPlatform: (_) => throw UnimplementedError(),
      ).isPropertySupported(
        PlatformWebViewCreationParamsProperty.contextMenu,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
  });

  test('WebView2 ContextMenuRequested is wired to the Dart contract', () {
    final webView = _sourceFile(
      'windows/in_app_webview/in_app_webview.cpp',
    ).readAsStringSync();
    final delegate = _sourceFile(
      'windows/in_app_webview/webview_channel_delegate.cpp',
    ).readAsStringSync();
    final contextMenu = _sourceFile(
      'windows/types/context_menu.cpp',
    ).readAsStringSync();
    final cmake = _sourceFile('windows/CMakeLists.txt').readAsStringSync();

    // Registered only when ICoreWebView2_11 exists and a menu was supplied.
    expect(webView, contains('webView.try_query<ICoreWebView2_11>()'));
    expect(webView, contains('add_ContextMenuRequested'));
    expect(webView, contains('ICoreWebView2Environment9'));
    expect(webView, contains('CreateContextMenuItem'));
    expect(webView, contains('add_CustomItemSelected'));
    expect(webView, contains('RemoveValueAtIndex'));
    expect(webView, contains('hideDefaultSystemContextMenuItems'));

    // Channel method names and payload keys read by the Dart controller.
    expect(delegate, contains('"onCreateContextMenu"'));
    expect(delegate, contains('"onContextMenuActionItemClicked"'));
    expect(delegate, contains('{"type", '));
    expect(delegate, contains('{"extra", '));
    expect(delegate, contains('{"title", '));

    // Menu items with a missing or invalid id/title are skipped, not thrown.
    expect(contextMenu, contains('std::holds_alternative<std::string>'));
    expect(contextMenu, contains('std::holds_alternative<int32_t>'));
    expect(contextMenu, contains('std::holds_alternative<int64_t>'));
    expect(cmake, contains('"types/context_menu.cpp"'));
    expect(cmake, contains('"types/context_menu.h"'));
  });
}
