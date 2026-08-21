import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

part 'download_job_state.g.dart';

///State of a native WebView download job.
@ExchangeableEnum()
class DownloadJobState_ {
  // ignore: unused_field
  final int _value;
  const DownloadJobState_._internal(this._value);

  ///The download has been created and is waiting to start.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 0),
      EnumIOSPlatform(value: 0),
      EnumMacOSPlatform(value: 0),
    ],
  )
  static const QUEUED = const DownloadJobState_._internal(0);

  ///The download is transferring bytes.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 1),
      EnumIOSPlatform(value: 1),
      EnumMacOSPlatform(value: 1),
    ],
  )
  static const RUNNING = const DownloadJobState_._internal(1);

  ///The download finished and the file is on disk.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 2),
      EnumIOSPlatform(value: 2),
      EnumMacOSPlatform(value: 2),
    ],
  )
  static const COMPLETED = const DownloadJobState_._internal(2);

  ///The download failed.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 3),
      EnumIOSPlatform(value: 3),
      EnumMacOSPlatform(value: 3),
    ],
  )
  static const FAILED = const DownloadJobState_._internal(3);

  ///The download was canceled.
  @EnumSupportedPlatforms(
    platforms: [
      EnumAndroidPlatform(value: 4),
      EnumIOSPlatform(value: 4),
      EnumMacOSPlatform(value: 4),
    ],
  )
  static const CANCELED = const DownloadJobState_._internal(4);
}
