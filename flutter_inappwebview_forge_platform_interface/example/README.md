# flutter_inappwebview_forge_platform_interface example

Apps should depend on
[`flutter_inappwebview_forge`](https://pub.dev/packages/flutter_inappwebview_forge),
not on this package. This example is for authors of a platform
implementation.

An implementation extends `InAppWebViewPlatform`, overrides the
`createPlatform*` factories it supports, and registers itself as
`InAppWebViewPlatform.instance`. Every factory that is not overridden throws
`UnimplementedError`, so a platform can grow feature by feature.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

/// Platform entry point. Flutter calls [registerWith] through the
/// `dartPluginClass` declared in the implementation's pubspec.yaml.
class MyInAppWebViewPlatform extends InAppWebViewPlatform {
  static void registerWith() {
    InAppWebViewPlatform.instance = MyInAppWebViewPlatform();
  }

  @override
  MyCookieManager createPlatformCookieManager(
    PlatformCookieManagerCreationParams params,
  ) {
    return MyCookieManager(params);
  }
}

/// In-memory cookie store. A real implementation forwards each call to the
/// native cookie API (for example over a MethodChannel).
class MyCookieManager extends PlatformCookieManager {
  MyCookieManager(super.params) : super.implementation();

  final Map<String, List<Cookie>> _cookies = {};

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
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    final cookies = _cookies.putIfAbsent(url.host, () => []);
    cookies.removeWhere((cookie) => cookie.name == name);
    cookies.add(Cookie(name: name, value: value, path: path));
    return true;
  }

  @override
  Future<List<Cookie>> getCookies({
    required WebUri url,
    PlatformInAppWebViewController? iosBelow11WebViewController,
    PlatformInAppWebViewController? webViewController,
  }) async {
    return List.unmodifiable(_cookies[url.host] ?? const <Cookie>[]);
  }
}

Future<void> main() async {
  MyInAppWebViewPlatform.registerWith();

  // The app-facing package creates platform objects through the registered
  // instance; this is what `CookieManager.instance()` does internally.
  final cookieManager = PlatformCookieManager(
    const PlatformCookieManagerCreationParams(),
  );
  final url = WebUri('https://example.com');
  await cookieManager.setCookie(url: url, name: 'session', value: 'abc');
  final cookies = await cookieManager.getCookies(url: url);
  debugPrint('${cookies.map((cookie) => '${cookie.name}=${cookie.value}')}');

}
```

Declare the Dart entry point in the implementation's `pubspec.yaml`:

```yaml
flutter:
  plugin:
    implements: flutter_inappwebview_forge
    platforms:
      linux: # android, ios, macos, windows, linux or web
        dartPluginClass: MyInAppWebViewPlatform
```

`CookieManager.isClassSupported()` and the other static capability checks use
`PlatformCookieManager.static()`, so also override
`createPlatformCookieManagerStatic()` when the platform supports them.

See `flutter_inappwebview_forge_android` (or the iOS, macOS, Windows, Linux
and Web packages) in the
[repository](https://github.com/emirkanacar/flutter_inappwebview) for complete
implementations.
