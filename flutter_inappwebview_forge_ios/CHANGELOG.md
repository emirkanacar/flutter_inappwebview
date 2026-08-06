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
