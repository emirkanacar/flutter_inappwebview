import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../inappwebview_platform.dart';
import '../types/disposable.dart';
import 'download_job_info.dart';

part 'platform_download_job_controller.g.dart';

/// Object specifying creation parameters for creating a [PlatformDownloadJobController].
@SupportedPlatforms(
  platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform(), WindowsPlatform()],
)
@immutable
class PlatformDownloadJobControllerCreationParams {
  /// Used by the platform implementation to create a new [PlatformDownloadJobController].
  const PlatformDownloadJobControllerCreationParams({required this.id});

  ///Download job ID.
  @SupportedPlatforms(
    platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform(), WindowsPlatform()],
  )
  final String id;

  ///Check if the current class is supported by the [defaultTargetPlatform] or a specific [platform].
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformDownloadJobControllerCreationParamsClassSupported
          .isClassSupported(platform: platform);

  ///Check if the given [property] is supported by the [defaultTargetPlatform] or a specific [platform].
  bool isPropertySupported(
    PlatformDownloadJobControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) => _PlatformDownloadJobControllerCreationParamsPropertySupported
      .isPropertySupported(property, platform: platform);
}

///Completion handler for a [PlatformDownloadJobController].
typedef DownloadJobCompletionHandler =
    Future<void> Function(bool completed, String? error)?;

///Progress handler for a [PlatformDownloadJobController].
typedef DownloadJobProgressHandler = Future<void> Function(double progress)?;

///Controller for a native WebView download started from [onDownloadStarting].
///
///Returning a [DownloadStartResponse] with [DownloadStartResponse.resultFilePath]
///from `onDownloadStarting` starts a native job. The previous notify-only
///default (a `null` response) is unchanged.
@SupportedPlatforms(
  platforms: [AndroidPlatform(), IOSPlatform(), MacOSPlatform(), WindowsPlatform()],
)
abstract class PlatformDownloadJobController extends PlatformInterface
    implements Disposable {
  /// Creates a new [PlatformDownloadJobController].
  factory PlatformDownloadJobController(
    PlatformDownloadJobControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview_forge` has not been set.',
    );
    final PlatformDownloadJobController controller = InAppWebViewPlatform
        .instance!
        .createPlatformDownloadJobController(params);
    PlatformInterface.verify(controller, _token);
    return controller;
  }

  /// Creates a new empty [PlatformDownloadJobController] to access static methods.
  factory PlatformDownloadJobController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview_forge` has not been set.',
    );
    final PlatformDownloadJobController controller = InAppWebViewPlatform
        .instance!
        .createPlatformDownloadJobControllerStatic();
    PlatformInterface.verify(controller, _token);
    return controller;
  }

  /// Used by the platform implementation to create a new [PlatformDownloadJobController].
  @protected
  PlatformDownloadJobController.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The parameters used to initialize the [PlatformDownloadJobController].
  final PlatformDownloadJobControllerCreationParams params;

  ///Download job ID.
  String get id => params.id;

  ///Called when transfer progress changes.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  DownloadJobProgressHandler? onProgressChanged;

  ///Called when the job completes, fails, or is canceled.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  DownloadJobCompletionHandler? onComplete;

  ///Cancels the native download.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(available: '14.5'),
      MacOSPlatform(available: '11.3'),
      WindowsPlatform(),
    ],
  )
  Future<void> cancel() {
    throw UnimplementedError(
      'cancel is not implemented on the current platform',
    );
  }

  ///Returns a snapshot of the current job.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  Future<DownloadJobInfo?> getInfo() {
    throw UnimplementedError(
      'getInfo is not implemented on the current platform',
    );
  }

  ///Check if the given [method] is supported.
  bool isMethodSupported(
    PlatformDownloadJobControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformDownloadJobControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );

  @override
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(),
      IOSPlatform(),
      MacOSPlatform(),
      WindowsPlatform(),
    ],
  )
  void dispose() {
    throw UnimplementedError(
      'dispose is not implemented on the current platform',
    );
  }
}
