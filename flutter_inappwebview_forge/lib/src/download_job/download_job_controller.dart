import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController}
///
///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.supported_platforms}
class DownloadJobController {
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.supported_platforms}
  DownloadJobController({required String id})
    : this.fromPlatformCreationParams(
        params: PlatformDownloadJobControllerCreationParams(id: id),
      );

  /// Constructs a [DownloadJobController].
  ///
  /// See [DownloadJobController.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  DownloadJobController.fromPlatformCreationParams({
    required PlatformDownloadJobControllerCreationParams params,
  }) : this.fromPlatform(platform: PlatformDownloadJobController(params));

  /// Constructs a [DownloadJobController] from a specific platform implementation.
  DownloadJobController.fromPlatform({required this.platform});

  /// Implementation of [PlatformDownloadJobController] for the current platform.
  final PlatformDownloadJobController platform;

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.id}
  String get id => platform.id;

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.onProgressChanged}
  DownloadJobProgressHandler? get onProgressChanged =>
      platform.onProgressChanged;

  set onProgressChanged(DownloadJobProgressHandler? handler) {
    platform.onProgressChanged = handler;
  }

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.onComplete}
  DownloadJobCompletionHandler? get onComplete => platform.onComplete;

  set onComplete(DownloadJobCompletionHandler? handler) {
    platform.onComplete = handler;
  }

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.cancel}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.cancel.supported_platforms}
  Future<void> cancel() => platform.cancel();

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.getInfo}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.getInfo.supported_platforms}
  Future<DownloadJobInfo?> getInfo() => platform.getInfo();

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.dispose}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.dispose.supported_platforms}
  void dispose() => platform.dispose();

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobControllerCreationParams.isClassSupported}
  static bool isClassSupported({TargetPlatform? platform}) =>
      const PlatformDownloadJobControllerCreationParams(
        id: '',
      ).isClassSupported(platform: platform);

  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.isMethodSupported}
  static bool isMethodSupported(
    PlatformDownloadJobControllerMethod method, {
    TargetPlatform? platform,
  }) => PlatformDownloadJobController.static().isMethodSupported(
    method,
    platform: platform,
  );
}
