import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

part 'webview_navigation_event_type.g.dart';

///Type of a [WebViewNavigationEvent] from Android `NavigationListener`.
@ExchangeableEnum()
class WebViewNavigationEventType_ {
  // ignore: unused_field
  final int _value;
  const WebViewNavigationEventType_._internal(this._value);

  ///Main-frame navigation started.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 0)])
  static const STARTED = WebViewNavigationEventType_._internal(0);

  ///Main-frame navigation was redirected.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 1)])
  static const REDIRECTED = WebViewNavigationEventType_._internal(1);

  ///Main-frame navigation completed.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 2)])
  static const COMPLETED = WebViewNavigationEventType_._internal(2);

  ///`DOMContentLoaded` fired for the current page.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 3)])
  static const DOM_CONTENT_LOADED = WebViewNavigationEventType_._internal(3);

  ///`window.load` fired for the current page.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 4)])
  static const LOAD = WebViewNavigationEventType_._internal(4);

  ///First Contentful Paint.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 5)])
  static const FIRST_CONTENTFUL_PAINT = WebViewNavigationEventType_._internal(
    5,
  );

  ///Largest Contentful Paint.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 6)])
  static const LARGEST_CONTENTFUL_PAINT = WebViewNavigationEventType_._internal(
    6,
  );

  ///A performance mark was registered.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 7)])
  static const PERFORMANCE_MARK = WebViewNavigationEventType_._internal(7);

  ///A previously seen page was evicted, including from BFCache.
  @EnumSupportedPlatforms(platforms: [EnumAndroidPlatform(value: 8)])
  static const PAGE_DELETED = WebViewNavigationEventType_._internal(8);
}
