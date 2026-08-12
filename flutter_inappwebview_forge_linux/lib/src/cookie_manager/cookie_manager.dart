import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Object specifying creation parameters for creating a [LinuxCookieManager].
///
/// When adding additional fields make sure they can be null or have a default
/// value to avoid breaking changes. See [PlatformCookieManagerCreationParams] for
/// more information.
class LinuxCookieManagerCreationParams
    extends PlatformCookieManagerCreationParams {
  /// Creates a new [LinuxCookieManagerCreationParams] instance.
  const LinuxCookieManagerCreationParams();

  /// Creates a [LinuxCookieManagerCreationParams] instance based on [PlatformCookieManagerCreationParams].
  factory LinuxCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
    PlatformCookieManagerCreationParams params,
  ) {
    return const LinuxCookieManagerCreationParams();
  }
}

/// Implementation of [PlatformCookieManager] for Linux using WebKitGTK.
class LinuxCookieManager extends PlatformCookieManager {
  static const MethodChannel _channel = MethodChannel(
    'com.emirkanacar/flutter_inappwebview_cookiemanager',
  );

  /// Constructs a [LinuxCookieManager].
  LinuxCookieManager(PlatformCookieManagerCreationParams params)
    : super.implementation(
        params is LinuxCookieManagerCreationParams
            ? params
            : LinuxCookieManagerCreationParams.fromPlatformCookieManagerCreationParams(
                params,
              ),
      );

  static final LinuxCookieManager _instance = LinuxCookieManager(
    const LinuxCookieManagerCreationParams(),
  );

  /// The [LinuxCookieManager] singleton instance.
  static LinuxCookieManager instance() => _instance;

  /// Creates and returns a new [LinuxCookieManager] for static methods.
  factory LinuxCookieManager.static() => _instance;

  void _addWebViewId(
    Map<String, dynamic> args,
    PlatformInAppWebViewController? webViewController,
  ) {
    final webViewId = webViewController?.getViewId();
    if (webViewId != null) {
      args['webViewId'] = webViewId;
    }
  }

  @override
  Future<bool> setCookie({
    required WebUri url,
    required String name,
    required String value,
    String path = "/",
    String? domain,
    int? expiresDate,
    int? maxAge,
    bool? isSecure,
    bool? isHttpOnly,
    HTTPCookieSameSitePolicy? sameSite,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final Map<String, dynamic> cookie = {
      'name': name,
      'value': value,
      'path': path,
      if (domain != null) 'domain': domain,
      if (expiresDate != null) 'expiresDate': expiresDate,
      if (maxAge != null) 'maxAge': maxAge,
      if (isSecure != null) 'isSecure': isSecure,
      if (isHttpOnly != null) 'isHttpOnly': isHttpOnly,
      if (sameSite != null) 'sameSite': sameSite.toString().split('.').last,
    };

    final args = <String, dynamic>{'url': url.toString(), 'cookie': cookie};
    _addWebViewId(args, webViewController);
    final result = await _channel.invokeMethod<bool>('setCookie', args);

    return result ?? false;
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final args = <String, dynamic>{'url': url.toString()};
    _addWebViewId(args, webViewController);
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getCookies',
      args,
    );

    if (result == null) {
      return [];
    }

    return result
        .cast<Map<dynamic, dynamic>>()
        .map((cookieMap) => Cookie.fromMap(cookieMap.cast<String, dynamic>())!)
        .toList();
  }

  @override
  Future<Cookie?> getCookie({
    required WebUri url,
    required String name,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final args = <String, dynamic>{'url': url.toString(), 'name': name};
    _addWebViewId(args, webViewController);
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>?>(
      'getCookie',
      args,
    );

    if (result == null) {
      return null;
    }

    return Cookie.fromMap(result.cast<String, dynamic>());
  }

  @override
  Future<bool> deleteCookie({
    required WebUri url,
    required String name,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final args = <String, dynamic>{
      'url': url.toString(),
      'name': name,
      'path': path,
      'domain': domain ?? '',
    };
    _addWebViewId(args, webViewController);
    final result = await _channel.invokeMethod<bool>('deleteCookie', args);

    return result ?? false;
  }

  @override
  Future<bool> deleteCookies({
    required WebUri url,
    String path = "/",
    String? domain,
    @Deprecated("Use webViewController instead")
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final args = <String, dynamic>{
      'url': url.toString(),
      'path': path,
      'domain': domain ?? '',
    };
    _addWebViewId(args, webViewController);
    final result = await _channel.invokeMethod<bool>('deleteCookies', args);

    return result ?? false;
  }

  @override
  Future<bool> deleteAllCookies() async {
    final result = await _channel.invokeMethod<bool>('deleteAllCookies');
    return result ?? false;
  }

  @override
  Future<List<Cookie>> getAllCookies() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getAllCookies');

    if (result == null) {
      return [];
    }

    return result
        .cast<Map<dynamic, dynamic>>()
        .map((cookieMap) => Cookie.fromMap(cookieMap.cast<String, dynamic>())!)
        .toList();
  }
}
