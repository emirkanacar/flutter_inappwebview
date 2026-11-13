import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_containercontroller',
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

  AndroidContainerController controller() => AndroidContainerController(
    const PlatformContainerControllerCreationParams(),
  );

  test('warmUpRendererProcess sends the container id', () async {
    reply = true;
    expect(
      await controller().warmUpRendererProcess(containerId: 'profile-a'),
      isTrue,
    );
    expect(calls.single.method, 'warmUpRendererProcess');
    expect(calls.single.arguments, {'containerId': 'profile-a'});
  });

  test('warmUpRendererProcess maps a null native reply to false', () async {
    reply = null;
    expect(
      await controller().warmUpRendererProcess(containerId: 'profile-a'),
      isFalse,
    );
  });

  test('capability metadata is Android only', () {
    final c = controller();
    expect(
      c.isMethodSupported(
        PlatformContainerControllerMethod.warmUpRendererProcess,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      c.isMethodSupported(
        PlatformContainerControllerMethod.warmUpRendererProcess,
        platform: TargetPlatform.iOS,
      ),
      isFalse,
    );
    expect(
      WebViewFeature.WARM_UP_RENDERER_PROCESS.toNativeValue(),
      'WARM_UP_RENDERER_PROCESS',
    );
  });

  test('native handler gates on the feature and avoids opt-in APIs', () {
    final source = File(
      'android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/'
      'container/ContainerManager.kt',
    ).readAsStringSync();
    expect(source, contains('"warmUpRendererProcess" ->'));
    expect(
      source,
      contains('WebViewFeature.isFeatureSupported("WARM_UP_RENDERER_PROCESS")'),
    );
    expect(source, isNot(contains('ExperimentalWarmUpRendererProcess')));
  });
}
