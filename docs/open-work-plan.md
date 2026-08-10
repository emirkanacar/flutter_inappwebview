# Open Work Plan

Last reviewed: 2026-08-10

This is the active implementation and reproduction backlog for work that is
not yet resolved in the local Forge repository. Locally implemented records
that still need real runtime evidence are tracked separately in
[`runtime-validation-pending.md`](runtime-validation-pending.md). The plan is
derived from the supplied `issues.csv` and `pr.csv` snapshots, the current
source tree, package changelogs, and [`known-issues.md`](known-issues.md).

## Scope and counts

The export contains 125 issues and 73 PRs. Eighty-four issue records have a
documented local implementation, mitigation, source-review, or host/platform
boundary: 68 await real runtime validation, #2709 is source-validated with no
native runtime gate, #2745 is closed by source review, and
#2570/#2584/#2598/#2636/#2659/#2680/#2688/#2698/#2713/#2723/#2727/#2753/#2796/#2831 have no Forge-owned fix because
their failures belong to host app/site configuration, the Apple/WebKit
Simulator, Android framework/provider/dependency, and Flutter engine/platform-view layers.
The other 41 issue records
remain in this active plan. Four additional PR-only records
(`#2243`, `#2771`, `#2871`, and `#2474`) are implemented locally and await
runtime validation; they do not change the issue counts below.

| Category | Export | Runtime pending | Source-validated; no runtime gate | Source-review closed | Host/platform boundary | Active open | Treatment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| Bugs | 98 | 54 | 1 | 1 | 14 | 28 | Technical work, validation, or reproduction required |
| Enhancements | 16 | 6 | 0 | 0 | 0 | 10 | API/design decision and implementation required |
| Unlabelled | 8 | 8 | 0 | 0 | 0 | 0 | Triage before implementation |
| Showcase | 3 | 0 | 0 | 0 | 0 | 3 | Product examples, not plugin engineering work |
| **Total issue records** | **125** | **68** | **1** | **1** | **14** | **41** | **38 active technical records after excluding showcase entries** |

The upstream export marks every record `OPEN`. That value is historical metadata; this plan uses local code evidence to decide whether a record is resolved, mitigated, validation-only, or still open.

## Status rules

- **P0 containment:** crash, security, data-loss, or deadlock risk. Reproduce or add a safe guard before feature work.
- **P1 stability:** confirmed runtime, lifecycle, build, or release compatibility problem.
- **P2 API/feature:** requires a public API, platform capability, or product decision.
- **P3 triage:** low-detail, duplicate, environment-specific, or unconfirmed report.
- **Runtime validation pending:** the local implementation, regression coverage, and host/build checks pass, but the target device, provider, browser engine, native runtime, or release artifact still needs real validation. These records live in [`runtime-validation-pending.md`](runtime-validation-pending.md), not in this active queue.
- **Host/platform boundary:** available evidence identifies an external runtime or provider failure with no package-owned control point. These records remain visible in [`known-issues.md`](known-issues.md) and the resolution log, but are not counted as local fixes or active implementation work.
- **Source-validated; no runtime gate:** the complete behavior is a pure Dart or source-contract path covered by focused regression tests, so no device/provider/native runtime gate is required.
- **Locally resolved:** the acceptance criteria, regression coverage, affected native build, and required device/runtime or documented host-limitation evidence all pass. A source-only patch is not enough.
- **Active open work:** no complete local implementation boundary has been established, or a runtime failure has returned the issue to implementation/reproduction.

## Local resolutions outside this plan

The 68 implementation or mitigation records awaiting real validation are
listed in [`runtime-validation-pending.md`](runtime-validation-pending.md),
along with the four PR-only records. They are resolved implementation work,
not active queue items, and therefore are excluded from the active counts
above. [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745)
is closed by source review and has no package runtime gate. Android [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721)
now has an idempotent native WebView geometry refresh for display-size changes
and visibility recovery; its Android 16/API 36 and OEM provider validation is
tracked in the runtime register. The opt-in display-size diagnostic starts on
the API 35 AVD, but host `wm size` change/reset currently disconnects that AVD
before the geometry assertion, so no runtime count changes.

Android [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709)
is source-validated with a focused Dart serialization test and has no device or
provider runtime gate. iOS [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711)
now has a Dart regression guard for stale-controller `goBack()` calls after the
native channel disappears during scene/platform-view teardown; iOS package
tests, SwiftPM manifest validation, and the simulator build pass, while real
scene/device validation remains in the runtime register. Windows [#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814)
was previously grouped under an unrelated Android listener note and is back in
the active reproduction queue with its actual platform scope.

Android [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)
now has Android 35 AVD happy-path evidence for the recursive activity-extra
codec across InAppBrowser and Chrome Custom Tabs, including lifecycle callbacks.
Malformed external extras, restore/rotation, and physical/provider coverage
remain in the runtime register; therefore the 68 runtime-pending count includes
this release-gate record.

Pub.dev analysis issue [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757)
and its related upstream [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758)
are fixed locally by changing disabled `linter.rules` overrides from the
string `ignore` form to boolean `false` across the federated packages. The
legacy Pana 0.23.3 failure reproduces with the old form and passes with the
new form in an isolated package; full package publish analysis remains a
release gate because these Forge package names are not yet published.

Android release-gate issue [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687)
is mitigated in the example release path. The Gradle build directory now
resolves from the project directory to the Flutter-expected `example/build`
path. After a normal release tooling regeneration (without `--no-pub`), the
JDK 21 release build produces `build/app/outputs/flutter-apk/app-release.apk`,
the Android plugin `syncReleaseLibJars` task succeeds, and the APK installs and
launches on the API 35 `emulator-5554` with `MainActivity` resumed and no fatal
crash in the smoke log. A clean JDK 17/provider/AAB/publish matrix remains in
the runtime register.

Android [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641)
and [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685)
are implemented in Android 1.0.40. Legacy API 19/20 and provider compatibility
paths remain SDK-gated, while the native compatibility files explicitly isolate
their deprecation diagnostics. The 47-test Android package suite,
`compileDebugKotlin`, and the debug APK build pass without package-owned
Java/Android deprecation warnings. A clean release/AAB/publish matrix remains
in the runtime register because the direct release compile still encounters the
generated dev-only `integration_test` registrant and the normal Flutter release
path uses a stale configured Android Studio JDK location in this environment.

Shared iOS/Android [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720)
now clears stale localhost-server state when the request stream ends or errors.
Platform-interface source coverage includes controlled restart and independent
server lifecycles; release-mode background/lock/resume, explicit restart, and
WebView reload validation remains in the runtime register.

iOS [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568)
now defers `loadUrl` calls made during `shouldOverrideUrlLoading` until the
WebKit navigation decision is released. Source/regression, SwiftPM, and Xcode
example validation pass; physical iOS navigation/header validation remains in
the runtime register.

iOS/macOS [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)
now isolates the `ASWebAuthenticationPresentationContextProviding` witness in
an availability-gated provider object. iOS/macOS source tests and SwiftPM
manifest checks pass, and the iOS example builds with Xcode 27; exact Xcode
26.4.1 and macOS consuming-app validation remain in the runtime register.

iOS [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787)
now retains the WebView's pre-keyboard `UIScrollView` zoom scale and content
offset, then refreshes the final platform-view frame/layout after dismissal so
WKWebView's DOM `visualViewport` returns to the Flutter WebView geometry. A
previous iPhone 17 Pro iOS 26.2 run passed
(`778px -> 435.44px -> 778px`), but current clean DDS reruns are inconclusive:
iOS 26.2 reports zero viewport metrics and iOS 27 does not expose a software
keyboard transition. Physical iOS 17, device, and native `WKWebView`
comparison validation remain in the runtime register, so #2787 remains
validation-pending.

Android [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)
now prioritizes `shouldInterceptRequest` and Service Worker interception on the
main looper, removes timed-out queued dispatches, and ignores late callback
results. The API 35 diagnostic also exposed and fixed a Kotlin overload
recursion in `injectDeferredObject` that caused `OutOfMemoryError` during rapid
navigation; Android 1.0.34 calls the platform `WebView.evaluateJavascript`
overload directly. Source tests and the API 35/WebView 124 diagnostic pass, but
physical Android 10/11 OEM/provider and back/forward validation remain in the
runtime register, so the active/runtime counts do not change.

Android [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718)
is source-hardened in Android 1.0.42. API 21+ cookie mutations no longer call
the synchronous `CookieManager.flush()` after asynchronous updates, while the
explicit `flush` API remains available. The Android package suite passes 49/49
tests and the native debug compilation/AAR build pass. Android 10/provider and
Play Console validation remain in the runtime register, so the 68 runtime-
pending and 41 active counts are unchanged.

Android [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555)
has a fresh 2026-08-10 API 35 AVD diagnostic pass for both virtual-display and
hybrid composition: the Flutter keyboard reopens after WebView clear/dispose
with `keyboardInsetAfterDispose=24.0` and an active Flutter focus node. Android
10 physical-device and OEM/provider validation remain in the separate runtime
register, so the 68 runtime-pending and 41 active counts are unchanged.

Android [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878)
is source-hardened and remains outside this active plan in the runtime register.
The existing API 35/WebView 124 diagnostic passes only with the documented
`SystemChannels.textInput.show` workaround; two workaround-free attempts lost
the Flutter VM service and then reported the AVD offline before the keyboard
assertion. This is not independent native runtime proof. Samsung One UI/WebView
150+ and physical-device validation remain required, so the 68 runtime-pending
count is unchanged.

Android file chooser PR [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243) is implemented locally in Android 1.0.41. The native callback boundary rejects canonicalized private-sandbox `file://` URIs from single-select, multi-select, and legacy picker results while preserving `content://` and FileProvider capture URIs. The source regression and native build are release evidence; hostile external-picker/provider validation remains a separate runtime gate, and this PR-only record does not change the issue counts above.

The iOS compatibility work from PRs [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771) and [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), together with the Android compatibility work from PR [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474), is also implemented locally. These are PR-only export records rather than issue rows, so they are tracked in the resolution log and known-issues validation matrix instead of the issue counts above.

Their remaining device/build checks are included in the runtime register. Do
not reopen their implementation without new failing evidence.

The Android provider-cast reports [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673)
and [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594)
are now mapped to the reported `WebSettingsCompat.setForceDarkStrategy` boundary;
their setter/getter fail-open guards and source tests are in the runtime register.
Android [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)
also validates optional native MethodChannel string fields by runtime type before
dispatching callbacks. Android 1.0.37 additionally rejects malformed permission
request/cancellation maps and non-list resources containers, while filtering
unknown resource entries without changing the public callback contract. Its
API/provider matrix remains in the runtime register, so the 68 runtime-pending
count is unchanged.

Android [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843)
and [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849)
now also release the first-load gate after a bounded WebView provider-startup
timeout, while preserving bridge and document-start registration retries. The
API 35/WebView 124 profile/AOT diagnostic passes four clean cold-start installs
with `onWebViewCreated`, `onLoadStop`, and both bridge checks succeeding. Physical,
headless, and release/provider validation remains in the runtime register, so the
68 runtime-pending count is unchanged.
The separate Android System WebView renderer report [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698)
contains only provider/Chromium termination evidence and provider rollback
results, so it is tracked as a host/platform boundary until a Forge-owned stack
or minimal-host comparison identifies a package control point.

iOS/Android disposal report [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)
now completes pending async JavaScript callbacks during teardown in both native
implementations, in addition to the idempotent disposal guards. The iPhone 17
Pro iOS 26.2 Simulator diagnostic completes four navigate-away/dispose/recreate
cycles with the safe `WebView navigation started` terminal result; the harness
accepts that result as well as `WebView disposed`. The API 35 AVD diagnostic
does the same across virtual-display and hybrid composition. Android emits the
expected Chromium renderer exit code `-1` while an explicitly destroyed WebView
is released, but no `AndroidRuntime`, fatal, or Dart test failure appears. Android
IME report [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555)
has detached-view and stale-runtime guards. Android fullscreen surface report
[#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819)
now also restores fullscreen state from `onRenderProcessGone` before forwarding
renderer-loss callbacks, while retaining its pre-destroy fullscreen exit
fallback. The Android package suite passes all 49 tests on 2026-08-10, but the
API 35 AVD cannot validate the reported MediaTek gralloc path. All three remain runtime pending until the affected physical-device
matrices pass. The API 35 IME diagnostic now passes for virtual-display and
hybrid composition WebViews after clear/dispose, but the Android 10/OEM gate
remains pending. The #2654 physical iOS 17+ and Android API 33+/OEM renderer
matrix also remains a release gate, so the runtime-pending count stays 68.

iOS popup crash report [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)
now also completes pending popup async JavaScript callbacks when a new
provisional navigation starts. The iPhone 17 Pro iOS 26.2 Simulator diagnostic
passes three popup attach/evaluate/navigate/dispose cycles, including
`shouldOverrideUrlLoading`; physical iOS 15–26 and Xcode 16/26 validation
remains in the runtime register, so the 68 runtime-pending count is unchanged.

Android screen-lock report [#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837)
now has an API 35 AVD lock/unlock checkpoint diagnostic. Hybrid-composition
WebView content and URL survive a real ADB keyevent lock/unlock sequence with
no AndroidRuntime, fatal, or renderer crash in the captured log. The Flutter
host's DDS/golden-stream connection prevents a clean integration-test exit;
Android 10 and OEM/provider validation therefore remain in the runtime
register and the count stays 68.

The following records are outside the implementation queue because the
available evidence identifies a host/platform failure with no package-owned
control point. They remain visible in the resolution log and must not be
reported as upstream-closed:

- [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636):
  iOS 18.4/18.5 Simulator can fail to resolve `libswiftWebKit.dylib` when the
  app deployment target remains below the affected runtime's requirement.
  The issue is addressed by newer Simulator/WebKit runtimes or host
  configuration; raising Forge's iOS 15 baseline would be an incompatible
  workaround.
- [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584):
  the reported iOS 18.4 startup crash is in Simulator/WebKit's
  `libswiftWebKit.dylib` boundary and has no reproducible Forge-owned source
  control point. It remains visible for Xcode/Simulator runtime tracking and
  must not be conflated with the local WebMessage payload validation work.
- [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659):
  Android's HTML time input reaches the platform `TimePicker` and the supplied
  stack ends in `TimePickerSpinnerDelegate.updateInputState`. Forge does not
  create or own that picker, so an OEM/framework fix or a reproducible provider
  workaround is required before changing plugin code.
- [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727):
  reports consistently identify Flutter's iOS platform-view gesture lifecycle;
  multiple upstream users report that upgrading Flutter to 3.41 resolves the
  modal-sheet/dialog regression. The Forge plugin cannot safely repair an
  engine gesture state from its WebKit layer while retaining the 3.38.6
  compatibility baseline.
- [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713):
  the Drawer dismissal/touch-loss report aligns with Flutter's iOS platform-view
  hit-testing and gesture lifecycle issue chain ([#175099](https://github.com/flutter/flutter/issues/175099),
  [#158961](https://github.com/flutter/flutter/issues/158961)). Reported
  workarounds operate at the Flutter overlay or engine level; Forge's iOS
  WebKit layer has no safe control point for resetting that gesture state.
- [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723):
  the ListView/NestedScrollView tap-loss report is tied to the Flutter iOS
  platform-view gesture path. The report uses Flutter 3.35.5, while the linked
  [workaround](https://khal.it/blog/flutter-webview-tap-gestures-break-nestedscrollview-ios-fix)
  identifies the framework fix as Flutter 3.38.6+; Forge's compatibility
  baseline is already 3.38.6. The plugin cannot repair an older Flutter
  gesture arena from its WebKit layer.
- [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598):
  dragging a Flutter `Draggable`/`Positioned` overlay can still scroll the
  underlying iOS WebView. Forge passes the caller's recognizers to `UiKitView`,
  while its opt-in `preventGestureDelay` hook only runs when the WebView itself
  wins hit testing; the plugin does not own the overlay's Flutter gesture arena.
  This is tracked as a host/platform boundary until a reproducible Flutter
  3.38.6+ minimal example identifies a Forge-owned control point.
- [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680):
  the Android mobile-data MP3 failure is tied to a Cloudflare `206 Partial
  Content` response and Android WebView/provider network delivery. The
  follow-up reports that the same URL works with `webview_flutter`, while
  Forge's default path passes through to Android WebView unless the host app
  supplies an interception response. The upstream record was stale-closed on
  2026-08-07; it remains a host/provider boundary locally until a Forge-owned
  interception regression is demonstrated.
- [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688):
  Android 35 hybrid, virtual-display, and direct-native transition diagnostics
  pass, and an external ADB capture shows a clean WebView-to-Flutter transition
  without a blank, black, or returning WebView frame. Source review found no
  Forge route-animation or Android surface-ordering control point, so this is
  tracked as an Android/Flutter engine/platform-view boundary rather than an
  implementation item.
- [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570):
  iCloud Keychain Password AutoFill depends on the host app's Associated
  Domains entitlement, the site's `apple-app-site-association` response, and
  semantic HTML `autocomplete` fields. The Forge iOS configuration has no
  Password AutoFill switch and cannot edit host entitlements or the remote
  login page, so the record is tracked as a host/application boundary.
- [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753):
  iOS `WKNavigationDelegate` reports navigation failures, not arbitrary
  HTTPS iframe subresource failures. The upstream report has no Forge-owned
  native callback or complete cross-origin JavaScript replacement; adding a
  partial error script would not preserve the `onReceivedError` contract.
  The record is tracked as an Apple/WebKit capability boundary pending a
  documented API-level decision or new WebKit evidence.
- [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831):
  the installed WebKit SDK declares the public geolocation decision delegate
  at iOS 27.0, not iOS 26.0. The iPhone 17 Pro iOS 26.2 diagnostic confirms
  `callbackOrigin=null` with a secure HTTPS page, while the iOS 27 Simulator
  receives the Dart callback and completes the deny path. iOS 26 prompt
  button behavior has no public Forge-owned decision hook; private WebKit APIs
  are not an acceptable plugin fix, so the record is tracked as a host boundary.
- [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796):
  the issue body references missing Pigeon classes inside
  `webview_flutter_android` 4.10.13, but the Forge dependency graph has no
  `webview_flutter_android` dependency or generated classes. It remains visible
  for dependency attribution tracking and has no Forge-owned build fix.

## Priority queue

### P0: Contain and reproduce

No unresolved P0 implementation item is currently in the active queue. Former
P0 record [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)
is now classified as an Apple/WebKit host boundary: the public geolocation
decision delegate is available in the iOS 27 SDK, while the iPhone 17 Pro iOS
26.2 run never invokes it. The iOS 27 Simulator deny-path diagnostic passes;
iOS 26 prompt ownership remains with WebKit.

### P1: Native stability and compatibility

#### Apple platforms

| Issues | Work package | Plan |
| --- | --- | --- |
| None currently | iOS channel and scene lifecycle | #2711 now catches only `MissingPluginException` from stale `goBack()` calls after native channel teardown. Keep it in the runtime register until physical iOS scene transitions, platform-view recreation, and a production-like stale-controller sequence are validated. |
| None currently | Apple keyboard viewport and accessibility layout | #2787 is source-fixed in iOS 2.1.20 and moved to the runtime register. Its iPhone 17 Pro iOS 26.2 Simulator diagnostic passes after restoring the pre-keyboard zoom/offset and final frame/layout; physical iOS 17/device and native `WKWebView` comparison validation remain pending. |

#### Android

| Issues | Work package | Plan |
| --- | --- | --- |
| None currently | Android WebView/platform-view transition | #2688 has clean Android 35 hybrid, virtual-display, direct-native, and external ADB visual evidence with no Forge-owned route-animation or surface-ordering control point; retain it in the host/platform boundary register. |

#### Windows and Linux

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814) | Windows child-window teardown | Reproduce the reported multi-window exit with and without `FindInteractionController`, then capture the WebView2 environment and child-window teardown order before changing native ownership. |
| [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752), [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615), [#2807](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2807) | Native startup and renderer failures | Reproduce on Arch Linux/WPE and affected Windows machines with full native logs. Test create/destroy/recreate, graphics-context invalidation, bundled/system WPE, and WebView2 runtime versions. |
| [#2735](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2735), [#2692](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2692), [#2682](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2682), [#2642](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2642), [#2577](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2577) | Windows focus, transparency, hit testing, and release behavior | Add a Windows native smoke matrix for focus, minimize/restore, transparent backgrounds, Google Sheets menus, and release packaging. Verify C++ child-window state after every async callback. |
| [#2732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2732), [#2590](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2590) | Screenshot/video and missing-plugin behavior | Reproduce with hardware video frames and generated plugin registrants. Define whether the native backend can capture video surfaces; otherwise return a documented unsupported result instead of a black image or missing method. |

### P1: Build, packaging, and release gates

| Issues | Plan | Exit criterion |
| --- | --- | --- |
| [#2839](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2839), [#2820](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2820), [#2672](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2672) | Reproduce MSVC `/await`, Xcode 26, CMake, and Windows/Linux warning failures on the supported toolchain. Pin or conditionally gate toolchain-specific settings. | Clean debug/release builds and actionable diagnostics on the supported matrix; unsupported toolchains fail with a clear prerequisite message. |
| [#2691](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2691) | Stabilize the remaining Windows build-warning and release-artifact path. Android [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641) and [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685) are implemented in Android 1.0.40; their clean release/provider/AAB/publish matrix remains in the runtime register. #2687's release JAR path is also mitigated and its remaining JDK/provider/AAB/publish matrix is tracked there. | `flutter analyze`, publish dry-run, Android release build, and all generated metadata checks pass without package-owned warnings. |
| [#2815](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2815), [#2788](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2788), [#2695](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2695), [#2686](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2686), [#2682](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2682) | Triage vague initialization, Windows warning/release, network, Safari, and packaging reports | Require a reproducible command, environment, and stack trace. Close as host/application-specific in the local log when no package path exists. |

### P2: API and feature decisions

These items must not be implemented by copying an upstream PR directly. Each one changes a public contract or has platform capability differences.

| Issue | Requested capability | Design step | Implementation boundary |
| --- | --- | --- | --- |
| [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846) | AGP 9 built-in Kotlin | Finish the migration tracked in [the Android plan](android-kotlin-kts-migration-plan.md) after the Flutter `>=3.47.0` toolchain decision. | Android Gradle files, examples, CI, namespace/registrant checks, and release builds. |
| [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834) | Sec-CH-UA and Client Hints control | Confirm which headers the native engines permit and document that browser/WebView policy may override them. | Per-platform settings only where supported; no false cross-platform guarantee. |
| [#2811](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2811) | WebAssembly support | Define whether this means browser WASM compilation, embedded WASM execution, or a native backend requirement. | Reproduce with a minimal WASM page before changing plugin code; likely a support/documentation item. |
| [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793) | Typed `bridgeEvents` API | Define event ordering, backpressure, payload typing, and compatibility with current JavaScript handlers. | Additive platform-interface API, all bridge implementations, generated metadata, and integration tests. |
| [#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760) | Windows pull-to-refresh without a scrollbar | Confirm WebView2 gesture support and whether this is a plugin overlay or native capability. | Windows-only capability with an explicit unsupported fallback. |
| [#2712](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2712) | DNS-level request blocking | Define whether URL/resource interception is sufficient; do not promise DNS control from an iframe/WebView callback. | Threat model, platform feasibility decision, and documentation before API work. |
| [#2706](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2706) | H5 input-operation interception | Convert the vague request into a concrete DOM event/API and test case. | JavaScript bridge only after security and event-volume review. |
| [#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690) | Apple Intelligence Writing Tools | Confirm public WebKit/UIKit API availability and deployment targets. | iOS/macOS settings only if a stable native API exists. |
| [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) | Android Payment Request / Google Pay | Validate Android WebView feature availability, permissions, and app/browser requirements. | Android feature check, callback contract, and a real-device integration test. |

### P3: Low-detail and product backlog

These records remain listed so they are not lost, but they should not consume implementation time before P0/P1 work has evidence:

`#2824`, `#2821`, `#2804`, `#2798`, `#2795`, `#2742`, `#2730`, `#2702`, `#2681`, `#2667`.

For each P3 item, first add the platform, OS/runtime version, minimal reproduction, expected behavior, actual behavior, and native stack trace to the triage record. A title-only report is not enough for a shared implementation change.

Showcase records [#2822](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2822), [#2769](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2769), and [#2716](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2716) remain community/product references and are excluded from engineering completion metrics.

## Runtime validation register

Runtime-pending records are resolved implementation work, not active queue
items. The complete register contains 68 issue records and four PR-only
records; counts, issue IDs, and platform gates are maintained in
[`runtime-validation-pending.md`](runtime-validation-pending.md). This plan
keeps only the 41 issue records that still need implementation, design, or
reproduction. Fourteen host/platform boundaries are tracked above and are not
counted as resolved implementations.

## PR queue

The PR export is also marked `OPEN`; do not merge or copy it without checking the current Forge source. These are the most relevant candidate records for the work packages above:

| Work package | Related PRs/issues |
| --- | --- |
| Linux rendering/build | [#2881](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2881), [#2832](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2832), [#2829](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2829) |
| iOS/macOS crashes and APIs | [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879), [#2870](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2870), [#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853), [#2836](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2836), [#2828](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2828), [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809), [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), [#2671](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2671) |
| Android API/stability | [#2823](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2823), [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817), [#2756](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2756), [#2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743), [#2722](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2722) |
| Windows stability/API | [#2869](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2869), [#2838](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2838), [#2806](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2806), [#2786](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2786), [#2768](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2768), [#2708](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2708) |
| Web and JavaScript bridge | [#2794](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2794), [#2792](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2792), [#2715](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2715), [#2495](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2495) |
| Toolchain and migration | [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846), [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758), [#2575](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2575), [#2574](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2574) |

Upstream PR [#2881](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2881) remains open. Its Linux EGL re-import work and reporter validation are useful evidence for #2861, but the PR is not treated as merged or as a substitute for the Forge Fedora/X11/Intel runtime gate.

## Implementation sequence

### Phase 0: Reproduction and test harness

- Add issue-specific test case names and environment fields to the example/test runner.
- Create Android, iOS/macOS, Windows, Linux, and Web matrices without changing behavior.
- Capture native logs, WebView/WebKit/WPE versions, composition mode, Flutter version, and platform lifecycle events.
- Mark each record `reproduced`, `not reproduced`, `host-specific`, or `needs reporter data`.

### Phase 1: P0 containment

- Keep the runtime validation register current for the Linux rendering fallback, iOS popup/geolocation behavior, Android activity extras, and the other local mitigations.
- Reopen a runtime-pending record here only when its real validation produces a new failure or shows that the implementation boundary is incomplete.
- Add only guards that are idempotent, nullable-safe, and covered by a failing regression test.

### Phase 2: Native stability

- Run the Apple crash/layout matrix, Android provider/WebView matrix, and Windows/Linux native lifetime matrix.
- Fix confirmed crashes and deadlocks in the owning platform package.
- Keep platform-interface changes limited to payload or capability corrections required by a confirmed native fix.

### Phase 3: Build and release gates

- Resolve toolchain failures and warnings on the supported versions.
- Run generated metadata, `flutter analyze`, package tests, native builds, SPM/CocoaPods checks, and Android APK/AAB artifact validation.
- Update package changelogs only after the relevant acceptance criteria pass.

### Phase 4: API and feature work

- Make a written capability/threat-model decision for each P2 item.
- Implement platform interface, generated files, all platform adapters, documentation, and integration tests together.
- Ship additive APIs only when unsupported platforms have explicit capability behavior.

## Definition of done

The 2026-08-10 status pass has 68 locally implemented or mitigated issue
records awaiting runtime validation, one source-validated issue (#2709) with
no runtime gate, one issue (#2745) closed by source review, fourteen
host/platform boundaries (#2570, #2584, #2598, #2636, #2659, #2680, #2688,
#2698, #2713, #2723, #2727, #2753, #2796, and #2831), and 41 active issue records in this plan. The runtime-pending
records and host boundaries are
deliberately not counted as active implementation work; their status notes
 live in [`runtime-validation-pending.md`](runtime-validation-pending.md) and
 [`known-issues.md`](known-issues.md). The active queue contains 28 bugs, 10
 enhancements, 0 unlabelled records, and 3 showcase records (38 active
 technical records after excluding showcases).

An issue leaves this plan for the runtime register when:

1. The original scenario has a minimal regression test or a documented host/platform limitation.
2. The fix is implemented in the owning federated package and preserves channel/API contracts.
3. Affected native builds and source tests pass on the target platform.
4. The missing device, browser engine, WebView, WebKit, WPE, or artifact gate is recorded in the runtime register.
5. The package changelog, [`known-issues.md`](known-issues.md), this plan, and the runtime register agree.

An issue leaves the runtime register only when its required real validation
passes and the final status is recorded in `known-issues.md` and the
resolution log.
