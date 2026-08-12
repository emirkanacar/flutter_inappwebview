import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

import '../types/attributed_string.dart';
import '../types/pull_to_refresh_size.dart';
import '../util.dart';
import '../types/main.dart';
import 'platform_pull_to_refresh_controller.dart';

part 'pull_to_refresh_settings.g.dart';

///Pull-To-Refresh Settings for [PlatformPullToRefreshController].
@SupportedPlatforms(
  platforms: [AndroidPlatform(), IOSPlatform(), WindowsPlatform()],
)
@ExchangeableObject(copyMethod: true)
class PullToRefreshSettings_ {
  ///Sets whether the pull-to-refresh feature is enabled or not.
  ///The default value is `true`.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), WindowsPlatform()],
  )
  bool? enabled;

  ///The color of the refresh control.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), WindowsPlatform()],
  )
  Color_? color;

  ///The background color of the refresh control.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), WindowsPlatform()],
  )
  Color_? backgroundColor;

  ///Allows pull-to-refresh to start when the document has no vertical scrollbar.
  ///
  ///On Windows this is an opt-in Flutter gesture implementation. The gesture
  ///is accepted only when the document is already at its top edge.
  @SupportedPlatforms(platforms: [WindowsPlatform()])
  bool? allowWithNoScrollbar;

  ///The distance to trigger a sync in dips.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  int? distanceToTriggerSync;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  int? slingshotDistance;

  ///The size of the refresh indicator.
  @SupportedPlatforms(platforms: [AndroidPlatform()])
  PullToRefreshSize_? size;

  ///The title text to display in the refresh control.
  @SupportedPlatforms(platforms: [IOSPlatform()])
  AttributedString_? attributedTitle;

  PullToRefreshSettings_({
    this.enabled = true,
    this.color,
    this.backgroundColor,
    this.allowWithNoScrollbar = false,
    this.distanceToTriggerSync,
    this.slingshotDistance,
    this.size,
    this.attributedTitle,
  });

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    PullToRefreshSettingsProperty property, {
    TargetPlatform? platform,
  }) => _PullToRefreshSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}

///Use [PullToRefreshSettings] instead.
@Deprecated("Use PullToRefreshSettings instead")
class PullToRefreshOptions {
  ///Sets whether the pull-to-refresh feature is enabled or not.
  bool enabled;

  ///The color of the refresh control.
  Color? color;

  ///The background color of the refresh control.
  Color? backgroundColor;

  ///Allows pull-to-refresh to start when the document has no vertical scrollbar.
  ///
  ///**NOTE**: Available only on Windows.
  bool allowWithNoScrollbar;

  ///The distance to trigger a sync in dips.
  ///
  ///**NOTE**: Available only on Android.
  int? distanceToTriggerSync;

  ///The distance in pixels that the refresh indicator can be pulled beyond its resting position.
  ///
  ///**NOTE**: Available only on Android.
  int? slingshotDistance;

  ///The size of the refresh indicator.
  ///
  ///**NOTE**: Available only on Android.
  AndroidPullToRefreshSize? size;

  ///The title text to display in the refresh control.
  ///
  ///**NOTE**: Available only on iOS.
  IOSNSAttributedString? attributedTitle;

  PullToRefreshOptions({
    this.enabled = true,
    this.color,
    this.backgroundColor,
    this.allowWithNoScrollbar = false,
    this.distanceToTriggerSync,
    this.slingshotDistance,
    this.size,
    this.attributedTitle,
  });

  Map<String, dynamic> toMap() {
    return {
      "enabled": enabled,
      "color": color?.toHex(),
      "backgroundColor": backgroundColor?.toHex(),
      "allowWithNoScrollbar": allowWithNoScrollbar,
      "distanceToTriggerSync": distanceToTriggerSync,
      "slingshotDistance": slingshotDistance,
      "size": size?.toNativeValue(),
      "attributedTitle": attributedTitle?.toMap() ?? {},
    };
  }

  Map<String, dynamic> toJson() {
    return this.toMap();
  }

  @override
  String toString() {
    return toMap().toString();
  }
}
