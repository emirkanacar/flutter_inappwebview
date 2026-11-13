import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_macos/flutter_inappwebview_forge_macos.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

String _source(String fileName) {
  const relativePath =
      'macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos';
  return [
    File('$relativePath/$fileName'),
    File('flutter_inappwebview_forge_macos/$relativePath/$fileName'),
  ].firstWhere((file) => file.existsSync()).readAsStringSync();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_cookiemanager',
  );
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  Object? reply;

  setUp(() {
    calls.clear();
    reply = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return reply;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  MacOSCookieManager manager() =>
      MacOSCookieManager(const PlatformCookieManagerCreationParams());

  test('setCookiePolicy sends the native policy value', () async {
    reply = true;
    expect(
      await manager().setCookiePolicy(policy: HTTPCookieStorePolicy.DISALLOW),
      isTrue,
    );
    expect(calls.single.method, 'setCookiePolicy');
    expect(calls.single.arguments, {'policy': 'disallow'});
  });

  test('setCookiePolicy maps a null native reply to false', () async {
    reply = null;
    expect(
      await manager().setCookiePolicy(policy: HTTPCookieStorePolicy.ALLOW),
      isFalse,
    );
  });

  test('getCookiePolicy maps native values and unknown values', () async {
    reply = 'allow';
    expect(await manager().getCookiePolicy(), HTTPCookieStorePolicy.ALLOW);
    expect(calls.single.method, 'getCookiePolicy');
    reply = 'somethingNew';
    expect(await manager().getCookiePolicy(), isNull);
    reply = null;
    expect(await manager().getCookiePolicy(), isNull);
  });

  test('cookie policy capability metadata includes macOS', () {
    final m = manager();
    for (final method in [
      PlatformCookieManagerMethod.setCookiePolicy,
      PlatformCookieManagerMethod.getCookiePolicy,
    ]) {
      expect(
        m.isMethodSupported(method, platform: TargetPlatform.macOS),
        isTrue,
      );
      expect(
        m.isMethodSupported(method, platform: TargetPlatform.android),
        isFalse,
      );
    }
  });

  test(
    'native lockdown setting is parsed, reported, and applied per navigation',
    () {
      final settings = _source('InAppWebView/InAppWebViewSettings.swift');
      expect(settings, contains('var isLockdownModeEnabled: Bool? = nil'));
      expect(
        settings,
        contains(
          'isLockdownModeEnabled = settings["isLockdownModeEnabled"] as? Bool',
        ),
      );
      expect(
        settings,
        contains(
          'realSettings["isLockdownModeEnabled"] = isLockdownModeEnabled',
        ),
      );
      final webView = _source('InAppWebView/InAppWebView.swift');
      expect(webView, contains('applyLockdownMode(to: preferences)'));
      expect(
        webView,
        contains(
          'applyLockdownMode(to: configuration.defaultWebpagePreferences)',
        ),
      );
    },
  );

  test(
    'native cookie policy handlers guard availability and unknown values',
    () {
      final source = _source('MyCookieManager.swift');
      expect(source, contains('case "setCookiePolicy":'));
      expect(source, contains('case "getCookiePolicy":'));
      expect(source, contains('@unknown default:'));
      expect(source, contains('Unknown cookie policy'));
    },
  );
}
