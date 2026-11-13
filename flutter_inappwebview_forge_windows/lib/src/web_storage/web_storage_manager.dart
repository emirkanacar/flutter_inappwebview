import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Object specifying creation parameters for creating a [WindowsWebStorageManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformWebStorageManagerCreationParams] for
/// more information.
@immutable
class WindowsWebStorageManagerCreationParams
    extends PlatformWebStorageManagerCreationParams {
  /// Creates a new [WindowsWebStorageManagerCreationParams] instance.
  const WindowsWebStorageManagerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebStorageManagerCreationParams params,
  ) : super();

  /// Creates a [WindowsWebStorageManagerCreationParams] instance based on [PlatformWebStorageManagerCreationParams].
  factory WindowsWebStorageManagerCreationParams.fromPlatformWebStorageManagerCreationParams(
    PlatformWebStorageManagerCreationParams params,
  ) {
    return WindowsWebStorageManagerCreationParams(params);
  }
}

///{@macro flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager}
class WindowsWebStorageManager extends PlatformWebStorageManager
    with ChannelController {
  /// Creates a new [WindowsWebStorageManager].
  WindowsWebStorageManager(PlatformWebStorageManagerCreationParams params)
    : super.implementation(
        params is WindowsWebStorageManagerCreationParams
            ? params
            : WindowsWebStorageManagerCreationParams.fromPlatformWebStorageManagerCreationParams(
                params,
              ),
      ) {
    channel = const MethodChannel(
      'com.emirkanacar/flutter_inappwebview_webstoragemanager',
    );
    handler = _handleMethod;
    initMethodCallHandler();
  }

  static WindowsWebStorageManager? _instance;

  ///Gets the WebStorage manager shared instance.
  static WindowsWebStorageManager instance() {
    return (_instance != null) ? _instance! : _init();
  }

  static WindowsWebStorageManager _init() {
    _instance = WindowsWebStorageManager(
      WindowsWebStorageManagerCreationParams(
        const PlatformWebStorageManagerCreationParams(),
      ),
    );
    return _instance!;
  }

  static WindowsWebStorageManager? _static;

  /// Provide static access.
  factory WindowsWebStorageManager.static() {
    _static ??= WindowsWebStorageManager(
      WindowsWebStorageManagerCreationParams(
        const PlatformWebStorageManagerCreationParams(),
      ),
    );
    return _static!;
  }

  Future<dynamic> _handleMethod(MethodCall call) async {}

  @override
  Future<bool> deleteBrowsingData() async {
    Map<String, dynamic> args = <String, dynamic>{};
    return await channel?.invokeMethod<bool>('deleteBrowsingData', args) ??
        false;
  }

  @override
  void dispose() {
    // empty
  }
}
