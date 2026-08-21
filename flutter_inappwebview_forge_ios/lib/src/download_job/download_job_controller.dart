import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [IOSDownloadJobController].
@immutable
class IOSDownloadJobControllerCreationParams
    extends PlatformDownloadJobControllerCreationParams {
  /// Creates iOS download job parameters.
  const IOSDownloadJobControllerCreationParams({required super.id});

  /// Creates iOS parameters from common parameters.
  factory IOSDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
    PlatformDownloadJobControllerCreationParams params,
  ) {
    return IOSDownloadJobControllerCreationParams(id: params.id);
  }
}

/// iOS implementation of [PlatformDownloadJobController].
class IOSDownloadJobController extends PlatformDownloadJobController
    with ChannelController {
  /// Creates an iOS download job controller.
  IOSDownloadJobController(PlatformDownloadJobControllerCreationParams params)
    : super.implementation(
        params is IOSDownloadJobControllerCreationParams
            ? params
            : IOSDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel(
      'com.emirkanacar/flutter_inappwebview_downloadjobcontroller_${params.id}',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static final IOSDownloadJobController _staticValue = IOSDownloadJobController(
    const IOSDownloadJobControllerCreationParams(id: ''),
  );

  /// Provides static access.
  factory IOSDownloadJobController.static() => _staticValue;

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
