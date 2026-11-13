// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'http_cookie_store_policy.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Class that represents whether a WebView cookie store accepts cookies.
///Used by `CookieManager.setCookiePolicy` and `CookieManager.getCookiePolicy`.
class HTTPCookieStorePolicy {
  final String _value;
  final String? _nativeValue;
  const HTTPCookieStorePolicy._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory HTTPCookieStorePolicy._internalMultiPlatform(
    String value,
    Function nativeValue,
  ) => HTTPCookieStorePolicy._internal(value, nativeValue());

  ///The cookie store accepts and sends cookies. This is the default.
  static const ALLOW = HTTPCookieStorePolicy._internal('allow', 'allow');

  ///The cookie store neither stores new cookies nor sends existing ones.
  static const DISALLOW = HTTPCookieStorePolicy._internal(
    'disallow',
    'disallow',
  );

  ///Set of all values of [HTTPCookieStorePolicy].
  static final Set<HTTPCookieStorePolicy> values = [
    HTTPCookieStorePolicy.ALLOW,
    HTTPCookieStorePolicy.DISALLOW,
  ].toSet();

  ///Gets a possible [HTTPCookieStorePolicy] instance from [String] value.
  static HTTPCookieStorePolicy? fromValue(String? value) {
    if (value != null) {
      try {
        return HTTPCookieStorePolicy.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [HTTPCookieStorePolicy] instance from a native value.
  static HTTPCookieStorePolicy? fromNativeValue(String? value) {
    if (value != null) {
      try {
        return HTTPCookieStorePolicy.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [HTTPCookieStorePolicy] instance value with name [name].
  ///
  /// Goes through [HTTPCookieStorePolicy.values] looking for a value with
  /// name [name], as reported by [HTTPCookieStorePolicy.name].
  /// Returns the first value with the given name, otherwise `null`.
  static HTTPCookieStorePolicy? byName(String? name) {
    if (name != null) {
      try {
        return HTTPCookieStorePolicy.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [HTTPCookieStorePolicy] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, HTTPCookieStorePolicy> asNameMap() =>
      <String, HTTPCookieStorePolicy>{
        for (final value in HTTPCookieStorePolicy.values) value.name(): value,
      };

  ///Gets [String] value.
  String toValue() => _value;

  ///Gets [String] native value if supported by the current platform, otherwise `null`.
  String? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 'allow':
        return 'ALLOW';
      case 'disallow':
        return 'DISALLOW';
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
    return _value;
  }
}
