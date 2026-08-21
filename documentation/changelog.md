# Changelog

This page highlights the changes most relevant to application developers. The
complete, release-by-release record remains in the package source:

- [Complete package changelog](https://github.com/emirkanacar/flutter_inappwebview/blob/master/flutter_inappwebview_forge/CHANGELOG.md)
- [Platform package changelogs](https://github.com/emirkanacar/flutter_inappwebview/tree/master)

## 2.1.74 - 2026-08-21

- iOS `InAppBrowser.openWithSystemBrowser` opens URLs with
  `UIApplication.open(_:options:completionHandler:)` instead of the iOS 27
  SDK-deprecated `canOpenURL` pre-check.

## 2.1.73 - 2026-08-21

- Pub.dev static analysis now uses lowerCamelCase `urls` on
  `prewarmConnections` and explicit `Future<void>` return types on
  `setServiceWorkerClient`.

## 2.1.72 - 2026-08-21

- Flutter web applications can compile with `flutter build web --wasm`.
- Localhost `dart:io` types stay behind `dart.library.io`; Web JavaScript
  bridge values convert to Dart primitives.
- `InAppLocalhostServer` remains unsupported on web.

## 2.1.71 - 2026-08-14

- Added opt-in `InAppWebViewPreloader` for headless startup and reuse through
  `InAppWebView(preloader: ...)`.
- Hardened Android, iOS, macOS, Windows, Linux, and Web keep-alive/headless
  ownership and disposal paths.
- Added cross-platform `disableAutocorrection` behavior for editable HTML
  elements.
- Added the iOS/macOS Universal Link navigation policy while retaining safe
  fallbacks on other platforms.
- Coalesced Web iframe scroll callbacks and avoided duplicate native script
  registration.
- Added lifecycle, ownership-transfer, and settings-performance regression
  coverage.

## 2.1.67 - 2026-08-13

- Added Windows pull-to-refresh support for pages without a vertical scrollbar.

## 2.1.65 - 2026-08-12

- Added persistent `ContainerController` support for platform data profiles.

## 2.1.57 - 2026-08-12

- Added the additive `InAppWebViewController.bridgeEvents` helper while
  preserving existing JavaScript handler behavior.

## Release policy

Public Dart APIs and MethodChannel contracts are kept compatible whenever
possible. Deprecated APIs remain documented during the compatibility window;
removal requires an intentional major-version decision. Runtime validation
notes are recorded separately in the repository engineering docs.

For the upstream history and original project context, see
[Migration and upstream relationship](migration-from-upstream.md).
