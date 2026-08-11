# Runtime Validation Pending

Last reviewed: 2026-08-11

This register contains issue records whose local implementation or mitigation
is complete, but whose target device, provider, browser, native runtime, or
release artifact has not yet been exercised. These records are not active
implementation work and are excluded from the counts in
[open-work-plan.md](open-work-plan.md). Their root-cause notes and acceptance
details remain in [known-issues.md](known-issues.md).

## Current counts

| Local status | Issue records | Count | Meaning |
| --- | --- | ---: | --- |
| Locally implemented or mitigated; runtime validation pending | Issue register below | 68 | Source, regression, and host/build checks pass; real validation remains. |
| Resolved locally; no runtime gate | [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709) | 1 | Pure Dart serialization is covered by a focused regression test; no device/provider behavior is involved. |
| Closed by source review | [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | 1 | No plugin-owned security sink was found; no package runtime test is required. |
| Host/platform-specific boundary | [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570), [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584), [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598), [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636), [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659), [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680), [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688), [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713), [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723), [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727), [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753), [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | 14 | Strong evidence points to Apple/WebKit Simulator or callback limitations, Android framework/provider/dependency, host app/site configuration, and Flutter engine/platform-view behavior; no Forge-owned control point is available. |
| Open implementation or reproduction | [open work plan](open-work-plan.md) | 41 | No complete local implementation boundary has been established. |
| **Issue export total** | 125 | **125** | Historical export count; upstream `OPEN` state is unchanged. |

Four PR-only records also have local implementations but remain outside the
125-issue count: [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243),
[#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771),
[#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), and
[#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474).

Android PR [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243)
is source-fixed in Android 1.0.41: the file chooser now canonicalizes and
rejects private-sandbox `/data/` `file://` results across single, multi-select,
and legacy callbacks. `content://` selections and FileProvider capture URIs
remain allowed. The Android package suite passes 48/48 tests, `compileDebugKotlin`,
and the `assembleDebug` AAR task. The Flutter APK wrapper is blocked by the
existing Gradle 8.13/JDK `OutgoingVariantsReportTask` compatibility failure;
an adversarial external-picker/provider matrix across API levels also remains
pending. This PR-only record does not change the 68-issue count.

### Count by exported category

| Category | Export | Runtime pending | Source-validated; no runtime gate | Source-review closed | Host/platform boundary | Still open | Technical open after showcase |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Bugs | 98 | 54 | 1 | 1 | 14 | 28 | 28 |
| Enhancements | 16 | 6 | 0 | 0 | 0 | 10 | 10 |
| Unlabelled | 8 | 8 | 0 | 0 | 0 | 0 | 0 |
| Showcase | 3 | 0 | 0 | 0 | 0 | 3 | 0 |
| **Total** | **125** | **68** | **1** | **1** | **14** | **41** | **38** |

Android [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)
now validates nullable and non-string optional callback fields before dispatch,
including permission-request and cancellation maps plus the resources container;
the remaining gate is the Android API/provider matrix listed in
[`known-issues.md`](known-issues.md). The count remains 68.

Android [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641)
and [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685)
are implemented in Android 1.0.40. Legacy API 19/20 and provider compatibility
paths remain SDK-gated, while the native compatibility files isolate their
deprecation diagnostics. The 47-test Android package suite,
`compileDebugKotlin`, and the debug APK build pass without package-owned
Java/Android deprecation warnings. The direct release compile still encounters
the generated dev-only `integration_test` registrant, and the normal Flutter
release path uses a stale configured Android Studio JDK location in this
environment; clean JDK 17/21, AAB, provider, device, and publish validation
remain required. The records therefore stay in this register and the count is
now 68.

Android [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843)
and [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849)
now include a bounded provider-startup fallback in Android 1.0.38 and an opt-in
profile/AOT cold-start diagnostic. Four clean API 35/WebView 124 installs pass
`onWebViewCreated`, `onLoadStop`, and the JavaScript bridge/document-start checks.
The opt-in [`android_headless_cold_start_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_headless_cold_start_diagnostic_test.dart)
also passes four headless create/load/dispose cycles with an
`AT_DOCUMENT_START` bridge marker, and the general HeadlessInAppWebView suite
passes 6/6 on the same API 35 AVD. No app `AndroidRuntime`, ANR, or native fatal
appears; explicit headless disposal emits Chromium renderer exit code `-1`,
which is the known teardown signature tracked separately under external #2491.
Physical release/R8 and provider coverage remains required, so the record stays
in this register and the count remains 68.

Android [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)
now has Android 35 AVD happy-path evidence for nested InAppBrowser and Chrome
Custom Tabs activity extras. The package test suite and opt-in diagnostic pass,
including open/load/close callbacks; restore/rotation, malformed external
extras, and physical/provider coverage remain release gates, so the record stays
in this register and the count remains 68.

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
results. During the fresh 2026-08-10 API 35 rapid-navigation diagnostic, a separate Kotlin
overload recursion in `injectDeferredObject` was also confirmed as the direct
source of the observed `OutOfMemoryError`; Android 1.0.34 now calls the
platform `WebView.evaluateJavascript` overload. Android source tests and the
API 35/WebView 124 diagnostic pass (`finalLoaded=true`, final marker `final`,
31 interception callbacks, and no app fatal crash, ANR, or OOM in the log). Physical Android 10/11
OEM/provider validation and broader back/forward coverage remain required, so
the record stays in this register and the count remains 68.

Android [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718)
is source-hardened in Android 1.0.42. API 21+ `setCookie`, `deleteCookie`, and
`deleteCookies` mutations no longer call the synchronous `CookieManager.flush()`
after queuing their asynchronous updates; the explicit `flush` API is preserved
for callers that require it. The Android package suite passes 49/49 tests,
`compileDebugKotlin`, and `assembleDebug`. Android 10/provider and Play Console
cookie-clear validation remain required. The existing remote-URL Cookie Manager
integration test built and installed on the API 35 AVD but timed out after 60
seconds before its assertions, with no fatal AndroidRuntime or ANR log captured.
A fresh isolated `flutter drive` attempt on 2026-08-10 installed the same test
but Flutter 3.44.8 crashed in VM-service setup with
`registerService: (-32000) Service connection disposed`; the AVD log again had
no app `AndroidRuntime`, fatal, or ANR. Neither run reached the cookie
assertions, so this is not counted as a completed runtime gate. The record
stays in this register and the count remains 68.

Android [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878)
now has an opt-in fullscreen → exit → separate Flutter `TextField` diagnostic
at
[`flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart).
The existing API 35/WebView 124 pass uses the documented
`SystemChannels.textInput.show` workaround, so it does not independently prove
the native fullscreen restoration path. Two workaround-free attempts lost the
Flutter VM service and then reported `emulator-5554` offline before the keyboard
assertion; no AndroidRuntime, ANR, or app crash was captured. Samsung One
UI/WebView 150+ and physical-device validation remain required, so the record
stays in this register and the count remains 68.

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
On 2026-08-10, a clean API 35 AVD run passed both virtual-display and hybrid
composition cycles: each focused the HTML input, cleared and disposed the
WebView, then reopened the Flutter keyboard with
`keyboardInsetAfterDispose=24.0` and an active Flutter focus node. No
AndroidRuntime, fatal, or IME NPE appeared in the run. Android 10 and OEM
validation remain required, so this record stays in the register and the count
remains 68.

iOS [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711)
now has a targeted Dart regression test that reproduces the missing native
channel and passes after `goBack()` treats only `MissingPluginException` as a
teardown no-op. The iOS package tests (2/2), SwiftPM manifest validation, and
Simulator build pass. A four-cycle iPhone 17 Pro iOS 26.2 disposal diagnostic
completes with `WebView navigation started` outcomes after the harness's
navigate-away race; the test accepts that safe terminal result and records no
missing-plugin failure or app crash. Physical/device scene reattachment and
stale-controller validation remain required, so #2711 stays in this register.

iOS [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710)
now has an opt-in seek/fullscreen diagnostic at
[`ios_fullscreen_video_seek_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_fullscreen_video_seek_diagnostic_test.dart).
On 2026-08-11, the iPhone 17 Pro iOS 26.2 Simulator passed three cycles using a
bundled H.264/AAC video: play, seek, native-container fullscreen entry,
runtime opt-out dismissal, and re-entry all produced the expected state. The
test exited 0, the iOS package tests passed 2/2, and the SwiftPM manifest
validated with the documented module-cache workaround. Physical iOS 26/GPU,
HLS/iframe, orientation, media-control, and consuming-app validation remain
required, so #2710 stays in this register and the count remains 68.

iOS/Android [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)
now has disposal lifecycle diagnostics at
[`ios_disposal_lifecycle_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_disposal_lifecycle_diagnostic_test.dart)
and
[`android_disposal_lifecycle_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_disposal_lifecycle_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator completes four cycles with each pending
async JavaScript call reaching the safe `WebView navigation started` terminal
error after the harness begins navigation; the diagnostic now accepts both
that result and `WebView disposed`. A clean iPhone 17 Pro iOS 27 Simulator run
also completed four cycles with outcomes `[WebView navigation started, WebView
disposed, WebView navigation started, WebView navigation started]`. The API 35
`emulator-5554` does the same across virtual-display and hybrid composition. A
fresh 2026-08-10 `flutter drive` run completes all four cycles with exit code 0;
explicit disposal logs Chromium renderer exit code `-1`, but no app
`AndroidRuntime`, fatal, ANR, or Dart test failure appears. This matches the
renderer-teardown signature reported by external [#2491](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2491),
which is outside the supplied 125-issue export; the exact back-button and
affected-OEM path remains unvalidated. Physical iOS 17+ and Android API
33+/OEM/provider validation remain required, so #2654 stays in this register
and the count remains 68.

iOS [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)
now has an opt-in multi-window navigation diagnostic at
[`ios_multi_window_navigation_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_multi_window_navigation_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator passes three popup
attach/evaluate/navigate/dispose cycles, including page and custom-world
JavaScript, `shouldOverrideUrlLoading`, and an async call raced with
`about:blank` navigation. A fresh 2026-08-10 `flutter drive` run exits 0 with
`popupActions=3` and the same navigation sequence; no `EXC_BAD_ACCESS`,
`SIGSEGV`, `SIGABRT`, or fatal Simulator log is present. iOS 2.1.23 completes
pending native and legacy async callbacks with `WebView navigation started`
before the new provisional navigation and ignores late completions. Physical
iOS 15–26, Xcode 16/26, and symbolicated-crash validation remain required, so
#2867 stays in this register and the count remains 68.

Android [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819)
now restores fullscreen state in both the pre-destroy fallback and the
`onRenderProcessGone` path before forwarding renderer-loss events. The Android
package suite passes all 49 tests on 2026-08-10, including the renderer-loss
fullscreen regression. No available device reproduces the reported MediaTek
gralloc/surface failure; the API 35 AVD cannot stand in for that GPU/provider
matrix, and a physical MediaTek test with fullscreen H.264/HLS playback and
network loss remains required, so the count remains 68.

Android [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680)
is tracked as a host/provider boundary rather than runtime-pending implementation
work: the reported Cloudflare `206 Partial Content` failure is not on Forge's
default request path, and the upstream record was stale-closed on 2026-08-07.

iOS [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)
is now tracked as a host/platform boundary rather than runtime-pending
implementation work. The installed WebKit SDK declares the public geolocation
decision delegate at iOS 27.0. The fresh 2026-08-10 iOS 27 Simulator deny-path
diagnostic receives `https://example.com` in Dart and returns `error:1`; the iPhone 17 Pro
iOS 26.2 run leaves `callbackOrigin=null` on the same secure HTTPS page. The
iOS 26 prompt remains owned by WebKit because no public Forge decision hook is
available; private WebKit APIs are out of scope.

iOS [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)
now has successful opt-in diagnostics on iOS 26.0, 26.2, and 27.0 Simulators:
`window.open` sends `https://example.com/popup` to `onCreateWindow`, the callback
returns `false`, and the caller remains at `https://example.com/`. The record
remains in this register until physical iOS 15-26 popup attachment, navigation,
disposal, and scene-transition coverage is completed.

Android [#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837)
now has an opt-in screen-lock redraw diagnostic at
[`android_screen_lock_redraw_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_screen_lock_redraw_diagnostic_test.dart).
On the API 35 `emulator-5554` hybrid-composition run, a real ADB lock/unlock
checkpoint preserved the `ANDROID_SCREEN_LOCK_MARKER` DOM content and the
WebView URL, with no AndroidRuntime, fatal, or renderer crash in the captured
log. The Flutter host's DDS/golden-stream connection is unstable for this
diagnostic, so the checkpoint is evidence rather than a clean integration-test
exit; Android 10 and affected OEM/provider lock/unlock validation remain
required and the count remains 68.

iOS [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787)
is source-fixed in iOS 2.1.20. The previously recorded iPhone 17 Pro iOS 26.2
Simulator pass measured `visualViewport.height` as `778px -> 435.44px ->
778px`, with `visualViewport.scale` returning from `0.939` to `1.0`. A fresh
default-DDS run on 2026-08-10 reproduces the same transition, including an
active HTML input and zero page offset after dismissal. Earlier clean DDS
reruns on the current host were inconclusive: iOS 26.2 reported zero WebKit
viewport metrics after loading, while iOS 27 reached the initial `778px`
viewport but did not expose a software-keyboard transition (`keyboardDelta=0`).
CoreSimulatorService connection failures were also observed. The fix retains
the pre-keyboard `UIScrollView` zoom/offset and refreshes the final frame/layout
after dismissal. Physical iOS 17/device and native `WKWebView` comparison
validation remain required, so the count remains 68.

## Issue register

The following 68 issue records have moved out of the active implementation
queue. They remain release gates until the required real validation is
recorded:

`#2536`, `#2555`, `#2568`, `#2580`, `#2594`, `#2600`, `#2619`, `#2641`,
`#2654`, `#2673`, `#2685`, `#2687`, `#2697`, `#2700`, `#2703`, `#2707`, `#2710`, `#2711`,
`#2717`, `#2718`, `#2720`, `#2721`, `#2725`, `#2728`, `#2733`, `#2736`, `#2737`,
`#2741`, `#2757`, `#2762`, `#2763`, `#2778`, `#2780`, `#2782`, `#2783`, `#2787`, `#2789`,
`#2791`, `#2797`, `#2805`, `#2812`, `#2813`, `#2819`, `#2826`, `#2830`,
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
