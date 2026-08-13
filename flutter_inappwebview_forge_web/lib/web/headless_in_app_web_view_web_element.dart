import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'headless_inappwebview_manager.dart';
import 'in_app_web_view_web_element.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'web_view_lifecycle_coordinator.dart';

class HeadlessInAppWebViewWebElement extends ChannelController {
  String id;
  late BinaryMessenger _messenger;
  InAppWebViewWebElement? webView;
  final WebViewLifecycleCoordinator lifecycle = WebViewLifecycleCoordinator();

  HeadlessInAppWebViewWebElement({
    required this.id,
    required BinaryMessenger messenger,
    required this.webView,
  }) {
    this._messenger = messenger;

    channel = MethodChannel(
      'com.emirkanacar/flutter_headless_inappwebview_${this.id}',
      const StandardMethodCodec(),
      _messenger,
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    if (!lifecycle.acceptsCallbacks && call.method != 'dispose') {
      return null;
    }
    switch (call.method) {
      case "dispose":
        dispose();
        break;
      case "setSize":
        Size size = MapSize.fromMap(
          call.arguments['size'].cast<String, dynamic>(),
        )!;
        setSize(size);
        break;
      case "getSize":
        return webView?.getSize().toMap();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'flutter_inappwebview for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  void onWebViewCreated() async {
    if (!lifecycle.acceptsCallbacks) {
      return;
    }
    await channel?.invokeMethod("onWebViewCreated");
  }

  void setSize(Size size) {
    webView?.iframeContainer.style.width = size.width.toString() + "px";
    webView?.iframeContainer.style.height = size.height.toString() + "px";
  }

  InAppWebViewWebElement? disposeAndGetFlutterWebView() {
    if (!lifecycle.beginDisposal()) {
      return null;
    }
    InAppWebViewWebElement? newFlutterWebView = webView;
    _completeDispose(disposeWebView: false);
    return newFlutterWebView;
  }

  @override
  void dispose() {
    if (!lifecycle.beginDisposal()) {
      return;
    }
    _completeDispose(disposeWebView: true);
  }

  void _completeDispose({required bool disposeWebView}) {
    disposeChannel();
    if (identical(HeadlessInAppWebViewManager.webViews[id], this)) {
      HeadlessInAppWebViewManager.webViews.remove(id);
    }
    if (disposeWebView) {
      webView?.dispose();
    } else {
      webView?.lifecycle.markDetachedRetained();
    }
    webView = null;
    lifecycle.finishDisposal();
  }
}
