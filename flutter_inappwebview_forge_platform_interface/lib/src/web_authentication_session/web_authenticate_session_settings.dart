import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';

import 'platform_web_authenticate_session.dart';
import '../types/enum_method.dart';

part 'web_authenticate_session_settings.g.dart';

///Class that represents the settings that can be used for a [PlatformWebAuthenticationSession].
@ExchangeableObject(copyMethod: true)
@SupportedPlatforms(
  platforms: [
    IOSPlatform(available: '13.0'),
    MacOSPlatform(available: '10.15'),
  ],
)
class WebAuthenticationSessionSettings_ {
  ///A Boolean value that indicates whether the session should ask the browser for a private authentication session.
  ///
  ///Set [prefersEphemeralWebBrowserSession] to `true` to request that the browser
  ///doesn’t share cookies or other browsing data between the authentication session and the user’s normal browser session.
  ///Whether the request is honored depends on the user’s default web browser.
  ///Safari always honors the request.
  ///
  ///The value of this property is `false` by default.
  ///
  ///Set this property before you call [PlatformWebAuthenticationSession.start]. Otherwise it has no effect.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '13.0'),
      MacOSPlatform(available: '10.15'),
    ],
  )
  bool? prefersEphemeralWebBrowserSession;

  ///Additional HTTP headers sent with the authentication request when the native API supports them.
  ///
  ///This property is available on iOS 17.4+ and macOS 14.4+.
  @SupportedPlatforms(
    platforms: [
      IOSPlatform(available: '17.4'),
      MacOSPlatform(available: '14.4'),
    ],
  )
  Map<String, String>? additionalHeaderFields;

  WebAuthenticationSessionSettings_({
    this.prefersEphemeralWebBrowserSession = false,
    this.additionalHeaderFields,
  });

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  static bool isPropertySupported(
    WebAuthenticationSessionSettingsProperty property, {
    TargetPlatform? platform,
  }) => _WebAuthenticationSessionSettingsPropertySupported.isPropertySupported(
    property,
    platform: platform,
  );
}
