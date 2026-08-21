// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_job_state.dart';

// **************************************************************************
// ExchangeableEnumGenerator
// **************************************************************************

///State of a native WebView download job.
class DownloadJobState {
  final int _value;
  final int? _nativeValue;
  const DownloadJobState._internal(this._value, this._nativeValue);
  // ignore: unused_element
  factory DownloadJobState._internalMultiPlatform(
    int value,
    Function nativeValue,
  ) => DownloadJobState._internal(value, nativeValue());

  ///The download was canceled.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final CANCELED = DownloadJobState._internalMultiPlatform(4, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 4;
      case TargetPlatform.iOS:
        return 4;
      case TargetPlatform.macOS:
        return 4;
      default:
        break;
    }
    return null;
  });

  ///The download finished and the file is on disk.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final COMPLETED = DownloadJobState._internalMultiPlatform(2, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 2;
      case TargetPlatform.iOS:
        return 2;
      case TargetPlatform.macOS:
        return 2;
      default:
        break;
    }
    return null;
  });

  ///The download failed.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final FAILED = DownloadJobState._internalMultiPlatform(3, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 3;
      case TargetPlatform.iOS:
        return 3;
      case TargetPlatform.macOS:
        return 3;
      default:
        break;
    }
    return null;
  });

  ///The download has been created and is waiting to start.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final QUEUED = DownloadJobState._internalMultiPlatform(0, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 0;
      case TargetPlatform.iOS:
        return 0;
      case TargetPlatform.macOS:
        return 0;
      default:
        break;
    }
    return null;
  });

  ///The download is transferring bytes.
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  static final RUNNING = DownloadJobState._internalMultiPlatform(1, () {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 1;
      case TargetPlatform.iOS:
        return 1;
      case TargetPlatform.macOS:
        return 1;
      default:
        break;
    }
    return null;
  });

  ///Set of all values of [DownloadJobState].
  static final Set<DownloadJobState> values = [
    DownloadJobState.CANCELED,
    DownloadJobState.COMPLETED,
    DownloadJobState.FAILED,
    DownloadJobState.QUEUED,
    DownloadJobState.RUNNING,
  ].toSet();

  ///Gets a possible [DownloadJobState] instance from [int] value.
  static DownloadJobState? fromValue(int? value) {
    if (value != null) {
      try {
        return DownloadJobState.values.firstWhere(
          (element) => element.toValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  ///Gets a possible [DownloadJobState] instance from a native value.
  static DownloadJobState? fromNativeValue(int? value) {
    if (value != null) {
      try {
        return DownloadJobState.values.firstWhere(
          (element) => element.toNativeValue() == value,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Gets a possible [DownloadJobState] instance value with name [name].
  ///
  /// Goes through [DownloadJobState.values] looking for a value with
  /// name [name], as reported by [DownloadJobState.name].
  /// Returns the first value with the given name, otherwise `null`.
  static DownloadJobState? byName(String? name) {
    if (name != null) {
      try {
        return DownloadJobState.values.firstWhere(
          (element) => element.name() == name,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Creates a map from the names of [DownloadJobState] values to the values.
  ///
  /// The collection that this method is called on is expected to have
  /// values with distinct names, like the `values` list of an enum class.
  /// Only one value for each name can occur in the created map,
  /// so if two or more values have the same name (either being the
  /// same value, or being values of different enum type), at most one of
  /// them will be represented in the returned map.
  static Map<String, DownloadJobState> asNameMap() =>
      <String, DownloadJobState>{
        for (final value in DownloadJobState.values) value.name(): value,
      };

  ///Gets [int] value.
  int toValue() => _value;

  ///Gets [int] native value if supported by the current platform, otherwise `null`.
  int? toNativeValue() => _nativeValue;

  ///Gets the name of the value.
  String name() {
    switch (_value) {
      case 4:
        return 'CANCELED';
      case 2:
        return 'COMPLETED';
      case 3:
        return 'FAILED';
      case 0:
        return 'QUEUED';
      case 1:
        return 'RUNNING';
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
