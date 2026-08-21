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
      conversationContext: const {
        'type': 'message',
        'threadIdentifier': 'thread-1',
        'selfIdentifiers': ['me'],
        'responsePrimaryRecipientIdentifiers': ['them'],
        'entries': [
          {
            'text': 'Hello',
            'senderIdentifier': 'them',
            'entryIdentifier': 'e1',
          },
        ],
      },
    );

    expect(settings.toMap()['allowsInlinePredictions'], isTrue);
    expect(settings.toMap()['backForwardCacheEnabled'], isTrue);
    expect(
      settings.toMap()['obscuredContentInsets'],
      containsPair('top', 2.0),
    );
    expect(
      settings.toMap()['conversationContext'],
      containsPair('threadIdentifier', 'thread-1'),
    );
    expect(
      InAppWebViewSettings.fromMap(settings.toMap())?.conversationContext,
      containsPair('type', 'message'),
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
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.conversationContext,
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
    expect(WebViewFeature.PRECONNECT.toNativeValue(), 'PRECONNECT');
    expect(
      WebViewFeature.BACK_FORWARD_CACHE_SETTINGS.toNativeValue(),
      'BACK_FORWARD_CACHE_SETTINGS',
    );
    expect(WebViewFeature.WEBVIEW_BUILDER.toNativeValue(), 'WEBVIEW_BUILDER');
  });

  test('BFCache depth and WebViewBuilder settings serialize on Android', () {
    final settings = InAppWebViewSettings(
      backForwardCacheTimeoutSeconds: 30,
      backForwardCacheMaxPagesInCache: 3,
      useWebViewBuilder: true,
      webViewBuilderOriginAllowList: {'https://example.com'},
    );
    final map = settings.toMap();
    expect(map['backForwardCacheTimeoutSeconds'], 30);
    expect(map['backForwardCacheMaxPagesInCache'], 3);
    expect(map['useWebViewBuilder'], isTrue);
    expect(map['webViewBuilderOriginAllowList'], contains('https://example.com'));
    expect(
      InAppWebViewSettings.isPropertySupported(
        InAppWebViewSettingsProperty.useWebViewBuilder,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      PlatformContainerControllerMethod.preconnect,
      isNotNull,
    );
  });

  test('DownloadStartResponse is opt-in on Android, iOS, macOS, and Windows', () {
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
      isTrue,
    );
  });
}
