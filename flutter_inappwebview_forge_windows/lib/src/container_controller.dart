import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [WindowsContainerController].
@immutable
class WindowsContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates Windows container controller parameters.
  const WindowsContainerControllerCreationParams(
    // This parameter preserves the federated API extension point.
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();
}

/// Windows implementation of [PlatformContainerController].
class WindowsContainerController extends PlatformContainerController {
  /// Creates a Windows container controller.
  WindowsContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is WindowsContainerControllerCreationParams
            ? params
            : WindowsContainerControllerCreationParams(params),
      );

  static const MethodChannel _channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_containercontroller',
  );

  static final WindowsContainerController _staticValue =
      WindowsContainerController(
        const WindowsContainerControllerCreationParams(
          PlatformContainerControllerCreationParams(),
        ),
      );

  /// Provides static access for the platform implementation.
  factory WindowsContainerController.static() => _staticValue;

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
