import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';
import '../in_app_webview/platform_webview.dart';
part 'navigation_action_policy.g.dart';

///Class that is used by [PlatformWebViewCreationParams.shouldOverrideUrlLoading] event.
///It represents the policy to pass back to the decision handler.
@ExchangeableEnum()
class NavigationActionPolicy_ {
  // ignore: unused_field
  final int _value;
  const NavigationActionPolicy_._internal(this._value);

  ///Cancel the navigation.
  static const CANCEL = const NavigationActionPolicy_._internal(0);

  ///Allow the navigation to continue.
  static const ALLOW = const NavigationActionPolicy_._internal(1);

  ///Turn the navigation into a download.
  ///
  ///**NOTE**: available only on iOS 14.5+. It will fallback to [CANCEL].
  static const DOWNLOAD = const NavigationActionPolicy_._internal(2);

  ///Allow the navigation without handing it off to an associated Universal
  ///Link application.
  ///
  ///**NOTE**: available only on iOS and macOS. On other platforms it falls
  ///back to [ALLOW]. This uses WebKit's long-standing raw policy value and is
  ///intended for login and OAuth POST navigations that must remain in the
  ///WebView.
  @EnumSupportedPlatforms(
    platforms: [EnumIOSPlatform(value: 3), EnumMacOSPlatform(value: 3)],
    defaultValue: 1,
  )
  static const ALLOW_WITHOUT_TRYING_APP_LINK =
      const NavigationActionPolicy_._internal(3);
}
