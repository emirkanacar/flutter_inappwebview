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
    ],
  )
  Future<bool> deleteContainer(String containerId) {
    throw UnimplementedError(
      'deleteContainer is not implemented on the current platform',
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
