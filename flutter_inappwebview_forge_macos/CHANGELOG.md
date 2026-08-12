## 1.1.8 - 2026-08-13

- Scope cookie operations with `webViewController` to the WebView's selected
  data store and apply per-WebView proxy settings on macOS 14+.

## 1.1.7 - 2026-08-12

- Add persistent WebKit containers through `ContainerController` and
  `InAppWebViewSettings.containerId` on macOS 14+.

## 1.1.6 - 2026-08-09

- Isolate the macOS 10.15+ `ASWebAuthenticationPresentationContextProviding` implementation from `WebAuthenticationSession`, preventing the Xcode availability compile failure ([#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)). Source tests and Swift Package manifest checks pass; consuming-app validation remains pending.

## 1.1.5 - 2026-08-08

- Keep the native macOS WebView frame synchronized to fractional Flutter platform-view bounds instead of relying on AppKit autoresizing masks ([#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826)).

## 1.1.4 - 2026-08-08

- Validate macOS WebStorage data types, records, timestamps, and display names before native cleanup operations ([#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717)).

## 1.1.3 - 2026-08-08

- Guard macOS custom URL-scheme callbacks against non-Forge WebViews and fail unsupported tasks safely ([#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619)).

## 1.1.2 - 2026-08-08

- Remove popup WebView ownership from the macOS window registry unconditionally during disposal, preventing stale browser-window references during teardown ([#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707)).

## 1.1.1 - 2026-08-06

- Support initial and runtime `ContextMenu` updates on macOS, forward create/hide lifecycle callbacks, and normalize numeric item identifiers safely ([#2683](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2683)).
- Render custom `ContextMenu.menuItems` through the native `NSMenu` hook and forward item actions to Dart ([#2855](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2855)).

- Guard `upgradeKnownHostsToHTTPS` for macOS 11.3 and newer to avoid an unavailable-selector crash ([#2741](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2741)).
- Terminate the injected `window.print` assignment with a semicolon for strict JavaScript parsers ([#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879)).
- Prefer the active key window when presenting `WebAuthenticationSession`, with visible-window fallbacks ([#2813](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2813)).
- Support `WebAuthenticationSessionSettings.additionalHeaderFields` on macOS 14.4+.
- Complete the macOS Swift Package Manager manifest with FlutterFramework, Swift Collections, and processed resources while retaining CocoaPods support.
- Update the Swift Collections SPM baseline and lock to `1.6.0` for current Xcode package-trait resolution.

- Publish the macOS Swift Package Manager migration as version `1.1.0`.

## 1.0.0

- First `flutter_inappwebview_forge_macos` release as part of the Forge federated plugin.
- Reset the macOS implementation version to `1.0.0`.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
