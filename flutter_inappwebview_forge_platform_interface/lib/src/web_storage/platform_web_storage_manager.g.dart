// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: type=lint

part of 'platform_web_storage_manager.dart';

// **************************************************************************
// SupportedPlatformsGenerator
// **************************************************************************

extension _PlatformWebStorageManagerCreationParamsClassSupported
    on PlatformWebStorageManagerCreationParams {
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManagerCreationParams.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView
  ///- iOS WKWebView 9.0+
  ///- Linux WPE WebKit
  ///- macOS WKWebView
  ///- Windows WebView2
  ///
  ///Use the [PlatformWebStorageManagerCreationParams.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.linux,
          TargetPlatform.macOS,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

extension _PlatformWebStorageManagerClassSupported
    on PlatformWebStorageManager {
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorage](https://developer.android.com/reference/android/webkit/WebStorage.html))
  ///- iOS WKWebView 9.0+ ([Official API - WKWebsiteDataStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore))
  ///- Linux WPE WebKit ([Official API - WebKitWebsiteDataManager](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/class.WebsiteDataManager.html))
  ///- macOS WKWebView ([Official API - WKWebsiteDataStore](https://developer.apple.com/documentation/webkit/wkwebsitedatastore))
  ///- Windows WebView2 ([Official API - ICoreWebView2Profile2](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2profile2)):
  ///    - Only deleteBrowsingData is supported on Windows.
  ///
  ///Use the [PlatformWebStorageManager.isClassSupported] method to check if this class is supported at runtime.
  ///{@endtemplate}
  static bool isClassSupported({TargetPlatform? platform}) {
    return ((kIsWeb && platform != null) || !kIsWeb) &&
        [
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.linux,
          TargetPlatform.macOS,
          TargetPlatform.windows,
        ].contains(platform ?? defaultTargetPlatform);
  }
}

///List of [PlatformWebStorageManager]'s methods that can be used to check if they are supported or not by the current platform.
enum PlatformWebStorageManagerMethod {
  ///Can be used to check if the [PlatformWebStorageManager.deleteAllData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.deleteAllData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorage.deleteAllData](https://developer.android.com/reference/android/webkit/WebStorage#deleteAllData()))
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteAllData,

  ///Can be used to check if the [PlatformWebStorageManager.deleteBrowsingData] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.deleteBrowsingData.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorageCompat.deleteBrowsingData](https://developer.android.com/reference/androidx/webkit/WebStorageCompat#deleteBrowsingData(android.webkit.WebStorage,java.lang.Runnable))):
  ///    - Requires an Android System WebView provider that supports WebViewFeature.DELETE_BROWSING_DATA; returns false otherwise.
  ///- iOS WKWebView 9.0+ ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata)):
  ///    - Removes every WKWebsiteDataStore.allWebsiteDataTypes() kind.
  ///- macOS WKWebView ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata)):
  ///    - Removes every WKWebsiteDataStore.allWebsiteDataTypes() kind.
  ///- Linux WPE WebKit ([Official API - webkit_website_data_manager_clear](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.clear.html)):
  ///    - Clears WEBKIT_WEBSITE_DATA_ALL from the default network session.
  ///- Windows WebView2 ([Official API - ICoreWebView2Profile2.ClearBrowsingDataAll](https://learn.microsoft.com/en-us/microsoft-edge/webview2/reference/win32/icorewebview2profile2#clearbrowsingdataall)):
  ///    - Clears the profile of the default WebViewEnvironment. Returns false when the WebView2 runtime does not expose ICoreWebView2Profile2.
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteBrowsingData,

  ///Can be used to check if the [PlatformWebStorageManager.deleteBrowsingDataForSite] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.deleteBrowsingDataForSite.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorageCompat.deleteBrowsingDataForSite](https://developer.android.com/reference/androidx/webkit/WebStorageCompat#deleteBrowsingDataForSite(android.webkit.WebStorage,java.lang.String,java.lang.Runnable))):
  ///    - Requires an Android System WebView provider that supports WebViewFeature.DELETE_BROWSING_DATA; returns null otherwise. The returned value is the site computed by WebView.
  ///- iOS WKWebView 9.0+ ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata)):
  ///    - Matches WKWebsiteDataRecord.displayName against the host and its parent domains. Returns the matched record name, or the normalized host when no data exists for the site.
  ///- macOS WKWebView ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata)):
  ///    - Matches WKWebsiteDataRecord.displayName against the host and its parent domains. Returns the matched record name, or the normalized host when no data exists for the site.
  ///- Linux WPE WebKit ([Official API - webkit_website_data_manager_remove](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.remove.html)):
  ///    - Matches webkit_website_data_get_name against the host and its parent domains. Returns the matched record name, or the normalized host when no data exists for the site.
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [site]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteBrowsingDataForSite,

  ///Can be used to check if the [PlatformWebStorageManager.deleteOrigin] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.deleteOrigin.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorage.deleteOrigin](https://developer.android.com/reference/android/webkit/WebStorage#deleteOrigin(java.lang.String)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [origin]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  deleteOrigin,

  ///Can be used to check if the [PlatformWebStorageManager.fetchDataRecords] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.fetchDataRecords.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 9.0+ ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  ///- Linux WPE WebKit ([Official API - webkit_website_data_manager_fetch](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.fetch.html))
  ///- macOS WKWebView ([Official API - WKWebsiteDataStore.fetchDataRecords](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532932-fetchdatarecords))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [dataTypes]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  fetchDataRecords,

  ///Can be used to check if the [PlatformWebStorageManager.getOrigins] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.getOrigins.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorage.getOrigins](https://developer.android.com/reference/android/webkit/WebStorage#getOrigins(android.webkit.ValueCallback%3Cjava.util.Map%3E)))
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getOrigins,

  ///Can be used to check if the [PlatformWebStorageManager.getQuotaForOrigin] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.getQuotaForOrigin.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorage.getQuotaForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getQuotaForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [origin]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getQuotaForOrigin,

  ///Can be used to check if the [PlatformWebStorageManager.getUsageForOrigin] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.getUsageForOrigin.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- Android WebView ([Official API - WebStorage.getUsageForOrigin](https://developer.android.com/reference/android/webkit/WebStorage#getUsageForOrigin(java.lang.String,%20android.webkit.ValueCallback%3Cjava.lang.Long%3E)))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [origin]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  getUsageForOrigin,

  ///Can be used to check if the [PlatformWebStorageManager.removeDataFor] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.removeDataFor.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 9.0+ ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata))
  ///- Linux WPE WebKit ([Official API - webkit_website_data_manager_remove](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.remove.html))
  ///- macOS WKWebView ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532936-removedata))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [dataTypes]: all platforms
  ///- [dataRecords]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeDataFor,

  ///Can be used to check if the [PlatformWebStorageManager.removeDataModifiedSince] method is supported at runtime.
  ///
  ///{@template flutter_inappwebview_forge_platform_interface.PlatformWebStorageManager.removeDataModifiedSince.supported_platforms}
  ///
  ///**Officially Supported Platforms/Implementations**:
  ///- iOS WKWebView 9.0+ ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///- Linux WPE WebKit ([Official API - webkit_website_data_manager_clear](https://wpewebkit.org/reference/stable/wpe-webkit-2.0/method.WebsiteDataManager.clear.html))
  ///- macOS WKWebView ([Official API - WKWebsiteDataStore.removeData](https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata))
  ///
  ///**Parameters - Officially Supported Platforms/Implementations**:
  ///- [dataTypes]: all platforms
  ///- [date]: all platforms
  ///
  ///Use the [PlatformWebStorageManager.isMethodSupported] method to check if this method is supported at runtime.
  ///{@endtemplate}
  removeDataModifiedSince,
}

extension _PlatformWebStorageManagerMethodSupported
    on PlatformWebStorageManager {
  static bool isMethodSupported(
    PlatformWebStorageManagerMethod method, {
    TargetPlatform? platform,
  }) {
    switch (method) {
      case PlatformWebStorageManagerMethod.deleteAllData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.deleteBrowsingData:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
              TargetPlatform.windows,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.deleteBrowsingDataForSite:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
              TargetPlatform.iOS,
              TargetPlatform.macOS,
              TargetPlatform.linux,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.deleteOrigin:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.fetchDataRecords:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.getOrigins:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.getQuotaForOrigin:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.getUsageForOrigin:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.android,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.removeDataFor:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
      case PlatformWebStorageManagerMethod.removeDataModifiedSince:
        return ((kIsWeb && platform != null) || !kIsWeb) &&
            [
              TargetPlatform.iOS,
              TargetPlatform.linux,
              TargetPlatform.macOS,
            ].contains(platform ?? defaultTargetPlatform);
    }
  }
}
