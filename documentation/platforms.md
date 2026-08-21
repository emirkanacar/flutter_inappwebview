# Platform guide

The plugin exposes one Dart API, but the underlying engine and platform
constraints differ. Design for the common contract first and gate optional
features with runtime capability checks.

## Android

- Uses the system Android WebView provider.
- Minimum SDK is **24**. AndroidX WebKit is `1.16.0`. Apps that need API
  19–23 must stay on plugin 2.1.76 / Android 1.0.55.
- NavigationParameters, Profile preconnect/prefetch/headers, BFCache
  depth settings, opt-in `WebViewBuilder`, muted audio, and NavigationListener
  remain feature-checked against the installed WebView provider.
- Hybrid composition is available and can be selected through settings.
- WebView provider version, renderer behavior, permissions, IME, fullscreen,
  and file chooser behavior depend partly on the device provider.
- Physical-device validation is recommended for keyboard, media capture,
  fullscreen, renderer loss, and provider-specific behavior.

Android applications must also declare the permissions and activity behavior
required by the pages they host. The plugin cannot grant a host application's
missing manifest permissions.

## iOS

- Uses `WKWebView` supplied by the operating system.
- Minimum deployment target is iOS 15.0.
- Scene/window lifecycle affects popup, focus, fullscreen, and authentication
  presentation.
- WebKit availability varies by iOS release. Unsupported settings retain a
  safe fallback. iOS 26 APIs such as `obscuredContentInsets`, session-storage
  fetch/restore, `isBlockedByScreenTime`, and `conversationContext` (Smart
  Reply) are availability-checked.
- Physical-device validation is recommended for keyboard, scene transitions,
  popup windows, media, and WebKit process termination.

## macOS

macOS also uses `WKWebView`, but window and application lifecycle differ from
iOS. Persistent containers and proxy behavior depend on the macOS WebKit
version and the selected data store.

## Windows

Windows uses WebView2. The installed WebView2 runtime is separate from the
Flutter package version. Keep native enum and callback handling defensive
because new WebView2 values can appear independently of the plugin release.
Opt-in native downloads follow the same `onDownloadStarting` /
`DownloadJobController` contract as Android and Apple platforms; a `null`
response remains notify-only.

## Linux

Linux uses WPE WebKit and requires the native WPE development packages. The
rendering path may use EGL or a software fallback depending on the host.
Validate the target distribution and WPE version before shipping.

## Web

The Web implementation uses an iframe and browser JavaScript. Same-origin
restrictions apply: cross-origin documents may not expose their current URL or
DOM state to the parent application.

## Capability checks

For optional API behavior, use the static support checks exposed by the
relevant class. Do not infer support from the operating system name alone;
the WebView/WebKit/provider version can be the deciding factor.
