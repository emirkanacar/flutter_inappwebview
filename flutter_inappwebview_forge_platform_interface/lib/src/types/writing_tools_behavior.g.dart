// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'writing_tools_behavior.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///Configures the Writing Tools experience for an iOS WebView.
///
///Writing Tools support is available on iOS 18.0 and later. The system can
///still provide a more limited experience when the requested capabilities are
///not available on the device.
class IOSWritingToolsBehavior {
  final int _value;
  final int? _nativeValue;
  const IOSWritingToolsBehavior._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory IOSWritingToolsBehavior._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => IOSWritingToolsBehavior._internal(value, nativeValue());

  ///Requests the complete inline-editing Writing Tools experience.
  static const COMPLETE = IOSWritingToolsBehavior._internal(1, 1);

  ///Lets the system choose the most appropriate Writing Tools experience.
  static const DEFAULT = IOSWritingToolsBehavior._internal(0, 0);

  ///Requests the limited overlay-panel Writing Tools experience.
  static const LIMITED = IOSWritingToolsBehavior._internal(2, 2);

  ///Prevents Writing Tools from modifying text in the WebView.
  static const NONE = IOSWritingToolsBehavior._internal(-1, -1);

  ///Set of all values of [IOSWritingToolsBehavior].
  static final Set<IOSWritingToolsBehavior> values = [
    IOSWritingToolsBehavior.COMPLETE,
    IOSWritingToolsBehavior.DEFAULT,
    IOSWritingToolsBehavior.LIMITED,
    IOSWritingToolsBehavior.NONE,
  ].toSet();

  ///Gets a possible [IOSWritingToolsBehavior] instance from [int] value.
  static IOSWritingToolsBehavior? fromValue(int? value) {
    if (value != null) {
      try {
        return IOSWritingToolsBehavior.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [IOSWritingToolsBehavior] instance from a native value.
  static IOSWritingToolsBehavior? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return IOSWritingToolsBehavior.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [IOSWritingToolsBehavior] instance value with name [name].
  ///
  /// Goes through [IOSWritingToolsBehavior.values] looking for a value with
  /// name [name], as reported by [IOSWritingToolsBehavior.name].
  /// Returns the first value with the given name, otherwise `null`.
  static IOSWritingToolsBehavior? byName(String? name) {
    if (name != null) {
      try {
        return IOSWritingToolsBehavior.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [IOSWritingToolsBehavior] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, IOSWritingToolsBehavior> asNameMap() =>
      <String, IOSWritingToolsBehavior>{
        for (final value in IOSWritingToolsBehavior.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 1:
        return 'COMPLETE';
      case 0:
        return 'DEFAULT';
      case 2:
        return 'LIMITED';
      case -1:
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
