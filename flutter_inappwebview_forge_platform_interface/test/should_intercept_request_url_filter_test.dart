import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  group('shouldInterceptRequestUrlFilter', () {
    test('defaults to an empty list so every request is intercepted', () {
      final settings = InAppWebViewSettings();
      expect(settings.shouldInterceptRequestUrlFilter, isEmpty);
      expect(settings.toMap()['shouldInterceptRequestUrlFilter'], isEmpty);
    });

    test('round-trips through the channel map and copy', () {
      const patterns = [r'^https://api\.example\.com/', r'\.json(\?|$)'];
      final settings = InAppWebViewSettings(
        shouldInterceptRequestUrlFilter: patterns,
      );
      final map = settings.toMap();
      expect(map['shouldInterceptRequestUrlFilter'], patterns);
      expect(
        InAppWebViewSettings.fromMap(map)?.shouldInterceptRequestUrlFilter,
        patterns,
      );
      expect(settings.copy().shouldInterceptRequestUrlFilter, patterns);
    });

    test('capability metadata lists Android only', () {
      bool supported(TargetPlatform platform) =>
          InAppWebViewSettings.isPropertySupported(
            InAppWebViewSettingsProperty.shouldInterceptRequestUrlFilter,
            platform: platform,
          );
      expect(supported(TargetPlatform.android), isTrue);
      expect(supported(TargetPlatform.iOS), isFalse);
      expect(supported(TargetPlatform.macOS), isFalse);
      expect(supported(TargetPlatform.windows), isFalse);
      expect(supported(TargetPlatform.linux), isFalse);
    });
  });
}
