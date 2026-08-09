# Runtime Validation Pending

Last reviewed: 2026-08-10

This register contains issue records whose local implementation or mitigation
is complete, but whose target device, provider, browser, native runtime, or
release artifact has not yet been exercised. These records are not active
implementation work and are excluded from the counts in
[open-work-plan.md](open-work-plan.md). Their root-cause notes and acceptance
details remain in [known-issues.md](known-issues.md).

## Current counts

| Local status | Issue records | Count | Meaning |
| --- | --- | ---: | --- |
| Locally implemented or mitigated; runtime validation pending | Issue register below | 69 | Source, regression, and host/build checks pass; real validation remains. |
| Closed by source review | [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | 1 | No plugin-owned security sink was found; no package runtime test is required. |
| Host/platform-specific boundary | [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570), [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584), [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598), [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636), [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659), [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680), [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688), [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713), [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723), [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727), [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753), [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796) | 13 | Strong evidence points to Apple/WebKit Simulator or callback limitations, Android framework/provider/dependency, host app/site configuration, and Flutter engine/platform-view behavior; no Forge-owned control point is available. |
| Open implementation or reproduction | [open work plan](open-work-plan.md) | 42 | No complete local implementation boundary has been established. |
| **Issue export total** | 125 | **125** | Historical export count; upstream `OPEN` state is unchanged. |

Three PR-only records also have local implementations but remain outside the
125-issue count: [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771),
[#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), and
[#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474).

### Count by exported category

| Category | Export | Runtime pending | Source-review closed | Host/platform boundary | Still open | Technical open after showcase |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Bugs | 98 | 55 | 1 | 13 | 29 | 29 |
| Enhancements | 16 | 6 | 0 | 0 | 10 | 10 |
| Unlabelled | 8 | 8 | 0 | 0 | 0 | 0 |
| Showcase | 3 | 0 | 0 | 0 | 3 | 0 |
| **Total** | **125** | **69** | **1** | **13** | **42** | **39** |

Android [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)
now validates nullable and non-string optional callback fields before dispatch;
the remaining gate is the Android API/provider matrix listed in
[`known-issues.md`](known-issues.md).

Android [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)
now has Android 35 AVD happy-path evidence for nested InAppBrowser and Chrome
Custom Tabs activity extras. The package test suite and opt-in diagnostic pass,
including open/load/close callbacks; restore/rotation, malformed external
extras, and physical/provider coverage remain release gates, so the record stays
in this register and the count remains 69.

Pub.dev analysis issue [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757)
and upstream [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758)
are fixed locally by using boolean `false` for disabled `linter.rules`
overrides across the federated packages. Pana 0.23.3 reproduces the old
string-value crash and passes the corrected form in an isolated package. The
full package publish analysis remains pending because the Forge package names
are not yet available on pub.dev.

Android release-gate issue [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687)
is mitigated in the example release path. The Gradle build directory now
resolves from the project directory to the Flutter-expected `example/build`
path. After a normal release tooling regeneration (without `--no-pub`), the
JDK 21 release build produces `build/app/outputs/flutter-apk/app-release.apk`,
the Android plugin `syncReleaseLibJars` task succeeds, and the APK installs and
launches on the API 35 `emulator-5554` with `MainActivity` resumed and no fatal
crash in the smoke log. Clean JDK 17/provider/AAB/publish validation remains
required.

iOS/macOS [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)
now isolates the authentication presentation provider behind the iOS 13/macOS
10.15 availability boundaries. Source tests, Swift Package manifest checks,
and the Xcode 27 iOS example build pass; exact Xcode 26.4.1 and macOS
consuming-app validation remain required.

Android [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)
now prioritizes `shouldInterceptRequest` and Service Worker interception on the
main looper, removes timed-out queued dispatches, and ignores late callback
results. During the API 35 rapid-navigation diagnostic, a separate Kotlin
overload recursion in `injectDeferredObject` was also confirmed as the direct
source of the observed `OutOfMemoryError`; Android 1.0.34 now calls the
platform `WebView.evaluateJavascript` overload. Android source tests and the
opt-in API 35/WebView 124 diagnostic pass (`finalLoaded=true`, final marker
`final`, 31 interception callbacks, no fatal crash). Physical Android 10/11
OEM/provider validation and broader back/forward coverage remain required, so
the record stays in this register and the count remains 69.

Android [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878)
now has an opt-in fullscreen → exit → separate Flutter `TextField` diagnostic
at
[`flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart).
The API 35 `emulator-5554` with WebView 124 passes the flow with
`insetBeforeFocus=0.0`, `insetAfterFocus=24.0`, and an active Flutter focus
node; ADB IME history records `SHOW_SOFT_INPUT` on the host activity. Samsung
One UI/WebView 150+ and physical-device validation remain required, so the
record stays in this register and the count remains 69.

Android [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721)
now has an opt-in display-size recovery diagnostic at
[`android_display_size_recovery_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_display_size_recovery_diagnostic_test.dart).
The API 35 AVD builds and starts the diagnostic, but both host `wm size`
change/reset attempts temporarily put `emulator-5554` offline before the test
could complete its geometry assertion; no Forge/native crash was recorded.
The display-size and OEM-provider gate therefore remains pending.

Android [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555)
now has an opt-in IME lifecycle diagnostic at
[`android_ime_lifecycle_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_ime_lifecycle_diagnostic_test.dart).
On the API 35 AVD, both virtual-display and hybrid composition cycles focus
the HTML input, clear and dispose the WebView, then reopen the Flutter keyboard
with `keyboardInsetAfterDispose=24.0` and an active Flutter focus node. The
explicit WebView disposal also logs Chromium renderer exit code `-1`, but no
AndroidRuntime, fatal, or IME NPE appears; Android 10 and OEM validation remain
required.

iOS/Android [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)
now has disposal lifecycle diagnostics at
[`ios_disposal_lifecycle_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_disposal_lifecycle_diagnostic_test.dart)
and
[`android_disposal_lifecycle_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_disposal_lifecycle_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator completes four cycles with every pending
async JavaScript call returning `WebView disposed`. The API 35 `emulator-5554`
does the same across virtual-display and hybrid composition; explicit disposal
logs Chromium renderer exit code `-1`, but no `AndroidRuntime`, fatal, or Dart
test failure appears. Physical iOS 17+ and Android API 33+/OEM/provider
validation remain required, so #2654 stays in this register and the count
remains 69.

iOS [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)
now has an opt-in multi-window navigation diagnostic at
[`ios_multi_window_navigation_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_multi_window_navigation_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator passes three popup
attach/evaluate/navigate/dispose cycles, including page and custom-world
JavaScript, `shouldOverrideUrlLoading`, and an async call raced with
`about:blank` navigation. iOS 2.1.22 completes pending native and legacy async
callbacks with `WebView navigation started` before the new provisional
navigation and ignores late completions. Physical iOS 15–26, Xcode 16/26, and
symbolicated-crash validation remain required, so #2867 stays in this register
and the count remains 69.

Android [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819)
now restores fullscreen state in both the pre-destroy fallback and the
`onRenderProcessGone` path before forwarding renderer-loss events. The Android
source regression test passes, but no available device reproduces the reported
MediaTek gralloc/surface failure; a physical MediaTek test with fullscreen
H.264/HLS playback and network loss remains required, so the count remains 69.

Android [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680)
is tracked as a host/provider boundary rather than runtime-pending implementation
work: the reported Cloudflare `206 Partial Content` failure is not on Forge's
default request path, and the upstream record was stale-closed on 2026-08-07.

iOS [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)
now has a successful opt-in HTTPS deny-path diagnostic on the iOS 27 Simulator:
the Dart callback received `https://example.com` and returned `error:1`. The
iOS 26.0 and 26.2 Simulator runs build successfully but leave
`callbackOrigin=null` and the DOM result unset, so the record remains in this
register until a physical iOS 26 grant/deny and scene-lifecycle matrix is
completed. On the iPhone 17 Pro iOS 26.2 Simulator, `simctl privacy grant
location` produces `granted` without invoking the Dart callback, while
`revoke` leaves the request pending; these states do not exercise the
interactive system prompt.

iOS [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)
now has successful opt-in diagnostics on iOS 26.0, 26.2, and 27.0 Simulators:
`window.open` sends `https://example.com/popup` to `onCreateWindow`, the callback
returns `false`, and the caller remains at `https://example.com/`. The record
remains in this register until physical iOS 15-26 popup attachment, navigation,
disposal, and scene-transition coverage is completed.

iOS [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787)
is source-fixed in iOS 2.1.20. The opt-in diagnostic passes on the iPhone 17 Pro
iOS 26.2 Simulator (`38B5237D-C667-489A-A7EA-F3B1CAAA0119`): the keyboard
transition measures `visualViewport.height` as `778px -> 435.44px -> 778px`,
with `visualViewport.scale` returning from `0.939` to `1.0` and the page offset
returning to zero. The fix retains the pre-keyboard `UIScrollView` zoom/offset
and refreshes the final frame/layout after dismissal. Physical iOS 17/device
and native `WKWebView` comparison validation remain required.

## Issue register

The following 69 issue records have moved out of the active implementation
queue. They remain release gates until the required real validation is
recorded:

`#2536`, `#2555`, `#2568`, `#2580`, `#2594`, `#2600`, `#2619`, `#2654`,
`#2673`, `#2687`, `#2697`, `#2700`, `#2703`, `#2707`, `#2709`, `#2710`,
`#2711`, `#2717`, `#2718`, `#2720`, `#2721`, `#2725`, `#2728`, `#2733`, `#2736`, `#2737`,
`#2741`, `#2757`, `#2762`, `#2763`, `#2778`, `#2780`, `#2782`, `#2783`, `#2787`, `#2789`,
`#2791`, `#2797`, `#2805`, `#2812`, `#2813`, `#2814`, `#2819`, `#2826`, `#2830`, `#2831`,
`#2835`, `#2837`, `#2840`, `#2841`, `#2842`, `#2843`, `#2848`, `#2849`,
`#2850`, `#2852`, `#2855`, `#2856`, `#2859`, `#2861`, `#2862`, `#2863`,
`#2867`, `#2868`, `#2872`, `#2873`, `#2875`, `#2878`, `#2880`.

## Validation tracks

| Track | Required evidence |
| --- | --- |
| Android | Physical API/provider coverage, activity restore and rotation, cold-start/AOT cycles, malformed extras, IME/fullscreen behavior, and final APK/AAB checks where applicable. |
| iOS/macOS | Physical-device WebKit/AppKit coverage across supported OS versions, UIScene activation, popup/presentation, keyboard, authentication, geolocation grant/deny, and SPM/CocoaPods consuming-app validation. |
| Windows | Native WebView2 create/resize/dispose/recreate flows, affected runtime versions, minimized/focus behavior, and debug/release builds on Windows. |
| Linux | WPE/WebKit build matrix plus Fedora/X11/Intel runtime frames, GL-disabled fallback, backend diagnostics, and required `pkg-config` configurations. |
| Web | Browser integration coverage for same-origin navigation/history and cross-origin privacy behavior. |

The per-issue required evidence is maintained in the detailed findings in
[known-issues.md](known-issues.md). A source test, static assertion, host
build, or manifest check is recorded as supporting evidence, not as a
replacement for the target runtime test.

## Status transitions

1. A complete local implementation leaves `open-work-plan.md` and enters this
   register with its source, regression, and host validation evidence.
2. If real validation fails, move the issue back to the active work plan with
   the failing environment and native evidence.
3. If all required real validation passes, remove the issue from this
   register and mark it fully locally validated in `known-issues.md` and the
   resolution log.
4. Host/platform-specific boundaries are neither runtime-pending fixes nor
   upstream closures; keep their evidence and limitations in
   `known-issues.md` and the resolution log.
5. Do not change or comment on the upstream GitHub issue state as part of
   these local transitions.
