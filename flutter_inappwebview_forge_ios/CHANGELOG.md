## 2.1.8 - 2026-08-08

- Decode optional cookie origin properties and website data types safely instead of force-unwrapping provider-controlled values ([#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600)).

## 2.1.7 - 2026-08-08

- Guard custom URL-scheme callbacks against non-plugin WebView instances and fail the task with a structured error instead of force-casting ([#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619)).

## 2.1.6 - 2026-08-08

- Return no popup WebView when the iOS window manager is unavailable instead of creating an unattached child with a synthetic window ID ([#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)).

## 2.1.5 - 2026-08-08

- Keep prompt presentation paths guarded when no visible view controller is available; iOS device reproduction for the location-prompt lifecycle remains required ([#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)).

## 2.1.4 - 2026-08-07

- Skip duplicate `estimatedProgress` values before sending them across the platform channel.
- Coalesce `contentSize` KVO callbacks to one main-loop update while preserving the first old size and latest current size.
- Add static regression coverage for progress and content-size callback coalescing.

## 2.1.3 - 2026-08-07

- Complete pending legacy asynchronous JavaScript callbacks with a structured `WebView disposed` error during teardown instead of dropping their completion handlers.
- Add static regression coverage for pending callback cleanup and disposal behavior.

## 2.1.2 - 2026-08-06

- Return a structured error when `evaluateJavaScript` receives a nil frame instead of calling the unsafe WebKit content-world overload ([#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771)).
- Route page-world `callAsyncJavaScript` calls through the legacy result-handler shim on iOS 15-17, preserve custom content-world isolation where supported, and report the iOS 16.0.x limitation explicitly ([#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871)).
- Register and dispose the native legacy async-JavaScript result handler safely for regular and popup WebViews.
- Add static regression coverage for nil frames, result routing, popup handling, and content-world availability.

## 2.1.1 - 2026-08-06

- Terminate the injected `window.print` assignment with a semicolon for strict JavaScript parsers ([#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879)).
- Support `WebAuthenticationSessionSettings.additionalHeaderFields` on iOS 17.4+.
- Preserve object data and Error stack/message content when forwarding console arguments to Dart ([#2850](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2850)).
- Add an iOS 26+ native fullscreen container that keeps the same `WKWebView` instance alive after a video seek or time change.
- Intercept the affected HTML5 video fullscreen path without using the public JavaScript bridge, preserve dynamic and iframe video discovery, and authenticate native messages per WebView.
- Restore the WebView's original superview, constraints, frame, and autoresizing state when fullscreen ends or the WebView is disposed.
- Add source-level regression coverage for the native fullscreen state machine and controller lifecycle.

## 2.0.2 - 2026-08-06

- Defer popup WebView JavaScript initialization until Flutter attaches the platform view.
- Use the page-world fallback for popup `evaluateJavaScript` and `callAsyncJavaScript` on iOS 14–17 to avoid the known shared-configuration `WKContentWorld` crash path during multi-window navigation.
- Add regression coverage and document the remaining iOS 18/Xcode 26 validation for [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867); keep [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) tracked as an upstream WebKit fullscreen issue.
- Refresh the iOS example lockfile for implementation 2.0.2 and platform interface 1.0.4.

## 2.0.1 - 2026-08-06

- Restore scroll-view content insets from `keyboardDidHide` after UIKit finishes its keyboard layout pass, preventing the stale-negative-inset regression reported for iOS 17.2+.
- Require Flutter 3.38.6 or newer for the fixed iOS platform-view gesture behavior.
- Add static regression coverage for keyboard restoration and scene-aware window resolution.

## 2.0.0 - 2026-08-06

- Add UIScene-compatible Flutter plugin registration for both application and scene lifecycle forwarding.
- Replace AppDelegate/global window lookups with an active `UIWindowScene` key-window helper for iOS 15+.
- Raise the minimum iOS deployment target to 15.0 and remove the pre-scene window and legacy authentication-session paths.
- Complete the iOS Swift Package Manager manifest with FlutterFramework, Swift Collections, and processed resources while retaining CocoaPods support.
- Update the Swift Collections SPM lock to `1.6.0` for current Xcode package-trait resolution.
- Update the iOS example application to use Flutter's implicit engine and SceneDelegate lifecycle model.
- Add a minimal iOS example test so the example test harness can load successfully.
- Raise the Flutter baseline to `>=3.38.0` for the UIScene registration APIs.

- Breaking: raise the iOS implementation version to `2.0.0` because iOS 12 support has been removed.

## 1.0.0

- First `flutter_inappwebview_forge_ios` release as part of the Forge federated plugin.
- Reset the iOS implementation version to `1.0.0`.
- Includes the iOS keyboard, scroll callback, disposal, and dependency baseline improvements prepared for the Forge release.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
