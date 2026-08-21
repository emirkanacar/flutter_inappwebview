import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Creation parameters for [AndroidContainerController].
@immutable
class AndroidContainerControllerCreationParams
    extends PlatformContainerControllerCreationParams {
  /// Creates Android container controller parameters.
  const AndroidContainerControllerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformContainerControllerCreationParams params,
  ) : super();

  /// Creates Android parameters from common parameters.
  factory AndroidContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
    PlatformContainerControllerCreationParams params,
  ) {
    return AndroidContainerControllerCreationParams(params);
  }
}

/// Android implementation of [PlatformContainerController].
class AndroidContainerController extends PlatformContainerController {
  /// Creates an Android container controller.
  AndroidContainerController(PlatformContainerControllerCreationParams params)
    : super.implementation(
        params is AndroidContainerControllerCreationParams
            ? params
            : AndroidContainerControllerCreationParams.fromPlatformContainerControllerCreationParams(
                params,
              ),
      );

  static AndroidContainerController? _instance;

  static const MethodChannel _channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_containercontroller',
  );

  /// Gets the shared Android controller instance.
  static AndroidContainerController instance() =>
      _instance ??= AndroidContainerController(
        const AndroidContainerControllerCreationParams(
          PlatformContainerControllerCreationParams(),
        ),
      );

  static final AndroidContainerController _staticValue =
      AndroidContainerController(
        const AndroidContainerControllerCreationParams(
          PlatformContainerControllerCreationParams(),
        ),
      );

  /// Provides static access for the platform implementation.
  factory AndroidContainerController.static() => _staticValue;

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

  @override
  Future<bool> addCustomHeader({
    required String containerId,
    required String headerName,
    required String headerValue,
    Set<String>? originRules,
  }) async =>
      await _channel.invokeMethod<bool>('addCustomHeader', <String, dynamic>{
        'containerId': containerId,
        'headerName': headerName,
        'headerValue': headerValue,
        'originRules': originRules?.toList(),
      }) ??
      false;

  @override
  Future<bool> removeCustomHeader({
    required String containerId,
    required String headerName,
  }) async =>
      await _channel.invokeMethod<bool>('removeCustomHeader', <String, dynamic>{
        'containerId': containerId,
        'headerName': headerName,
      }) ??
      false;

  @override
  Future<bool> prefetchUrl({
    required String containerId,
    required String url,
  }) async =>
      await _channel.invokeMethod<bool>('prefetchUrl', <String, dynamic>{
        'containerId': containerId,
        'url': url,
      }) ??
      false;
}
