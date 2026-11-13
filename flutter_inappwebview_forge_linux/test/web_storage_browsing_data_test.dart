import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_linux/flutter_inappwebview_forge_linux.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_linux/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

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

  LinuxWebStorageManager manager() =>
      LinuxWebStorageManager(const PlatformWebStorageManagerCreationParams());

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

  test('deleteBrowsingDataForSite returns null for a null reply', () async {
    reply = null;
    expect(
      await manager().deleteBrowsingDataForSite(site: 'example.com'),
      isNull,
    );
  });

  test('capability metadata lists Linux', () {
    final m = manager();
    for (final method in [
      PlatformWebStorageManagerMethod.deleteBrowsingData,
      PlatformWebStorageManagerMethod.deleteBrowsingDataForSite,
    ]) {
      expect(
        m.isMethodSupported(method, platform: TargetPlatform.linux),
        isTrue,
      );
    }
  });

  test('native handler clears all data kinds and uses the site matcher', () {
    final source = _sourceFile(
      'linux/web_storage_manager.cc',
    ).readAsStringSync();
    final cmake = _sourceFile('linux/CMakeLists.txt').readAsStringSync();
    expect(source, contains('"deleteBrowsingData"'));
    expect(source, contains('"deleteBrowsingDataForSite"'));
    expect(source, contains('WEBKIT_WEBSITE_DATA_ALL'));
    expect(source, contains('WebsiteDataSiteMatcher::normalizedHost'));
    expect(source, contains('WebsiteDataSiteMatcher::matchingNames'));
    expect(cmake, contains('"utils/website_data_site_matcher.cc"'));
  });
}
