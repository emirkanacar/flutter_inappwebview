import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

///{@macro flutter_inappwebview_forge_platform_interface.PlatformPathHandler}
///
///{@macro flutter_inappwebview_forge_platform_interface.PlatformPathHandler.supported_platforms}
abstract class PathHandler
    implements PlatformPathHandler, PlatformPathHandlerEvents {
  /// Constructs a [PathHandler] from a specific platform implementation.
  PathHandler.fromPlatform({required this.platform}) {
    platform.eventHandler = this;
  }

  /// Returns whether this class is supported on the current platform.
  ///
  /// Use [platform] to check support for a specific platform.
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPathHandlerCreationParams(
        path: '',
      ).isClassSupported(platform: platform);

  @override
  late final PlatformPathHandlerEvents? eventHandler;

  /// Implementation of [PlatformPathHandler] for the current platform.
  final PlatformPathHandler platform;

  @override
  String get type => platform.type;

  @override
  String get path => platform.path;

  @override
  Future<WebResourceResponse?> handle(String path) async {
    return null;
  }

  @override
  Map<String, dynamic> toMap({EnumMethod? enumMethod}) =>
      platform.toMap(enumMethod: enumMethod);

  @override
  Map<String, dynamic> toJson() => platform.toJson();
}

///{@macro flutter_inappwebview_forge_platform_interface.PlatformAssetsPathHandler}
///
///{@macro flutter_inappwebview_forge_platform_interface.PlatformAssetsPathHandler.supported_platforms}
class AssetsPathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformAssetsPathHandler}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformAssetsPathHandler.supported_platforms}
  AssetsPathHandler({required String path})
    : this.fromPlatformCreationParams(
        params: PlatformAssetsPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: path),
        ),
      );

  /// Constructs a [AssetsPathHandler].
  ///
  /// See [AssetsPathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  AssetsPathHandler.fromPlatformCreationParams({
    required PlatformAssetsPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformAssetsPathHandler(params));

  /// Constructs a [AssetsPathHandler] from a specific platform implementation.
  AssetsPathHandler.fromPlatform({
    required PlatformAssetsPathHandler super.platform,
  }) : super.fromPlatform();

  /// Implementation of [PlatformAssetsPathHandler] for the current platform.
  @override
  PlatformAssetsPathHandler get platform =>
      super.platform as PlatformAssetsPathHandler;

  /// Returns whether this class is supported on the current platform.
  ///
  /// Use [platform] to check support for a specific platform.
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPathHandlerCreationParams(
        path: '',
      ).isClassSupported(platform: platform);
}

///{@macro flutter_inappwebview_forge_platform_interface.PlatformResourcesPathHandler}
///
///{@macro flutter_inappwebview_forge_platform_interface.PlatformResourcesPathHandler.supported_platforms}
class ResourcesPathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformResourcesPathHandler}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformResourcesPathHandler.supported_platforms}
  ResourcesPathHandler({required String path})
    : this.fromPlatformCreationParams(
        params: PlatformResourcesPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: path),
        ),
      );

  /// Constructs a [ResourcesPathHandler].
  ///
  /// See [ResourcesPathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  ResourcesPathHandler.fromPlatformCreationParams({
    required PlatformResourcesPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformResourcesPathHandler(params));

  /// Constructs a [ResourcesPathHandler] from a specific platform implementation.
  ResourcesPathHandler.fromPlatform({
    required PlatformResourcesPathHandler super.platform,
  }) : super.fromPlatform();

  /// Implementation of [PlatformResourcesPathHandler] for the current platform.
  @override
  PlatformResourcesPathHandler get platform =>
      super.platform as PlatformResourcesPathHandler;

  /// Returns whether this class is supported on the current platform.
  ///
  /// Use [platform] to check support for a specific platform.
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPathHandlerCreationParams(
        path: '',
      ).isClassSupported(platform: platform);
}

///{@macro flutter_inappwebview_forge_platform_interface.PlatformInternalStoragePathHandler}
///
///{@macro flutter_inappwebview_forge_platform_interface.PlatformInternalStoragePathHandler.supported_platforms}
class InternalStoragePathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformInternalStoragePathHandler}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformInternalStoragePathHandler.supported_platforms}
  InternalStoragePathHandler({required String path, required String directory})
    : this.fromPlatformCreationParams(
        params: PlatformInternalStoragePathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: path),
          directory: directory,
        ),
      );

  /// Constructs a [InternalStoragePathHandler].
  ///
  /// See [InternalStoragePathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  InternalStoragePathHandler.fromPlatformCreationParams({
    required PlatformInternalStoragePathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformInternalStoragePathHandler(params));

  /// Constructs a [InternalStoragePathHandler] from a specific platform implementation.
  InternalStoragePathHandler.fromPlatform({
    required PlatformInternalStoragePathHandler super.platform,
  }) : super.fromPlatform();

  /// Implementation of [PlatformInternalStoragePathHandler] for the current platform.
  @override
  PlatformInternalStoragePathHandler get platform =>
      super.platform as PlatformInternalStoragePathHandler;

  String get directory => platform.directory;

  /// Returns whether this class is supported on the current platform.
  ///
  /// Use [platform] to check support for a specific platform.
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPathHandlerCreationParams(
        path: '',
      ).isClassSupported(platform: platform);
}

///{@macro flutter_inappwebview_forge_platform_interface.PlatformCustomPathHandler}
///
///{@macro flutter_inappwebview_forge_platform_interface.PlatformCustomPathHandler.supported_platforms}
abstract class CustomPathHandler extends PathHandler {
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformCustomPathHandler}
  ///
  ///{@macro flutter_inappwebview_forge_platform_interface.PlatformCustomPathHandler.supported_platforms}
  CustomPathHandler({required String path})
    : this.fromPlatformCreationParams(
        params: PlatformCustomPathHandlerCreationParams(
          PlatformPathHandlerCreationParams(path: path),
        ),
      );

  /// Constructs a [CustomPathHandler].
  ///
  /// See [CustomPathHandler.fromPlatformCreationParams] for setting parameters for
  /// a specific platform.
  CustomPathHandler.fromPlatformCreationParams({
    required PlatformCustomPathHandlerCreationParams params,
  }) : this.fromPlatform(platform: PlatformCustomPathHandler(params));

  /// Constructs a [CustomPathHandler] from a specific platform implementation.
  CustomPathHandler.fromPlatform({
    required PlatformCustomPathHandler super.platform,
  }) : super.fromPlatform();

  /// Implementation of [PlatformCustomPathHandler] for the current platform.
  @override
  PlatformCustomPathHandler get platform =>
      super.platform as PlatformCustomPathHandler;

  /// Returns whether this class is supported on the current platform.
  ///
  /// Use [platform] to check support for a specific platform.
  static bool isClassSupported({TargetPlatform? platform}) =>
      PlatformPathHandlerCreationParams(
        path: '',
      ).isClassSupported(platform: platform);
}
