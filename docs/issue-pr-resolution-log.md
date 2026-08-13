# Issue and PR Resolution Log

Last reviewed: 2026-08-14

This document records the issue and pull-request exports supplied for the Forge maintenance work and relates them to the implementation already present in this repository.

## How to read this log

- The supplied `issues.csv` snapshot contains 125 issue records. Every exported issue has state `OPEN` because that is the upstream state at export time.
- The supplied `pr.csv` snapshot contains 73 PR records. Every exported PR has state `OPEN` for the same reason.
- `OPEN` in the export is not evidence that the local Forge implementation is unfixed. Local status is based on code, regression tests, changelogs, and the commit history in this repository.
- The CSV files contain title-level metadata only. They do not contain merge commits, review decisions, issue bodies, or complete issue-to-PR relationships.
- Where a PR clearly matches an issue by title or adjacent report, the relationship is listed. Otherwise the issue and PR are kept as separate records rather than inferred as a false one-to-one mapping.
- “Fixed”, “mitigated”, and “validation pending” describe the local implementation boundary. They do not change upstream GitHub state.

The detailed root-cause notes are in [known-issues.md](known-issues.md). Package release notes are in the root and platform `CHANGELOG.md` files.

## 2026-08-14 WebView prewarm and reuse helper (local feature)

The root package adds `InAppWebViewPreloader` as a small Dart coordinator over
the existing headless-to-normal WebView transfer. `prewarm()` is single-flight
for concurrent callers, `InAppWebView(preloader: ...)` forwards the same
headless owner and KeepAlive token, and `dispose()` selects the headless or
retained KeepAlive cleanup path exactly once. No MethodChannel names, payload
keys, native code, or platform-interface contracts changed. The focused
preloader tests pass; physical cold-start, first-frame, memory, and page-load
profiling remain runtime validation rather than a claimed benchmark result.

## 2026-08-13 Android/iOS lifecycle and settings refactor checkpoint

The first implementation wave of the lifecycle/performance plan is source-
validated in Android 1.0.53 and iOS 2.1.31. Keep-alive and headless manager
maps no longer retain nullable placeholders; ownership is removed before
disposal, duplicate IDs dispose the previous native owner, and headless
disposal is idempotent. Both native packages now use an internal lifecycle
coordinator for teardown and tracked async JavaScript completion; Android
also rejects stale renderer/registration callbacks. Android skips unchanged
content-blocker and asset-loader work. iOS skips unchanged content-blocker
compilation and does not apply omitted `mediaType` or scroll-axis values
during partial settings updates. Public Dart APIs and MethodChannel contracts
are unchanged. Focused package tests, Android example Kotlin compilation,
and iOS SwiftPM validation pass; the example-wide Dart analysis remains noisy
because of pre-existing example-only diagnostics and is not used as the
platform-native gate. Android and iOS
channel dispatch now group JavaScript, settings, WebMessage, and lifecycle
operations behind internal handlers. The iOS Simulator
now passes the expanded 100-cycle disposal/recreate diagnostic, plus 50
keep-alive and 50 headless-to-normal transfer cycles. The connected Android API
36 device passed 100 disposal/recreate cycles and 50 keep-alive plus 50
headless-to-normal transfer cycles with `--no-uninstall` before the final
Android headless guaranteed-cleanup path was added. The final Android code
then passed the same 100 disposal/recreate and 50+50 ownership-transfer matrix
on the API 35 `Medium_Phone` emulator with `--no-uninstall`. On 2026-08-13 it
also passed the final 100 disposal/recreate and 50+50 ownership-transfer
matrix on the connected physical API 36 target without uninstalling the app;
the filtered post-test log had no app `AndroidRuntime`, fatal, signal, or ANR
entry. The final iOS code also passed on 2026-08-13 on the connected physical
iOS target: 100 disposal/recreate cycles and 50+50 ownership-transfer cycles
completed with `--no-uninstall`. Broader Android provider/OEM and renderer-loss
coverage, plus broader physical iOS keyboard/scene/provider gates, remain
pending;
no upstream issue or PR state was changed.
Android and iOS native user/plugin script registration now skips active
duplicates while retaining retryable failed registrations. Android and iOS
pull-to-refresh callbacks also pass through the hosted WebView
lifecycle gate and reset the native refreshing state when teardown wins the
race.
The Android JavaScript bridge now rejects work before queueing and before
evaluating a queued response after disposal. iOS evaluateJavascript results
are lifecycle-tracked and completed once during navigation or disposal, with
the existing MethodChannel result shape preserved.
Native callback results and default decisions on both platforms also use
exactly-once completion gates for teardown races; public channel names and
payloads remain unchanged. A fallback is accepted only as part of the active
completion handler and is rejected after a handled result has completed.
Android JavaScript UI and bridge error callbacks also claim the boundary
before invoking native cancel/reject fallbacks.
The callback audit also gates delayed Android IME, scroll-stop, and context-menu
work, plus iOS delayed keyboard, gesture, scroll, content-size, and context-menu
work, before native UI is touched after disposal.
It also gates Android floating-menu/plugin-script callbacks and iOS delayed
focus/image-reference callbacks, and corrects the iOS incremental
`isPagingEnabled` assignment without changing the channel payload.
Android web-archive and iOS screenshot/PDF/web-archive native completions are
now tracked as lifecycle operations and drained exactly once during teardown.
Android screenshot work and initial platform-view loading also re-check
lifecycle admission across posted callbacks.
The iOS deferred popup initialization and fullscreen-container presentation
callbacks use the same main-queue lifecycle gate.
The follow-up source audit makes headless-to-normal ownership removal atomic
in both factories, disposes stale entries that cannot yield a native view, and
protects newer headless owners from an older wrapper's late cleanup. Duplicate
headless IDs now dispose any active owner in the shared native ID namespace.
The iOS WebKit delegate completes stale permission, navigation,
authentication, dialog, and popup decisions with native defaults after
disposal.
The Android and iOS headless-to-normal transfer path removes the transferred
native WebView from its old active ownership map before disposing the headless
wrapper; matching source assertions cover the single-owner invariant.
Their managers now also clear active and retained ownership before disposing
all remaining native WebViews during plugin teardown; macOS follows the same
manager teardown rule. Android `finally` and iOS/macOS `defer` cleanup paths
ensure the coordinator reaches its terminal state after an accepted dispose.
Android print-job and Custom Tabs ownership maps, and the equivalent iOS
print-job, authentication-session, and in-app-browser maps, are now non-null;
managers detach all entries before child disposal to avoid null placeholders and
concurrent ownership mutation.
Android async JavaScript preparation and failed WebView queue posts now consume
their operation exactly once with the existing result structure. iOS screenshot
compression options default safely instead of force-casting nullable channel
values; package tests and host builds pass.
Lifecycle coordinator state transitions and debug traces are now serialized on
Android and iOS so concurrent disposal or renderer callbacks cannot win twice.
iOS KVO registrations are tracked per object/key path and removed idempotently
during teardown.
The headless-to-normal factories also restore transferred native WebViews in
the active manager map after detaching the old headless owner, preserving one
reachable owner for lookup and plugin teardown.
The native lifecycle coordinators now also have device-free Android JVM and iOS
host regression runners for retained reattachment, renderer-loss recovery,
exactly-once async completion, and concurrent disposal.
The Web implementation additionally caches settings snapshots to skip unchanged
JavaScript interop updates; outgoing Web callbacks re-check lifecycle admission
after asynchronous channel work, and async operation IDs prevent duplicate
completion. The Web package tests and example build pass; browser runtime
validation remains pending.

The follow-up ownership slice is also source-validated in macOS 1.1.9,
Windows 1.0.14, Linux 1.0.8, and Web 1.0.3. macOS headless/keep-alive maps no
longer use nullable entries and duplicate owners are disposed; Windows and
Linux replace duplicate native owners deterministically; Linux enables its WPE
disposal callback gate before cleanup; and Web headless transfer retains the
iframe/JavaScript bridge while rebinding the regular view channel and manager
ID. Web tests and the Web example build pass, as do macOS/Windows/Linux source
tests and the macOS SwiftPM manifest check. Web scroll notifications are
coalesced to animation-frame cadence. Linux and Windows retained ownership now
use internal lifecycle coordinators for detach/reattach and disposal. Web create, retained-transfer, reattach,
and disposal now share one internal lifecycle coordinator without changing the
Web MethodChannel contract. Linux now diffs WebKit/WPE settings against the
previous snapshot and skips duplicate content-blocker compilation. Android
startup/renderer/scroll/geometry guards now use the coordinator as
their single disposal source. Windows and Linux channel delegates also gate
outgoing native events and callback requests through lifecycle state while
preserving the existing callback fallback behavior. macOS example compilation
is
blocked by the host Xcode beta's existing 10.15 deployment target, Windows
native validation requires Windows/WebView2, and Linux native validation
requires WPE packages and `pkg-config`. No upstream issue or PR state changed.
The iOS and macOS delegates now apply the same outgoing callback boundary,
including WebMessage and FindInteraction sub-delegates; their pending
MethodChannel results are drained exactly once during teardown. The macOS
coordinator also tracks native and legacy async JavaScript completions and
resolves each pending callback once. The iOS example build and both iOS/macOS
source suites pass; target-runtime validation remains pending.
Android channel events and decision callbacks now use the lifecycle gate with
their existing default fallback behavior, and Android headless ownership uses
the coordinator instead of a second dispose flag. Android source tests and
Kotlin compilation pass.

## 2026-08-13 iOS Writing Tools settings (#2690)

Upstream [issue #2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690)
requested an API for Apple Intelligence Writing Tools settings. The installed
iOS SDK exposes the public `WKWebViewConfiguration.writingToolsBehavior` API
from iOS 18.0, backed by `UIWritingToolsBehavior` values `none`, `default`,
`complete`, and `limited`. Forge now implements the additive
`IOSWritingToolsBehavior` enum and
`InAppWebViewSettings.writingToolsBehavior` in platform-interface 1.1.15 and
applies it to the initial iOS `WKWebViewConfiguration` in iOS 2.1.30. The
setting is availability-guarded, serialized, capability-advertised, and
reported by `getSettings()`; iOS 15-17 preserve WebKit's default behavior.
Platform-interface tests and iOS source-contract tests pass. Physical iOS
18+ Writing Tools UI, capability fallback, and readback validation remain
pending. The upstream issue state was not changed.

## 2026-08-13 iOS input accessory and autocorrection controls (local)

No upstream issue or PR reference was supplied for this local reproduction.
`disableInputAccessoryView` previously only changed the WebView subclass
getter; after an HTML input regained focus, WebKit could retain the accessory
view because the active responder's input views were not reloaded. iOS 2.1.31
now calls `reloadInputViews()` across the WebView hierarchy after the setting
changes and during keyboard presentation. Platform-interface 1.1.17 and root
2.1.70 expose `InAppWebViewSettings.disableAutocorrection` for Android, iOS,
macOS, Windows, Linux, and Web. Each implementation applies
`autocorrect="off"` and `spellcheck="false"` to existing and dynamically-added
editable HTML elements when the WebView is created. Platform-interface and
native source-contract tests cover serialization, capability metadata, and
script coverage. Physical keyboard/WebView validation remains pending. No
upstream issue state was changed.

## 2026-08-13 Cross-platform container API parity

Upstream [PR #2825](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2825)
requested named persistent WebView containers, `InAppWebViewSettings.containerId`,
container enumeration/deletion, and per-container proxy support. Forge now
implements the Android, iOS, macOS, Windows, and Linux storage portion in
platform-interface 1.1.13, Android 1.0.52, iOS 2.1.29, macOS 1.1.8, Windows
1.0.12, Linux 1.0.7, and root 2.1.66: `ContainerController` exposes
named container management; Android binds `ProfileStore` before bridge,
cookie, or other WebView state initialization and routes scoped cookie calls to
that WebView's profile cookie store; iOS 17+ binds UUID identifiers to
`WKWebsiteDataStore` and exposes enumeration/deletion; iOS cookie calls scoped
with `webViewController` now use that WebView data store; iOS 17+ also applies
`proxySettings` to the selected data store; macOS and Linux controller-scoped
cookie calls now use the WebView's data store/network session; Linux applies
proxy settings to the selected network session and Windows maps the first
default proxy rule and bypass list during WebView2 environment creation;
Android `CookieManager.flush` now
fans out to all container profile cookie stores; `clearContainerData` clears
supported container data without deleting the profile. The source regression
suite, Android Kotlin compile, and Xcode iOS example build pass. Android
WebView 110+/`MULTI_PROFILE` and physical iOS 17+ validation are still
required; desktop target-OS builds/runtime validation remain pending. An
explicit Windows `WebViewEnvironment` cannot be reconfigured after creation.
The upstream PR
state was not changed.

## 2026-08-13 Windows pull-to-refresh without a scrollbar

Upstream [issue #2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760)
requested an option to keep pull-to-refresh available for Windows pages that
do not expose a vertical scrollbar. Forge implements the additive
`PullToRefreshSettings.allowWithNoScrollbar` setting in platform-interface
1.1.14 and root 2.1.67. Windows 1.0.13 wires the setting through
`WindowsPullToRefreshController` and `CustomPlatformView`: a touch gesture is
eligible only after `window.scrollY <= 0` succeeds, then the existing
`onRefresh` callback fires after an 80 logical-pixel downward drag. The
indicator state is exposed through the existing begin/end/color controller
methods. The default remains disabled and failed top-edge checks fail closed.
Platform-interface tests pass 14/14 and Windows source-contract tests pass
1/1. Windows example/consuming-app build and WebView2 runtime gesture
validation remain pending. The upstream issue state and comments were not
changed.

## 2026-08-12 iOS physical popup validation

The physical iOS device ran `ios_popup_default_handling_diagnostic_test.dart`
with `--no-uninstall`. The test received `https://example.com/popup` in
`onCreateWindow`, returned `false`, kept the caller at
`https://example.com/`, and finished with `All tests passed!`. The app and
provisioning profile remained installed on the device. Repeated popup
attachment, navigation, disposal, and scene-transition coverage across iOS
15-26 remains pending. No upstream issue state or comment was changed.

## 2026-08-11 iOS fullscreen seek runtime validation

Upstream [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710)
remains open; no upstream state or comment was changed. Forge iOS 2.1.17's
native-container mitigation was exercised by the opt-in
[`ios_fullscreen_video_seek_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_fullscreen_video_seek_diagnostic_test.dart).
The iPhone 17 Pro iOS 26.2 Simulator passed three real MP4 play/seek/fullscreen
cycles, dismissed the container through the runtime opt-out, and re-entered
with the expected `isInFullscreen` transitions. The test exited 0; iOS package
tests passed 2/2 and the SwiftPM manifest validated with the module-cache
workaround. Physical iOS/GPU/media matrices remain release gates, so #2710 is
resolved at the implementation boundary but remains runtime-pending and the
counts are unchanged.

## 2026-08-11 Android A16 critical-path validation

The Samsung A16 (`SM-A165F`, Android 16/API 36, MediaTek MT6789, WebView
150.0.7871.181) was used for the first physical Android validation pass. The
opt-in #2718 cookie diagnostic completes 10/10 mutation and explicit-flush
cycles, leaves an empty final cookie list, and records cycle durations from 21
to 279 ms. The #2580 rapid-interception diagnostic completes 24 rapid
navigations with `finalLoaded=true`, the `final` DOM marker, and 31
interception callbacks. The #2878 fullscreen-exit diagnostic reports
`insetBeforeFocus=0.0`, `insetAfterFocus=346.31`, and an active Flutter focus
node without the documented workaround. The #2555 diagnostic passes both
virtual-display and hybrid composition with `keyboardInsetAfterDispose=358.4`
and an active Flutter focus node. The #2837 screen-lock diagnostic also passes
on the A16 in hybrid and virtual-display composition: the DOM marker and URL
survive a real lock/unlock checkpoint and both tests exit successfully. None of
the runs emits an app `AndroidRuntime`, fatal, ANR, IME NPE, or OOM. The cookie,
interception, IME, fullscreen, and disposal runs show only Chromium tile-memory
warnings; #2837 also has one system `ActivityManager` freeze warning, while
#2536 records provider/browser startup warnings and one system
`ActivityManager` IntentRedirect Hardening warning. Android 10/11 OEM/provider,
back/forward, and Play Console/release validation remain pending, so the
records stay in the runtime register and the counts do not change. No upstream
issue or PR state/comment was changed.

## 2026-08-12 iOS physical-device signing and disposal validation

The iOS example was updated to use the local team `2A93W9KX49` and the
`com.emirkanacar.flutterinappwebview-ios-example5` bundle-id prefix while
retaining the existing example target structure. Xcode's automatic signing
then produced a valid device-signed app after the provisioning approval was
accepted. The physical iOS device installed and launched the app, and
`ios_disposal_lifecycle_diagnostic_test.dart` passed with `All tests passed!`.
This is one physical-device lifecycle checkpoint; repeated cycles and the
broader iOS 15-26/provider matrix remain pending. No upstream issue or PR
state/comment was changed.

## 2026-08-12 Android action-mode and display-size validation continuation

The Android package suite passes 53/53 tests, including the #2868 action-mode
regression that prevents OEM icon-only placeholders and guards malformed
provider resources. The Android example `:app:compileDebugKotlin` task also
passes. On the connected Android 16 device, #2721 applied and reset the
`wm size` override, restoring the physical `1080x2340` size, but the Activity
and VM service restarted during the configuration change before the geometry
assertion could complete. The app remained installed and resumed normally.

The physical iOS disposal diagnostic was rerun with `--no-uninstall` and
completed four cycles with outcomes `[WebView disposed, WebView disposed,
WebView navigation started, WebView navigation started]`; the test passed and
the app remained installed.

## 2026-08-12 iOS physical keyboard viewport validation

The physical iOS device ran `ios_keyboard_viewport_diagnostic_test.dart` with
`--no-uninstall`. The WebKit visual viewport changed from `839px` to
`487.8125px` while the native keyboard was visible, then returned to `839px`
with `visualViewportOffsetTop=0` after dismissal. The test finished with
`All tests passed!`; the app and provisioning profile remained installed.
Custom page-zoom and broader iOS 17+ comparison coverage remain pending.

## 2026-08-12 iOS physical fullscreen validation gate

The physical iOS device ran `ios_fullscreen_video_seek_diagnostic_test.dart`
with `--no-uninstall`. The first bundled-video seek/fullscreen cycle returned
`request=null` and did not deliver the `onEnterFullscreen` callback within the
diagnostic timeout, so the test failed before exercising the three-cycle
mitigation. The app and provisioning profile remained installed. This is
recorded as a physical WebKit/media validation failure; no source change is
claimed from this run.

## 2026-08-12 iOS physical multi-window navigation validation

The physical iOS device ran `ios_multi_window_navigation_diagnostic_test.dart`
with `--no-uninstall`. Three popup attach/evaluate/navigate/dispose cycles
completed, with popup navigation callbacks including
`https://example.com/popup-0` and the expected `about:blank` transitions. The
test finished with `All tests passed!`; the app and provisioning profile
remained installed. Broader iOS 15-26/Xcode matrix and symbolicated-crash
comparison remain pending.

## 2026-08-12 Android 16/API 36 physical validation continuation

The connected Android 16/API 36 device, using WebView 151.0.7922.83, passed
the opt-in diagnostics for #2555 IME lifecycle, #2878 fullscreen keyboard,
#2654 disposal/recreate, #2819 renderer/fullscreen, #2837 screen-lock redraw,
#2843/#2849 cold-start bridge, #2536 Bundle codec/activity handoff, #2688
WebView-to-Flutter transition, #2580 rapid interception/navigation, and #2718
cookie mutation/explicit flush. The headless cold-start diagnostic also passed
four document-start cycles. The #2721 display-size override was applied and
reset successfully, but Android restarted the example Activity/VM service on
the resize path before the geometry assertion, so that issue remains runtime-
pending. The #2868 resource/action-mode crash has not yet had a dedicated
selection-toolbar reproduction on this device. No upstream issue or PR
state/comment was changed.

## 2026-08-10 Android file chooser sandbox URI

GitHub CLI review of upstream [PR #2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243)
identified a security boundary in Android file chooser results: an implicit
third-party picker can return a private `file://` URI that the host WebView
then exposes to page content. Forge Android 1.0.41 now canonicalizes the URI
path, rejects the host application's `ApplicationInfo.dataDir` and all
`/data/` paths, and applies the same filter to modern single-select,
`ClipData` multi-select, and legacy callbacks. `content://` selections and
FileProvider camera captures remain supported.

The Android package suite passes 48/48 tests, `compileDebugKotlin`, and the
`assembleDebug` AAR task. The Flutter APK wrapper remains blocked by the
existing Gradle 8.13/JDK `OutgoingVariantsReportTask` compatibility failure;
adversarial external-picker/provider testing also remains pending. This is a
PR-only record outside the 125-issue count. The upstream PR remains open and
no upstream comment or state change was made.

## 2026-08-10 Android cold-start provider timeout

GitHub CLI review of upstream [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), and related [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) confirms the shared cold-start race: provider startup and document-start registration can overlap Chromium browser-process initialization. Android 1.0.38 now bounds the asynchronous provider-startup gate at five seconds, then relies on the existing bridge/document-start registration retries instead of holding the first platform-view load indefinitely.

The new opt-in `android_cold_start_bridge_diagnostic_test.dart` passes four clean profile/AOT installs on the API 35 `emulator-5554` with WebView 124: `onWebViewCreated`, `onLoadStop`, `typeof window.flutter_inappwebview == object`, and the document-start marker all succeed. On 2026-08-11, `android_headless_cold_start_diagnostic_test.dart` passes four headless create/load/dispose cycles with the same document-start marker, and the general HeadlessInAppWebView suite passes 6/6. No app `AndroidRuntime`, ANR, or native fatal appears. Explicit headless disposal emits Chromium renderer exit code `-1`, matching the known teardown signature tracked separately under external #2491, while the test process exits 0. Flutter Driver cannot run in release mode, so physical-device, release/R8, and provider-matrix validation remain required. No upstream issue state or comment was changed.

## 2026-08-10 iOS/Android disposal callback completion

Upstream [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)
remains `OPEN`; the local status is separate from the upstream export. The
iOS implementation now tracks native iOS 14+ and legacy async JavaScript
callbacks together, completes both callback sets with `WebView disposed`
before teardown, and ignores late WebKit completions after the table is cleared.
Android now completes its pending async JavaScript callback table before
releasing the channel, while retaining idempotent disposal and fullscreen
cleanup ordering.

The iPhone 17 Pro iOS 26.2 Simulator diagnostic completes four
navigate-away/dispose/recreate cycles with the safe `WebView navigation started`
terminal result; a clean iPhone 17 Pro iOS 27 Simulator run also completes four
cycles with safe `WebView navigation started`/`WebView disposed` outcomes. The
diagnostic accepts both outcomes. The API 35 `emulator-5554` diagnostic covers virtual-display
and hybrid composition. Explicit Android WebView destruction still logs
Chromium renderer exit code `-1`, but the host reports no `AndroidRuntime`,
fatal, or Dart test failure. Physical iOS 17+ and Android API 33+/OEM/provider
validation remain release gates.

## 2026-08-10 iOS popup navigation callback completion

Upstream [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)
and related popup workaround [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776)
remain open upstream. Forge iOS 2.1.22 now completes pending native and legacy
`callAsyncJavaScript` callbacks with `WebView navigation started` when a new
provisional navigation begins, clears the callback tables before completion,
and ignores late WebKit callbacks. The source contract test and the opt-in
`ios_multi_window_navigation_diagnostic_test.dart` pass; the iPhone 17 Pro
iOS 26.2 Simulator completes three popup attach/evaluate/navigate/dispose
cycles and reports all `shouldOverrideUrlLoading` URLs. Physical iOS 15–26,
Xcode 16/26, and symbolicated-crash validation remain release gates.

## 2026-08-10 Android screen-lock redraw checkpoint

Android [#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837)
already has the visibility recovery fix in Android 1.0.8. The new opt-in
`android_screen_lock_redraw_diagnostic_test.dart` reached a real API 35
`emulator-5554` hybrid-composition checkpoint: after ADB keyevent lock/unlock,
the `ANDROID_SCREEN_LOCK_MARKER` DOM content and WebView URL remained intact,
and the captured log contained no `AndroidRuntime`, fatal, or renderer crash.
The host Flutter runner could not complete a clean exit because DDS/golden
stream setup was unavailable; Android 10 and affected OEM/provider validation
remain release gates. No upstream issue state or comment was changed.

## 2026-08-10 Android permission payload boundary hardening

GitHub CLI review of upstream [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)
and related [#2857](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2857)
confirmed that the upstream patch covers the nullable context-menu title only.
The local Android 1.0.30 hardening already covered that field and the other
optional strings, but a focused regression test then reproduced a remaining
`String`-to-`List` cast failure when a valid permission origin was paired with a
malformed `resources` container. Android 1.0.37/root 2.1.40 now validates the
permission request and cancellation map, origin, and resources container before
decoding; valid string entries are retained and unknown entries are filtered.
The focused test and Android package suite pass. The API/provider matrix remains
in the runtime register, and no upstream issue state or comment was changed.

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
| Locally implemented or mitigated; runtime validation pending | 74 issues | [runtime-validation-pending.md](runtime-validation-pending.md) |
| Resolved locally; no runtime gate | 1 issue (`#2709`) | Focused Dart serialization regression test; no device/provider behavior is involved |
| Closed by source review | 1 issue (`#2745`) | No package runtime gate |
| Host/platform-specific boundary | 15 issues (`#2570`, `#2584`, `#2598`, `#2636`, `#2659`, `#2680`, `#2688`, `#2698`, `#2713`, `#2723`, `#2727`, `#2753`, `#2796`, `#2815`, `#2831`) | Host/provider/engine/application/site/dependency tracking in [known-issues.md](known-issues.md); no Forge-owned fix |
| Open implementation or reproduction | 34 issues | [open-work-plan.md](open-work-plan.md) |
| PR-only local implementations awaiting runtime validation | 9 PRs | `#2243`, `#2771`, `#2871`, `#2474`, `#2823`, `#2853`, `#2743`, `#2825`, `#2866` |

The issue inventory below remains the historical 125-record export and is not
reduced when a record moves between the local status registers.

## Local resolution history

| 2026-08-13 | Universal Link navigation policy | [#2866](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2866) | The additive `NavigationActionPolicy.ALLOW_WITHOUT_TRYING_APP_LINK` maps to WebKit raw value `3` on iOS/macOS and falls back to `ALLOW` (`1`) on Android, Web, Windows, and Linux. iOS/macOS decode the raw policy defensively; focused Dart and native source-contract tests pass. An associated app and Universal Link domain are still required to validate an OAuth/form POST without app handoff. |

| 2026-08-10 | Android file chooser private-sandbox URI | [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243) | Android 1.0.41 rejects canonicalized private `/data/` `file://` results from modern single-select, `ClipData` multi-select, and legacy callbacks while preserving `content://` and FileProvider capture URIs. Focused source regression and native build validation remain the local gates; adversarial picker/provider testing is pending. |
| 2026-08-12 | Android audio capture file chooser | [#2823](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2823) | Android 1.0.44 detects `audio/*`, launches a recorder directly for capture-only requests when available, and adds a guarded audio recorder option to the chooser without requiring camera permission. Source regression and native build validation remain local gates; device/provider recorder validation is pending. |
| 2026-08-12 | Android WebAuthn support setting | [#2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743) | Android 1.0.45 exposes nullable `WebAuthenticationSupport` values through platform-interface 1.1.5, applies them with the `WEB_AUTHENTICATION` feature guard, and reports the effective setting through `getRealSettings`. The 2026-08-12 physical Android diagnostic reports `WEB_AUTHENTICATION=true` and effective `FOR_APP=1`; platform-interface and Android tests plus the native Kotlin/AAR build pass. Physical Digital Asset Links and authenticator-flow validation remains pending. |
| 2026-08-12 | Android Payment Request / Google Pay | [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) | Android 1.0.46 and root 2.1.54 expose nullable `paymentRequestEnabled` through platform-interface 1.1.6, apply it only behind `WebViewFeature.PAYMENT_REQUEST`, report it through `getRealSettings`, and include the Chromium Payment Request manifest queries. The 2026-08-12 physical Android diagnostic reports `PAYMENT_REQUEST=true` and effective `paymentRequestEnabled=true`; platform-interface and Android tests plus `compileDebugKotlin` and `assembleDebug` pass. Google Pay readiness/transaction, host publication, merchant, user-agent, and provider matrix validation remains pending. |
| 2026-08-12 | Android Sec-CH-UA and Client Hints customization | [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834) | Android 1.0.47, platform-interface 1.1.7, and root 2.1.55 expose nullable `userAgentMetadata`, generate `USER_AGENT_METADATA` capability metadata, filter malformed brand entries, and apply `WebSettingsCompat.setUserAgentMetadata` only behind the AndroidX feature check. The opt-in physical Android diagnostic passed on 2026-08-12: configured platform, platform version, model, mobile state, and full version list were returned by `navigator.userAgentData.getHighEntropyValues`; the app was updated in place with `--no-uninstall`. Provider/request-header matrix validation remains pending because Chromium policy may override header generation or prevent complete suppression. |
| 2026-08-12 | Android AGP 9 built-in Kotlin compatibility | [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846) | Android 1.0.48 and root 2.1.56 conditionally apply `org.jetbrains.kotlin.android` only for AGP <9 and configure JVM 17 through `KotlinAndroidProjectExtension`; the Forge examples no longer force-disable built-in Kotlin/new DSL. The static migration regression passes; Flutter >=3.47/AGP 9/Gradle 9/JDK 17 and legacy AGP 8 consuming-app validation remain pending. |
| 2026-08-12 | iOS platform-view focus recovery | [#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853) | iOS 2.1.25 searches the WebView hierarchy for a focusable `WKContentView` before falling back to `WKWebView`, restoring the existing `requestFocus()` channel/API contract. iOS source tests and SwiftPM manifest validation pass; physical document-focus and focus-event validation remains pending. |
| 2026-08-10 | Android cookie mutation ANR [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | No upstream relationship inferred | Android 1.0.42 removes UI-thread `CookieManager.flush()` calls after asynchronous `setCookie`, `deleteCookie`, and `deleteCookies` mutations, while preserving the explicit `flush` API. The Android package suite passes 49/49 tests, `compileDebugKotlin`, and `assembleDebug`. The remote-URL Cookie Manager integration test builds/installs on API 35 but times out before assertions without a fatal/ANR log, so Android 10/provider and Play Console validation remains pending. |
| 2026-08-11 | Android explicit cookie flush completion [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | No upstream relationship inferred | Android 1.0.43 completes the explicit `CookieManager.flush()` MethodChannel result after the native persistence request, closing the caller-side future hang while retaining the 1.0.42 asynchronous-mutation ANR mitigation. The source regression suite passes 48/48; the A16 diagnostic passes 10/10 cycles with an empty final cookie list and no app crash/ANR. Android 10/provider and Play Console validation remain pending. |
| 2026-08-11 | Android cold-start and startup reattach [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) | [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) | Android 1.0.38 orders provider startup and document-start registration, bounds a stuck startup callback, retries transient failures, and recreates the startup executor after engine detach while ignoring stale generations. Android source tests, four API 35/WebView 124 profile/AOT cold-start installs, four headless document-start cycles, and the general headless 6/6 suite pass. Explicit disposal emits Chromium renderer code `-1` without an app fatal/ANR and is tracked separately as a teardown signature; physical release/R8 and provider validation remains pending. |
| 2026-08-09 | iOS/macOS Xcode authentication availability [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830) | [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809) | iOS 2.1.19 and macOS 1.1.6 isolate the authentication presentation provider behind the iOS 13/macOS 10.15 availability boundaries. iOS/macOS source tests, Swift Package manifest checks, and the Xcode 27 iOS example build pass; exact Xcode 26.4.1 and macOS consuming-app validation remain pending. |
| 2026-08-10 | Android interception freeze and cookie ANR [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | No upstream relationship inferred | Android synchronous interception is bounded by concurrency and timeout limits, and `deleteAllCookies` no longer flushes synchronously after asynchronous removal. The fresh API 35/WebView 124 #2580 diagnostic passes 24 rapid navigations with `finalLoaded=true`, the `final` DOM marker, and 31 interception callbacks; no app `AndroidRuntime`, fatal, ANR, or OOM log appears. Android 10/provider and Play Console runtime validation remains pending. |
| 2026-08-09 | Android interception dispatch hardening [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | [#2773](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2773) (closed, not merged) | Android 1.0.31 prioritizes WebView and Service Worker interception callbacks on the main looper, cancels queued callbacks after timeout, and suppresses late results. Android tests and analysis pass; rapid-navigation/provider validation remains pending. |
| 2026-08-09 | Android rapid-navigation JavaScript injection OOM [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | No upstream relationship inferred | Kotlin migration overload recursion in `injectDeferredObject` called the plugin `evaluateJavascript` overload instead of the platform WebView overload. Android 1.0.34 fixes the boundary and adds a source regression test. The fresh API 35/WebView 124 diagnostic passes 24 rapid navigations with `finalLoaded=true`, the `final` DOM marker, 31 interception callbacks, and no app fatal/ANR/OOM; physical Android 10/11 OEM/provider validation remains pending. |
| 2026-08-10 | Android fullscreen exit keyboard restoration [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878) | No upstream relationship inferred | Android 1.0.34 restores the Flutter container input connection after `onHideCustomView()` by requesting focus, resetting the non-hybrid proxy when applicable, and restarting the Android IME input. The 2026-08-11 workaround-free Samsung A16/WebView 150 diagnostic passes with `insetBeforeFocus=0.0`, `insetAfterFocus=346.31`, and an active Flutter focus node; Android 10/OEM and broader physical-device validation remain pending. |
| 2026-08-10 | iOS popup/window-ID crashes [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | No upstream relationship inferred | iOS now defers popup window-ID initialization off KVO, verifies observed object identity, ignores callbacks after disposal, and uses the initialized page world for popup JavaScript. A fresh iPhone 17 Pro iOS 26.2 `flutter drive` run exits 0 after three popup attach/evaluate/navigate/dispose cycles, including `shouldOverrideUrlLoading` and the async `about:blank` race; no `EXC_BAD_ACCESS`, `SIGSEGV`, `SIGABRT`, or fatal Simulator log is present. Physical iOS/Xcode validation and a symbolicated crash comparison remain pending. |
| 2026-08-08 | iOS header replacement navigation [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | No upstream relationship inferred | iOS counts simultaneous navigation-policy decisions, queues replacement-header loads until the final decision handler completes, and rejects malformed URL requests safely. Source tests pass; physical navigation validation remains pending. |
| 2026-08-11 | iOS 26 fullscreen and geolocation behavior [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | The native fullscreen-container mitigation is source-validated and the fresh iPhone 17 Pro iOS 26.2 Simulator diagnostic passes three seek, native-container entry, runtime opt-out dismissal, and re-entry cycles with correct fullscreen state. Physical iOS 26/GPU/media validation remains pending. #2831 is classified as an Apple/WebKit boundary: the public geolocation decision delegate is iOS 27+, the iOS 27 deny-path diagnostic passes, and the iPhone 17 Pro iOS 26.2 run does not invoke the Dart callback. No upstream state was changed. |
| 2026-08-10 | iOS keyboard `visualViewport` restoration [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860) addresses the separate #2859 inset regression | iOS 2.1.20 captures the pre-keyboard `UIScrollView` zoom scale/content offset, restores them after `keyboardDidHide`, and refreshes the final platform-view frame/layout. A fresh default-DDS iPhone 17 Pro iOS 26.2 Simulator run passes with `visualViewport.height 778.0 -> 435.4375 -> 778.0`, scale `1.0 -> 0.93925 -> 1.0`, active HTML input, and zero page offset after dismissal. Earlier clean DDS runs were inconclusive because of WebKit metrics, software-keyboard, and CoreSimulatorService conditions. Physical iOS 17/device, custom page-zoom, and native `WKWebView` comparison validation remain pending. |
| 2026-08-08 | iOS draggable overlay gesture ownership [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598) | No upstream relationship inferred | Source review confirms that the overlay belongs to Flutter's host gesture arena: Forge forwards `gestureRecognizers` to `UiKitView`, and its opt-in `preventGestureDelay` hook only runs when the WebView itself is hit-tested. The reported iOS 18/18.6 overlay-drag/underlying-scroll behavior is therefore tracked as a host/platform boundary with no package code change; a minimal Flutter 3.38.6+ comparison remains the required follow-up. |
| 2026-08-08 | iOS Password AutoFill ownership [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570) | No upstream relationship inferred | Source review found the standard `WKWebViewConfiguration` path and no Forge-owned Password AutoFill switch. Apple requires host-app associated domains and semantically marked HTML fields; the plugin cannot modify consuming-app entitlements, the site's AASA response, or third-party login markup. The report remains a host/application/site boundary pending the same-domain physical-device and native `WKWebView` comparison. |
| 2026-08-08 | iOS navigation decision/load ordering [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | No upstream relationship inferred | iOS now queues `loadUrl` requests issued while `shouldOverrideUrlLoading` is waiting for the WebKit policy decision and flushes them after `.allow`/`.cancel` is delivered. The source regression, Flutter analysis, SwiftPM manifest check, and Xcode example build pass; physical navigation/header validation remains pending. |
| 2026-08-08 | iOS Simulator dyld failure [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636) | No upstream relationship inferred | The native stack and upstream reproduction identify an iOS 18.4/18.5 Simulator/WebKit deployment-target failure while physical devices and newer Simulator runtimes work. Forge supports iOS 15.0 and cannot safely raise that baseline, so this is recorded as a host/platform boundary with no package code change. |
| 2026-08-08 | Android HTML time input picker crash [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659) | No upstream relationship inferred | The supplied NPE ends in Android's `TimePickerSpinnerDelegate.updateInputState`; source review found no Forge-owned time picker or interception boundary. The record remains visible for OEM/framework tracking and is not presented as locally fixed. |
| 2026-08-08 | iOS modal-sheet gesture lifecycle [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727) | No upstream relationship inferred | Upstream reports identify a Flutter iOS platform-view gesture regression and multiple users report that Flutter 3.41/3.41.3 resolves it. Forge retains the 3.38.6 compatibility baseline and has no safe WebKit-layer control point, so the record is tracked as a host/platform boundary without a package code change. |
| 2026-08-08 | iOS Drawer/WebView touch lifecycle [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713) | No upstream relationship inferred | The report aligns with Flutter's iOS platform-view hit-testing and gesture lifecycle issue chain ([#175099](https://github.com/flutter/flutter/issues/175099), [#158961](https://github.com/flutter/flutter/issues/158961)); reported workarounds operate at the Flutter overlay or engine level. Forge's iOS WebKit layer has no safe control point for resetting that state, so the record is tracked as a host/platform boundary without a package code change. |
| 2026-08-08 | iOS ListView/NestedScrollView gesture lifecycle [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723) | No upstream relationship inferred | The reproducer uses Flutter 3.35.5 and the reported failure is a platform-view tap loss after parent scrolling. The linked [workaround](https://khal.it/blog/flutter-webview-tap-gestures-break-nestedscrollview-ios-fix) identifies a Flutter framework fix in 3.38.6+, which is Forge's compatibility baseline; the iOS widget passes gesture recognizers through to `UiKitView` and has no safe native control point for repairing an older Flutter gesture arena. The record is tracked as a host/platform boundary without a package code change. |
| 2026-08-08 | iOS/Android localhost server liveness [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720) | No upstream relationship inferred | The shared default server now clears a stale `HttpServer` reference on request-stream completion or error, preserving current-server identity during close/replacement races. Platform-interface source, normal-close, controlled-restart, and independent-server lifecycle tests pass; iOS/Android release-mode background/resume/restart/reload validation remains pending in the runtime register. |
| 2026-08-08 | Android display-size WebView geometry [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721) | No upstream relationship inferred | Android now refreshes hybrid-composition WebView geometry after actual size changes and visibility return through an idempotent invalidation/relayout helper. The source regression, Android focused tests, and example APK/AAR build pass. The opt-in display-size diagnostic starts on API 35, but host `wm size` change/reset temporarily disconnects the AVD before the geometry assertion; the same reversible override on the 2026-08-11 and 2026-08-12 Samsung A16 runs restarts the example activity/VM service before geometry can be read. The Activity remains up and no app crash/ANR appears, but neither run produces a geometry result, so Android 16/API 36 and OEM provider runtime validation remains pending. |
| 2026-08-09 | Android activity-extra deserialization [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | No upstream relationship inferred | Android 1.0.33 uses a recursive primitive/nested-`Bundle` codec, corrects the Chrome Custom Tabs manager channel namespace, and keeps the Custom Tabs session bound until activity destruction. Android source tests (41), debug APK build, the API 35 `emulator-5554` diagnostic, and the 2026-08-11 Samsung A16 InAppBrowser/Chrome Custom Tabs open-load-close diagnostic pass. The A16 filtered log includes a Samsung `ActivityManager` IntentRedirect Hardening warning for the Custom Tabs intent but no app crash/ANR. Restore/rotation, malformed external extras, and physical/provider validation remain pending. |
| 2026-08-10 | iOS popup default handling [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | No upstream relationship inferred | iOS now removes the pending popup transport without loading the target into the caller WebView when `onCreateWindow` returns `false`, `null`, or is unhandled. Explicit same-window `controller.loadUrl` remains available from the callback; source regression coverage passes. A clean iPhone 17 Pro iOS 26.2 DDS diagnostic received `https://example.com/popup`, returned `false`, and kept the caller at `https://example.com/`; physical iOS 15-26 popup attachment, navigation, disposal, and scene-transition validation remains pending. |
| 2026-08-12 | Android Firebase Auth missing initial state [#2815](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2815) | No upstream relationship inferred | The supplied Android 12/Flutter 3.41.6 report combines app-specific auth-page JavaScript/reloads with a `__/firebase/init.json` 404; a follow-up reports Firebase Authorized Domains configuration resolved the symptom. Forge does not clear `sessionStorage` during navigation and no minimal plugin-owned storage failure is provided, so the record is classified as a host/Firebase configuration boundary without a package code change. |
| 2026-08-12 | Typed JavaScript bridge events and handlers [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793) | No upstream relationship inferred | Platform-interface 1.1.8 and root 2.1.57 add `JavaScriptBridgeEvents` on top of the existing runtime bridge and handler contract, with Dart/JavaScript event listeners and typed JSON/serialized codecs. Platform-interface tests pass 7/7 and changed-file analysis is clean. The opt-in Android physical-device diagnostic passed on 2026-08-12 with JavaScript-to-Dart events, Dart-to-JavaScript dispatch, and an asynchronous typed handler response; the app was updated in place with `--no-uninstall`. iOS, Web, Windows, macOS, Linux, and broader Android provider/runtime validation remain pending. |
| 2026-08-12 | Android 16/OEM text-selection resource crash [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868) | No upstream relationship inferred | The Android 16 trace reaches Chromium WebView `onCreateActionMode`, then throws `Resources.NotFoundException` for resource `0x30c0008` through the JNI exception path. Android 1.0.49 keeps the exact resource guard and adds a `RuntimeException` fallback around native action-mode creation, logging and skipping the provider-owned action mode instead of terminating the app. Android package tests pass; exact Android 16/provider validation remains pending. |
| 2026-08-08 | Linux no-GL buffer path [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | No upstream relationship inferred | `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` now enables `LIBGL_ALWAYS_SOFTWARE` before WPE starts and skips EGL import so SHM/pixel import supplies CPU-readable frames. Static source coverage was added; Fedora/X11/Intel runtime validation remains pending. |
| 2026-08-08 | JavaScript evaluation source review [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | No upstream relationship inferred | The only dynamic evaluation sites are explicit `evaluateJavascript` wrappers receiving the caller-provided source. Android and Web static tests pin those boundaries; no plugin-owned remote-data sink was found, so no speculative replacement was made. |
| 2026-08-10 | iOS geolocation availability correction [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | The installed WebKit SDK declares `WKUIDelegate.webView(_:requestGeolocationPermissionFor:initiatedByFrame:decisionHandler:)` at iOS 27.0, not iOS 26.0. The bridge is compiled and advertised for iOS 27+, where a fresh HTTPS deny-path diagnostic passes with `callbackOrigin=https://example.com` and `error:1`; the iPhone 17 Pro iOS 26.2 run leaves `callbackOrigin=null`. The record moves from runtime-pending to the host/platform boundary because iOS 26 exposes no public Forge-owned decision hook; private WebKit APIs are out of scope. |
| 2026-08-08 | macOS fractional platform-view frame sync [#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826) | No upstream relationship inferred | macOS no longer relies on AppKit autoresizing masks for the native WebView child. Bounds synchronization is guarded for finite frames and runs during layout and resize callbacks. The new source regression assertion fails against the original implementation and passes after the fix; the Xcode 27 example build passes with a temporary 12.0 deployment-target override, while Retina/fractional-width runtime validation remains pending. |

| 2026-08-09 | Android nullable and malformed callback payloads [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856); Web iframe URL tracking [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | No upstream relationship inferred | Android request-result and event decoding now validates optional strings before constructing `WebUri`, public fields, or callback arguments. Web same-origin/current-location and cross-origin-null behavior is protected by source assertions. Android focused tests pass with the system Flutter 3.44.8; Web test loading is blocked by the toolchain mismatch, and device/browser validation remains pending. |
| 2026-08-08 | Android provider-specific setting casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594); macOS browser-window teardown [#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707) | No upstream relationship inferred | Android `forceDarkStrategy` setter/getter provider casts fail open and focused tests pass. macOS popup registry removal is unconditional and protected by a static assertion. macOS test loading is blocked by the Flutter toolchain mismatch; provider/device and macOS runtime validation remain pending. |
| 2026-08-08 | Android renderer callback boundary [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); iOS location prompt lifecycle [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | Android renderer callbacks now reject unrelated WebView instances and static regression tests pass. iOS 27 now bridges the public geolocation decision handler through Dart; iOS 26 does not expose that callback and is tracked as an Apple/WebKit boundary. |
| 2026-08-10 | Android InAppBrowser activity-result ownership [#2797](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2797) | No upstream relationship inferred | The Android ChromeClient no longer consumes unclaimed or unrelated activity results, and the InAppBrowser listener loop remains snapshot-based. Focused source tests pass; API 35/36 and OEM permission/file-picker runtime validation remains pending. |
| 2026-08-10 | Android internal-storage path-handler recursion [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709) | No upstream relationship inferred | `AndroidInternalStoragePathHandler.toMap()` now calls `super.toMap()` once. The focused Dart test serializes the base fields and directory successfully; no native runtime gate is required. |
| 2026-08-10 | iOS missing-plugin `goBack` report [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711) | No upstream relationship inferred | iOS `goBack()` now catches only `MissingPluginException` when the native WebView channel has already been removed during scene/platform-view teardown. The regression test fails against the original implementation and passes after the fix; iOS package tests (2/2), SwiftPM manifest validation, and the Simulator build pass. Physical/device scene reattachment and stale-controller validation remain pending. |
| 2026-08-12 | Windows child-window teardown [#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814) | No upstream relationship inferred | Windows `InAppWebView::~InAppWebView()` now disposes `FindInteractionController` before WebView2 `Stop()`/`Close()`, preventing event-handler removal from an already closed controller. The Windows static source regression passes; Windows 11/WebView2 multi-window runtime validation remains pending. |
| 2026-08-12 | Windows Visual Studio 2026/MSVC 14.5x build compatibility [#2839](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2839) | [#2869](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2869) | Windows 1.0.9 updates WIL to 1.0.260126.7 and scopes `/FS` plus `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` to the plugin CMake target. WebView2 was already at 1.0.4078.44. The source regression passes; Visual Studio 2026/MSVC 14.5x clean/incremental build and runtime validation remain pending. |
| 2026-08-12 | Windows WebView2 resize/teardown access violation [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752) | No upstream relationship inferred | Windows 1.0.10 marks the WebView as disposed before teardown, serializes `put_Bounds`, `put_RasterizationScale`, visibility, position, and `Close()` through a controller mutex, and ignores late callbacks. The Windows static regression passes; a Windows/WebView2 native build and the reported transparent-background resize/teardown runtime matrix remain pending. |
| 2026-08-08 | Windows resize teardown [#2736](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2736) | No upstream relationship inferred | The late-resize controller guard is source-validated; Windows test loading is blocked by the Flutter toolchain mismatch and native runtime validation remains pending. |
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
| 2026-08-10 | iOS/Android disposal crash [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | No upstream relationship inferred | iOS `InAppWebView.dispose()` and Android native WebView disposal are now idempotent; Android fullscreen cleanup still runs before destroy. Source tests and native builds pass. Clean iPhone 17 Pro iOS 27 Simulator, fresh API 35 Android `flutter drive`, and the 2026-08-11 Samsung A16 diagnostic complete four disposal/recreate cycles; Android emits renderer exit code `-1` during explicit teardown but exits with no app `AndroidRuntime`, fatal, ANR, or Dart failure. This matches the external #2491 renderer signature, but its exact back-button/OEM path remains pending; physical iOS/Android teardown and renderer validation remain required. |
| 2026-08-10 | Android 10 IME lifecycle crash [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | No upstream relationship inferred | Detached-view checks and `RuntimeException` fallbacks now cover delayed focus, `restartInput`, `isActive`, and soft-input operations. Android source tests and compilation pass. The API 35 AVD and 2026-08-11 Samsung A16 diagnostics pass for virtual-display and hybrid composition, reopening a Flutter keyboard with `keyboardInsetAfterDispose=24.0` and `358.4` respectively after WebView clear/dispose; no AndroidRuntime/fatal/IME NPE appears. Android 10 physical-device and OEM validation remains pending. |
| 2026-08-08 | Android System WebView renderer termination [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698) | No upstream relationship inferred | The upstream body identifies a provider-version-specific Chromium crash and reports recovery after rolling back Android System WebView. No Forge-owned stack or control point is present, so the issue moves from runtime-pending to host/provider tracking without a speculative plugin patch. |
| 2026-08-09 | Android screen-transition flicker [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688) | No upstream relationship inferred | GitHub CLI review still finds only an Android 35 symptom report with no minimal code, native stack, or composition-mode comparison. Source review finds no Forge route-animation or surface-ordering control point. The opt-in diagnostic passes on `emulator-5554` (API 35) with hybrid composition (`destinationPresent=true`, `webViewPresent=false`, 45 frame timings), virtual-display composition (`loadStopObserved=true`, `destinationPresent=true`, `webViewPresent=false`, 45 frame timings), and the example's direct native `android.webkit.WebView` baseline (`destinationPresent=true`, `webViewPresent=false`, 45 frame timings). The virtual run logs a roughly 2.97-second startup `Davey`/GC stall before the WebView is hosted, but no mode reproduces the reported transition failure. External ADB screenshots show a clean blue WebView-to-orange Flutter transition without a blank, black, or returning WebView frame. The record is reclassified as an Android/Flutter engine/platform-view boundary; no behavior workaround was added and the upstream state is unchanged. |
| 2026-08-10 | Android fullscreen renderer/surface cleanup [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) | No upstream relationship inferred | Android 1.0.35 runs the idempotent fullscreen exit/state reset before forwarding `onRenderProcessGone`, in addition to the existing `FlutterWebView.dispose()` fallback when `onHideCustomView()` is unavailable. The Android package suite passes all 49 tests, including the renderer-loss regression. The normal fullscreen/exit path also passes on the 2026-08-11 MediaTek Samsung A16. On 2026-08-12, the opt-in direct Vimeo iframe diagnostic enters hybrid fullscreen; after Wi-Fi is disabled, a black/loading surface is observed, but `onExitFullscreen` is delivered, `onRenderProcessGone` is not delivered, `fullscreenState=false`, and the test exits without an app crash or ANR. GitHub CLI review still identifies the exact upstream shape as Vimeo content from `https://iframely.com/domains/vimeo` with network loss and a banner/popup overlay; that forced gralloc/renderer-loss path was not reproduced, so physical validation remains required. |
| 2026-08-09 | Android mobile-data audio provider boundary [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680) | No upstream relationship inferred | GitHub CLI review found `ERR_FAILED` only on mobile data for a `206 Partial Content` Cloudflare MP3 response; the follow-up says `webview_flutter` succeeds and the upstream record was stale-closed. Forge's default request path passes through to Android WebView unless the app supplies an interception response, so the issue moves to host/provider tracking without a speculative plugin change. |
| 2026-08-09 | iOS iframe subresource error callback boundary [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753) | No upstream relationship inferred | iOS forwards WebKit navigation failures through `onReceivedError`, but `WKNavigationDelegate` does not expose arbitrary HTTPS iframe subresource failures. The report remains an Apple/WebKit capability boundary; a partial JavaScript error listener would not preserve the public callback contract. |
| 2026-08-09 | Android Pigeon build attribution [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796) | No upstream relationship inferred | GitHub CLI review shows the compiler errors are inside `webview_flutter_android` 4.10.13. The Forge package graph and source tree contain no `webview_flutter_android` dependency or generated Pigeon classes; the only `webview_flutter` reference is an optional example test script. The record moves to dependency attribution tracking without a Forge code change. |
| 2026-08-10 | Android deprecation-warning compatibility boundary [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685) | [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817) | Android 1.0.40 keeps API 19/20 cookie, WebView, print, fullscreen, and provider compatibility paths intact while isolating their deprecation diagnostics at the native file boundary. The Android package suite passes 47/47; `compileDebugKotlin` and the debug APK build pass without package-owned Java/Android deprecation warnings. Direct release compilation is blocked by the generated dev-only `integration_test` registrant, and the normal Flutter release path uses a stale configured Android Studio JDK in this environment; clean release/provider/AAB/publish validation remains in the runtime register. |
| 2026-08-09 | Android release JAR gate review [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687) | No upstream relationship inferred | The example Gradle build directory now resolves from `projectDirectory` to the Flutter-expected `example/build` path. After a normal release tooling regeneration (without `--no-pub`), JDK 21 `flutter build apk --release --no-pub` produces the release APK; `:flutter_inappwebview_forge_android:syncReleaseLibJars` succeeds; and API 35 AVD install/launch keeps `MainActivity` resumed with no fatal crash in the smoke log. Clean JDK 17/provider/AAB/publish validation remains in the runtime register. |
| 2026-08-09 | Pub.dev Pana analysis compatibility [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757) | [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758) | Forge analysis options now use boolean `false` for disabled linter rules across the federated packages. Pana 0.23.3 reproduces the original `String`/`bool` crash with the old `ignore` values and passes the corrected form in an isolated package. Full Pana/publish validation against the published Forge package graph remains pending. |

| Local release | Issue/report scope | Related PR records | Local result |
| --- | --- | --- | --- |
| 2.1.48 / Android 1.0.43 | Android cookie mutation ANR [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | No upstream relationship inferred | API 21+ cookie mutations no longer force synchronous `CookieManager.flush()` on the WebView UI thread after asynchronous updates, and the explicit `flush` MethodChannel result now completes. The Android package suite passes 48/48 and the native debug build path compiles the fix. The A16 diagnostic passes 10/10 cycles with an empty final cookie list and no app crash/ANR; Android 10/provider and Play Console validation remain required. |
| 2.1.40 / Android 1.0.37 | Android nullable and malformed permission callback payloads [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856) | [#2857](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2857) | Android permission request/cancellation payloads now validate the map, origin, and resources container before decoding, filter unknown resource entries, and preserve native default behavior for malformed payloads. The focused regression and Android package tests pass; API/provider validation remains required. |
| 2.1.39 / iOS 2.1.22 | iOS popup `EXC_BAD_ACCESS` and async callback ownership [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776) | Popup JavaScript remains in the initialized page world, and pending native/legacy async callbacks now complete with `WebView navigation started` before a new provisional navigation. Source tests and the iPhone 17 Pro iOS 26.2 three-cycle diagnostic pass; physical iOS 15–26/Xcode 16/26 validation remains required. |
| 2.1.38 / iOS 2.1.21 / Android 1.0.36 | iOS/Android WebView disposal and pending async JavaScript callbacks [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | No direct PR relationship was present in the export | Native iOS 14+ and legacy callbacks plus Android callbacks now complete with `WebView disposed` before teardown, and late callbacks are ignored. The iPhone 17 Pro iOS 26.2 Simulator and API 35 AVD hybrid/virtual-display diagnostics pass; physical iOS/Android provider validation remains required. |
| 2.1.37 / iOS 2.1.20 | iOS keyboard `visualViewport` restoration [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860) addresses the separate #2859 inset regression | Root 2.1.37 depends on iOS 2.1.20. The pre-keyboard zoom/offset and final frame/layout are restored after HTML input dismissal; source coverage and the iPhone 17 Pro iOS 26.2 Simulator diagnostic pass. Physical iOS 17/device and custom page-zoom validation remain required. |
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
