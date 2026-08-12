import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [LinuxContainerController].
@immutable
class LinuxContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates Linux container controller parameters.
  const LinuxContainerControllerCreationParams(
    // This parameter preserves the federated API extension point.
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();
}

/// Linux implementation of [PlatformContainerController].
class LinuxContainerController extends PlatformContainerController {
  /// Creates a Linux container controller.
  LinuxContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is LinuxContainerControllerCreationParams
            ? params
            : LinuxContainerControllerCreationParams(params),
      );

  static const MethodChannel _channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_containercontroller',
  );

  static final LinuxContainerController _staticValue = LinuxContainerController(
    const LinuxContainerControllerCreationParams(
      PlatformContainerControllerCreationParams(),
    ),
  );

  /// Provides static access for the platform implementation.
  factory LinuxContainerController.static() => _staticValue;

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

  @override
  Future<bool> clearContainerData(String containerId) async =>
      await _channel.invokeMethod<bool>('clearContainerData', <String, dynamic>{
        'containerId': containerId,
      }) ??
      false;
}
