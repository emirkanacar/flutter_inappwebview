import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  group('isLockdownModeEnabled', () {
    test('defaults to null so the system setting is kept', () {
      final settings = InAppWebViewSettings();
      expect(settings.isLockdownModeEnabled, isNull);
      expect(settings.toMap()['isLockdownModeEnabled'], isNull);
    });

    test('round-trips true and false through the channel map', () {
      for (final value in [true, false]) {
        final map = InAppWebViewSettings(isLockdownModeEnabled: value).toMap();
        expect(map['isLockdownModeEnabled'], value);
        expect(InAppWebViewSettings.fromMap(map)?.isLockdownModeEnabled, value);
      }
    });

    test('capability metadata lists iOS and macOS only', () {
      bool supported(TargetPlatform platform) =>
          InAppWebViewSettings.isPropertySupported(
            InAppWebViewSettingsProperty.isLockdownModeEnabled,
            platform: platform,
          );
      expect(supported(TargetPlatform.iOS), isTrue);
      expect(supported(TargetPlatform.macOS), isTrue);
      expect(supported(TargetPlatform.android), isFalse);
      expect(supported(TargetPlatform.windows), isFalse);
      expect(supported(TargetPlatform.linux), isFalse);
    });
  });

  group('HTTPCookieStorePolicy', () {
    test('uses the native channel values', () {
      expect(HTTPCookieStorePolicy.ALLOW.toNativeValue(), 'allow');
      expect(HTTPCookieStorePolicy.DISALLOW.toNativeValue(), 'disallow');
      expect(
        HTTPCookieStorePolicy.fromNativeValue('disallow'),
        HTTPCookieStorePolicy.DISALLOW,
      );
    });

    test('maps unknown or missing native values to null', () {
      expect(HTTPCookieStorePolicy.fromNativeValue('blockThirdParty'), isNull);
      expect(HTTPCookieStorePolicy.fromNativeValue(null), isNull);
    });
  });
}
