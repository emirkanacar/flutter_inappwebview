import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Manages persistent WebView storage containers.
///
/// A WebView joins a container through [InAppWebViewSettings.containerId] at
/// construction time. Container data is kept separate from the default
/// WebView profile.
class ContainerController {
  /// Creates a controller for the current platform.
  ContainerController()
    : this.fromPlatformCreationParams(
        const PlatformContainerControllerCreationParams(),
      );

  /// Creates a controller from platform-specific creation parameters.
  ContainerController.fromPlatformCreationParams(
    PlatformContainerControllerCreationParams params,
  ) : this.fromPlatform(PlatformContainerController(params));

  /// Creates a controller from a platform implementation.
  ContainerController.fromPlatform(this.platform);

  /// The platform implementation used by this controller.
  final PlatformContainerController platform;

  static ContainerController? _instance;

  /// Gets the shared controller instance.
  static ContainerController instance() {
    return _instance ??= ContainerController();
  }

  /// Returns all named persistent containers.
  Future<List<String>> getAllContainerNames() =>
      platform.getAllContainerNames();

  /// Returns whether [containerId] exists.
  Future<bool> hasContainer(String containerId) =>
      platform.hasContainer(containerId);

  /// Deletes [containerId] when it is not in use.
  Future<bool> deleteContainer(String containerId) =>
      platform.deleteContainer(containerId);

  /// Clears data in [containerId] without removing the container.
  Future<bool> clearContainerData(String containerId) =>
      platform.clearContainerData(containerId);

  /// Checks whether this API is available on [platform].
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformContainerController.static().isClassSupported(platform: platform);

  /// Checks whether [method] is available on [platform].
  static bool isMethodSupported(
    PlatformContainerControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformContainerController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
