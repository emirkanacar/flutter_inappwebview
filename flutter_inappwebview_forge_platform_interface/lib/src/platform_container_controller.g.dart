// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_container_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformContainerControllerCreationParamsClassSupported
    on PlatformContainerControllerCreationParams {
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - androidx.webkit.ProfileStore](https://developer.android.com/reference/androidx/webkit/ProfileStore))
  ///
  ///Use the [PlatformContainerControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformContainerControllerClassSupported
    on PlatformContainerController {
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - androidx.webkit.ProfileStore](https://developer.android.com/reference/androidx/webkit/ProfileStore))
  ///
  ///Use the [PlatformContainerController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [TargetPlatform.android].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformContainerController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformContainerControllerMethod {
  ///Can be used to check if the [PlatformContainerController.deleteContainer] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.deleteContainer.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - ProfileStore.deleteProfile](https://developer.android.com/reference/androidx/webkit/ProfileStore))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteContainer,

  ///Can be used to check if the [PlatformContainerController.getAllContainerNames] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.getAllContainerNames.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - ProfileStore.getAllProfileNames](https://developer.android.com/reference/androidx/webkit/ProfileStore#getAllProfileNames()))
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getAllContainerNames,

  ///Can be used to check if the [PlatformContainerController.hasContainer] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.hasContainer.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - ProfileStore.getProfile](https://developer.android.com/reference/androidx/webkit/ProfileStore))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasContainer,
}

extension _PlatformContainerControllerMethodSupported
    on PlatformContainerController {
  static bool isMethodSupported(
    PlatformContainerControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformContainerControllerMethod.deleteContainer:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.getAllContainerNames:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.hasContainer:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
