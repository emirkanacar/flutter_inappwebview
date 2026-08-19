<div align="center">

# flutter_inappwebview_forge

![InAppWebView-logo](https://user-images.githubusercontent.com/5956938/195422744-bdcfed16-73f0-4bc9-94ab-ecf10771a1c4.png)

[![pub package](https://img.shields.io/pub/v/flutter_inappwebview_forge.svg)](https://pub.dev/packages/flutter_inappwebview_forge)
[![pub points](https://img.shields.io/pub/points/flutter_inappwebview_forge)](https://pub.dev/packages/flutter_inappwebview_forge/score)
[![license](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](LICENSE)

A maintained Flutter plugin for inline WebViews, headless WebViews, and in-app
browser windows on Android, iOS, macOS, Windows, Linux, and Web.

</div>

`flutter_inappwebview_forge` is a maintained fork of
[Flutter InAppWebView](https://github.com/pichillilorenzo/flutter_inappwebview).
The public Dart API stays familiar (`InAppWebView`, `InAppWebViewController`,
settings, and callbacks) while this repository owns the Forge package names,
native implementations, and release process.

## Features

- One Dart API across Android WebView, iOS/macOS `WKWebView`, Windows WebView2,
  Linux WPE WebKit, and Web iframes
- Inline `InAppWebView`, `HeadlessInAppWebView`, and `InAppBrowser`
- Opt-in `InAppWebViewPreloader` to start a page before a route is shown and
  reuse the same native WebView
- JavaScript handlers, user scripts, cookies, storage, and localhost serving
- Keep-alive, headless transfer, and disposal paths that stay idempotent
- Runtime support checks so unavailable platform features fail safely

## Requirements

| Target | Minimum |
| --- | --- |
| Dart | `^3.8.0` |
| Flutter | `>=3.38.6` |
| Android | `minSdkVersion >= 19`, AGP `>= 7.3.0` |
| iOS | 15.0+, Xcode 15+ |
| macOS | 10.14+, Xcode 15+ |
| Windows | WebView2 runtime and NuGet CLI on `PATH` |
| Linux | WPE WebKit 2.0 development packages |
| Web | iframe plus the plugin support script when required |

iOS still needs Flutter 3.38.6 or newer. Earlier Flutter versions can dispatch
WebView gestures incorrectly on iOS.

## Installation

```yaml
dependencies:
  flutter_inappwebview_forge: ^2.1.71
```

```sh
flutter pub get
```

```dart
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
```

Endorsed platform packages are selected automatically. Do not add
`flutter_inappwebview` and `flutter_inappwebview_forge` to the same app.

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

Keep the controller in `State`, not in `build()`. Do not issue navigation or
JavaScript commands before `onWebViewCreated`.

## Preload a known page

If the destination URL is known before the route opens, start the native
WebView early and reuse it:

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

Keep the preloader alive until the inline WebView takes ownership. Dispose it
only when the application no longer needs that WebView.

## Documentation

User guides live in [`documentation/`](documentation/README.md):

- [Getting started](documentation/getting-started.md)
- [Inline WebView](documentation/in-app-webview.md)
- [Preload and reuse](documentation/preload-and-reuse.md)
- [Examples and recipes](documentation/examples.md)
- [Feature guide](documentation/features.md)
- [Platform guide](documentation/platforms.md)
- [Lifecycle and performance](documentation/lifecycle-and-performance.md)
- [Troubleshooting](documentation/troubleshooting.md)
- [Migration from upstream](documentation/migration-from-upstream.md)
- [Changelog](documentation/changelog.md)
- [API reference](documentation/api-reference.md)

Contributor and engineering records are in [`docs/`](docs/README.md):

- [Project overview](docs/project-overview.md)
- [Development guide](docs/development.md)
- [Known issues](docs/known-issues.md)
- [Open work plan](docs/open-work-plan.md)

## Migration from `flutter_inappwebview`

Replace the package name and import. Widget and controller names stay the same.

```yaml
dependencies:
  flutter_inappwebview_forge: ^2.1.71
```

```dart
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
```

See [Migration and upstream relationship](documentation/migration-from-upstream.md)
for the full package map and compatibility notes.

## Support

Report bugs and compatibility problems in the
[issue tracker](https://github.com/emirkanacar/flutter_inappwebview/issues).

## Attribution and license

Originally created and maintained by Lorenzo Pichilli with contributions from
the open-source community. This fork is maintained by Emirkan Acar.

See [ATTRIBUTION.md](ATTRIBUTION.md). Distributed under the
[Apache License 2.0](LICENSE).
