import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_internal_annotations/flutter_inappwebview_forge_internal_annotations.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'inappwebview_platform.dart';

part 'platform_container_controller.g.dart';

/// Object specifying creation parameters for a [PlatformContainerController].
///
/// Platform specific implementations can add additional fields by extending
/// this class.
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'androidx.webkit.ProfileStore',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProfileStore',
      available: '110',
    ),
    IOSPlatform(
      apiName: 'WKWebsiteDataStore.dataStoreForIdentifier',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041131-datastoreforidentifier',
      available: '17.0',
    ),
    MacOSPlatform(
      apiName: 'WKWebsiteDataStore(forIdentifier:)',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4055360-init',
      available: '14.0',
    ),
    WindowsPlatform(
      apiName: 'CoreWebView2Environment userDataFolder',
      apiUrl:
          'https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder',
    ),
    LinuxPlatform(
      apiName: 'WebKitWebsiteDataManager persistent directories',
      apiUrl:
          'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html',
    ),
  ],
)
@immutable
class PlatformContainerControllerCreationParams {
  /// Used by the platform implementation to create a controller.
  const PlatformContainerControllerCreationParams();

  /// Checks whether this controller is available on [platform].
  bool isClassSupported({TargetPlatform? platform}) =>
      _PlatformContainerControllerCreationParamsClassSupported.isClassSupported(
        platform: platform,
      );
}

/// Manages persistent WebView storage containers.
///
/// A container is a named profile containing cookies, DOM storage, IndexedDB,
/// service workers, cache, and other WebView data. A WebView joins a container
/// through [InAppWebViewSettings.containerId] when it is constructed.
@SupportedPlatforms(
  platforms: [
    AndroidPlatform(
      apiName: 'androidx.webkit.ProfileStore',
      apiUrl:
          'https://developer.android.com/reference/androidx/webkit/ProfileStore',
      available: '110',
    ),
    IOSPlatform(
      apiName: 'WKWebsiteDataStore',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore',
      available: '17.0',
    ),
    MacOSPlatform(
      apiName: 'WKWebsiteDataStore',
      apiUrl:
          'https://developer.apple.com/documentation/webkit/wkwebsitedatastore',
      available: '14.0',
    ),
    WindowsPlatform(
      apiName: 'CoreWebView2Environment userDataFolder',
      apiUrl:
          'https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder',
    ),
    LinuxPlatform(
      apiName: 'WebKitWebsiteDataManager persistent directories',
      apiUrl:
          'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html',
    ),
  ],
)
abstract class PlatformContainerController extends PlatformInterface {
  /// Creates a new controller.
  factory PlatformContainerController(
    PlatformContainerControllerCreationParams params,
  ) {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview_forge` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set. For unit testing, '
      '`InAppWebViewPlatform.instance` can be set with your own test implementation.',
    );
    final controller = InAppWebViewPlatform.instance!
        .createPlatformContainerController(params);
    PlatformInterface.verify(controller, _token);
    return controller;
  }

  /// Creates a controller for static methods.
  factory PlatformContainerController.static() {
    assert(
      InAppWebViewPlatform.instance != null,
      'A platform implementation for `flutter_inappwebview_forge` has not been set. Please '
      'ensure that an implementation of `InAppWebViewPlatform` has been set.',
    );
    final controller = InAppWebViewPlatform.instance!
        .createPlatformContainerControllerStatic();
    PlatformInterface.verify(controller, _token);
    return controller;
  }

  /// Constructor for platform implementations.
  @protected
  PlatformContainerController.implementation(this.params)
    : super(token: _token);

  static final Object _token = Object();

  /// The creation parameters used by this controller.
  final PlatformContainerControllerCreationParams params;

  /// Returns all named persistent containers.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.getAllProfileNames',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore#getAllProfileNames()',
        available: '110',
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.fetchAllDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName: 'WKWebsiteDataStore.fetchAllDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers',
        available: '14.0',
      ),
      WindowsPlatform(
        apiName: 'CoreWebView2Environment userDataFolder',
        apiUrl:
            'https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebsiteDataManager persistent directories',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html',
      ),
    ],
  )
  Future<List<String>> getAllContainerNames() {
    throw UnimplementedError(
      'getAllContainerNames is not implemented on the current platform',
    );
  }

  /// Returns whether [containerId] exists.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.getProfile',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore',
        available: '110',
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.fetchAllDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName: 'WKWebsiteDataStore.fetchAllDataStoreIdentifiers',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041132-fetchalldatastoreidentifiers',
        available: '14.0',
      ),
      WindowsPlatform(
        apiName: 'CoreWebView2Environment userDataFolder',
        apiUrl:
            'https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebsiteDataManager persistent directories',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html',
      ),
    ],
  )
  Future<bool> hasContainer(String containerId) {
    throw UnimplementedError(
      'hasContainer is not implemented on the current platform',
    );
  }

  /// Deletes [containerId] when it is not in use.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'ProfileStore.deleteProfile',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/ProfileStore',
        available: '110',
      ),
      IOSPlatform(
        apiName: 'WKWebsiteDataStore.removeDataStoreForIdentifier',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041133-removedatastoreforidentifier',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName: 'WKWebsiteDataStore.remove(forIdentifier:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/4041133-removedatastoreforidentifier',
        available: '14.0',
      ),
      WindowsPlatform(
        apiName: 'CoreWebView2Environment userDataFolder',
        apiUrl:
            'https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebsiteDataManager persistent directories',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html',
      ),
    ],
  )
  Future<bool> deleteContainer(String containerId) {
    throw UnimplementedError(
      'deleteContainer is not implemented on the current platform',
    );
  }

  /// Clears data in [containerId] without removing the container.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.getCookieManager / getWebStorage',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile',
        available: '110',
      ),
      IOSPlatform(
        apiName:
            'WKWebsiteDataStore.removeData(ofTypes:modifiedSince:completionHandler:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata',
        available: '17.0',
      ),
      MacOSPlatform(
        apiName:
            'WKWebsiteDataStore.removeData(ofTypes:modifiedSince:completionHandler:)',
        apiUrl:
            'https://developer.apple.com/documentation/webkit/wkwebsitedatastore/1532938-removedata',
        available: '14.0',
      ),
      WindowsPlatform(
        apiName: 'CoreWebView2Environment userDataFolder',
        apiUrl:
            'https://learn.microsoft.com/microsoft-edge/webview2/concepts/user-data-folder',
      ),
      LinuxPlatform(
        apiName: 'WebKitWebsiteDataManager persistent directories',
        apiUrl:
            'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebsiteDataManager.html',
      ),
    ],
  )
  Future<bool> clearContainerData(String containerId) {
    throw UnimplementedError(
      'clearContainerData is not implemented on the current platform',
    );
  }

  /// Adds a static request header for matching origins on the Android profile.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.addCustomHeader',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#addCustomHeader(java.lang.String,java.lang.String,java.util.Set)',
        available: '110',
        note: 'Requires [WebViewFeature.CUSTOM_REQUEST_HEADERS].',
      ),
    ],
  )
  Future<bool> addCustomHeader({
    required String containerId,
    required String headerName,
    required String headerValue,
    Set<String>? originRules,
  }) {
    throw UnimplementedError(
      'addCustomHeader is not implemented on the current platform',
    );
  }

  /// Removes a previously added custom header from the Android profile.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.removeCustomHeader',
        available: '110',
        note: 'Requires [WebViewFeature.CUSTOM_REQUEST_HEADERS].',
      ),
    ],
  )
  Future<bool> removeCustomHeader({
    required String containerId,
    required String headerName,
  }) {
    throw UnimplementedError(
      'removeCustomHeader is not implemented on the current platform',
    );
  }

  /// Prefetches [url] into the Android profile HTTP cache.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.prefetchUrlAsync',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#prefetchUrlAsync(java.lang.String,androidx.webkit.PrefetchParameters,java.util.concurrent.Executor,androidx.webkit.OutcomeReceiver)',
        available: '110',
        note: 'Requires [WebViewFeature.PROFILE_URL_PREFETCH].',
      ),
    ],
  )
  Future<bool> prefetchUrl({
    required String containerId,
    required String url,
  }) {
    throw UnimplementedError(
      'prefetchUrl is not implemented on the current platform',
    );
  }

  /// Preconnects to the origin of [url] on the Android profile.
  ///
  /// This can speed up a later navigation without starting a full prefetch.
  @SupportedPlatforms(
    platforms: [
      AndroidPlatform(
        apiName: 'Profile.preconnect',
        apiUrl:
            'https://developer.android.com/reference/androidx/webkit/Profile#preconnect(java.lang.String)',
        available: '110',
        note: 'Requires [WebViewFeature.PRECONNECT].',
      ),
    ],
  )
  Future<bool> preconnect({
    required String containerId,
    required String url,
  }) {
    throw UnimplementedError(
      'preconnect is not implemented on the current platform',
    );
  }

  /// Checks whether this controller is available on [platform].
  bool isClassSupported({TargetPlatform? platform}) =>
      params.isClassSupported(platform: platform);

  /// Checks whether [method] is available on [platform].
  bool isMethodSupported(
    PlatformContainerControllerMethod method, {
    TargetPlatform? platform,
  }) => _PlatformContainerControllerMethodSupported.isMethodSupported(
    method,
    platform: platform,
  );
}
