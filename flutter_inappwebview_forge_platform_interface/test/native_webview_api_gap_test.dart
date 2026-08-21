import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  test('audio mute and visual-state settings serialize', () {
    final settings = InAppWebViewSettings(
      allowsInlinePredictions: true,
      backForwardCacheEnabled: true,
      obscuredContentInsets: const EdgeInsets.fromLTRB(1, 2, 3, 4),
    );

    expect(settings.toMap()['allowsInlinePredictions'], isTrue);
    expect(settings.toMap()['backForwardCacheEnabled'], isTrue);
    expect(
      settings.toMap()['obscuredContentInsets'],
      containsPair('top', 2.0),
    );
    expect(settings.copy().allowsInlinePredictions, isTrue);
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.allowsInlinePredictions,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.backForwardCacheEnabled,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.obscuredContentInsets,
        platform: TargetPlatform.iOS,
      ),
      isTrue,
    );
  });

  test('WebViewFeature constants cover mute, navigation, and profile APIs', () {
    expect(WebViewFeature.MUTE_AUDIO.toNativeValue(), 'MUTE_AUDIO');
    expect(
      WebViewFeature.NAVIGATION_LISTENER.toNativeValue(),
      'NAVIGATION_LISTENER',
    );
    expect(WebViewFeature.PRERENDER_URL.toNativeValue(), 'PRERENDER_URL');
    expect(
      WebViewFeature.PROFILE_URL_PREFETCH.toNativeValue(),
      'PROFILE_URL_PREFETCH',
    );
    expect(
      WebViewFeature.CUSTOM_REQUEST_HEADERS.toNativeValue(),
      'CUSTOM_REQUEST_HEADERS',
    );
    expect(
      WebViewFeature.BACK_FORWARD_CACHE.toNativeValue(),
      'BACK_FORWARD_CACHE',
    );
  });

  test('DownloadStartResponse is opt-in on Android, iOS, and macOS', () {
    final response = DownloadStartResponse(
      handled: true,
      action: DownloadStartResponseAction.DOWNLOAD,
      resultFilePath: '/tmp/file.bin',
    );

    expect(response.toMap()['handled'], isTrue);
    expect(response.toMap()['resultFilePath'], '/tmp/file.bin');
    expect(DownloadStartResponseAction.DOWNLOAD.toNativeValue(), 1);
    expect(
      const PlatformDownloadJobControllerCreationParams(
        id: 'job',
      ).isClassSupported(platform: TargetPlatform.android),
      isTrue,
    );
    expect(
      const PlatformDownloadJobControllerCreationParams(
        id: 'job',
      ).isClassSupported(platform: TargetPlatform.iOS),
      isTrue,
    );
    expect(
      const PlatformDownloadJobControllerCreationParams(
        id: 'job',
      ).isClassSupported(platform: TargetPlatform.macOS),
      isTrue,
    );
    expect(
      const PlatformDownloadJobControllerCreationParams(
        id: 'job',
      ).isClassSupported(platform: TargetPlatform.windows),
      isFalse,
    );
  });
}
