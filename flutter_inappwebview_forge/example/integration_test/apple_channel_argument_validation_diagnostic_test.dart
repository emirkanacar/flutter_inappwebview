import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_APPLE_CHANNEL_ARGUMENT_VALIDATION_DIAGNOSTIC',
);

const _cookieChannel = MethodChannel(
  'com.emirkanacar/flutter_inappwebview_cookiemanager',
);

Matcher _invalidArguments(String method, String key) => isA<PlatformException>()
    .having((e) => e.code, 'code', 'invalid_arguments')
    .having((e) => e.message, 'message', contains(method))
    .having((e) => e.message, 'message', contains("'$key'"));

// Opt-in runtime check for the iOS/macOS method-channel argument hardening.
// A malformed call must complete with an `invalid_arguments` FlutterError
// instead of crashing the process on a force-unwrapped argument, and the
// channel must keep working for well-formed calls afterwards.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final skip = !_runDiagnostic || !(Platform.isIOS || Platform.isMacOS);

  testWidgets('Apple malformed channel arguments return invalid_arguments', (
    WidgetTester tester,
  ) async {
    // Make sure the plugin channels are registered.
    final cookieManager = CookieManager.instance();

    // Missing required argument.
    await expectLater(
      _cookieChannel.invokeMethod('setCookie', {'url': 'https://example.com/'}),
      throwsA(_invalidArguments('setCookie', 'name')),
    );

    // Required argument with the wrong type.
    await expectLater(
      _cookieChannel.invokeMethod('setCookie', {
        'url': 42,
        'name': 'n',
        'value': 'v',
        'path': '/',
      }),
      throwsA(_invalidArguments('setCookie', 'url')),
    );

    // No arguments at all.
    await expectLater(
      _cookieChannel.invokeMethod('getCookies'),
      throwsA(_invalidArguments('getCookies', 'url')),
    );

    // The channel still serves well-formed calls after the rejected ones.
    final url = WebUri('https://example.com/');
    expect(
      await cookieManager.setCookie(
        url: url,
        name: 'forge_channel_check',
        value: 'ok',
      ),
      isTrue,
    );
    final cookie = await cookieManager.getCookie(
      url: url,
      name: 'forge_channel_check',
    );
    expect(cookie?.value, 'ok');
    await cookieManager.deleteCookie(url: url, name: 'forge_channel_check');
  }, skip: skip);
}
