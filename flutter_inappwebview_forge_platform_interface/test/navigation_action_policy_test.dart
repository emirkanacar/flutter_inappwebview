import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  setUpAll(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDownAll(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('Universal Link policy maps to the WebKit raw value on iOS', () {
    final policy = NavigationActionPolicy.ALLOW_WITHOUT_TRYING_APP_LINK;

    expect(policy.toValue(), 3);
    expect(policy.name(), 'ALLOW_WITHOUT_TRYING_APP_LINK');
    expect(policy.toNativeValue(), 3);
    expect(NavigationActionPolicy.fromValue(3), same(policy));
    expect(NavigationActionPolicy.values, contains(policy));
  });
}
