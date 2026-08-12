import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  test('containerId is included in settings serialization', () {
    final settings = InAppWebViewSettings(containerId: 'account-a');

    expect(settings.toMap()['containerId'], 'account-a');
    expect(settings.copy().containerId, 'account-a');
  });

  test('container capability metadata covers Android and iOS', () {
    const params = PlatformContainerControllerCreationParams();

    expect(params.isClassSupported(platform: TargetPlatform.android), isTrue);
    expect(params.isClassSupported(platform: TargetPlatform.iOS), isTrue);
    expect(params.isClassSupported(platform: TargetPlatform.linux), isFalse);
  });
}
