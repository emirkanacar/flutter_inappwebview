import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:web/web.dart';

import 'in_app_web_view_web_element.dart';

class InAppWebViewManager extends ChannelController {
  static final Map<dynamic, InAppWebViewWebElement> webViews = {};
  static final Map<int, CreateWindowAction?> windowActions = {};
  static int windowAutoincrementId = 0;
  static String javaScriptBridgeName = "flutter_inappwebview";
  late BinaryMessenger _messenger;

  InAppWebViewManager({required BinaryMessenger messenger}) {
    this._messenger = messenger;
    channel = MethodChannel(
      'com.emirkanacar/flutter_inappwebview_manager',
      const StandardMethodCodec(),
      _messenger,
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "getDefaultUserAgent":
        return getDefaultUserAgent();
      case "setJavaScriptBridgeName":
        javaScriptBridgeName = call.arguments["bridgeName"];
        break;
      case "getJavaScriptBridgeName":
        return javaScriptBridgeName;
      default:
        throw UnimplementedError("Unimplemented ${call.method} method");
    }
    return null;
  }

  String getDefaultUserAgent() {
    return window.navigator.userAgent;
  }

  static void registerWebView(dynamic viewId, InAppWebViewWebElement webView) {
    final previousWebView = webViews.remove(viewId);
    if (previousWebView != null && !identical(previousWebView, webView)) {
      previousWebView.dispose();
    }
    webViews[viewId] = webView;
  }

  @override
  void dispose() {
    disposeChannel();
  }
}
