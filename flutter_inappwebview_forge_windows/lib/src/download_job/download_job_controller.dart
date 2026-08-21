import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [WindowsDownloadJobController].
@immutable
class WindowsDownloadJobControllerCreationParams
    extends PlatformDownloadJobControllerCreationParams {
  /// Creates Windows download job parameters.
  const WindowsDownloadJobControllerCreationParams({required super.id});

  /// Creates Windows parameters from common parameters.
  factory WindowsDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
    PlatformDownloadJobControllerCreationParams params,
  ) {
    return WindowsDownloadJobControllerCreationParams(id: params.id);
  }
}

/// Windows implementation of [PlatformDownloadJobController].
class WindowsDownloadJobController extends PlatformDownloadJobController
    with ChannelController {
  /// Creates a Windows download job controller.
  WindowsDownloadJobController(PlatformDownloadJobControllerCreationParams params)
    : super.implementation(
        params is WindowsDownloadJobControllerCreationParams
            ? params
            : WindowsDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel(
      'com.emirkanacar/flutter_inappwebview_downloadjobcontroller_${params.id}',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static final WindowsDownloadJobController _staticValue =
      WindowsDownloadJobController(
        const WindowsDownloadJobControllerCreationParams(id: ''),
      );

  /// Provides static access.
  factory WindowsDownloadJobController.static() => _staticValue;

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
