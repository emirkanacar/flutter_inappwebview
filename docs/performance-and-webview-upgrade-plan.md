# iOS and Android Performance & WebView Upgrade Plan

Last reviewed: 2026-08-05  
Status: In progress — Phase 1  
Scope: iOS and Android first

Phase 1 implementation started in this workspace:

- AndroidX Browser is now `1.10.0`; AndroidX WebKit remains at `1.14.0` while the minSdk 19 compatibility contract is preserved.
- Android synchronous platform callbacks are bounded and never block the main looper.
- Android bridge/document-start registration and the first renderer load are ordered after platform-view attach; activity-free headless WebViews retain a direct path.
- Cold document-start registration failures are logged and degraded to the existing in-memory script path instead of crashing the app.
- iOS keyboard-dismissal inset restoration and scroll callback coalescing are implemented as the first lifecycle/performance slice.
- iOS UIScene and Swift Package Manager migration is tracked in [`ios-uiscene-spm-migration-plan.md`](ios-uiscene-spm-migration-plan.md); the implementation slice is complete and device validation remains.

## Executive decision

The first release should focus on native startup, platform-channel pressure, input/layout lifecycle, and WebView observability. Dependency upgrades are part of the plan, but the Android WebView support-library upgrade must not silently remove older Android users.

Recommended first implementation sequence:

1. Establish a release/profile performance baseline and collect the device WebView version.
2. Upgrade `androidx.browser` from `1.9.0` to stable `1.10.0`.
3. Keep `androidx.webkit` at `1.14.0` on the compatibility-preserving branch while auditing the package's effective minimum SDK.
4. Implement the Android startup and blocking-callback changes suggested by [PR #2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) and issues [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843)/[#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849).
5. Implement the iOS `contentInset`, focus, JavaScript-evaluation, and disposal/lifecycle fixes.
6. Evaluate `androidx.webkit:1.15.0` and `1.16.0` on explicit minSdk branches rather than changing the main compatibility contract implicitly.

This document is an implementation plan, not an approval to cherry-pick open upstream PRs wholesale.

## Evidence and inputs

- `issues.csv`: 125 open issue records were screened and the promoted findings are documented in [`known-issues.md`](known-issues.md).
- `pr.csv`: 73 open PR records; 40 carry the Android label and 51 carry the iOS label. Labels overlap.
- High-signal PRs for this plan include [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844), [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860), [#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853), [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776), [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), [#2794](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2794), [#2614](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2614), and [#2558](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2558).

The most relevant local paths are:

- Android dependency and SDK contract: `flutter_inappwebview_forge_android/android/build.gradle`
- Android startup: `flutter_inappwebview_forge_android/android/src/main/java/.../webview/in_app_webview/InAppWebView.java`
- Android document-start scripts: `.../types/UserContentController.java`
- Android channel callbacks: `.../webview/WebViewChannelDelegate.java`
- iOS layout, keyboard, scroll, JavaScript, and disposal lifecycle: `flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/InAppWebView/InAppWebView.swift`
- iOS dependency/deployment contract: `flutter_inappwebview_forge_ios/ios/flutter_inappwebview_forge_ios.podspec`

## WebView version strategy

There are three different version surfaces. They must be tracked separately.

| Surface | Current repository state | Upgrade model | Plan |
| --- | --- | --- | --- |
| AndroidX WebKit | `androidx.webkit:webkit:1.14.0` | Bundled compatibility library; latest stable is `1.16.0` | Do not move the main branch to 1.16 until the minSdk decision is explicit. |
| AndroidX Browser | `androidx.browser:browser:1.10.0` | Bundled AndroidX library; latest stable is `1.10.0` | Completed in Phase 1; run the Android regression matrix before release. |
| Android System WebView | Device-provided | Updated independently on user devices | Record `WebViewCompat.getCurrentWebViewPackage()` where available; do not treat AndroidX upgrades as engine upgrades. |
| iOS `WKWebView` | System WebKit; minimum deployment target is iOS 15 | Delivered with the iOS runtime and SDK | Do not look for a package version bump; test OS/Xcode/WebKit behavior across supported iOS 15+ versions. |

The official AndroidX WebKit release notes state that `1.15.0` raises the library minimum from API 21 to API 23, while `1.16.0` requires API 24 and makes async WebView startup and navigation-listener APIs stable: [AndroidX WebKit release notes](https://developer.android.com/jetpack/androidx/releases/webkit). The official Browser release notes list `1.10.0` as the stable release: [AndroidX Browser release notes](https://developer.android.com/jetpack/androidx/releases/browser).

AndroidX WebKit is a compatibility layer over the separately updated WebView APK. The application controls the AndroidX library version, but not the WebView APK version installed on each device: [Jetpack WebKit overview](https://developer.android.com/develop/ui/views/layout/webapps/jetpack-webkit-overview). The Android WebView package can be read for telemetry using the platform/compatibility API: [WebView API reference](https://developer.android.com/reference/android/webkit/WebView#getCurrentWebViewPackage()).

The current `minSdkVersion 19` declaration therefore needs an effective-minimum audit: the AndroidX WebKit release notes describe the 1.15 transition as API 21 → API 23, which implies that the 1.14 line is not a full API 19 compatibility guarantee. No minSdk increase should be made until the supported-user distribution and the built AAR/manifest behavior are verified.

### Version tracks

#### Track A — compatibility-preserving first release

- Upgrade `androidx.browser` to `1.10.0`.
- Keep `androidx.webkit` at `1.14.0` while auditing API 19/21 behavior.
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

## Android work packages

### A1 — Startup and bridge readiness (P0)

Problem at the review baseline: `InAppWebView.prepare()` registered the native JavaScript bridge and document-start scripts synchronously. `UserContentController` called `WebViewCompat.addDocumentStartJavaScript` directly. This matches the failure pattern in [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) and [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849).

Phase 1 status: platform-view registrations and the first load are now ordered through `View.post()`. Activity-free headless WebViews use the direct path so they do not wait for an attach that will never happen, and document-start registration exceptions degrade to a logged fallback. An explicit readiness/retry state and AndroidX async-startup comparison remain for the next validation track.

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

Phase 1 status: the main looper no longer waits synchronously, and background request callbacks have a 500 ms upper bound with a safe null fallback. Timeout telemetry and a fully asynchronous interception contract remain open work.

Plan:

- Map the full request-interception call graph and identify which callbacks truly require a synchronous response.
- Remove unbounded latch waits from the WebView callback path.
- Use a bounded response strategy with a safe default, or make Dart interception opt-in when the WebView API cannot be made asynchronous without changing behavior.
- Record timeout/fallback counters so applications can detect degraded interception.
- Add slow-Dart, nested-navigation, redirect, and concurrent-resource tests.

Exit criteria:

- No unbounded wait remains on a WebView callback thread.
- A slow or unavailable Dart handler cannot freeze the UI or WebView request pipeline.
- Existing interception behavior remains covered by compatibility tests.

### A3 — Event-channel pressure (P1)

Problem: scroll, progress, and console callbacks allocate payload maps and cross the platform channel at high frequency.

Phase 1 status: iOS scroll-change callbacks are coalesced once per main-loop turn while preserving the latest offset and user-scroll signal. Android scroll/progress/console event-rate measurement remains before changing Android semantics.

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

Problem: the current `frame` setter and keyboard callbacks apply negative content-inset compensation, while scroll offset KVO dispatches a main-queue task for each change. This matches [issue #2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859) and [PR #2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860).

Plan:

- Make content-inset adjustment idempotent and separate the base inset from keyboard compensation.
- Restore the exact pre-keyboard inset on `keyboardWillHide`.
- Coalesce KVO scroll changes with a pending-update flag or display-link-style scheduler.
- Do not replace KVO with `scrollViewDidScroll` without reproducing the existing white-space rendering issue documented in the source.
- Test rotations, safe-area changes, keyboard animation, nested Flutter scrolling, and scroll-to-bottom after keyboard dismissal.

Exit criteria:

- No stale negative inset after keyboard hide, rotation, or WebView frame changes.
- No unbounded main-queue scroll backlog.
- Scroll p95 frame time and final-position correctness do not regress.

### I2 — JavaScript evaluation compatibility (P0)

Use [PR #2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [PR #2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776), [PR #2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), and [PR #2574](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2574) as compatibility inputs.

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
| Port the idea after local tests | #2844, #2860, #2853, #2871, #2776, #2771, #2574, #2614, #2558 | Re-implement against the current branch and add regression coverage. |
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

Deliverable: baseline report and a go/no-go decision for Tracks A, B, and C.

### Phase 1 — Safe dependency and observability update

- Upgrade AndroidX Browser to `1.10.0`.
- Keep AndroidX WebKit at `1.14.0` on the compatibility branch.
- Add WebView package telemetry and feature-availability logging.
- Add performance regression test scaffolding without changing public callback semantics.

Deliverable: isolated dependency commit plus baseline comparison.

### Phase 2 — Android startup and callback pipeline

- Implement A1 and A2.
- Add headless/inline cold-start tests.
- Add slow-Dart and request-interception fallback tests.
- Benchmark hybrid/surface composition and event coalescing.

Deliverable: Android P0 performance/stability patch with no minSdk change.

### Phase 3 — iOS layout and lifecycle pipeline

- Implement I1 and I2.
- Implement I3 lifecycle tests and fixes.
- Validate bridge-disabled, content-world, popup, keyboard, and fullscreen paths.

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
