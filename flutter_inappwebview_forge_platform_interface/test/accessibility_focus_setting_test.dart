import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  test('enableAccessibilityFocus defaults to false and round-trips', () {
    expect(InAppWebViewSettings().enableAccessibilityFocus, isFalse);
    expect(
      InAppWebViewSettings().toMap()['enableAccessibilityFocus'],
      isFalse,
    );
    final settings = InAppWebViewSettings.fromMap({
      'enableAccessibilityFocus': true,
    });
    expect(settings?.enableAccessibilityFocus, isTrue);
    expect(settings?.toMap()['enableAccessibilityFocus'], isTrue);
  });

  test('enableAccessibilityFocus is supported on macOS and Windows only', () {
    for (final platform in TargetPlatform.values) {
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.enableAccessibilityFocus,
          platform: platform,
        ),
        platform == TargetPlatform.macOS || platform == TargetPlatform.windows,
        reason: platform.name,
      );
    }
  });
}
