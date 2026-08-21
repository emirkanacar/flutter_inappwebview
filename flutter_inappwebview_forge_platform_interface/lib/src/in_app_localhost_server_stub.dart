import 'package:flutter/foundation.dart';

import 'platform_in_app_localhost_server.dart';

/// Object specifying creation parameters for creating a [DefaultInAppLocalhostServer].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformInAppLocalhostServerCreationParams] for
/// more information.
@immutable
class DefaultInAppLocalhostServerCreationParams
    extends PlatformInAppLocalhostServerCreationParams {
  /// Creates a new [DefaultInAppLocalhostServerCreationParams] instance.
  const DefaultInAppLocalhostServerCreationParams(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformInAppLocalhostServerCreationParams params,
  ) : super();

  /// Creates a [DefaultInAppLocalhostServerCreationParams] instance based on [PlatformInAppLocalhostServerCreationParams].
  factory DefaultInAppLocalhostServerCreationParams.fromPlatformInAppLocalhostServerCreationParams(
    PlatformInAppLocalhostServerCreationParams params,
  ) {
    return DefaultInAppLocalhostServerCreationParams(params);
  }
}

/// Web/WASM stub. Localhost serving requires `dart:io` and is not available.
class DefaultInAppLocalhostServer extends PlatformInAppLocalhostServer {
  static final DefaultInAppLocalhostServer _staticValue =
      DefaultInAppLocalhostServer(
        const PlatformInAppLocalhostServerCreationParams(),
      );

  /// Creates a new empty [DefaultInAppLocalhostServer] to access static methods.
  factory DefaultInAppLocalhostServer.static() => _staticValue;

  /// Creates a new [DefaultInAppLocalhostServer].
  DefaultInAppLocalhostServer(PlatformInAppLocalhostServerCreationParams params)
    : super.implementation(
        params is DefaultInAppLocalhostServerCreationParams
            ? params
            : DefaultInAppLocalhostServerCreationParams.fromPlatformInAppLocalhostServerCreationParams(
                params,
              ),
      );

  @override
  Future<void> start() {
    throw UnimplementedError(
      'start is not implemented on the current platform',
    );
  }

  @override
  Future<void> close() {
    throw UnimplementedError(
      'close is not implemented on the current platform',
    );
  }

  @override
  bool isRunning() {
    throw UnimplementedError(
      'isRunning is not implemented on the current platform',
    );
  }
}
