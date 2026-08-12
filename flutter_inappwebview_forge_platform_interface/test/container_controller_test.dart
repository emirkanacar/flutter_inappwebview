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
    for (final platform in <TargetPlatform>[
      TargetPlatform.android,
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.containerId,
          platform: platform,
        ),
        isTrue,
      );
    }
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

  test('proxySettings capability covers supported platforms', () {
    for (final platform in <TargetPlatform>[
      TargetPlatform.iOS,
      TargetPlatform.macOS,
      TargetPlatform.linux,
      TargetPlatform.windows,
    ]) {
      expect(
        InAppWebViewSettings.isPropertySupported(
          InAppWebViewSettingsProperty.proxySettings,
          platform: platform,
        ),
        isTrue,
      );
    }
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.proxySettings,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });

  test('container capability metadata covers supported platforms', () {
    const params = PlatformContainerControllerCreationParams();

    expect(params.isClassSupported(platform: TargetPlatform.android), isTrue);
    expect(params.isClassSupported(platform: TargetPlatform.iOS), isTrue);
    for (final platform in <TargetPlatform>[
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      expect(params.isClassSupported(platform: platform), isTrue);
    }
  });

  test('clearContainerData capability covers supported platforms', () {
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
    for (final platform in <TargetPlatform>[
      TargetPlatform.macOS,
      TargetPlatform.windows,
      TargetPlatform.linux,
    ]) {
      expect(
        PlatformContainerController.static().isMethodSupported(
          PlatformContainerControllerMethod.clearContainerData,
          platform: platform,
        ),
        isTrue,
      );
    }
  });

  test('Windows pull-to-refresh no-scrollbar setting is serialized', () {
    final settings = PullToRefreshSettings(allowWithNoScrollbar: true);

    expect(settings.toMap()['allowWithNoScrollbar'], isTrue);
    expect(settings.copy().allowWithNoScrollbar, isTrue);
    expect(
      PullToRefreshSettings.isPropertySupported(
        PullToRefreshSettingsProperty.allowWithNoScrollbar,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
    expect(
      PullToRefreshSettings.isPropertySupported(
        PullToRefreshSettingsProperty.allowWithNoScrollbar,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
    expect(
      PlatformPullToRefreshControllerCreationParams().isClassSupported(
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
  });

  test('iOS Writing Tools behavior is serialized and capability-gated', () {
    final settings = InAppWebViewSettings(
      writingToolsBehavior: IOSWritingToolsBehavior.COMPLETE,
    );

    expect(settings.toMap()['writingToolsBehavior'], 1);
    expect(
      settings.copy().writingToolsBehavior,
      IOSWritingToolsBehavior.COMPLETE,
    );
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.writingToolsBehavior,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.writingToolsBehavior,
        platform: TargetPlatform.android,
      ),
      isFalse,
    );
  });
}
