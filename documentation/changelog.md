# Changelog

This page highlights the changes most relevant to application developers. The
complete, release-by-release record remains in the package source:

- [Complete package changelog](https://github.com/emirkanacar/flutter_inappwebview/blob/master/flutter_inappwebview_forge/CHANGELOG.md)
- [Platform package changelogs](https://github.com/emirkanacar/flutter_inappwebview/tree/master)

## 2.1.77 - 2026-08-21

- Continue native WebView API gap coverage: Android NavigationParameters
  + Profile `preconnect`, BFCache depth settings, opt-in WebViewBuilder,
  `saveStateWithOptions`, ProcessGlobalConfig UI-thread startup mode,
  Windows `DownloadJobController` parity, and iOS 26
  `conversationContext` (Smart Reply).
- **Android breaking floor:** `minSdkVersion` is now **24** and AndroidX
  WebKit is `1.16.0`. Stay on 2.1.76 for API 19–23 hosts.
- Ships with platform-interface 1.1.22, Android 1.0.56, iOS 2.1.35,
  Windows 1.0.15, and macOS 1.1.10.

## 2.1.76 - 2026-08-21

- Add `setAudioMuted` / `isAudioMuted`, opt-in native
  `DownloadJobController` downloads, Android `onVisualStateReady`,
  iOS/macOS cookie observers, `findString`, Android Profile headers
  and prefetch, feature-gated AndroidX WebKit 1.15 navigation APIs,
  and iOS 26 obscured-content / session-storage helpers.
- A `null` `onDownloadStarting` response remains notify-only.
- Ships with platform-interface 1.1.21, Android 1.0.55, iOS 2.1.34, and
  macOS 1.1.10. Android `minSdk 19` is unchanged.

## 2.1.75 - 2026-08-21

- Deprecated, still present: `InAppWebViewGroupOptions` / `*Options`,
  `initialOptions`, `setOptions` / `getOptions`, `onLoadError` /
  `onLoadHttpError`, `onDownloadStart` / `onDownloadStartRequest`,
  `androidOn*` / `iosOn*` callbacks, `clearCache()`, `findAllAsync`,
  `JavaScriptHandlerCallback`, and `IOS*` / `Android*` type aliases. Use the
  current names in [Deprecated APIs](deprecated-api.md). Removal needs a
  major version; see the
  [migration plan](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/deprecated-api-migration-plan.md).
- Deprecated `saveFormData` now states that Android Autofill replaced
  WebView form-data saving. It is a no-op on API 26+ and has no Dart
  replacement.
- Deprecated `forceDark` / `forceDarkStrategy` remain; use
  `algorithmicDarkeningAllowed`.

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
possible. Deprecated APIs remain in the public surface during the
compatibility window and are listed by name in each affected changelog and in
[Deprecated APIs](deprecated-api.md). Removal requires an intentional
major-version decision; the sequence is
[Deprecated API migration plan](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/deprecated-api-migration-plan.md).
Runtime validation notes are recorded separately in the repository
engineering docs.

For the upstream history and original project context, see
[Migration and upstream relationship](migration-from-upstream.md).
