# iOS and Android Performance & WebView Upgrade Plan

Last reviewed: 2026-08-21
Status: Phase 1 source slice complete; first Android and iOS Phase 2/3 fixes landed, with profiling and device validation pending
Scope: iOS and Android first

Current state in this workspace:

- AndroidX Browser is `1.10.0`; AndroidX WebKit is **`1.16.0`** with
  declared **`minSdk 24`** (Track C). Hosts that need API 19–23 must stay on
  2.1.76 / Android 1.0.55 + WebKit 1.15.0.
- Stable `WebViewOutcomeReceiver` startup, NavigationListener (feature-gated),
  `saveStateWithOptions`, live BFCache settings, Profile preconnect, and
  opt-in `WebViewBuilder.applyTo` are implemented on the Android package.
- Android asynchronous provider startup is coordinated by `WebViewStartupCoordinator`, with a safe fallback for older or overridden WebKit providers.
- Android synchronous platform callbacks use a shared main-looper dispatcher, bounded in-flight capacity, and method-specific timeouts; they never block the main looper indefinitely.
- Android bridge/document-start registration and the first renderer load are ordered after platform-view attach; activity-free headless WebViews retain a direct path.
- Cold document-start registration failures are logged and degraded to the existing in-memory script path instead of crashing the app.
- Android progress callbacks no longer re-inject document-start scripts; duplicate progress and unchanged scroll positions are not sent across the platform channel, and scroll updates are coalesced to one pending frame dispatch.
- Android native-registration retries clear their scheduled state and stop pending callbacks when a WebView is disposed.
- iOS keyboard-dismissal inset restoration, scroll callback coalescing, progress de-duplication, and content-size callback coalescing are implemented as the first lifecycle/performance slice; device profiling and edge-case validation remain open.
- iOS pre-iOS 18 asynchronous JavaScript routing, native iOS 14+ callback tracking, and nil-frame guards are implemented; fallback latency, disposal, and popup stress validation remain open.
- iOS pending asynchronous JavaScript callbacks now complete with a disposal error during teardown, and Android pending callbacks use the same bounded cleanup contract.
- iOS UIScene and Swift Package Manager migration is tracked in [`ios-uiscene-spm-migration-plan.md`](ios-uiscene-spm-migration-plan.md); the implementation slice is complete and device validation remains.
- The opt-in `InAppWebViewPreloader` helper now exposes a single-flight
  headless prewarm and headless-to-inline KeepAlive handoff. It reuses the
  existing native lifecycle path; cold-start, first-frame, memory, and page
  readiness measurements remain runtime validation work.
- AndroidX WebKit is now `1.16.0` on the main branch with declared
  `minSdk 24` (Track C). NavigationListener, `navigate()` with
  NavigationParameters, prerender, BFCache depth settings, Profile
  preconnect/headers/prefetch, and opt-in WebViewBuilder are feature-checked.

The source-level slice is complete for this checkpoint. The next release decision must be based on release/profile measurements, not on dependency version numbers alone.

## Executive decision

The first release should focus on native startup, platform-channel pressure, input/layout lifecycle, and WebView observability. Dependency upgrades are part of the plan, but the Android WebView support-library upgrade must not silently remove older Android users.

Recommended first implementation sequence:

1. Establish a release/profile performance baseline and collect the device WebView version.
2. Keep the landed `androidx.browser` `1.10.0` upgrade isolated and revalidate it against the Android regression matrix.
3. Keep declared `minSdk 19` while `androidx.webkit` is `1.15.0`; feature-check 1.15 APIs rather than raising the floor.
4. Implement the Android startup and blocking-callback changes suggested by [PR #2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) and issues [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843)/[#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849).
5. Implement the iOS `contentInset`, focus, JavaScript-evaluation, and disposal/lifecycle fixes.
6. Evaluate `androidx.webkit:1.15.0` and `1.16.0` on explicit minSdk branches rather than changing the main compatibility contract implicitly.

This document is an implementation plan, not an approval to cherry-pick open upstream PRs wholesale.

## Near-term execution plan

The next milestone is deliberately split into four bounded work packages. Each package must have a before/after profile result and a focused regression test before it is included in a release candidate.

| Package | Platform | Priority | Scope | Release gate |
| --- | --- | --- | --- | --- |
| A-P1 | Android | P0 | Measure provider startup, platform-view attach, bridge readiness, document-start registration, and first usable frame. Then make readiness/retry state explicit and idempotent. | 100/100 cold starts on the selected API/device matrix; no duplicate registration and no callback loss. |
| A-P2 | Android | P0/P1 | Audit the bounded request-interception waits, measure scroll/progress/console channel pressure, and benchmark hybrid versus surface composition. | No UI/WebView freeze under slow Dart; event coalescing reduces channel load without changing terminal events or final scroll position. |
| I-P1 | iOS | P0 | Profile keyboard, content-inset, scroll KVO, scene transitions, and fullscreen/IME handoff on iOS 15 through the latest supported release. | No stale inset or scroll backlog; p95 frame time and final-position behavior do not regress. |
| I-P2 | iOS | P0/P1 | Profile `callAsyncJavaScript`/Promise fallback, `windowId`, popup teardown, message-handler cleanup, and repeated create/dispose cycles. | No lost completion callback, bounded pending handlers, and no native crash across 100 repeated lifecycle cycles. |

Implementation order:

1. Capture the shared baseline and record OS, device, WebView/WebKit, Flutter, Xcode, and plugin versions.
2. Land Android A-P1 and A-P2 independently so startup and channel changes can be rolled back separately.
3. Land iOS I-P1 and I-P2 independently so layout and JavaScript fallback behavior remain attributable.
4. Re-run the dependency matrix and decide whether an AndroidX WebKit branch is justified. Do not combine a minSdk increase with runtime behavior changes.

## Evidence and inputs

- `issues.csv`: 125 open issue records were screened and the promoted findings are documented in [`known-issues.md`](known-issues.md).
- `pr.csv`: 73 open PR records; 40 carry the Android label and 51 carry the iOS label. Labels overlap.
- High-signal PRs for this plan include [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844), [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860), [#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853), [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776), [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), [#2794](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2794), [#2614](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2614), and [#2558](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2558).

The most relevant local paths are:

- Android startup: `flutter_inappwebview_forge_android/android/src/main/kotlin/com/emirkanacar/flutter_inappwebview_forge_android/WebViewStartupCoordinator.kt` and `.../webview/in_app_webview/InAppWebView.kt`
- Android document-start scripts: `.../types/UserContentController.kt`
- Android channel callbacks: `.../webview/WebViewChannelDelegate.kt` and `.../webview/in_app_webview/InAppWebViewClient.kt`
- Android dependency and SDK contract: `flutter_inappwebview_forge_android/android/build.gradle.kts`
- iOS layout, keyboard, scroll, JavaScript, and disposal lifecycle: `flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/InAppWebView/InAppWebView.swift`
- iOS dependency/deployment contract: `flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios.podspec`

## WebView version strategy

There are three different version surfaces. They must be tracked separately.

| Surface | Current repository state | Upgrade model | Plan |
| --- | --- | --- | --- |
| AndroidX WebKit | `androidx.webkit:webkit:1.15.0` | Bundled compatibility library; 1.16 remains a candidate upgrade line | Feature-check 1.15 APIs on the minSdk 19 branch; do not move to 1.16 until the minSdk 24 decision is explicit. |
| AndroidX Browser | `androidx.browser:browser:1.10.0` | Bundled AndroidX library | Completed in Phase 1; run the Android regression matrix before release. |
| Android System WebView | Device-provided | Updated independently on user devices | Record `WebViewCompat.getCurrentWebViewPackage()` where available; do not treat AndroidX upgrades as engine upgrades. |
| iOS `WKWebView` | System WebKit; minimum deployment target is iOS 15 | Delivered with the iOS runtime and SDK | Do not look for a package version bump; test OS/Xcode/WebKit behavior across supported iOS 15+ versions. |

The AndroidX WebKit candidate lines must be checked against the official release notes at implementation time because their API floor and available startup/navigation APIs determine whether a branch can retain the current minSdk contract: [AndroidX WebKit release notes](https://developer.android.com/jetpack/androidx/releases/webkit). Browser dependency changes should remain isolated from WebKit changes: [AndroidX Browser release notes](https://developer.android.com/jetpack/androidx/releases/browser).

AndroidX WebKit is a compatibility layer over the separately updated WebView APK. The application controls the AndroidX library version, but not the WebView APK version installed on each device: [Jetpack WebKit overview](https://developer.android.com/develop/ui/views/layout/webapps/jetpack-webkit-overview). The Android WebView package can be read for telemetry using the platform/compatibility API: [WebView API reference](https://developer.android.com/reference/android/webkit/WebView#getCurrentWebViewPackage()).

The current `minSdkVersion 19` declaration therefore needs an effective-minimum audit. No minSdk increase should be made until the supported-user distribution, resolved dependency graph, built AAR/manifest behavior, and installability on the retained API matrix are verified.

### Version tracks

#### Track A — compatibility-preserving first release

- Upgrade `androidx.browser` to `1.10.0`.
- Upgrade `androidx.webkit` to `1.15.0` without raising declared minSdk.
- Keep `androidx.webkit` 1.16.0 off the main branch until a minSdk 24 decision.
- Use `WebViewFeature.isFeatureSupported` for every optional WebKit capability.
- Add runtime WebView package telemetry.
- Land plugin-level startup and lifecycle fixes without depending on WebKit 1.16.

#### Track B — API 23 branch

- Raise the effective Android minimum to API 23 only after adoption data and migration notes are approved.
- Upgrade to `androidx.webkit:1.15.0`.
- Use the performance/navigation APIs that are available in this line where feature checks permit.
- Keep API 19–22 coverage in the compatibility branch or clearly document the support change.

#### Track C — API 24 performance branch

- Raise the effective Android minimum to API 24.
- Upgrade to `androidx.webkit:1.16.0`.
- Evaluate stable async startup through `ProcessGlobalConfig`/`WebViewStartUpConfig`.
- Evaluate stable navigation listeners and native FCP/LCP/performance-mark metrics.
- Do not target `1.17.0-alpha*` for a production release.

## Baseline and test matrix

All performance decisions require release/profile measurements. Debug-only measurements are not release gates.

### Metrics

- Cold process start → native WebView construction.
- Native construction → platform-view-created callback.
- Platform-view-created → bridge ready.
- Bridge ready → first contentful paint and first `onLoadStop`.
- Scroll frame time, p50/p95 frame duration, and dropped frames.
- Method-channel calls per second and payload bytes for scroll, progress, console, and bridge events.
- JavaScript evaluation latency and completion/error rate.
- Memory after 1, 5, and 10 WebViews; renderer/process memory where available.
- `dispose()` duration and create/dispose retention after repeated cycles.
- ANR, renderer termination, native crash, and Dart callback-loss rate.
- WebView package version, OS version, device model, composition mode, and plugin/Flutter version.

### Android matrix

- API 19, 21, 23, 24, 29, 35, and 36 where the selected dependency track supports them.
- At least one low-memory device, one Pixel-class device, and one Samsung/OEM device.
- Stable WebView APK plus one older supported WebView APK where feasible.
- Hybrid composition and surface composition.
- Inline WebView, HeadlessInAppWebView, KeepAlive reuse, bridge enabled/disabled, and 5–9 document-start scripts.
- Scroll-heavy page, keyboard input, fullscreen video, popup/window creation, cookie cleanup, and repeated disposal.

### iOS matrix

- iOS 15.x, 16.x, 17.x, 18.x, and the latest supported iOS version available to CI/devices.
- A low-memory device and a recent high-performance device; simulator coverage is not a substitute for device coverage.
- Current and previous supported Xcode/Flutter toolchains.
- Keyboard show/hide, scroll-to-bottom, fullscreen video, `window.open`, KeepAlive reuse, `callAsyncJavaScript`, `evaluateJavaScript` with `windowId`, focus, and repeated disposal.

### Measurement implementation

- Dart: add opt-in `Timeline` spans around platform-view creation, platform-view readiness, first load callbacks, JavaScript completion, and disposal. Do not add a continuously enabled public telemetry stream for the first milestone.
- Android: use `android.os.Trace` spans and Perfetto/Android Studio profiling for provider startup, platform-view attach, bridge registration, request interception, event dispatch, and composition. Include `WebViewCompat.getCurrentWebViewPackage()` in captured samples.
- iOS: use `os_signpost` and Instruments Points of Interest/Time Profiler for WebView creation, navigation, KVO scheduling, keyboard transitions, JavaScript fallback, popup teardown, and disposal.
- Every sample must include package version, Flutter/Dart version, OS, device model, Android API or iOS version, Android System WebView package when available, Xcode/SDK for Apple builds, composition mode, page fixture, and run number.
- Store baseline and candidate results as review artifacts; a single median is insufficient. Report p50, p95, worst case, dropped frames, allocations/memory, and error or timeout counts.
- Keep instrumentation removable or disabled by default so measurement code does not become a permanent channel or frame-time cost.

## Android work packages

### A1 — Startup and bridge readiness (P0)

Problem at the review baseline: `InAppWebView.prepare()` registered the native JavaScript bridge and document-start scripts synchronously. `UserContentController` called `WebViewCompat.addDocumentStartJavaScript` directly. This matches the failure pattern in [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) and [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849).

Phase 1 status: platform-view registrations and the first load are now ordered through `View.post()`. Activity-free headless WebViews use the direct path so they do not wait for an attach that will never happen, and document-start registration exceptions degrade to a logged fallback. Registration retry scheduling and disposal guards are now explicit; AndroidX async-startup comparison remains for the next validation track.

The current source slice also removes progress-driven duplicate script injection, coalesces Android scroll dispatches, suppresses duplicate progress/scroll payloads, and makes registration retry/disposal state idempotent. These changes require release-device profiling before further callback-policy changes.

Plan:

- Separate WebView construction from bridge/script registration and initial navigation.
- Add an explicit native readiness state and a queue for registrations that arrive before readiness.
- Ensure bridge/script registration is idempotent and can be retried after readiness.
- Guarantee that the Dart platform-view-created callback is delivered exactly once or returns a structured error.
- Test inline and headless cold starts with bridge enabled and disabled.
- On Track C, compare this path with AndroidX 1.16 async startup rather than assuming the dependency alone fixes the race.

Exit criteria:

- 100/100 cold starts deliver the expected creation callback on the selected release-device matrix.
- No document-start registration is attempted before the native readiness contract allows it.
- No duplicate bridge or user-script registrations after retries/rebuilds.

### A2 — Remove blocking request interception (P0)

Problem at the review baseline: `shouldInterceptRequest` reached `Util.invokeMethodAndWaitResult`, which waited synchronously for Dart. This aligns with the freeze/deadlock report in [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580).

Phase 1 status: the main looper no longer waits synchronously. Background resource callbacks use a shared main-looper dispatcher, bounded in-flight capacity, and method-specific timeouts (250 ms for WebView request interception and 500 ms by default) with a safe null fallback. Timeout telemetry and a fully asynchronous interception contract remain open work.

Plan:

- Map the full request-interception call graph and identify which callbacks truly require a synchronous response.
- Remove unbounded latch waits from the WebView callback path.
- Use a bounded response strategy with a safe default, or make Dart interception opt-in when the WebView API cannot be made asynchronous without changing behavior.
- Reuse one main-looper dispatcher and cap all synchronous channel-backed resource callbacks so service-worker and custom asset paths cannot create an unbounded native wait set.
- Record timeout/fallback counters so applications can detect degraded interception.
- Add slow-Dart, nested-navigation, redirect, and concurrent-resource tests.

Exit criteria:

- No unbounded wait remains on a WebView callback thread.
- A slow or unavailable Dart handler cannot freeze the UI or WebView request pipeline.
- Existing interception behavior remains covered by compatibility tests.

### A3 — Event-channel pressure (P1)

Problem: scroll, progress, and console callbacks allocate payload maps and cross the platform channel at high frequency.

Phase 1 status: iOS scroll-change callbacks are coalesced once per main-loop turn while preserving the latest offset and user-scroll signal; progress and content-size updates are also de-duplicated/coalesced. Android now drops duplicate progress and unchanged scroll payloads and coalesces scroll updates to the next animation frame; event-rate and terminal-event validation remain open.

Plan:

- Measure event rates before changing semantics.
- Coalesce scroll events to the latest position while preserving the final position in each frame/window.
- Throttle progress updates without suppressing the terminal 100% state.
- Add bounded console-message handling for high-volume pages; preserve error-level messages.
- Evaluate the additive `bridgeEvents` design from [PR #2794](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2794) only after Android and iOS runtime validation.

Exit criteria:

- At least 30% fewer channel calls in the scroll benchmark without a visible position regression.
- No lost terminal progress event.
- Console/bridge payload size and allocation behavior are documented.

### A4 — Composition, IME, fullscreen, and disposal (P1)

- Benchmark hybrid versus surface composition; do not change the default without correctness and frame-time evidence.
- Test fullscreen exit → keyboard use in another Flutter text field.
- Test renderer loss and surface loss during fullscreen video.
- Serialize cookie deletion/flush operations and measure their main-thread cost.
- Exercise create → attach → detach → KeepAlive → reattach → dispose cycles.
- Use [PR #2614](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2614) and [PR #2558](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2558) as lifecycle references, not unreviewed patches.

### A5 — Android release compatibility (P1)

- Add Android 15/16 deprecation checks, including the navigation/status-bar path from [PR #2729](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2729).
- Add AAB checks for 16 KB page-size compatibility.
- Upgrade AndroidX Browser separately from WebKit so failures can be isolated.
- Audit nullable/unknown native values and FileProvider changes from [PR #2874](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2874) before release.

## iOS work packages

### I1 — Keyboard/contentInset and scroll scheduling (P0)

Problem: the current `frame` setter and keyboard callbacks apply negative content-inset compensation, while scroll and content-size KVO changes can enqueue main-queue work during layout. This matches [issue #2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859) and [PR #2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860).

Current status: the initial inset restoration, scroll coalescing, progress de-duplication, and content-size coalescing slice is implemented. Device validation for keyboard animation, rotation, safe-area changes, and nested Flutter scrolling remains open.

Plan:

- Make content-inset adjustment idempotent and separate the base inset from keyboard compensation.
- Restore the exact pre-keyboard inset on `keyboardWillHide`.
- Coalesce KVO scroll changes with a pending-update flag or display-link-style scheduler.
- Coalesce content-size KVO changes while preserving the first old size and latest current size in each main-loop turn.
- Do not replace KVO with `scrollViewDidScroll` without reproducing the existing white-space rendering issue documented in the source.
- Test rotations, safe-area changes, keyboard animation, nested Flutter scrolling, and scroll-to-bottom after keyboard dismissal.

Exit criteria:

- No stale negative inset after keyboard hide, rotation, or WebView frame changes.
- No unbounded main-queue scroll backlog.
- Scroll p95 frame time and final-position correctness do not regress.

### I2 — JavaScript evaluation compatibility (P0)

Use [PR #2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [PR #2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776), [PR #2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), and [PR #2574](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2574) as compatibility inputs.

Current status: the pre-iOS 18 routing, native iOS 14+ callback tracking, nil-frame safety, and cross-platform disposal completion fixes are implemented. Latency, Promise serialization, popup teardown, and device-side handler-cleanup measurements remain open.

- Keep native `callAsyncJavaScript` only where the OS/content-world combination is verified.
- Use a tested Promise/`evaluateJavaScript` fallback before iOS 18 where required.
- Make `windowId` and nil-frame paths return structured errors instead of crashing or dropping completion callbacks.
- Keep Swift `@MainActor`/main-thread requirements explicit and test current plus previous Xcode versions.
- Ensure fallback message handlers are removed after completion, timeout, error, and disposal—even when the public JavaScript bridge is disabled.
- Preserve or explicitly document custom content-world isolation; do not silently widen page-world execution.

Exit criteria:

- Promise resolution/rejection and JSON serialization are covered on iOS 15–18 test targets.
- No completion callback is lost during disposal or popup teardown.
- Pending fallback calls do not grow without bound.

### I3 — Focus, fullscreen, and window lifecycle (P1)

- Add document-focus tests for Flutter platform views based on [PR #2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853).
- Test fullscreen video start/seek/exit and WebKit process termination.
- Test `window.open`/`onCreateWindow` ownership, popup disposal, and `windowId` JavaScript evaluation.
- Test KeepAlive URL restoration and multiple WebView instances.
- Audit `dispose()` ordering so KVO observers, message handlers, delegates, and pending callbacks are released exactly once.
- Keep the iOS 15 deployment target and validate the scene-based lifecycle on every supported iOS release.

### I4 — iOS toolchain and system WebKit compatibility (P1)

- Treat iOS `WKWebView` as a system framework, not a separately versioned package: [Apple WKWebView documentation](https://developer.apple.com/documentation/webkit/wkwebview).
- Run Xcode 16/current Xcode builds and retain a previous supported Xcode build in CI where possible.
- Include the Xcode/SDK compatibility issue in [PR #2574](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2574) and the newer Xcode-related PRs as build-gate inputs.
- Keep `swift-collections` and Swift tools updates isolated from runtime WebKit changes.
- Record iOS version, device model, Xcode, Flutter, and plugin versions with every native crash/performance sample.

## PR triage policy

Open PRs are evidence and design input, not release-ready commits.

| Action | PRs | Rule |
| --- | --- | --- |
| Port the idea after local tests | #2844, #2860, #2853, #2776, #2574, #2614, #2558 | Re-implement against the current branch and add regression coverage. |
| Validate the local implementation | #2243, #2871, #2771, #2474 | These PR-only compatibility fixes are present locally; use device/provider tests to verify behavior and avoid re-porting them. |
| Benchmark before adoption | #2794, #2851, #2864, #2390 | Measure channel, payload, render, or first-frame effects before changing public behavior. |
| Do not cherry-pick wholesale | #2548 | The branch contains unrelated commits and unresolved follow-up reports. |
| Maintenance batch | #2879, #2870, #2817, #2729 | Land with build/deprecation verification, separate from runtime performance changes. |
| Defer from the iOS/Android first milestone | Linux, Windows, WPE, DMA-BUF, WebView2-only PRs | Keep in the backlog unless they affect shared platform-interface or CI contracts. |

## Delivery phases

### Phase 0 — Baseline and compatibility audit

- Build release/profile examples for the current dependency set.
- Add timing, event-count, memory, disposal, and native-crash instrumentation.
- Verify effective Android minSdk for WebKit 1.14 and test API 19/21/23/24 installation/build behavior.
- Capture Android System WebView package versions and the complete iOS/Xcode/Flutter matrix.

Status: next prerequisite for the performance release; source changes must not be judged without this baseline.

Deliverable: baseline report and a go/no-go decision for Tracks A, B, and C.

### Phase 1 — Safe dependency and observability update

- Upgrade AndroidX Browser to `1.10.0`.
- Keep AndroidX WebKit at `1.14.0` on the compatibility branch.
- Add WebView package telemetry and feature-availability logging.
- Add performance regression test scaffolding without changing public callback semantics.

Status: source-level dependency and observability slice is complete; baseline comparison and release-device validation remain.

Deliverable: isolated dependency commit plus baseline comparison.

### Phase 2 — Android startup and callback pipeline

- Implement A1 and A2.
- Add headless/inline cold-start tests.
- Add slow-Dart and request-interception fallback tests.
- Benchmark hybrid/surface composition and event coalescing.

Status: first source fixes landed; the full callback and composition work remains queued after the Phase 0 baseline.

Deliverable: Android P0 performance/stability patch with no minSdk change.

### Phase 3 — iOS layout and lifecycle pipeline

- Implement I1 and I2.
- Implement I3 lifecycle tests and fixes.
- Validate bridge-disabled, content-world, popup, keyboard, and fullscreen paths.

Status: first source fixes landed; the existing iOS fixes require device and stress validation before additional changes.

Deliverable: iOS P0/P1 patch with iOS 15–latest compatibility evidence.

### Phase 4 — Optional WebKit 1.15/1.16 branch

- Create a clearly labeled minSdk 23 branch for WebKit 1.15.
- Create a minSdk 24 branch for WebKit 1.16 and stable async startup/FCP/LCP metrics.
- Compare adoption loss, build behavior, startup, memory, and crash/ANR rates against Track A.

Deliverable: a version-adoption decision with migration notes; no silent minSdk increase.

### Phase 5 — Release gate

- Run the complete device/OS/WebView matrix.
- Run AAB, target-SDK, native-symbol, and dependency checks.
- Verify crash-free create/dispose/fullscreen/keyboard/JavaScript cycles.
- Publish the tested compatibility matrix and update the changelog/API documentation.

## Initial acceptance criteria

These are proposed gates and must be calibrated against Phase 0 measurements.

- Cold-start platform-view creation callback succeeds 100/100 times on selected release devices.
- No unbounded synchronous wait remains in the Android request-interception path.
- iOS keyboard hide restores the pre-keyboard content inset in all tested layout transitions.
- No lost JavaScript completion callback during popup, frame-nil, or disposal paths.
- At least 30% fewer scroll channel calls in the benchmark without visible final-position regressions.
- No more than 5% regression in p95 first usable frame, memory, or disposal time; target improvements are measured relative to the baseline, not assumed from dependency versions.
- 100 repeated create/attach/detach/dispose cycles complete without a native crash or unbounded pending-handler growth.
- The Android System WebView package version and OS/toolchain metadata are present in performance/crash samples.
- Any minSdk increase is a separately approved release decision with migration notes.

## Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| WebKit 1.16 removes API 19–23 users | Keep Track A, measure adoption, and ship Tracks B/C separately. |
| Event throttling changes callback semantics | Coalesce only after measurement, preserve terminal events, and document behavior. |
| Async startup introduces a new race | Use an explicit readiness state, idempotent registration, and cold-start stress tests. |
| Android System WebView differs by OEM/version | Use feature checks and collect runtime package/version telemetry. |
| iOS WebKit behavior changes with the OS | Maintain OS/device/Xcode matrix and avoid assuming a plugin-only dependency fix. |
| Upstream PR contains unrelated or unsafe changes | Port narrowly, review diffs, add tests, and do not cherry-pick noisy branches such as #2548. |
| Compatibility fixes increase bridge memory | Track pending handlers and guarantee cleanup on success, error, timeout, and dispose. |

## Definition of done

- Baseline metrics and test matrix are stored with the release candidate.
- AndroidX Browser/WebKit versions and minSdk policy are documented.
- Android startup, interception, event, composition, and lifecycle paths have regression tests.
- iOS inset, scroll, focus, JavaScript, fullscreen, popup, and disposal paths have regression tests.
- Performance and crash telemetry identify the OS, WebView runtime, toolchain, device, and plugin version.
- No open P0 issue or unreviewed behavior change is hidden behind a dependency-only release.
- Changelog and compatibility documentation explain any changed minimum SDK, callback behavior, or fallback semantics.
