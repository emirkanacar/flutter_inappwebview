# Project Overview

Last reviewed: 2026-08-21

`flutter_inappwebview_forge` is a federated Flutter plugin that exposes a common Dart API for embedding a WebView, running a headless WebView, and opening an in-app browser. Native implementations translate the shared API into the WebView technology supplied by each operating system.

## Package graph

```text
flutter_inappwebview_forge
        |
        +-- flutter_inappwebview_forge_platform_interface
        |       |
        |       +-- android
        |       +-- iOS
        |       +-- macOS
        |       +-- Windows
        |       +-- Linux
        |       +-- Web
        |
        +-- platform implementations (endorsed automatically)
```

The root package owns public Dart widgets, controllers, settings, browser APIs, assets, and the example application. The platform-interface package owns contracts shared by all implementations. Endorsed platform packages register their own `dartPluginClass` or native plugin entry point through Flutter's federated-plugin mechanism.

## Package responsibilities

| Package | Native/runtime technology | Current version | Minimum Flutter | Main boundary |
| --- | --- | ---: | --- | --- |
| `flutter_inappwebview_forge` | Shared Dart API and example | 2.1.76 | 3.38.6 | Public controllers, widgets, settings, callbacks |
| `flutter_inappwebview_forge_platform_interface` | Dart federated contract | 1.1.21 | 3.32.0 | Method/event names, payload maps, types, capability metadata |
| `flutter_inappwebview_forge_android` | Android WebView, Kotlin, AndroidX | 1.0.55 | 3.32.0 | Method channels, platform views, WebView lifecycle |
| `flutter_inappwebview_forge_ios` | `WKWebView`, Swift, SPM/CocoaPods | 2.1.34 | 3.38.6 | Scene-aware windows, WebKit delegates, native resources |
| `flutter_inappwebview_forge_macos` | `WKWebView`, Swift, SPM/CocoaPods | 1.1.10 | 3.32.0 | macOS WebKit and browser windows |
| `flutter_inappwebview_forge_windows` | WebView2, C++/WinRT | 1.0.14 | 3.32.0 | WebView2 controller, child-window composition, COM lifetime |
| `flutter_inappwebview_forge_linux` | WPE WebKit, C++/GTK/EGL | 1.0.8 | 3.32.0 | WPE rendering, textures, native channel delegates |
| `flutter_inappwebview_forge_web` | Browser iframe and JavaScript | 1.0.4 | 3.32.0 | iframe lifecycle and same-origin URL access |

Versions are the package metadata at the review date, not a guarantee that all packages are published together.

## Runtime flow

1. An application creates `InAppWebView`, `HeadlessInAppWebView`, `InAppBrowser`, or another controller from the root package.
2. The root package resolves the platform implementation through the platform-interface singleton and federated plugin registration.
3. The platform implementation creates a native view/controller or headless runtime and opens the per-instance channel.
4. Settings and commands cross the Dart/native boundary as typed or map-like channel payloads.
5. Native callbacks become Dart events. Optional native values are normalized before public non-nullable Dart types are constructed.
6. Disposal closes event channels, unregisters native callbacks, releases WebView resources, and clears KeepAlive state where applicable.

The JavaScript bridge, document-start scripts, content blockers, web messages, browser windows, authentication, downloads, cookies, permissions, and fullscreen handling all follow this same contract-first flow.

## Platform notes

### Android

Android uses Kotlin native sources under `android/src/main/kotlin` and Kotlin DSL build files. The declared minimum SDK is 19, while AndroidX WebKit compatibility must be checked before dependency upgrades. Sensitive paths include WebView provider startup, document-start script registration, platform-view attach, IME focus, fullscreen cleanup, synchronous request interception, cookie deletion, and navigation-context preservation.

The Android implementation does not ship a plugin-owned JNI/NDK library. The consuming application's final APK/AAB still needs the [16 KB alignment check](../tool/check_android_16k_alignment.sh) because Flutter and transitive dependencies may contain native libraries.

### iOS and macOS

Apple implementations use `WKWebView`. iOS is scene-aware and requires iOS 15.0 or newer. Both iOS and macOS retain CocoaPods support and provide Swift Package Manager manifests with FlutterFramework and processed resources. Window presentation must resolve an active scene/window instead of relying on `UIApplicationDelegate.window`.

### Windows

Windows uses WebView2 and native C++/WinRT. WebView2 enum values can grow independently of the Dart enum, so unknown values must be ignored or represented safely. Child-window visibility and position must follow Flutter window minimize/restore events. COM and Composition objects must not be released through unsafe static destruction during DLL unload.

### Linux

Linux uses WPE WebKit with an EGL/texture rendering path and a software fallback. CMake accepts supported WPE WebKit `pkg-config` layouts and provides diagnostics when dependencies are missing. The implementation must compile against older supported WebKit versions by guarding newer symbols.

### Web

The Web implementation uses an iframe and browser JavaScript helpers. Same-origin documents may expose their current URL; cross-origin documents are restricted by the browser and must return `null` rather than stale initial data.

## Repository boundaries

- `lib/` in the root package is the public API; avoid platform-specific behavior here.
- `platform_interface/lib/` is the compatibility contract; changes require all implementations to be audited.
- Native directories own lifecycle, rendering, OS permissions, and runtime-specific workarounds.
- `example/` is both a manual test application and a source of integration tests; it is not a second public API.
- `dev_packages/` and generated files support serialization and capability metadata. Regenerate them through the repository scripts.

## Security and reliability principles

- Prefer controlled origins and least-privilege filesystem providers over universal file access.
- Treat unknown, omitted, or malformed native values as expected compatibility input.
- Assume a renderer or surface can disappear without the normal callback.
- Keep blocking work off the UI/WebView callback thread and bound any unavoidable wait.
- Make callbacks and cleanup idempotent so fallback paths do not duplicate Dart events.

See [known-issues.md](known-issues.md) and [issue-pr-resolution-log.md](issue-pr-resolution-log.md) for the fixes and validation boundaries that led to these rules.
