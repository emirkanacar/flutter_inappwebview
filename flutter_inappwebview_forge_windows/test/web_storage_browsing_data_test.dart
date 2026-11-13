import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_inappwebview_forge_windows/flutter_inappwebview_forge_windows.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_windows/$relativePath'),
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

  test('the Windows platform creates a WindowsWebStorageManager', () {
    final platform = WindowsInAppWebViewPlatform();
    expect(
      platform.createPlatformWebStorageManager(
        const PlatformWebStorageManagerCreationParams(),
      ),
      isA<WindowsWebStorageManager>(),
    );
    expect(
      platform.createPlatformWebStorageManagerStatic(),
      isA<WindowsWebStorageManager>(),
    );
  });

  test('deleteBrowsingData forwards the native result', () async {
    reply = true;
    expect(
      await WindowsWebStorageManager.instance().deleteBrowsingData(),
      isTrue,
    );
    expect(calls.single.method, 'deleteBrowsingData');
  });

  test('deleteBrowsingData maps a null native reply to false', () async {
    reply = null;
    expect(
      await WindowsWebStorageManager.instance().deleteBrowsingData(),
      isFalse,
    );
  });

  test('capability metadata lists Windows for deleteBrowsingData only', () {
    final m = WindowsWebStorageManager.static();
    expect(m.isClassSupported(platform: TargetPlatform.windows), isTrue);
    expect(
      m.isMethodSupported(
        PlatformWebStorageManagerMethod.deleteBrowsingData,
        platform: TargetPlatform.windows,
      ),
      isTrue,
    );
    for (final method in [
      PlatformWebStorageManagerMethod.deleteBrowsingDataForSite,
      PlatformWebStorageManagerMethod.fetchDataRecords,
      PlatformWebStorageManagerMethod.removeDataFor,
      PlatformWebStorageManagerMethod.removeDataModifiedSince,
    ]) {
      expect(
        m.isMethodSupported(method, platform: TargetPlatform.windows),
        isFalse,
      );
    }
  });

  test('native handler clears the profile through ICoreWebView2Profile2', () {
    final source = _sourceFile(
      'windows/web_storage_manager.cpp',
    ).readAsStringSync();
    final plugin = _sourceFile(
      'windows/flutter_inappwebview_windows_plugin.cpp',
    ).readAsStringSync();
    final cmake = _sourceFile('windows/CMakeLists.txt').readAsStringSync();
    expect(source, contains('"deleteBrowsingData"'));
    expect(source, contains('try_query<ICoreWebView2_13>()'));
    expect(source, contains('try_query<ICoreWebView2Profile2>()'));
    expect(source, contains('ClearBrowsingDataAll'));
    expect(plugin, contains('std::make_unique<WebStorageManager>(this)'));
    expect(cmake, contains('"web_storage_manager.cpp"'));
  });
}
