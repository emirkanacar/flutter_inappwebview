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
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.dataStoreForIdentifier](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041131-datastoreforidentifier))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore(forIdentifier:)](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4055360-init))
  ///- Windows WebView2 ([Official API - CoreWebView2Environment userDataFolder](https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager persistent directories](https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html))
  ///
  ///Use the [PlatformContainerControllerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformContainerControllerClassSupported
    on PlatformContainerController {
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - androidx.webkit.ProfileStore](https://developer.android.com/reference/androidx/webkit/ProfileStore))
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore))
  ///- Windows WebView2 ([Official API - CoreWebView2Environment userDataFolder](https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager persistent directories](https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html))
  ///
  ///Use the [PlatformContainerController.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
          TargetPlatform.windows,
          TargetPlatform.linux,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformContainerController]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformContainerControllerMethod {
  ///Can be used to check if the [PlatformContainerController.addCustomHeader] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.addCustomHeader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - Profile.addCustomHeader](https://developer.android.com/reference/androidx/webkit/Profile#addCustomHeader(java.lang.String,java.lang.String,java.util.Set))):
  ///    - Requires [WebViewFeature.CUSTOM_REQUEST_HEADERS].
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///- [headerName]: all platforms
  ///- [headerValue]: all platforms
  ///- [originRules]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  addCustomHeader,

  ///Can be used to check if the [PlatformContainerController.clearContainerData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.clearContainerData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - Profile.getCookieManager / getWebStorage](https://developer.android.com/reference/androidx/webkit/Profile))
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.removeData(ofTypes:modifiedSince:completionHandler:)](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.removeData(ofTypes:modifiedSince:completionHandler:)](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- Windows WebView2 ([Official API - CoreWebView2Environment userDataFolder](https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager persistent directories](https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  clearContainerData,

  ///Can be used to check if the [PlatformContainerController.deleteContainer] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.deleteContainer.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - ProfileStore.deleteProfile](https://developer.android.com/reference/androidx/webkit/ProfileStore))
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.removeDataStoreForIdentifier](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041133-removedatastoreforidentifier))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.remove(forIdentifier:)](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041133-removedatastoreforidentifier))
  ///- Windows WebView2 ([Official API - CoreWebView2Environment userDataFolder](https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager persistent directories](https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html))
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
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.fetchAllDataStoreIdentifiers](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.fetchAllDataStoreIdentifiers](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers))
  ///- Windows WebView2 ([Official API - CoreWebView2Environment userDataFolder](https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager persistent directories](https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html))
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
  ///- iOS WKWebView 17.0+ ([Official API - WKWebsiteDataStore.fetchAllDataStoreIdentifiers](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers))
  ///- macOS WKWebView 14.0+ ([Official API - WKWebsiteDataStore.fetchAllDataStoreIdentifiers](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers))
  ///- Windows WebView2 ([Official API - CoreWebView2Environment userDataFolder](https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager persistent directories](https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  hasContainer,

  ///Can be used to check if the [PlatformContainerController.preconnect] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.preconnect.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - Profile.preconnect](https://developer.android.com/reference/androidx/webkit/Profile#preconnect(java.lang.String))):
  ///    - Requires [WebViewFeature.PRECONNECT].
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///- [url]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  preconnect,

  ///Can be used to check if the [PlatformContainerController.prefetchUrl] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.prefetchUrl.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ ([Official API - Profile.prefetchUrlAsync](https://developer.android.com/reference/androidx/webkit/Profile#prefetchUrlAsync(java.lang.String,androidx.webkit.PrefetchParameters,java.util.concurrent.Executor,androidx.webkit.OutcomeReceiver))):
  ///    - Requires [WebViewFeature.PROFILE_URL_PREFETCH].
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///- [url]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  prefetchUrl,

  ///Can be used to check if the [PlatformContainerController.removeCustomHeader] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformContainerController.removeCustomHeader.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView 110+ (Official API - Profile.removeCustomHeader):
  ///    - Requires [WebViewFeature.CUSTOM_REQUEST_HEADERS].
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [containerId]: all platforms
  ///- [headerName]: all platforms
  ///
  ///Use the [PlatformContainerController.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeCustomHeader,
}

extension _PlatformContainerControllerMethodSupported
    on PlatformContainerController {
  static bool isMethodSupported(
    PlatformContainerControllerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformContainerControllerMethod.addCustomHeader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.clearContainerData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.deleteContainer:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.getAllContainerNames:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.hasContainer:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.windows,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.preconnect:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.prefetchUrl:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformContainerControllerMethod.removeCustomHeader:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
