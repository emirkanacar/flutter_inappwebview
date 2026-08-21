// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_navigation_event.dart';

// **************************************************************************
// ExchangeableObjectGenerator
// **************************************************************************

///Android `NavigationListener` payload for [PlatformWebViewCreationParams.onWebViewNavigation].
class WebViewNavigationEvent {
  ///Duration in milliseconds for FCP/LCP/performance-mark events.
  int? durationMillis;

  ///Whether this navigation is history back.
  bool? isBack;

  ///Whether this navigation is history forward.
  bool? isForward;

  ///Whether this navigation is a reload.
  bool? isReload;

  ///Whether this navigation is same-document.
  bool? isSameDocument;

  ///Performance mark name when [type] is [WebViewNavigationEventType_.PERFORMANCE_MARK].
  String? markName;

  ///Event type.
  WebViewNavigationEventType type;

  ///URL associated with the navigation or page, when known.
  WebUri? url;

  ///Whether the page/renderer initiated the navigation.
  bool? wasInitiatedByPage;
  WebViewNavigationEvent({
    this.durationMillis,
    this.isBack,
    this.isForward,
    this.isReload,
    this.isSameDocument,
    this.markName,
    required this.type,
    this.url,
    this.wasInitiatedByPage,
  });

  ///Gets a possible [WebViewNavigationEvent] instance from a [Map] value.
  static WebViewNavigationEvent? fromMap(
    Map<String, dynamic>? map, {
    EnumMethod? enumMethod,
  }) {
    if (map == null) {
      return null;
    }
    final instance = WebViewNavigationEvent(
      durationMillis: map['durationMillis'],
      isBack: map['isBack'],
      isForward: map['isForward'],
      isReload: map['isReload'],
      isSameDocument: map['isSameDocument'],
      markName: map['markName'],
      type: switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => WebViewNavigationEventType.fromNativeValue(
          map['type'],
        ),
        EnumMethod.value => WebViewNavigationEventType.fromValue(map['type']),
        EnumMethod.name => WebViewNavigationEventType.byName(map['type']),
      }!,
      url: map['url'] != null ? WebUri(map['url']) : null,
      wasInitiatedByPage: map['wasInitiatedByPage'],
    );
    return instance;
  }

  ///Converts instance to a map.
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) {
    return {
      "durationMillis": durationMillis,
      "isBack": isBack,
      "isForward": isForward,
      "isReload": isReload,
      "isSameDocument": isSameDocument,
      "markName": markName,
      "type": switch (enumMethod ?? EnumMethod.nativeValue) {
        EnumMethod.nativeValue => type.toNativeValue(),
        EnumMethod.value => type.toValue(),
        EnumMethod.name => type.name(),
      },
      "url": url?.toString(),
      "wasInitiatedByPage": wasInitiatedByPage,
    };
  }

  ///Converts instance to a map.
  Map<String, dynamic> toJson() {
    return toMap();
  }

  @override
  String toString() {
    return 'WebViewNavigationEvent{durationMillis: $durationMillis, isBack: $isBack, isForward: $isForward, isReload: $isReload, isSameDocument: $isSameDocument, markName: $markName, type: $type, url: $url, wasInitiatedByPage: $wasInitiatedByPage}';
  }
}
