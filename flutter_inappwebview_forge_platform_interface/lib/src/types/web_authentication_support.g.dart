// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_authentication_support.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Configures the WebAuthn support level for an Android WebView.
class WebAuthenticationSupport {
  final int _value;
  final int? _nativeValue;
  const WebAuthenticationSupport._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory WebAuthenticationSupport._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => WebAuthenticationSupport._internal(value, nativeValue());

  ///Allow WebAuthn requests for the app in which the WebView is embedded.
  static const FOR_APP = WebAuthenticationSupport._internal(1, 1);

  ///Allow WebAuthn requests for any website. This requires the app to have the
  ///privileges and Digital Asset Links needed by the Android WebView.
  static const FOR_BROWSER = WebAuthenticationSupport._internal(2, 2);

  ///Disable WebAuthn requests from the WebView.
  static const NONE = WebAuthenticationSupport._internal(0, 0);

  ///Set of all values of [WebAuthenticationSupport].
  static final Set<WebAuthenticationSupport> values = [
    WebAuthenticationSupport.FOR_APP,
    WebAuthenticationSupport.FOR_BROWSER,
    WebAuthenticationSupport.NONE,
  ].toSet();

  ///Gets a possible [WebAuthenticationSupport] instance from [int] value.
  static WebAuthenticationSupport? fromValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSupport.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [WebAuthenticationSupport] instance from a native value.
  static WebAuthenticationSupport? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return WebAuthenticationSupport.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [WebAuthenticationSupport] instance value with name [name].
  ///
  /// Goes through [WebAuthenticationSupport.values] looking for a value with
  /// name [name], as reported by [WebAuthenticationSupport.name].
  /// Returns the first value with the given name, otherwise `null`.
  static WebAuthenticationSupport? byName(String? name) {
    if (name != null) {
      try {
        return WebAuthenticationSupport.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [WebAuthenticationSupport] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, WebAuthenticationSupport> asNameMap() =>
      <String, WebAuthenticationSupport>{
        for (final value in WebAuthenticationSupport.values)
          value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'FOR_APP';
      case 2:
        return 'FOR_BROWSER';
      case 0:
        return 'NONE';
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
