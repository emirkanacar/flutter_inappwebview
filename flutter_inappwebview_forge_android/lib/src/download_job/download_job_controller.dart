import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [AndroidDownloadJobController].
@immutable
class AndroidDownloadJobControllerCreationParams
    extends PlatformDownloadJobControllerCreationParams {
  /// Creates Android download job parameters.
  const AndroidDownloadJobControllerCreationParams({required super.id});

  /// Creates Android parameters from common parameters.
  factory AndroidDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
    PlatformDownloadJobControllerCreationParams params,
  ) {
    return AndroidDownloadJobControllerCreationParams(id: params.id);
  }
}

/// Android implementation of [PlatformDownloadJobController].
class AndroidDownloadJobController extends PlatformDownloadJobController
    with ChannelController {
  /// Creates an Android download job controller.
  AndroidDownloadJobController(PlatformDownloadJobControllerCreationParams params)
    : super.implementation(
        params is AndroidDownloadJobControllerCreationParams
            ? params
            : AndroidDownloadJobControllerCreationParams.fromPlatformDownloadJobControllerCreationParams(
                params,
              ),
      ) {
    channel = MethodChannel(
      'com.emirkanacar/flutter_inappwebview_downloadjobcontroller_${params.id}',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static final AndroidDownloadJobController _staticValue =
      AndroidDownloadJobController(
        const AndroidDownloadJobControllerCreationParams(id: ''),
      );

  /// Provides static access.
  factory AndroidDownloadJobController.static() => _staticValue;

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
    return DownloadJobInfo.fromMap(
      (result as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void dispose() {
    disposeChannel();
  }
}
