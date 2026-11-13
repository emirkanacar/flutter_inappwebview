import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_macos/flutter_inappwebview_forge_macos.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_webstoragemanager',
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

  MacOSWebStorageManager manager() =>
      MacOSWebStorageManager(const PlatformWebStorageManagerCreationParams());

  test('deleteBrowsingData forwards the native result', () async {
    reply = true;
    expect(await manager().deleteBrowsingData(), isTrue);
    expect(calls.single.method, 'deleteBrowsingData');
  });

  test('deleteBrowsingData maps a null native reply to false', () async {
    reply = null;
    expect(await manager().deleteBrowsingData(), isFalse);
  });

  test(
    'deleteBrowsingDataForSite sends the site and returns the computed site',
    () async {
      reply = 'example.com';
      final site = await manager().deleteBrowsingDataForSite(
        site: 'https://www.example.com/path',
      );
      expect(site, 'example.com');
      expect(calls.single.method, 'deleteBrowsingDataForSite');
      expect(calls.single.arguments, {'site': 'https://www.example.com/path'});
    },
  );

  test('deleteBrowsingDataForSite returns null when unsupported', () async {
    reply = null;
    expect(
      await manager().deleteBrowsingDataForSite(site: 'example.com'),
      isNull,
    );
  });

  test(
    'capability metadata lists macos, Linux, and Windows (full data only)',
    () {
      final m = manager();
      for (final method in [
        PlatformWebStorageManagerMethod.deleteBrowsingData,
        PlatformWebStorageManagerMethod.deleteBrowsingDataForSite,
      ]) {
        expect(
          m.isMethodSupported(method, platform: TargetPlatform.macOS),
          isTrue,
        );
        expect(
          m.isMethodSupported(method, platform: TargetPlatform.windows),
          method == PlatformWebStorageManagerMethod.deleteBrowsingData,
        );
        expect(
          m.isMethodSupported(method, platform: TargetPlatform.linux),
          isTrue,
        );
      }
    },
  );
  test('removeDataModifiedSince sends milliseconds since epoch', () async {
    final date = DateTime.utc(2026, 1, 2, 3, 4, 5, 678);
    await manager().removeDataModifiedSince(
      dataTypes: {WebsiteDataType.WKWebsiteDataTypeCookies},
      date: date,
    );
    expect(calls.single.method, 'removeDataModifiedSince');
    expect(
      (calls.single.arguments as Map)['timestamp'],
      date.millisecondsSinceEpoch,
    );
  });

  test('native removeDataModifiedSince reads the timestamp as milliseconds', () {
    const relativePath =
        'macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos/MyWebStorageManager.swift';
    final file = [
      File(relativePath),
      File('flutter_inappwebview_forge_macos/$relativePath'),
    ].firstWhere((f) => f.existsSync());
    final source = file.readAsStringSync();
    expect(
      source,
      contains('timeIntervalSince1970: TimeInterval(timestamp) / 1000.0'),
    );
  });
}
