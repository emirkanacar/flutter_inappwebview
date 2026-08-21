# flutter_inappwebview_forge

A Flutter plugin for inline WebViews, headless WebViews, and in-app browser
windows on Android, iOS, macOS, Windows, Linux, and Web.

This package is a maintained fork of
[Flutter InAppWebView](https://github.com/pichillilorenzo/flutter_inappwebview).
The Dart widget and controller model stays familiar while Forge owns the
package names, native implementations, and releases.

## Features

- One Dart API across Android WebView, iOS/macOS `WKWebView`, Windows WebView2,
  Linux WPE WebKit, and Web iframes
- `InAppWebView`, `HeadlessInAppWebView`, and `InAppBrowser`
- Opt-in `InAppWebViewPreloader` for starting a page before a route is shown
- JavaScript handlers, user scripts, cookies, storage, and localhost serving
- Keep-alive, headless transfer, and idempotent disposal
- Runtime support checks for platform-specific features

## Requirements

- Dart SDK `^3.8.0`
- Flutter `>=3.38.6`
- Android `minSdkVersion >= 19`
- iOS 15.0+
- macOS 10.14+
- Windows with the WebView2 runtime
- Linux with WPE WebKit 2.0 development packages

The iOS implementation requires Flutter 3.38.6 or newer. Earlier Flutter
versions can still dispatch WebView gestures incorrectly on iOS.

## Installation

```yaml
dependencies:
  flutter_inappwebview_forge: ^2.1.76
```

```sh
flutter pub get
```

```dart
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
```

Endorsed platform packages (`android`, `ios`, `macos`, `windows`, `linux`,
`web`) are included automatically. Do not depend on both
`flutter_inappwebview` and `flutter_inappwebview_forge` in the same app.

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';

class BrowserPage extends StatefulWidget {
  const BrowserPage({super.key});

  @override
  State<BrowserPage> createState() => _BrowserPageState();
}

class _BrowserPageState extends State<BrowserPage> {
  InAppWebViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://example.com'),
          ),
          onWebViewCreated: (controller) {
            _controller = controller;
          },
          onLoadStop: (controller, url) {
            debugPrint('Loaded: $url');
          },
        ),
      ),
    );
  }
}
```

Keep the controller in `State`, not in `build()`. Do not call `loadUrl`,
`goBack`, or `evaluateJavascript` before `onWebViewCreated`.

Android apps need `android.permission.INTERNET`. iOS HTTP pages need a scoped
ATS exception rather than disabling ATS globally. See the
[getting started guide](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/getting-started.md)
for platform setup.

## Preload a known page

```dart
final preloader = InAppWebViewPreloader(
  headlessWebView: HeadlessInAppWebView(
    initialUrlRequest: URLRequest(
      url: WebUri('https://example.com'),
    ),
  ),
);

await preloader.prewarm();

InAppWebView(
  preloader: preloader,
  onWebViewCreated: (controller) {
    // This controller owns the transferred native WebView.
  },
);
```

Keep the preloader alive until the inline WebView takes ownership.

## Documentation

- [Getting started](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/getting-started.md)
- [Deprecated APIs](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/deprecated-api.md)
- [Examples](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/examples.md)
- [Preload and reuse](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/preload-and-reuse.md)
- [Platform guide](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/platforms.md)
- [Migration from upstream](https://github.com/emirkanacar/flutter_inappwebview/blob/master/documentation/migration-from-upstream.md)
- [Changelog](CHANGELOG.md)
- [API reference](https://emirkanacar.github.io/flutter_inappwebview/api/)
- [Repository](https://github.com/emirkanacar/flutter_inappwebview)

## Migration from `flutter_inappwebview`

```yaml
dependencies:
  flutter_inappwebview_forge: ^2.1.76
```

```dart
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
```

`InAppWebView` and `InAppWebViewController` keep the same names. The Android
namespace is `com.emirkanacar.flutter_inappwebview_forge_android`.

## Attribution and license

Originally created and maintained by Lorenzo Pichilli with contributions from
the open-source community. This fork is maintained by Emirkan Acar.

Distributed under the [Apache License 2.0](LICENSE).
