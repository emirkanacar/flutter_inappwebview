// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'webview_data_type.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///iOS/macOS `WKWebViewDataType` values for session data fetch/restore.
class WebViewDataType {
  final int _value;
  final int? _nativeValue;
  const WebViewDataType._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebViewDataType._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => WebViewDataType._internal(value, nativeValue());

  ///Session Storage data.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 26.0+
  ///- macOS WKWebView 26.0+
  static final SESSION_STORAGE = WebViewDataType._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [WebViewDataType].
  static final Set<WebViewDataType> values = [
    WebViewDataType.SESSION_STORAGE,
  ].toSet();

  ///Gets a possible [WebViewDataType] instance from [int] value.
  static WebViewDataType? fromValue(int? value) {
    if (value != null) {
      try {
        return WebViewDataType.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return WebViewDataType._internal(value, value);
      }
    }
    return null;
  }

  ///Gets a possible [WebViewDataType] instance from a native value.
  static WebViewDataType? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebViewDataType.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebViewDataType] instance value with name [name].
  ///
  /// Goes through [WebViewDataType.values] looking for a value with
  /// name [name], as reported by [WebViewDataType.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebViewDataType? byName(String? name) {
    if (name != null) {
      try {
        return WebViewDataType.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebViewDataType] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebViewDataType> asNameMap() => <String, WebViewDataType>{
    for (final value in WebViewDataType.values) value.name(): value,
  };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'SESSION_STORAGE';
    }
    return _value.toString();
  }

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(value) => value == _value;

  WebViewDataType operator |(WebViewDataType value) =>
      WebViewDataType._internal(
        value.toValue() | _value,
        value.toNativeValue() != null && _nativeValue != null
            ? value.toNativeValue()! | _nativeValue!
            : null,
      );

  ///Checks if the value is supported by the [defaultTargetPlatform].
  bool isSupported() {
    return _nativeValue != null;
  }

  @override
  String toString() {
    return name();
  }
}
