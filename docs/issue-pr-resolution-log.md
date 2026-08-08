# Issue and PR Resolution Log

Last reviewed: 2026-08-08

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

GitHub CLI review of the upstream issue bodies corrected two historical local
associations. Upstream [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600)
is the iOS `windowId`/`EXC_BAD_ACCESS` popup crash, not cookie property
decoding. Upstream [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584)
is an iOS 18.4 Simulator/WebKit startup crash, not WebMessage payload
validation. Cookie and WebMessage validation remain useful internal hardening,
but they are no longer presented as fixes for those upstream records. The
startup crash is classified as a host/platform boundary; the popup crash stays
runtime-pending until iOS device evidence is available.

## Current local status counts

The export contains 125 issues and 73 PRs. Local implementation status is
tracked separately from that historical export:

| Status | Count | Register |
| --- | ---: | --- |
| Locally implemented or mitigated; runtime validation pending | 66 issues | [runtime-validation-pending.md](runtime-validation-pending.md) |
| Closed by source review | 1 issue (`#2745`) | No package runtime gate |
| Host/platform-specific boundary | 8 issues (`#2570`, `#2584`, `#2598`, `#2636`, `#2659`, `#2713`, `#2723`, `#2727`) | Host/provider/engine/application/site tracking in [known-issues.md](known-issues.md); no Forge-owned fix |
| Open implementation or reproduction | 50 issues | [open-work-plan.md](open-work-plan.md) |
| PR-only local implementations awaiting runtime validation | 3 PRs | `#2771`, `#2871`, `#2474` |

The issue inventory below remains the historical 125-record export and is not
reduced when a record moves between the local status registers.

## Local resolution history

| 2026-08-08 | Android cold-start and startup reattach [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) | [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) | Android now orders provider startup and document-start registration, retries transient failures, and recreates the startup executor after engine detach while ignoring stale generations. Android source tests pass; release/AOT and headless real-device validation remains pending. |
| 2026-08-08 | Android interception freeze and cookie ANR [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | No upstream relationship inferred | Android synchronous interception is bounded by concurrency and timeout limits, and `deleteAllCookies` no longer flushes synchronously after asynchronous removal. Focused Android tests pass; Android 10/provider and Play Console runtime validation remains pending. |
| 2026-08-08 | iOS popup/window-ID crashes [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | No upstream relationship inferred | iOS now defers popup window-ID initialization off KVO, verifies observed object identity, ignores callbacks after disposal, and uses the initialized page world for popup JavaScript. Source tests pass; iOS device/Xcode validation remains pending. |
| 2026-08-08 | iOS header replacement navigation [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | No upstream relationship inferred | iOS counts simultaneous navigation-policy decisions, queues replacement-header loads until the final decision handler completes, and rejects malformed URL requests safely. Source tests pass; physical navigation validation remains pending. |
| 2026-08-08 | iOS 26 fullscreen and geolocation behavior [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | The native fullscreen-container mitigation and iOS 26 geolocation decision bridge remain enabled and source-validated. Physical iOS 26 fullscreen/grant/deny validation remains required; no upstream state was changed. |
| 2026-08-08 | iOS keyboard `visualViewport` diagnostic [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | No upstream relationship inferred | Added an opt-in integration diagnostic that records WebKit viewport metrics and the Flutter WebView frame. Flutter analysis and the iOS 26.0 simulator build pass; the baseline frame is `402x778` with a `778px` viewport, but the automated platform-view tap did not open the software keyboard (`activeElementId` remained empty), and no iOS 17 runtime is installed. No package behavior change was made; physical/iOS 17 and native inset/frame validation remain pending. |
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
| 2026-08-08 | Android activity-extra deserialization [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | No upstream relationship inferred | InAppBrowser and Chrome Custom Tabs maps/lists now cross activity boundaries through a recursive primitive/nested-`Bundle` codec. Android native source contains no `getSerializable`, `putSerializable`, or `java.io.Serializable` references; the static regression test and Android compile pass. API/provider restore and malformed-extra validation remain pending. |
| 2026-08-08 | iOS popup default handling [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | No upstream relationship inferred | iOS now removes the pending popup transport without loading the target into the caller WebView when `onCreateWindow` returns `false`, `null`, or is unhandled. Explicit same-window `controller.loadUrl` remains available from the callback; source regression coverage passes and iOS popup-device validation remains pending. |
| 2026-08-08 | Linux no-GL buffer path [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | No upstream relationship inferred | `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` now enables `LIBGL_ALWAYS_SOFTWARE` before WPE starts and skips EGL import so SHM/pixel import supplies CPU-readable frames. Static source coverage was added; Fedora/X11/Intel runtime validation remains pending. |
| 2026-08-08 | JavaScript evaluation source review [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | No upstream relationship inferred | The only dynamic evaluation sites are explicit `evaluateJavascript` wrappers receiving the caller-provided source. Android and Web static tests pin those boundaries; no plugin-owned remote-data sink was found, so no speculative replacement was made. |
| 2026-08-08 | iOS 26 geolocation decision bridge [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | No upstream relationship inferred | iOS 26 now implements the new `WKUIDelegate` geolocation decision callback and forwards it through the existing Dart `onGeolocationPermissionsShowPrompt` contract. The iOS source test, platform-interface tests, and Xcode 27 iOS example build pass; physical iOS 26 grant/deny and scene-lifecycle validation remains pending. |
| 2026-08-08 | macOS fractional platform-view frame sync [#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826) | No upstream relationship inferred | macOS no longer relies on AppKit autoresizing masks for the native WebView child. Bounds synchronization is guarded for finite frames and runs during layout and resize callbacks. The new source regression assertion fails against the original implementation and passes after the fix; the Xcode 27 example build passes with a temporary 12.0 deployment-target override, while Retina/fractional-width runtime validation remains pending. |

| 2026-08-08 | Android nullable request-result payloads [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856); Web iframe URL tracking [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | No upstream relationship inferred | Android request-result decoding now validates optional strings before constructing `WebUri` or public fields. Web same-origin/current-location and cross-origin-null behavior is protected by source assertions. Android focused tests pass with the system Flutter 3.44.8; Web test loading is blocked by the toolchain mismatch, and device/browser validation remains pending. |
| 2026-08-08 | Android provider-specific setting casts [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594); macOS browser-window teardown [#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707) | No upstream relationship inferred | Android allow-list parsing filters malformed values and focused tests pass. macOS popup registry removal is unconditional and protected by a static assertion. macOS test loading is blocked by the Flutter toolchain mismatch; provider/device and macOS runtime validation remain pending. |
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
| 2026-08-08 | Android WebStorage callback entries [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717); iOS navigation payloads [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | No upstream relationship inferred | Android malformed origin entries are skipped safely. iOS `postUrl` and `loadData` validate required channel values and return structured argument errors. The iOS source test passes with Flutter 3.44.8; provider/device validation remains pending. |
| 2026-08-08 | Android compatibility callback ownership [#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783); iOS load-file payloads [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | No upstream relationship inferred | Android compat callbacks now reject unrelated WebViews safely. iOS load-file payloads now validate required asset paths. Android tests and the iOS source test pass with Flutter 3.44.8; provider/device validation remains pending. |
| 2026-08-08 | macOS custom scheme ownership [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619); Android navigation ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697) | No upstream relationship inferred | macOS custom-scheme callbacks now reject unrelated WebViews. Android URL navigation now returns native default behavior for unrelated WebViews. Static/source validation is recorded; native runtime validation remains pending. |
| 2026-08-08 | Android page lifecycle ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); iOS proxy payloads [#2805](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2805) | No upstream relationship inferred | Android page lifecycle callbacks now reject unrelated WebViews safely. iOS proxy settings and rules now use optional decoding and malformed-rule filtering. Static/source validation is recorded; provider/runtime validation remains pending. |
| 2026-08-08 | Android Chrome callback ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); internal iOS WebMessageChannel payloads | No upstream relationship inferred | Android Chrome callbacks now reject unrelated WebViews safely. iOS WebMessageChannel indices and payloads are validated before access; this internal hardening is not associated with upstream #2584. Android tests and the iOS source test pass with Flutter 3.44.8; iOS runtime validation remains pending. |
| 2026-08-08 | Android file chooser callback ownership [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783); macOS WebStorage payloads [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717) | No upstream relationship inferred | Android file chooser callbacks use nullable casts. macOS WebStorage arguments and display names are validated before cleanup. Android tests pass; macOS loader/runtime validation remains pending. |
| 2026-08-08 | Linux GL runtime fallback [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | No upstream relationship inferred | Linux now switches from a failed GtkGLArea initialization to pixel-buffer rendering and emits a diagnostic. Linux test loading is blocked by the Flutter toolchain mismatch; Fedora/X11/Intel runtime validation remains pending. |

| Local release | Issue/report scope | Related PR records | Local result |
| --- | --- | --- | --- |
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
