import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:flutter_inappwebview_forge_example/providers/settings_manager.dart';

/// Lightweight settings manager for widget tests.
class TestSettingsManager extends SettingsManager {
  TestSettingsManager()
    : super(
        environmentFactory: (_) async => null,
        environmentSupportChecker: () => false,
      );

  @override
  Future<void> init() async {}

  @override
  InAppWebViewSettings buildSettings() => InAppWebViewSettings();

  @override
  WebViewEnvironmentSettings buildEnvironmentSettings() =>
      WebViewEnvironmentSettings(
        releaseChannels: EnvironmentReleaseChannels.STABLE,
      );

  @override
  WebViewEnvironment? get webViewEnvironment => null;

  @override
  int get environmentRevision => 0;

  @override
  int get settingsRevision => 0;
}
