import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [IOSContainerController].
@immutable
class IOSContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates iOS container controller parameters.
  const IOSContainerControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();

  /// Creates iOS parameters from common parameters.
  factory IOSContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
    PlatformContainerControllerCreationParams params,
  ) {
    return IOSContainerControllerCreationParams(params);
  }
}

/// iOS implementation of [PlatformContainerController].
class IOSContainerController extends PlatformContainerController {
  /// Creates an iOS container controller.
  IOSContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is IOSContainerControllerCreationParams
            ? params
            : IOSContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
                params,
              ),
      );

  static IOSContainerController? _instance;

  static const MethodChannel _channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_containercontroller',
  );

  /// Gets the shared iOS controller instance.
  static IOSContainerController instance() =>
      _instance ??= IOSContainerController(
        const IOSContainerControllerCreationParams(
          PlatformContainerControllerCreationParams(),
        ),
      );

  static final IOSContainerController _staticValue = IOSContainerController(
    const IOSContainerControllerCreationParams(
      PlatformContainerControllerCreationParams(),
    ),
  );

  /// Provides static access for the platform implementation.
  factory IOSContainerController.static() => _staticValue;

  @override
  Future<List<String>> getAllContainerNames() async {
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getAllContainerNames',
    );
    return result?.whereType<String>().toList(growable: false) ?? const [];
  }

  @override
  Future<bool> hasContainer(String containerId) async =>
      await _channel.invokeMethod<bool>('hasContainer', <String, dynamic>{
        'containerId': containerId,
      }) ??
      false;

  @override
  Future<bool> deleteContainer(String containerId) async =>
      await _channel.invokeMethod<bool>('deleteContainer', <String, dynamic>{
        'containerId': containerId,
      }) ??
      false;
}
