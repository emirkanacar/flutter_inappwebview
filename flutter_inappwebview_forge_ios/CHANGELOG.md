## 2.1.31 - 2026-08-13

- Partition the iOS WebView channel dispatch into internal JavaScript,
  settings, WebMessage, and lifecycle handlers without changing channel names,
  method names, or payloads.
- Dispose all active and retained manager-owned WebViews during plugin teardown
  after atomically clearing both ownership maps.
- Remove nullable ownership placeholders from print jobs, authentication
  sessions, and in-app browsers; managers clear ownership before child teardown.
- Treat malformed screenshot compression options as safe defaults instead of
  force-casting nullable channel values.
- Serialize iOS lifecycle state transitions and debug-trace reads so concurrent
  disposal or renderer callbacks remain idempotent.
- Add a device-free native Swift lifecycle runner covering retained
  reattachment, renderer-loss recovery, exactly-once async completion,
  idempotent disposal, and concurrent disposal ownership.
- Track iOS KVO registrations and remove only observers that were successfully
  registered during WebView teardown.
- Restore active manager ownership after transferring a headless WebView to a
  normal platform view, keeping the native instance reachable for lookup and
  plugin teardown.
- Finalize the iOS lifecycle coordinator from a deferred cleanup path after
  native teardown work.
- Skip duplicate user/plugin script registration in the native content
  controller.
- Add source regression coverage for the feature-group dispatch boundary.
- Route iOS WebView channel events through the same lifecycle gate as method
  calls and complete pending native-content-world and legacy async JavaScript
  callbacks exactly once during disposal; coordinator operation IDs prevent
  duplicate completion accounting.
- Complete stale iOS WebKit permission, navigation, authentication, dialog,
  and popup callbacks with native defaults after disposal.
- Track iOS evaluateJavascript completion callbacks through the lifecycle
  coordinator and complete them once when navigation or disposal wins the
  race with WebKit.
- Guard all iOS native MethodChannel callback results and default decisions
  with a thread-safe exactly-once completion gate during teardown races.
- Allow a default decision only while its owning result handler is completing;
  a later deinit or stale WebKit fallback cannot run after a handled result.
- Gate WebMessage and FindInteraction sub-delegate calls after WebView
  disposal, and drain their pending MethodChannel results exactly once during
  teardown.
- Gate delayed keyboard, gesture, scroll, content-size, and context-menu work
  after disposal so queued UIKit callbacks cannot touch a stale WebView.
- Gate delayed focus/image-reference lookups and correct the incremental
  `isPagingEnabled` settings update to target `UIScrollView.isPagingEnabled`.
- Track iOS screenshot, PDF, and web-archive completion callbacks through the
  lifecycle coordinator so teardown completes each pending result once.
- Gate deferred popup window initialization and fullscreen-container
  presentation after WebKit/UIKit callbacks cross a main-queue boundary.
- Drop stale iOS pull-to-refresh callbacks after WebView disposal while
  resetting the control's refreshing state.
- Remove a transferred headless WebView from the active ownership map before
  reattaching it as a normal platform view.
- Make headless-to-normal transfer remove the headless owner before the native
  handoff, dispose stale entries with no native view, and preserve newer
  owners when an older wrapper finishes disposing. Duplicate headless IDs now
  also replace an active WebView owner deterministically.

## 2.1.29 - 2026-08-12

- Add `ContainerController.clearContainerData` to clear all website data in an
  iOS 17+ container without deleting the underlying `WKWebsiteDataStore`.

## 2.1.28 - 2026-08-12

- Apply `InAppWebViewSettings.proxySettings` to the WebView's
  `WKWebsiteDataStore` on iOS 17+, keeping proxy configuration aligned with
  container storage isolation. Older iOS versions retain existing behavior.

## 2.1.27 - 2026-08-12

- Route iOS cookie operations that receive `webViewController` through that
  WebView's `WKWebsiteDataStore`, keeping container-scoped cookies isolated.
  Default cookie operations remain on the default data store. Physical iOS
  container and cookie validation remains pending.

## 2.1.26 - 2026-08-12

- Add iOS 17+ persistent WebView containers through `ContainerController` and
  `InAppWebViewSettings.containerId`, backed by `WKWebsiteDataStore`.
  Container identifiers must be valid UUID strings on iOS; iOS versions below
  17 retain the default WebKit data store behavior. Physical iOS validation
  remains pending.

## 2.1.25 - 2026-08-12

- iOS: make `requestFocus()` search the WebView hierarchy for the focusable
  `WKContentView` before falling back to the WebView itself, restoring
  `document.hasFocus()` and focus events when embedded as a Flutter platform
  view ([PR #2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853)).
  Physical iOS focus validation remains pending.

## 2.1.24 - 2026-08-10

- Correct the geolocation decision-handler availability boundary for [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831): the public `WKUIDelegate` bridge is compiled and advertised for iOS 27+, while iOS 26 remains an Apple/WebKit-owned prompt path without a public decision callback. The iOS 27 Simulator deny-path diagnostic passes.

## 2.1.23 - 2026-08-10

- iOS: tolerate a stale `goBack()` call when the native WebView channel has already been removed during scene or platform-view teardown ([#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711)). Only `MissingPluginException` is treated as a teardown no-op; normal channel failures remain unchanged. Add a regression test for the missing native channel path.

## 2.1.22 - 2026-08-10

- Complete pending popup callAsyncJavaScript callbacks when a new
  navigation starts, returning a structured error instead of leaving the
  Dart future unresolved during multi-window navigation races ([#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)).
  The iPhone 17 Pro iOS 26.2 Simulator diagnostic passes three
  attach/evaluate/navigate/dispose cycles; physical iOS 15-26/Xcode 16-26
  validation remains pending.
- Add source and opt-in integration regression coverage for popup
  page/custom-world evaluation and navigation callback ownership.

## 2.1.21 - 2026-08-10

- Complete pending native iOS 14+ and legacy `callAsyncJavaScript` callbacks
  with a structured `WebView disposed` error before WebView teardown, and
  ignore late WebKit completions ([#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)).
  The iPhone 17 Pro iOS 26.2 Simulator disposal diagnostic passes; physical
  iOS 17/device validation remains pending.
- Add an opt-in navigate-away/dispose/recreate regression diagnostic.

## 2.1.20 - 2026-08-09

- Restore the pre-keyboard `UIScrollView` zoom and offset, then refresh the
  final platform-view frame/layout so WKWebView's DOM viewport recovers after
  HTML input dismissal ([#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787)). The iPhone 17 Pro iOS 26.2 Simulator diagnostic passes; physical iOS 17/device validation remains pending.
- Add source regression coverage for the keyboard viewport restoration path.

## 2.1.19 - 2026-08-09

- Isolate the iOS 13+ `ASWebAuthenticationPresentationContextProviding` implementation from `WebAuthenticationSession`, preventing the Xcode 26 availability compile failure ([#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)). Source tests and the Xcode 27 iOS example build pass; exact Xcode 26.4.1 validation remains pending.

## 2.1.18 - 2026-08-08

- Make native `InAppWebView.dispose()` idempotent before observer, WebKit, and fullscreen cleanup, reducing duplicate teardown `EXC_BAD_ACCESS` risk ([#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)). Physical iOS teardown validation remains pending.

## 2.1.17 - 2026-08-08

- Harden popup `windowId` WebView lifecycle against stale KVO callbacks, pre-attachment JavaScript evaluation, and transient shared content-world/frame objects ([#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)). iOS device/Xcode validation remains pending.
- Count pending `shouldOverrideUrlLoading` decisions before flushing replacement-header loads, and ignore malformed URL requests safely ([#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568)). Physical navigation/header validation remains pending.
- Keep the iOS 26 fullscreen-container mitigation and geolocation decision bridge in the release gate ([#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)). Physical iOS 26 validation remains pending.
- Add source regression coverage for stale KVO objects, popup page-world evaluation, concurrent navigation decisions, and lifecycle disposal.

## 2.1.16 - 2026-08-08

- Defer iOS `loadUrl` requests issued from `shouldOverrideUrlLoading` until the WebKit navigation decision is released, preventing a white-screen/deadlock path when replacing navigation headers ([#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568)). Physical iOS navigation/header validation remains pending.

## 2.1.15 - 2026-08-08

- Bridge iOS 26 `WKUIDelegate` geolocation permission decisions to `onGeolocationPermissionsShowPrompt`, including safe deny fallback and response decoding ([#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)).
- Add iOS source regression coverage and validate the iOS example build with Xcode 27; physical iOS 26 grant/deny and scene-lifecycle validation remains required.
- Keep the iOS WebMessageChannel source compatible with Xcode 27 by removing an invalid optional binding around the non-optional `WebMessage.fromMap` result.

## 2.1.14 - 2026-08-08

- Align the repository Flutter development baseline with 3.44.8 and register the iOS native source assertions as an executable regression test.
- Block rejected or unhandled `onCreateWindow` popups without loading their target URL into the caller WebView ([#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)).

## 2.1.13 - 2026-08-08

- Validate iOS WebMessageChannel port indices and message payloads before accessing ports or dispatching messages (internal boundary hardening; not an upstream #2584 fix).

## 2.1.12 - 2026-08-08

- Validate iOS proxy settings and rules before constructing proxy configurations, ignoring malformed rule entries ([#2805](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2805)).

## 2.1.11 - 2026-08-08

- Validate iOS `loadFile` asset paths before dispatching them to the WebView channel (internal boundary hardening; not upstream #2654).

## 2.1.10 - 2026-08-08

- Validate iOS `postUrl` and `loadData` channel arguments before constructing URLs or reading typed post data (internal boundary hardening; not upstream #2654).

## 2.1.9 - 2026-08-08

- Validate iOS WebMessageListener creation payloads before constructing listeners, ignoring malformed IDs, names, or origin-rule lists (internal boundary hardening; not an upstream #2584 fix).

## 2.1.8 - 2026-08-08

- Decode optional cookie origin properties and website data types safely instead of force-unwrapping provider-controlled values (internal boundary hardening; not an upstream #2600 fix).

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

## 2.1.31 - 2026-08-13

- Refresh the iOS WebView input hierarchy when `disableInputAccessoryView` is
  enabled, including when an HTML input receives focus again.
- Add document-start autocorrection and spelling-suggestion hints for editable
  HTML elements through `InAppWebViewSettings.disableAutocorrection`.
- Make keep-alive and headless ownership maps non-optional and idempotent,
  including controlled replacement for duplicate IDs.
- Avoid recompiling unchanged content-blocker rules and applying omitted
  `mediaType` or scroll-axis settings during partial settings updates.
- Add an internal lifecycle coordinator for retained/reattached WebViews,
  async JavaScript operations, and idempotent disposal. Stale callbacks are
  ignored after teardown and pending JavaScript callbacks complete once.

## 2.1.30 - 2026-08-13

- Add iOS 18+ support for configuring the WebView's Apple Writing Tools
  behavior through `InAppWebViewSettings.writingToolsBehavior` ([#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690)).
  The setting is applied to the initial `WKWebViewConfiguration`; older iOS
  versions keep WebKit's default behavior.
