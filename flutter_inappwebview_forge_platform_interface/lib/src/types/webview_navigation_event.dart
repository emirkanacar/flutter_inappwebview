import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

import '../in_app_webview/platform_webview.dart';
import '../web_uri.dart';
import 'enum_method.dart';
import 'webview_navigation_event_type.dart';

part 'webview_navigation_event.g.dart';

///Android `NavigationListener` payload for [PlatformWebViewCreationParams.onWebViewNavigation].
@ExchangeableObject()
class WebViewNavigationEvent_ {
  ///Event type.
  WebViewNavigationEventType_ type;

  ///URL associated with the navigation or page, when known.
  WebUri? url;

  ///Duration in milliseconds for FCP/LCP/performance-mark events.
  int? durationMillis;

  ///Performance mark name when [type] is [WebViewNavigationEventType_.PERFORMANCE_MARK].
  String? markName;

  ///Whether this navigation is same-document.
  bool? isSameDocument;

  ///Whether this navigation is a reload.
  bool? isReload;

  ///Whether this navigation is history back.
  bool? isBack;

  ///Whether this navigation is history forward.
  bool? isForward;

  ///Whether the page/renderer initiated the navigation.
  bool? wasInitiatedByPage;

  WebViewNavigationEvent_({
    required this.type,
    this.url,
    this.durationMillis,
    this.markName,
    this.isSameDocument,
    this.isReload,
    this.isBack,
    this.isForward,
    this.wasInitiatedByPage,
  });
}
