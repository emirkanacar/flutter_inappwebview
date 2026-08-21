import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [MacOSDownloadJobController].
@immutable
class MacOSDownloadJobControllerCreationParams
    extends PlatformDownloadJobControllerCreationParams {
  /// Creates macOS download job parameters.
  const MacOSDownloadJobControllerCreationParams({required super.id});

  /// Creates macOS parameters from common parameters.
  factory MacOSDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
    PlatformDownloadJobControllerCreationParams params,
  ) {
    return MacOSDownloadJobControllerCreationParams(id: params.id);
  }
}

/// macOS implementation of [PlatformDownloadJobController].
class MacOSDownloadJobController extends PlatformDownloadJobController
    with ChannelController {
  /// Creates a macOS download job controller.
  MacOSDownloadJobController(PlatformDownloadJobControllerCreationParams params)
    : super.implementation(
        params is MacOSDownloadJobControllerCreationParams
            ? params
            : MacOSDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel(
      'com.emirkanacar/flutter_inappwebview_downloadjobcontroller_${params.id}',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static final MacOSDownloadJobController _staticValue =
      MacOSDownloadJobController(
        const MacOSDownloadJobControllerCreationParams(id: ''),
      );

  /// Provides static access.
  factory MacOSDownloadJobController.static() => _staticValue;

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onProgressChanged':
        final progress = (call.arguments['progress'] as num?)?.toDouble() ?? 0;
        await onProgressChanged?.call(progress);
        break;
      case 'onComplete':
        await onComplete?.call(
          call.arguments['completed'] == true,
          call.arguments['error'] as String?,
        );
        break;
      default:
        throw UnimplementedError('Unimplemented ${call.method} method');
    }
  }

  @override
  Future<void> cancel() async {
    await channel?.invokeMethod('cancel', <String, dynamic>{});
  }

  @override
  Future<DownloadJobInfo?> getInfo() async {
    final result = await channel?.invokeMethod('getInfo', <String, dynamic>{});
    return DownloadJobInfo.fromMap((result as Map?)?.cast<String, dynamic>());
  }

  @override
  void dispose() {
    disposeChannel();
  }
}
