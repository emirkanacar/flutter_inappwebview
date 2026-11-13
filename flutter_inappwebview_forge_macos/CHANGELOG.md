## 1.1.13 - 2026-11-14

- Support `isLockdownModeEnabled`. The value is written to the initial
  `defaultWebpagePreferences` and to the `WKWebpagePreferences` of every
  navigation decision, so `setSettings` changes apply from the next
  navigation. A `nil` value leaves WebKit's (system) value untouched.
- Add `setCookiePolicy` / `getCookiePolicy` to the cookie manager channel
  using `WKHTTPCookieStore.CookiePolicy`, scoped to the WebView's data store
  when `webViewId` is sent. Older OS versions reply `false` / `nil`; an
  unknown policy value replies `invalid_arguments`
  (macOS 13 / macOS 14 availability guards).
- Fix `removeDataModifiedSince`: the native handler read the Dart
  `millisecondsSinceEpoch` timestamp as seconds, which moved the cutoff
  date thousands of years into the future so almost nothing was removed.
  The channel payload is unchanged; the native side now divides by 1000.
- Add `deleteBrowsingData` / `deleteBrowsingDataForSite` to the WebStorage
  manager channel, sharing the iOS `WebsiteDataSiteMatcher` implementation
  (the two copies are checked to be identical by
  `tool/run_apple_website_data_matcher_tests.sh`).
- Method-channel handlers no longer force-cast required arguments
  (`arguments!["key"] as! T`). A missing, `null`, or wrong-type required
  argument now completes the call with a `FlutterError` whose code is
  `invalid_arguments` (surfaced in Dart as a `PlatformException`) instead of
  terminating the app. Channel names, method names, and payload keys are
  unchanged; optional arguments keep their existing defaults. Native-side
  counterpart of the Android payload hardening in
  [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856).
- Swift: `InAppBrowserManager.open(arguments:)` now takes `NSDictionary?` and
  `throws`. It is only called from the plugin's own channel handler.

## 1.1.12 - 2026-11-13

- `getHtml` now logs (via `debugPrint`) when the `file://` asset fallback
  cannot read the Flutter asset instead of swallowing the error.
- Resolve the `flutter analyze` infos reported by the pub.dev static
  analysis check (`this.` qualifiers, empty catches, `print` replaced by
  `debugPrint`, overridden fields replaced by typed getters, super
  parameters, collection literals). No public API or behavior change.

## 1.1.11 - 2026-11-13

- Fix the Xcode 27 / Swift 6.4 build ([Forge #2](https://github.com/emirkanacar/flutter_inappwebview/issues/2)):
  - Remove the internal `MyCookieManager.httpCookieStore` default argument
    from the public `getCookies` / `setCookie` / `deleteCookie` /
    `deleteCookies` helpers (iOS parity; every caller passes the store).
  - Store the macOS 14-only `ContainerManager` type-erased (`Any?`) on the
    plugin, matching `proxyManager` and iOS.
  - Assign and read `WKWebView.obscuredContentInsets` as `NSEdgeInsets`
    instead of `NSDirectionalEdgeInsets`.
- The channel names and settings payloads are unchanged.

## 1.1.10 - 2026-08-21

- Map `setAudioMuted` / `isAudioMuted` to
  `setAllMediaPlaybackSuspended`.
- Start an opt-in `WKDownload` job when `onDownloadStarting` returns
  `handled` and `resultFilePath`; the previous notify-only default is
  unchanged.
- Observe `WKHTTPCookieStore` changes and add `findString`,
  `allowsInlinePredictions`, and macOS 26
  `obscuredContentInsets` / session-storage / Screen Time APIs.
- Depend on platform-interface 1.1.21.

## 1.1.9 - 2026-08-13

- Support `NavigationActionPolicy.ALLOW_WITHOUT_TRYING_APP_LINK` for keeping
  Universal Link navigations inside WKWebView
  ([#2866](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2866)).
- Add `InAppWebViewSettings.disableAutocorrection` support for editable
  content in macOS WKWebView.
- Make headless and keep-alive ownership maps non-null, idempotent, and
  duplicate-safe during native disposal and platform-view reattachment.
- Dispose all active and retained manager-owned WebViews during plugin teardown
  after atomically clearing both ownership maps.
- Finalize the macOS lifecycle coordinator from a deferred cleanup path after
  native teardown work.
- Add an internal lifecycle coordinator that gates KVO, renderer-loss, retained
  WebView, and disposal transitions without changing public channel contracts.
- Gate macOS WebView channel events and callbacks after disposal, and complete
  pending native and legacy async JavaScript callbacks with the existing safe
  terminal result; coordinator operation IDs prevent duplicate completion
  accounting.
- Apply the same disposal gate and exactly-once pending-result cleanup to the
  WebMessage and FindInteraction sub-delegates.

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
