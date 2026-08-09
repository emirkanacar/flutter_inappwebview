# Issue and PR Resolution Log

Last reviewed: 2026-08-09

This document records the issue and pull-request exports supplied for the Forge maintenance work and relates them to the implementation already present in this repository.

## How to read this log

- The supplied `issues.csv` snapshot contains 125 issue records. Every exported issue has state `OPEN` because that is the upstream state at export time.
- The supplied `pr.csv` snapshot contains 73 PR records. Every exported PR has state `OPEN` for the same reason.
- `OPEN` in the export is not evidence that the local Forge implementation is unfixed. Local status is based on code, regression tests, changelogs, and the commit history in this repository.
- The CSV files contain title-level metadata only. They do not contain merge commits, review decisions, issue bodies, or complete issue-to-PR relationships.
- Where a PR clearly matches an issue by title or adjacent report, the relationship is listed. Otherwise the issue and PR are kept as separate records rather than inferred as a false one-to-one mapping.
- “Fixed”, “mitigated”, and “validation pending” describe the local implementation boundary. They do not change upstream GitHub state.

The detailed root-cause notes are in [known-issues.md](known-issues.md). Package release notes are in the root and platform `CHANGELOG.md` files.

## 2026-08-08 audit correction

GitHub CLI review of the upstream issue bodies corrected three historical local
associations. Upstream [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600)
is the iOS `windowId`/`EXC_BAD_ACCESS` popup crash, not cookie property
decoding. Upstream [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584)
is an iOS 18.4 Simulator/WebKit startup crash, not WebMessage payload
validation. Cookie and WebMessage validation remain useful internal hardening,
but they are no longer presented as fixes for those upstream records. The
startup crash is classified as a host/platform boundary; the popup crash stays
runtime-pending until iOS device evidence is available. Upstream [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698)
is an Android System WebView/Chromium renderer termination report tied to a
provider update and rollback, not the `forceDarkStrategy` cast reports in
[#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673) and
[#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594);
#2698 is therefore classified as a host/provider boundary. Upstream [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)
is the iOS/Android WebView disposal crash, not the internal iOS navigation
payload checks.

## 2026-08-09 critical Android/iOS triage correction

GitHub CLI review of [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753)
confirms that the report concerns HTTPS iframe subresource failures that do not
reach iOS `onReceivedError`. The Forge implementation already forwards the two
public `WKNavigationDelegate` failure callbacks, but WebKit does not expose an
equivalent arbitrary-subresource callback. The record is therefore tracked as
an Apple/WebKit capability boundary rather than a speculative JavaScript patch.

The same review of Android [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680)
found only a Cloudflare `206 Partial Content`/mobile-carrier failure. The
follow-up reports that the same resource works with `webview_flutter`, and
Forge's default path does not intercept or rewrite the request. The upstream
record was stale-closed on 2026-08-07; locally it moves from active reproduction
to host/provider boundary tracking without changing the historical export.

## 2026-08-09 Android callback payload hardening

Android [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)
now validates optional native MethodChannel string fields by runtime type before
dispatching callbacks. Null or malformed provider values no longer reach a
non-null `String` local in the event dispatcher; the existing callback and
default-behavior contracts are preserved. Focused Android tests pass, while the
API/provider device matrix remains in the runtime register.

## 2026-08-09 iOS/macOS authentication availability hardening

GitHub CLI review of upstream [PR #2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809)
confirmed that Xcode 26 diagnoses the `ASWebAuthenticationPresentationContextProviding`
conformance when its `presentationAnchor(for:)` witness is not isolated behind
the protocol's platform availability boundary. Local [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)
now uses availability-gated provider objects for iOS and macOS and retains each
provider for the lifetime of its authentication session. The iOS/macOS source
tests and Swift Package manifest checks pass, and the iOS example builds with
Xcode 27. Exact Xcode 26.4.1 and macOS consuming-app validation remain pending;
the upstream GitHub state is unchanged.

## 2026-08-09 Android activity-extra runtime validation

Android [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)
now has a passing API 35 AVD diagnostic for nested InAppBrowser and Chrome
Custom Tabs activity payloads. The run found and fixed a native/Dart Chrome
Custom Tabs manager channel typo and showed that unbinding the Custom Tabs
service from `onStop` dropped lifecycle callbacks while the external tab was
foreground; the session now remains bound until activity destruction. The
Android package suite (42 tests), debug APK build, activity launch, URL load,
and open/load/close callbacks pass on `emulator-5554`. Restore/rotation,
malformed external extras, physical/provider coverage remain pending, so #2536
stays in the runtime-validation register and the local counts do not change.

## 2026-08-09 Android interception dispatch hardening

GitHub CLI review of closed upstream [PR #2773](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2773)
confirmed the high-volume `shouldInterceptRequest` mitigation: dispatching the
native-to-Dart callback at the front of the Android main-looper queue. Local
Android [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)
now combines that priority dispatch with bounded concurrency, a 250 ms timeout,
queued-runnable cancellation, and late-result suppression. Service Worker
interception uses the same priority path. API 35 validation then identified the
Kotlin-migration overload recursion in `injectDeferredObject`; Android 1.0.34
now calls the platform `WebView.evaluateJavascript` overload directly. Android
source tests and the API 35/WebView 124 diagnostic pass with 24 rapid
navigations, `finalLoaded=true`, 31 interception callbacks, and no OOM. Physical
Android 10/11 OEM/provider and back/forward validation remain pending. The
upstream issue and PR states are unchanged.

## Current local status counts

The export contains 125 issues and 73 PRs. Local implementation status is
tracked separately from that historical export:

| Status | Count | Register |
| --- | ---: | --- |
| Locally implemented or mitigated; runtime validation pending | 68 issues | [runtime-validation-pending.md](runtime-validation-pending.md) |
| Closed by source review | 1 issue (`#2745`) | No package runtime gate |
| Host/platform-specific boundary | 13 issues (`#2570`, `#2584`, `#2598`, `#2636`, `#2659`, `#2680`, `#2688`, `#2698`, `#2713`, `#2723`, `#2727`, `#2753`, `#2796`) | Host/provider/engine/application/site/dependency tracking in [known-issues.md](known-issues.md); no Forge-owned fix |
| Open implementation or reproduction | 43 issues | [open-work-plan.md](open-work-plan.md) |
| PR-only local implementations awaiting runtime validation | 3 PRs | `#2771`, `#2871`, `#2474` |

The issue inventory below remains the historical 125-record export and is not
reduced when a record moves between the local status registers.

## Local resolution history

| 2026-08-08 | Android cold-start and startup reattach [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) | [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) | Android now orders provider startup and document-start registration, retries transient failures, and recreates the startup executor after engine detach while ignoring stale generations. Android source tests pass; release/AOT and headless real-device validation remains pending. |
| 2026-08-09 | iOS/macOS Xcode authentication availability [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830) | [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809) | iOS 2.1.19 and macOS 1.1.6 isolate the authentication presentation provider behind the iOS 13/macOS 10.15 availability boundaries. iOS/macOS source tests, Swift Package manifest checks, and the Xcode 27 iOS example build pass; exact Xcode 26.4.1 and macOS consuming-app validation remain pending. |
| 2026-08-08 | Android interception freeze and cookie ANR [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | No upstream relationship inferred | Android synchronous interception is bounded by concurrency and timeout limits, and `deleteAllCookies` no longer flushes synchronously after asynchronous removal. Focused Android tests pass; Android 10/provider and Play Console runtime validation remains pending. |
| 2026-08-09 | Android interception dispatch hardening [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | [#2773](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2773) (closed, not merged) | Android 1.0.31 prioritizes WebView and Service Worker interception callbacks on the main looper, cancels queued callbacks after timeout, and suppresses late results. Android tests and analysis pass; rapid-navigation/provider validation remains pending. |
| 2026-08-09 | Android rapid-navigation JavaScript injection OOM [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | No upstream relationship inferred | Kotlin migration overload recursion in `injectDeferredObject` called the plugin `evaluateJavascript` overload instead of the platform WebView overload. Android 1.0.34 fixes the boundary and adds a source regression test. The API 35/WebView 124 diagnostic passes 24 rapid navigations with `finalLoaded=true`, the `final` DOM marker, 31 interception callbacks, and no fatal crash; physical Android 10/11 OEM/provider validation remains pending. |
| 2026-08-09 | Android fullscreen exit keyboard restoration [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878) | No upstream relationship inferred | Android 1.0.34 restores the Flutter container input connection after `onHideCustomView()` by requesting focus, resetting the non-hybrid proxy when applicable, and restarting the Android IME input. The opt-in diagnostic performs a tapped HTML5 fullscreen request, exits it, focuses a separate Flutter `TextField`, and passes on API 35/WebView 124 (`insetBeforeFocus=0.0`, `insetAfterFocus=24.0`, focus active); Samsung/WebView 150+ and physical-device validation remain pending. |
| 2026-08-08 | iOS popup/window-ID crashes [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | No upstream relationship inferred | iOS now defers popup window-ID initialization off KVO, verifies observed object identity, ignores callbacks after disposal, and uses the initialized page world for popup JavaScript. Source tests pass; iOS device/Xcode validation remains pending. |
| 2026-08-08 | iOS header replacement navigation [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | No upstream relationship inferred | iOS counts simultaneous navigation-policy decisions, queues replacement-header loads until the final decision handler completes, and rejects malformed URL requests safely. Source tests pass; physical navigation validation remains pending. |
| 2026-08-08 | iOS 26 fullscreen and geolocation behavior [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | The native fullscreen-container mitigation and iOS 26 geolocation decision bridge remain enabled and source-validated. Physical iOS 26 fullscreen/grant/deny validation remains required; no upstream state was changed. |
| 2026-08-09 | iOS keyboard `visualViewport` diagnostic [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860) addresses the separate #2859 inset regression | Source review confirms that the Forge keyboard change and upstream #2860 restore native `contentInset` for #2859, not WebKit's DOM `visualViewport`. The opt-in diagnostic uses the reported `resizeToAvoidBottomInset: false` trigger and records WebKit viewport metrics plus the Flutter WebView frame. On iOS 27.0, the WebKit focus fallback reaches `activeElementId=keyboard-input`, but `TextInput.show` does not open the software keyboard (`keyboardDelta=0`); an iOS 26.2 run returns no non-zero viewport metrics after load. No package behavior change was made; physical/iOS 17/native inset-frame validation remains pending. |
| 2026-08-08 | iOS draggable overlay gesture ownership [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598) | No upstream relationship inferred | Source review confirms that the overlay belongs to Flutter's host gesture arena: Forge forwards `gestureRecognizers` to `UiKitView`, and its opt-in `preventGestureDelay` hook only runs when the WebView itself is hit-tested. The reported iOS 18/18.6 overlay-drag/underlying-scroll behavior is therefore tracked as a host/platform boundary with no package code change; a minimal Flutter 3.38.6+ comparison remains the required follow-up. |
| 2026-08-08 | iOS Password AutoFill ownership [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570) | No upstream relationship inferred | Source review found the standard `WKWebViewConfiguration` path and no Forge-owned Password AutoFill switch. Apple requires host-app associated domains and semantically marked HTML fields; the plugin cannot modify consuming-app entitlements, the site's AASA response, or third-party login markup. The report remains a host/application/site boundary pending the same-domain physical-device and native `WKWebView` comparison. |
| 2026-08-08 | iOS navigation decision/load ordering [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | No upstream relationship inferred | iOS now queues `loadUrl` requests issued while `shouldOverrideUrlLoading` is waiting for the WebKit policy decision and flushes them after `.allow`/`.cancel` is delivered. The source regression, Flutter analysis, SwiftPM manifest check, and Xcode example build pass; physical navigation/header validation remains pending. |
| 2026-08-08 | iOS Simulator dyld failure [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636) | No upstream relationship inferred | The native stack and upstream reproduction identify an iOS 18.4/18.5 Simulator/WebKit deployment-target failure while physical devices and newer Simulator runtimes work. Forge supports iOS 15.0 and cannot safely raise that baseline, so this is recorded as a host/platform boundary with no package code change. |
| 2026-08-08 | Android HTML time input picker crash [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659) | No upstream relationship inferred | The supplied NPE ends in Android's `TimePickerSpinnerDelegate.updateInputState`; source review found no Forge-owned time picker or interception boundary. The record remains visible for OEM/framework tracking and is not presented as locally fixed. |
| 2026-08-08 | iOS modal-sheet gesture lifecycle [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727) | No upstream relationship inferred | Upstream reports identify a Flutter iOS platform-view gesture regression and multiple users report that Flutter 3.41/3.41.3 resolves it. Forge retains the 3.38.6 compatibility baseline and has no safe WebKit-layer control point, so the record is tracked as a host/platform boundary without a package code change. |
| 2026-08-08 | iOS Drawer/WebView touch lifecycle [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713) | No upstream relationship inferred | The report aligns with Flutter's iOS platform-view hit-testing and gesture lifecycle issue chain ([#175099](https://github.com/flutter/flutter/issues/175099), [#158961](https://github.com/flutter/flutter/issues/158961)); reported workarounds operate at the Flutter overlay or engine level. Forge's iOS WebKit layer has no safe control point for resetting that state, so the record is tracked as a host/platform boundary without a package code change. |
| 2026-08-08 | iOS ListView/NestedScrollView gesture lifecycle [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723) | No upstream relationship inferred | The reproducer uses Flutter 3.35.5 and the reported failure is a platform-view tap loss after parent scrolling. The linked [workaround](https://khal.it/blog/flutter-webview-tap-gestures-break-nestedscrollview-ios-fix) identifies a Flutter framework fix in 3.38.6+, which is Forge's compatibility baseline; the iOS widget passes gesture recognizers through to `UiKitView` and has no safe native control point for repairing an older Flutter gesture arena. The record is tracked as a host/platform boundary without a package code change. |
| 2026-08-08 | iOS/Android localhost server liveness [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720) | No upstream relationship inferred | The shared default server now clears a stale `HttpServer` reference on request-stream completion or error, preserving current-server identity during close/replacement races. Platform-interface source, normal-close, controlled-restart, and independent-server lifecycle tests pass; iOS/Android release-mode background/resume/restart/reload validation remains pending in the runtime register. |
| 2026-08-08 | Android display-size WebView geometry [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721) | No upstream relationship inferred | Android now refreshes hybrid-composition WebView geometry after actual size changes and visibility return through an idempotent invalidation/relayout helper. The new source regression, Android focused tests, and example APK/AAR build pass; Android 16/API 36 display-size and OEM provider runtime validation remains pending. |
| 2026-08-09 | Android activity-extra deserialization [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | No upstream relationship inferred | Android 1.0.33 uses a recursive primitive/nested-`Bundle` codec, corrects the Chrome Custom Tabs manager channel namespace, and keeps the Custom Tabs session bound until activity destruction. Android source tests (41), debug APK build, and the API 35 `emulator-5554` InAppBrowser/Chrome Custom Tabs open-load-close diagnostic pass. Restore/rotation, malformed external extras, and physical/provider validation remain pending. |
| 2026-08-09 | iOS popup default handling [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | No upstream relationship inferred | iOS now removes the pending popup transport without loading the target into the caller WebView when `onCreateWindow` returns `false`, `null`, or is unhandled. Explicit same-window `controller.loadUrl` remains available from the callback; source regression coverage passes. The opt-in iOS 26.0, 26.2, and 27.0 Simulator diagnostics receive `https://example.com/popup`, return `false`, and keep the caller at `https://example.com/`; physical iOS 15-26 popup attachment, navigation, disposal, and scene-transition validation remains pending. |
| 2026-08-08 | Linux no-GL buffer path [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | No upstream relationship inferred | `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` now enables `LIBGL_ALWAYS_SOFTWARE` before WPE starts and skips EGL import so SHM/pixel import supplies CPU-readable frames. Static source coverage was added; Fedora/X11/Intel runtime validation remains pending. |
| 2026-08-08 | JavaScript evaluation source review [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | No upstream relationship inferred | The only dynamic evaluation sites are explicit `evaluateJavascript` wrappers receiving the caller-provided source. Android and Web static tests pin those boundaries; no plugin-owned remote-data sink was found, so no speculative replacement was made. |
| 2026-08-08 | iOS 26 geolocation decision bridge [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | iOS 26 now implements the new `WKUIDelegate` geolocation decision callback and forwards it through the existing Dart `onGeolocationPermissionsShowPrompt` contract. The iOS source test, platform-interface tests, and Xcode 27 iOS example build pass; the opt-in HTTPS deny-path diagnostic passes on the iOS 27 Simulator with `https://example.com` and `error:1`. Fresh iOS 26.0/26.2 Simulator runs build successfully but leave `callbackOrigin=null` and the DOM result unset, so Simulator/WebKit behavior remains unresolved; physical iOS 26 grant/deny and scene-lifecycle validation remains required. |
| 2026-08-08 | macOS fractional platform-view frame sync [#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826) | No upstream relationship inferred | macOS no longer relies on AppKit autoresizing masks for the native WebView child. Bounds synchronization is guarded for finite frames and runs during layout and resize callbacks. The new source regression assertion fails against the original implementation and passes after the fix; the Xcode 27 example build passes with a temporary 12.0 deployment-target override, while Retina/fractional-width runtime validation remains pending. |

| 2026-08-09 | Android nullable and malformed callback payloads [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856); Web iframe URL tracking [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | No upstream relationship inferred | Android request-result and event decoding now validates optional strings before constructing `WebUri`, public fields, or callback arguments. Web same-origin/current-location and cross-origin-null behavior is protected by source assertions. Android focused tests pass with the system Flutter 3.44.8; Web test loading is blocked by the toolchain mismatch, and device/browser validation remains pending. |
| 2026-08-08 | Android provider-specific setting casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594); macOS browser-window teardown [#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707) | No upstream relationship inferred | Android `forceDarkStrategy` setter/getter provider casts fail open and focused tests pass. macOS popup registry removal is unconditional and protected by a static assertion. macOS test loading is blocked by the Flutter toolchain mismatch; provider/device and macOS runtime validation remain pending. |
| 2026-08-08 | Android renderer callback boundary [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); iOS location prompt lifecycle [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | Android renderer callbacks now reject unrelated WebView instances and static regression tests pass. iOS now bridges the iOS 26 geolocation decision handler through Dart while preserving existing presenter guards; the iOS source test and Xcode 27 example build pass, and physical iOS 26 runtime validation remains required. |
| 2026-08-08 | Android activity-result lifecycle [#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814), [#2797](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2797), [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711), [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709); Windows resize teardown [#2736](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2736) | No upstream relationship inferred | Android listener snapshot dispatch and regression tests pass. Windows late-resize controller guard is source-validated; Windows test loading is blocked by the Flutter toolchain mismatch and native runtime validation remains pending. |
| 2026-08-08 | Linux rendering fallback [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861); iOS popup lifecycle [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | No upstream relationship inferred | Linux exposes an explicit software-rendering switch and preserves the pixel-buffer fallback. iOS rejects popup creation without a live manager instead of returning an unattached child. The iOS source test passes with Flutter 3.44.8; Linux loader and native runtime validation remain pending. |
| 2026-08-08 | Android popup lifecycle [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763); JavaScript security claim [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | No upstream relationship inferred | Android now rejects popup creation without a live manager before allocating a synthetic window ID or storing a result message. The #2745 source-to-sink review found no plugin-owned direct `eval()` sink; the security claim remains unestablished pending exploit evidence. |
| 2026-08-08 | Android callback ownership [#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783) | No upstream relationship inferred | Android client-certificate callbacks now reject non-Forge WebViews safely instead of force-casting them. Static regression coverage passes; provider/device input validation remains pending. |
| 2026-08-08 | iOS custom scheme ownership [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619); Windows headless teardown [#2778](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2778) | No upstream relationship inferred | iOS custom-scheme callbacks now fail safely for unrelated WebViews. Windows headless size access checks the controller lifetime. The iOS source test passes with Flutter 3.44.8; Windows loader and native runtime validation remain pending. |
| 2026-08-08 | Internal iOS cookie property decoding; Android startup callback lifetime | No upstream relationship inferred | iOS cookie cleanup now decodes optional origin properties and data types without force-casts. Android plugin detach now invalidates the old startup generation and recreates the coordinator executor on reattach. Static source coverage passes; iOS WebKit and Android device validation remain pending. |
| 2026-08-08 | Internal iOS WebMessageListener payloads; internal iOS WebMessageChannel payloads | No upstream relationship inferred | iOS listener construction, message maps, and port indices are validated before access. These are internal boundary hardening changes and are not associated with upstream #2584. |
| 2026-08-08 | iOS 18.4 Simulator startup crash [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584) | No upstream relationship inferred | GitHub CLI review of the issue body and comments identifies an external `libswiftWebKit.dylib`/Simulator/WebKit startup boundary. No Forge-owned source fix is justified; the record moves from runtime-pending to host/platform tracking. |
| 2026-08-08 | iOS popup `windowId` lifetime hardening [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | No upstream relationship inferred | Popup window-ID initialization is deferred off KVO, stale observer objects are ignored after disposal, and popup JavaScript stays in the initialized page world with an attachment guard. iOS source tests pass; iOS 15–26 device/Xcode validation remains pending. |
| 2026-08-08 | Android WebStorage callback entries [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717); internal iOS navigation payload validation | No upstream relationship inferred | Android malformed origin entries are skipped safely. iOS `postUrl` and `loadData` validate required channel values and return structured argument errors; this is internal hardening and is not associated with upstream #2654. The iOS source test passes with Flutter 3.44.8; provider/device validation remains pending. |
| 2026-08-08 | Android compatibility callback ownership [#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783); internal iOS load-file payload validation | No upstream relationship inferred | Android compat callbacks now reject unrelated WebViews safely. iOS load-file payloads now validate required asset paths; this is internal hardening and is not associated with upstream #2654. Android tests and the iOS source test pass with Flutter 3.44.8; provider/device validation remains pending. |
| 2026-08-08 | macOS custom scheme ownership [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619); Android navigation ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697) | No upstream relationship inferred | macOS custom-scheme callbacks now reject unrelated WebViews. Android URL navigation now returns native default behavior for unrelated WebViews. Static/source validation is recorded; native runtime validation remains pending. |
| 2026-08-08 | Android page lifecycle ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); iOS proxy payloads [#2805](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2805) | No upstream relationship inferred | Android page lifecycle callbacks now reject unrelated WebViews safely. iOS proxy settings and rules now use optional decoding and malformed-rule filtering. Static/source validation is recorded; provider/runtime validation remains pending. |
| 2026-08-08 | Android Chrome callback ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); internal iOS WebMessageChannel payloads | No upstream relationship inferred | Android Chrome callbacks now reject unrelated WebViews safely. iOS WebMessageChannel indices and payloads are validated before access; this internal hardening is not associated with upstream #2584. Android tests and the iOS source test pass with Flutter 3.44.8; iOS runtime validation remains pending. |
| 2026-08-08 | Android file chooser callback ownership [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783); macOS WebStorage payloads [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717) | No upstream relationship inferred | Android file chooser callbacks use nullable casts. macOS WebStorage arguments and display names are validated before cleanup. Android tests pass; macOS loader/runtime validation remains pending. |
| 2026-08-08 | Linux GL runtime fallback [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | No upstream relationship inferred | Linux now switches from a failed GtkGLArea initialization to pixel-buffer rendering and emits a diagnostic. Linux test loading is blocked by the Flutter toolchain mismatch; Fedora/X11/Intel runtime validation remains pending. |
| 2026-08-08 | Android provider `forceDarkStrategy` casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594) | No upstream relationship inferred | GitHub CLI review matched both reports to `WebSettingsCompat.setForceDarkStrategy`. Android now catches provider adapter exceptions in setter and getter paths, logs the fallback, and leaves the provider default/readback value intact. Source tests and Android compilation pass; Huawei/HONOR/OnePlus provider validation remains pending. |
| 2026-08-08 | iOS/Android disposal crash [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | No upstream relationship inferred | iOS `InAppWebView.dispose()` and Android native WebView disposal are now idempotent; Android fullscreen cleanup still runs before destroy. Source tests and native builds pass; physical iOS/Android teardown and renderer validation remains pending. |
| 2026-08-08 | Android 10 IME lifecycle crash [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | No upstream relationship inferred | Detached-view checks and `RuntimeException` fallbacks now cover delayed focus, `restartInput`, `isActive`, and soft-input operations. Android source tests and compilation pass; Android 10 physical-device validation remains pending. |
| 2026-08-08 | Android System WebView renderer termination [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698) | No upstream relationship inferred | The upstream body identifies a provider-version-specific Chromium crash and reports recovery after rolling back Android System WebView. No Forge-owned stack or control point is present, so the issue moves from runtime-pending to host/provider tracking without a speculative plugin patch. |
| 2026-08-09 | Android screen-transition flicker [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688) | No upstream relationship inferred | GitHub CLI review still finds only an Android 35 symptom report with no minimal code, native stack, or composition-mode comparison. Source review finds no Forge route-animation or surface-ordering control point. The opt-in diagnostic passes on `emulator-5554` (API 35) with hybrid composition (`destinationPresent=true`, `webViewPresent=false`, 45 frame timings), virtual-display composition (`loadStopObserved=true`, `destinationPresent=true`, `webViewPresent=false`, 45 frame timings), and the example's direct native `android.webkit.WebView` baseline (`destinationPresent=true`, `webViewPresent=false`, 45 frame timings). The virtual run logs a roughly 2.97-second startup `Davey`/GC stall before the WebView is hosted, but no mode reproduces the reported transition failure. External ADB screenshots show a clean blue WebView-to-orange Flutter transition without a blank, black, or returning WebView frame. The record is reclassified as an Android/Flutter engine/platform-view boundary; no behavior workaround was added and the upstream state is unchanged. |
| 2026-08-09 | Android mobile-data audio provider boundary [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680) | No upstream relationship inferred | GitHub CLI review found `ERR_FAILED` only on mobile data for a `206 Partial Content` Cloudflare MP3 response; the follow-up says `webview_flutter` succeeds and the upstream record was stale-closed. Forge's default request path passes through to Android WebView unless the app supplies an interception response, so the issue moves to host/provider tracking without a speculative plugin change. |
| 2026-08-09 | iOS iframe subresource error callback boundary [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753) | No upstream relationship inferred | iOS forwards WebKit navigation failures through `onReceivedError`, but `WKNavigationDelegate` does not expose arbitrary HTTPS iframe subresource failures. The report remains an Apple/WebKit capability boundary; a partial JavaScript error listener would not preserve the public callback contract. |
| 2026-08-09 | Android Pigeon build attribution [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796) | No upstream relationship inferred | GitHub CLI review shows the compiler errors are inside `webview_flutter_android` 4.10.13. The Forge package graph and source tree contain no `webview_flutter_android` dependency or generated Pigeon classes; the only `webview_flutter` reference is an optional example test script. The record moves to dependency attribution tracking without a Forge code change. |
| 2026-08-09 | Android deprecation warning batch 1 [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685) | [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817) | Ported the PR's current-Kotlin equivalents in Android 1.0.32: `Handler(Looper.getMainLooper())`, API-gated asynchronous session-cookie removal, and narrow suppression around legacy cookie fallback methods. Android package tests, analysis, and example `compileDebugKotlin` pass. The compiler still reports deferred `forceDark`, `saveFormData`, `AbsoluteLayout`, print, and other warning families, so both issues remain active for the complete release/publish gate. |
| 2026-08-09 | Android release JAR gate review [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687) | No upstream relationship inferred | The example Gradle build directory now resolves from `projectDirectory` to the Flutter-expected `example/build` path. After a normal release tooling regeneration (without `--no-pub`), JDK 21 `flutter build apk --release --no-pub` produces the release APK; `:flutter_inappwebview_forge_android:syncReleaseLibJars` succeeds; and API 35 AVD install/launch keeps `MainActivity` resumed with no fatal crash in the smoke log. Clean JDK 17/provider/AAB/publish validation remains in the runtime register. |
| 2026-08-09 | Pub.dev Pana analysis compatibility [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757) | [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758) | Forge analysis options now use boolean `false` for disabled linter rules across the federated packages. Pana 0.23.3 reproduces the original `String`/`bool` crash with the old `ignore` values and passes the corrected form in an isolated package. Full Pana/publish validation against the published Forge package graph remains pending. |

| Local release | Issue/report scope | Related PR records | Local result |
| --- | --- | --- | --- |
| 2.1.35 / Android 1.0.34 | Android interception and rapid-navigation OOM [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | No upstream relationship inferred | Root 2.1.35 depends on Android 1.0.34. The Kotlin overload boundary now calls the platform `WebView.evaluateJavascript` method, preventing recursive injection growth. Android source tests and the API 35/WebView 124 rapid-navigation diagnostic pass; physical Android 10/11 OEM/provider, back/forward, and release validation remain required. |
| 2.1.34 / Android 1.0.33 | Android activity-extra deserialization [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536); Android release JAR gate [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687) | No upstream relationship inferred | Root 2.1.34 depends on Android 1.0.33. Activity extras use the primitive/nested-`Bundle` codec, Chrome Custom Tabs channel/lifecycle handoff is corrected, and Android 35 activity-handoff validation passes. The example release output path and plugin release JAR synchronization are also validated on the API 35 AVD; restore/rotation, malformed-extra, provider/device, JDK, AAB, and publish gates remain. |
| 2.1.33 | Android deprecation warning batch 1 [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685) | [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817) | Root 2.1.33 depends on Android 1.0.32. Main-looper callback dispatch and API-level cookie compatibility are source-validated and compile successfully; remaining warning families and release/publish validation are still required. |
| 2.1.31 | iOS/macOS WebAuthenticationSession Xcode availability [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830) | [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809) | Root 2.1.31 depends on iOS 2.1.19 and macOS 1.1.6. The availability-gated provider fix is source-validated; Xcode 26.4.1 and macOS consuming-app validation remain required. |
| 2.1.29 | Android `forceDarkStrategy` provider casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594); iOS/Android disposal [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654); Android IME lifecycle [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | No direct PR relationship was present in the export | Android provider adapter exceptions now fail open, iOS/Android disposal is idempotent, and stale IME operations are guarded. Root 2.1.29 depends on Android 1.0.29 and iOS 2.1.18; physical provider/device validation remains required. |
| 2.0.0 | iOS AppDelegate window access and SPM requests: [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880), [#2842](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2842), [#2841](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2841) | No direct PR relationship was present in the export | UIScene-aware registration, iOS 15 baseline, iOS/macOS SPM manifests, and CocoaPods preservation. |
| 2.0.1 | FileProvider paths [#2873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2873), unknown WebView2 permission values [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875), nullable Android callbacks [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856), fullscreen renderer cleanup [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) | [#2874](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2874), [#2876](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2876), [#2857](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2857) | FileProvider scope is restricted, unknown enum values are ignored safely, optional callback fields are validated, and fullscreen cleanup is idempotent. Native Windows/device validation remains required. |
| 2.0.2 | Android universal file access [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848), [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700); cold-start races [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843); fullscreen keyboard [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878) | [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) | Universal file access is blocked at the native boundary, startup and document-start registration are ordered, and the Flutter IME connection is restored after fullscreen. Real-device validation remains required. |
| 2.0.3 | Windows lifetime crashes [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733); Android interception/cookie/IME reports [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555); navigation context [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791) | [#2838](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2838), [#2614](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2614), [#2558](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2558) | Native lifetime release and Dart mounted checks are hardened; blocking waits are bounded; HTTP(S) `ALLOW` navigation remains native so browser context is preserved. Affected-machine Windows tests remain required. |
| 2.0.4 | iOS keyboard inset [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), Flutter gesture baseline [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762), Android 15 API warnings [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860), [#2729](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2729) | Insets are restored after keyboard dismissal, Flutter `>=3.38.6` is required for the iOS gesture fix, and direct deprecated status-bar color calls are removed. |
| 2.0.5 | Samsung selection UI [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), Linux WPE symbol compatibility [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780), Windows minimized overlay [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789) | [#2781](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2781), [#2790](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2790) | Icon-only menu items no longer display `false`, older WPE builds avoid newer symbols, and minimized WebView2 child windows are hidden and restored. |
| 2.0.6 | Android 16 KB artifacts [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), Linux build prerequisites [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), Windows `loadFile` [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) | [#2829](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2829) | Release artifact checks, actionable WPE CMake diagnostics, and a restricted virtual HTTPS asset origin are documented and covered by regression tests. Host artifact and native validation remain required. |
| 2.0.7 | Web stale iframe URL [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737), iOS popup crash path [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776), [#2792](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2792) | Same-origin navigation reports the current iframe URL, cross-origin reads return `null`, and popup JavaScript initialization is delayed or uses the page-world fallback on affected iOS versions. |
| 2.1.2 | iOS nil-frame evaluation [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), iOS pre-iOS 18 async JavaScript [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), Android WebMessageListener fallback [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474) | [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474) | iOS now guards nil-frame content-world evaluation, routes page-world async calls through the legacy result handler on iOS 15–17, and reports the iOS 16.0.x custom-world limitation. Android now dispatches WebMessageListener messages through the JavaScript bridge when the provider lacks the native feature. Device/provider validation remains required. |
| 2.1.1 | macOS custom context menu [#2855](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2855), Android screen-lock redraw [#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837), iOS/macOS PrintJS semicolon [#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879), iOS console serialization [#2850](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2850), Android WebView background color [#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863), Apple authentication headers [#2835](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2835), Windows page zoom [#2812](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2812), macOS presentation anchor [#2813](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2813), Windows title lookup [#2725](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2725), macOS API availability [#2741](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2741), Android ProGuard configuration [#2852](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2852), and iOS 26 fullscreen video [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | [#2683](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2683), [#2851](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2851), [#2864](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2864), [#2836](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2836), [#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879) | Android visibility recovery now explicitly invalidates and relayouts the WebView after screen unlock; macOS custom context menu items are added to native `NSMenu` instances, receive initial/runtime configuration, forward lifecycle events and actions to Dart; iOS console objects/Errors retain useful data; Android exposes background color; Apple authentication headers, Windows page zoom, macOS presentation safety, Windows title lookup, macOS API availability, and Android ProGuard configuration remain covered by source/tests. The fullscreen change remains a targeted WebKit mitigation and still needs device validation. |

The exact implementation details and remaining validation for these entries are maintained in [known-issues.md](known-issues.md), rather than duplicated here.

## Issue inventory

The following index preserves every issue number from the supplied export. Labels overlap only where the source explicitly provides them. Titles and timestamps remain in the source snapshot used for the review.

### Bugs: 98

`#2875`, `#2873`, `#2872`, `#2868`, `#2867`, `#2862`, `#2861`, `#2856`, `#2855`, `#2852`, `#2848`, `#2843`, `#2841`, `#2839`, `#2837`, `#2831`, `#2830`, `#2824`, `#2821`, `#2820`, `#2819`, `#2815`, `#2814`, `#2813`, `#2807`, `#2804`, `#2798`, `#2797`, `#2796`, `#2795`, `#2791`, `#2789`, `#2788`, `#2787`, `#2783`, `#2782`, `#2780`, `#2778`, `#2763`, `#2757`, `#2753`, `#2752`, `#2745`, `#2742`, `#2741`, `#2737`, `#2736`, `#2735`, `#2733`, `#2732`, `#2730`, `#2728`, `#2727`, `#2725`, `#2723`, `#2721`, `#2720`, `#2718`, `#2717`, `#2713`, `#2711`, `#2710`, `#2709`, `#2707`, `#2702`, `#2700`, `#2698`, `#2697`, `#2695`, `#2692`, `#2688`, `#2687`, `#2686`, `#2685`, `#2682`, `#2681`, `#2680`, `#2673`, `#2672`, `#2667`, `#2659`, `#2654`, `#2642`, `#2641`, `#2636`, `#2619`, `#2615`, `#2600`, `#2598`, `#2594`, `#2590`, `#2584`, `#2580`, `#2577`, `#2570`, `#2568`, `#2555`, `#2536`.

### Enhancements: 16

`#2880`, `#2846`, `#2842`, `#2835`, `#2834`, `#2812`, `#2811`, `#2793`, `#2762`, `#2760`, `#2712`, `#2706`, `#2703`, `#2691`, `#2690`, `#2660`.

### Showcase: 3

`#2822`, `#2769`, `#2716`.

### Unlabelled: 8

`#2878`, `#2863`, `#2859`, `#2850`, `#2849`, `#2840`, `#2826`, `#2805`.

The label groups above reproduce the mutually exclusive issue label value exported for each record. Platform and resolution themes can still overlap in the triage notes. The authoritative issue-by-issue analysis is [known-issues.md](known-issues.md).

## PR inventory

All 73 PR numbers and titles from `pr.csv` are retained below. The export labels are platform/topic hints, not proof that a PR was merged or that it is the sole implementation source for a local fix.

| PR | Title |
| ---: | --- |
| 2881 | linux: re-import DMA-BUF into Flutter's EGLDisplay per frame |
| 2879 | fix(ios, macos): terminate PrintJS assignment with a semicolon |
| 2876 | fix(windows): prevent crash on unknown WebView2 permission resources |
| 2874 | Resolve: Restrict FileProvider paths to follow Android security guidance |
| 2871 | [flutter_inappwebview_ios] Fix callAsyncJavaScript crashes before iOS 18 |
| 2870 | fix macos with xcode 26.6 related to |
| 2869 | Windows: VS 2026 / MSVC 14.5x build fixes |
| 2866 | feat: add NavigationActionPolicy.ALLOW_WITHOUT_TRYING_APP_LINK to skip Universal Link app handoff |
| 2864 | Android: add InAppWebViewController.setBackgroundColor to override the WebView background |
| 2860 | iOS: restore scrollView.contentInset on keyboardWillHide (#1947 regression) |
| 2857 | Fix nullable Android context menu title |
| 2853 | [flutter_inappwebview_ios] Fix requestFocus() so document focus works inside Flutter platform views |
| 2851 | [iOS] Serialize console arguments so objects and Errors keep their data |
| 2844 | [Android] Defer JS bridge native registrations off platform-view attach |
| 2838 | fix(windows): prevent crash on app exit caused by WinRT COM release |
| 2836 | Add support for WebAuthenticationSession's additionalHeaderFields (iOS 17.4+, macOS 14.4+) |
| 2832 | Add WebkitGTK for linux |
| 2829 | Use nlohmann_json from system when compiling flutter_inappwebview_linux |
| 2828 | Fix macOS WebView frame drift with fractional platform view sizes |
| 2825 | Add container API: InAppWebViewSettings.containerId, ContainerController, per-container proxy |
| 2823 | [flutter_inappwebview_android] Add audio intent |
| 2817 | [flutter_inappwebview_android] Fix Android Java deprecation warnings (batch 1) |
| 2809 | Fix macOS Compile Failure in WebAuthenticationSession.swift |
| 2806 | Add ProxyController support for Windows (WebView2) |
| 2794 | feat(js-bridge): add bridgeEvents API and typed handler helpers |
| 2792 | fix(web): use srcdoc instead of data: URI in loadData to fix cross-origin restrictions |
| 2790 | windows: emit minimize/restore events to keep custom platform view synced |
| 2786 | Fix windows scrolling & user Data folder |
| 2781 | fix(linux): add version check for `webkit_web_view_get_theme_color` |
| 2776 | Fix iOS 14~17 EXC_BAD_ACCESS crash when evaluateJavaScript on windowID WebViews |
| 2771 | Fix iPad crash in evaluateJavaScript when frame is nil |
| 2770 | docs: add minimal test setup for InAppWebViewPlatform |
| 2768 | [FIX] Flutter Window loses focus on click InAppWebView |
| 2767 | macOS 11.x crash: WKWebViewConfiguration.upgradeKnownHostsToHTTPS unrecognized selector |
| 2766 | feat: Add PreferredColorScheme support for WebView2 color scheme management |
| 2758 | fix analysis failed on pub.dev (fix analysis_options.yaml) |
| 2756 | Pr android choose media |
| 2743 | feat: Add Web Authentication support for Android |
| 2729 | fix: skip deprecated navigation bar color APIs on Android 15 (API 35) |
| 2722 | feat: Add support for payment requests on Android |
| 2715 | fix: add window context handling for AJAX interception in iframe scenarios |
| 2708 | fix windows hang-on |
| 2694 | V6.0.0 |
| 2683 | fix(ios): context menu not updating when setContextMenu is called from Flutter |
| 2671 | Add WKWebView proxy support for iOS 17+ |
| 2638 | Fix KeepAlive null error |
| 2631 | fix: remove printing headers inside server listen |
| 2614 | Fix: keepAlive not working when URL changed |
| 2575 | fix: add _disable_constexpr_mutex_constructor macro to prevent compilation failure |
| 2574 | bug-fix: update evaluateJavaScript method signature to use @MainActor |
| 2564 | refactor: inappwebview example |
| 2563 | Update InterceptAjaxRequestJS.swift |
| 2558 | fix: `ChannelController.debugAssertNotDisposed()` throwing when calling disposed channel |
| 2548 | fix: dealloc InAppWebViewManager |
| 2526 | Download when nuget.exe not exists |
| 2495 | [web] move some functions from js to dart |
| 2474 | Compatible with Android 10 and below WebViewFeature.WEB_MESSAGE_LISTENER is false |
| 2390 | WIP android: Renders properly content outside viewports |
| 2312 | Support keyboardDisplayRequiresUserAction to focus automatically in iOS |
| 2243 | Fixes CVE-2020-6563 |
| 2181 | docs(pubdev): add Android, iOS and Web platforms in pubspec.yaml |
| 2105 | fix InterceptAjaxRequest code |
| 2099 | bugfix/ajax-blob |
| 2082 | Bump express from 4.18.1 to 4.19.2 in /test_node_server |
| 2033 | android: request camera permission for inputs |
| 2023 | bugfix/ajax |
| 1952 | Fix credentials typo |
| 1756 | Fix/ios keyboard appearance |
| 1679 | added support for window.open in onCreateWindow (android) |
| 1659 | Fix: Wait for a blank page to be loaded before closing the browser |
| 1603 | Fix: windowType not checked in InAppBrowser show function macOS |
| 1342 | Update InAppWebView.swift |
| 1105 | fix screen freeze bug when keyboard is shown and textfield doesn't move |

## Follow-up policy

- Keep a local implementation status in changelogs and `known-issues.md` even when upstream metadata remains `OPEN`.
- Link a PR only when the title, code, or commit history supports the relationship.
- Do not close a validation gap in documentation until the relevant device, OS, browser engine, or native build has actually been exercised.
- When a new fix changes a channel payload, enum, setting, or capability, update the platform interface, generated output, platform implementations, tests, and changelog in the same change.
