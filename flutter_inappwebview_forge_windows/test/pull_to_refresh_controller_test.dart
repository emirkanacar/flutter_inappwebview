import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_inappwebview_forge_windows/src/pull_to_refresh_controller.dart';

void main() {
  test(
    'Windows pull-to-refresh controller completes its callback lifecycle',
    () async {
      var refreshCount = 0;
      final controller = WindowsPullToRefreshController(
        PlatformPullToRefreshControllerCreationParams(
          settings: PullToRefreshSettings(allowWithNoScrollbar: true),
          onRefresh: () => refreshCount++,
        ),
      );

      expect(controller.allowWithNoScrollbar, isTrue);
      expect(await controller.isEnabled(), isTrue);

      controller.triggerRefresh();

      expect(refreshCount, 1);
      expect(await controller.isRefreshing(), isTrue);

      await controller.endRefreshing();
      expect(await controller.isRefreshing(), isFalse);
      controller.dispose();
    },
  );
}
