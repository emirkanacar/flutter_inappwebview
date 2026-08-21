// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_navigation_event_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Type of a [WebViewNavigationEvent] from Android `NavigationListener`.
class WebViewNavigationEventType {
  final int _value;
  final int? _nativeValue;
  const WebViewNavigationEventType._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebViewNavigationEventType._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => WebViewNavigationEventType._internal(value, nativeValue());

  ///Main-frame navigation completed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final COMPLETED = WebViewNavigationEventType._internalMultiPlatform(
    2,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 2;
        default:
          break;
      }
      return null;
    },
  );

  ///`DOMContentLoaded` fired for the current page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final DOM_CONTENT_LOADED =
      WebViewNavigationEventType._internalMultiPlatform(3, () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return 3;
          default:
            break;
        }
        return null;
      });

  ///First Contentful Paint.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final FIRST_CONTENTFUL_PAINT =
      WebViewNavigationEventType._internalMultiPlatform(5, () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return 5;
          default:
            break;
        }
        return null;
      });

  ///Largest Contentful Paint.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final LARGEST_CONTENTFUL_PAINT =
      WebViewNavigationEventType._internalMultiPlatform(6, () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return 6;
          default:
            break;
        }
        return null;
      });

  ///`window.load` fired for the current page.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final LOAD = WebViewNavigationEventType._internalMultiPlatform(4, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///A previously seen page was evicted, including from BFCache.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final PAGE_DELETED = WebViewNavigationEventType._internalMultiPlatform(
    8,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 8;
        default:
          break;
      }
      return null;
    },
  );

  ///A performance mark was registered.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final PERFORMANCE_MARK =
      WebViewNavigationEventType._internalMultiPlatform(7, () {
        switch (defaultTargetPlatform) {
          case TargetPlatform.android:
            return 7;
          default:
            break;
        }
        return null;
      });

  ///Main-frame navigation was redirected.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final REDIRECTED = WebViewNavigationEventType._internalMultiPlatform(
    1,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 1;
        default:
          break;
      }
      return null;
    },
  );

  ///Main-frame navigation started.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  static final STARTED = WebViewNavigationEventType._internalMultiPlatform(
    0,
    () {
      switch (defaultTargetPlatform) {
        case TargetPlatform.android:
          return 0;
        default:
          break;
      }
      return null;
    },
  );

  ///Set of all values of [WebViewNavigationEventType].
  static final Set<WebViewNavigationEventType> values = [
    WebViewNavigationEventType.COMPLETED,
    WebViewNavigationEventType.DOM_CONTENT_LOADED,
    WebViewNavigationEventType.FIRST_CONTENTFUL_PAINT,
    WebViewNavigationEventType.LARGEST_CONTENTFUL_PAINT,
    WebViewNavigationEventType.LOAD,
    WebViewNavigationEventType.PAGE_DELETED,
    WebViewNavigationEventType.PERFORMANCE_MARK,
    WebViewNavigationEventType.REDIRECTED,
    WebViewNavigationEventType.STARTED,
  ].toSet();

  ///Gets a possible [WebViewNavigationEventType] instance from [int] value.
  static WebViewNavigationEventType? fromValue(int? value) {
    if (value != null) {
      try {
        return WebViewNavigationEventType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebViewNavigationEventType] instance from a native value.
  static WebViewNavigationEventType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebViewNavigationEventType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebViewNavigationEventType] instance value with name [name].
  ///
  /// Goes through [WebViewNavigationEventType.values] looking for a value with
  /// name [name], as reported by [WebViewNavigationEventType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebViewNavigationEventType? byName(String? name) {
    if (name != null) {
      try {
        return WebViewNavigationEventType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebViewNavigationEventType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebViewNavigationEventType> asNameMap() =>
      <String, WebViewNavigationEventType>{
        for (final value in WebViewNavigationEventType.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 2:
        return 'COMPLETED';
      case 3:
        return 'DOM_CONTENT_LOADED';
      case 5:
        return 'FIRST_CONTENTFUL_PAINT';
      case 6:
        return 'LARGEST_CONTENTFUL_PAINT';
      case 4:
        return 'LOAD';
      case 8:
        return 'PAGE_DELETED';
      case 7:
        return 'PERFORMANCE_MARK';
      case 1:
        return 'REDIRECTED';
      case 0:
        return 'STARTED';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
