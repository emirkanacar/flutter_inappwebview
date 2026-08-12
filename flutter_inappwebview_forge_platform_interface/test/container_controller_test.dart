import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

class _TestContainerController extends PlatformContainerController {
  _TestContainerController()
    : super.implementation(const PlatformContainerControllerCreationParams());
}

class _TestInAppWebViewPlatform extends InAppWebViewPlatform {
  @override
  PlatformContainerController createPlatformContainerControllerStatic() {
    return _TestContainerController();
  }
}

void main() {
  test('containerId is included in settings serialization', () {
    final settings = InAppWebViewSettings(containerId: 'account-a');

    expect(settings.toMap()['containerId'], 'account-a');
    expect(settings.copy().containerId, 'account-a');
  });

  test('proxySettings is included in settings serialization', () {
    final settings = InAppWebViewSettings(
      proxySettings: ProxySettings(
        proxyRules: [ProxyRule(url: 'http://127.0.0.1:8080')],
      ),
    );

    expect(
      settings.toMap()['proxySettings'],
      containsPair('proxyRules', isA<List<dynamic>>()),
    );
    expect(
      settings.copy().proxySettings?.proxyRules.single.url,
      'http://127.0.0.1:8080',
    );
  });

  test('proxySettings is supported only on Apple WebKit platforms', () {
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.proxySettings,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.proxySettings,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });

  test('container capability metadata covers Android and iOS', () {
    const params = PlatformContainerControllerCreationParams();

    expect(params.isClassSupported(platform: TargetPlatform.android), isTrue);
    expect(params.isClassSupported(platform: TargetPlatform.iOS), isTrue);
    expect(params.isClassSupported(platform: TargetPlatform.linux), isFalse);
  });

  test('clearContainerData capability covers Android and iOS', () {
    InAppWebViewPlatform.instance = _TestInAppWebViewPlatform();

    expect(
      PlatformContainerController.static().isMethodSupported(
        PlatformContainerControllerMethod.clearContainerData,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      PlatformContainerController.static().isMethodSupported(
        PlatformContainerControllerMethod.clearContainerData,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
  });
}
