// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_download_job_controller.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformDownloadJobControllerCreationParamsClassSupported
    on PlatformDownloadJobControllerCreationParams {
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformDownloadJobControllerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PlatformDownloadJobControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformDownloadJobControllerCreationParams]'s properties that can be used to check i they are supported or not by the current platform.
enum PlatformDownloadJobControllerCreationParamsProperty {
  ///Can be used to check if the [PlatformDownloadJobControllerCreationParams.id] property is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformDownloadJobControllerCreationParams.id.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PlatformDownloadJobControllerCreationParams.isPropertySupported] method to check if this property is supported at runtime.
  ///{@endtemplate}
  id,
}

extension _PlatformDownloadJobControllerCreationParamsPropertySupported
    on PlatformDownloadJobControllerCreationParams {
  static bool isPropertySupported(
    PlatformDownloadJobControllerCreationParamsProperty property, {
    TargetPlatform? platform,
  }) {
    switch (property) {
      case PlatformDownloadJobControllerCreationParamsProperty.id:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}

///List of [PlatformDownloadJobController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformDownloadJobControllerMethod {
  ///Can be used to check if the [PlatformDownloadJobController.cancel] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.cancel.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 14.5+
  ///- macOS WKWebView 11.3+
  ///- Windows WebView2
  ///
  ///Use the [PlatformDownloadJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  cancel,

  ///Can be used to check if the [PlatformDownloadJobController.dispose] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.dispose.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PlatformDownloadJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  dispose,

  ///Can be used to check if the [PlatformDownloadJobController.getInfo] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformDownloadJobController.getInfo.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PlatformDownloadJobController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getInfo,
}

extension _PlatformDownloadJobControllerMethodSupported
    on PlatformDownloadJobController {
  static bool isMethodSupported(
    PlatformDownloadJobControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformDownloadJobControllerMethod.cancel:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformDownloadJobControllerMethod.dispose:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformDownloadJobControllerMethod.getInfo:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
