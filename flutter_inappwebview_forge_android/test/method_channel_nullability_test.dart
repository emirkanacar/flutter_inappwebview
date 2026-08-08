import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'nullable and malformed Android event fields do not abort the event dispatcher',
    () async {
      ContextMenuItem? contextMenuItem;
      var geolocationPromptCalled = false;
      var safeBrowsingCalled = false;
      var permissionRequestCalled = false;

      final controller = AndroidInAppWebViewController(
        AndroidInAppWebViewControllerCreationParams(
          id: 1,
          webviewParams: PlatformWebViewCreationParams(
            contextMenu: ContextMenu(
              onContextMenuActionItemClicked: (item) {
                contextMenuItem = item;
              },
            ),
            onGeolocationPermissionsShowPrompt: (_, __) async {
              geolocationPromptCalled = true;
              return null;
            },
            onSafeBrowsingHit: (_, __, ___) async {
              safeBrowsingCalled = true;
              return null;
            },
            onPermissionRequest: (_, __) async {
              permissionRequestCalled = true;
              return null;
            },
          ),
        ),
      );

      await controller.handler!(
        const MethodCall('onContextMenuActionItemClicked', {
          'id': 1,
          'title': null,
        }),
      );
      await controller.handler!(
        const MethodCall('onContextMenuActionItemClicked', {
          'id': 1,
          'title': 42,
        }),
      );
      await controller.handler!(
        const MethodCall('onGeolocationPermissionsShowPrompt', {
          'origin': null,
        }),
      );
      await controller.handler!(
        const MethodCall('onGeolocationPermissionsShowPrompt', {'origin': 42}),
      );
      await controller.handler!(
        const MethodCall('onSafeBrowsingHit', {'url': null, 'threatType': 0}),
      );
      await controller.handler!(
        const MethodCall('onSafeBrowsingHit', {'url': 42, 'threatType': 0}),
      );
      await controller.handler!(
        const MethodCall('onPermissionRequest', {
          'origin': null,
          'resources': null,
        }),
      );
      await controller.handler!(
        const MethodCall('onPermissionRequest', {
          'origin': 42,
          'resources': [null, 7],
        }),
      );
      await controller.handler!(
        const MethodCall('onInjectedScriptLoaded', [null]),
      );
      await controller.handler!(
        const MethodCall('onInjectedScriptLoaded', [42]),
      );
      await controller.handler!(
        const MethodCall('onInjectedScriptError', [null]),
      );
      await controller.handler!(
        const MethodCall('onInjectedScriptError', [42]),
      );

      expect(contextMenuItem?.title, '');
      expect(geolocationPromptCalled, isFalse);
      expect(safeBrowsingCalled, isFalse);
      expect(permissionRequestCalled, isFalse);
    },
  );
}
