# iOS and Android Performance Plan

Last reviewed: 2026-11-21\
Status: source fixes landed; release/profile baseline and device validation remain\
Scope: iOS and Android first

Completed work is described in the package changelogs and
[`known-issues.md`](known-issues.md); this plan keeps only what is still open
and the gates for it. Open upstream PRs are design input, not patches to
cherry-pick.

## Current state

- Android: AndroidX WebKit `1.16.0` with `minSdk 24` (Track C, Android 1.0.56)
  and AndroidX Browser `1.10.0`. API 19-23 hosts stay on 2.1.76 / Android
  1.0.55 + WebKit 1.15.0. Optional WebKit 1.16 APIs (NavigationListener,
  `navigate()` parameters, prerender, BFCache, Profile preconnect/prefetch,
  `WebViewBuilder`) are feature-checked.
- Android startup: `WebViewStartupCoordinator` coordinates async provider
  startup with a fallback; bridge/document-start registration and the first
  load run after platform-view attach (`View.post()`), headless WebViews use the
  direct path, and registration failures degrade to the in-memory script path.
  Retry state is cleared on dispose.
- Android callbacks: synchronous platform callbacks use one main-looper
  dispatcher, bounded in-flight capacity, and timeouts (250 ms for request
  interception, 500 ms default) with a null fallback. Progress no longer
  re-injects scripts.
- iOS: keyboard inset restoration, scroll/content-size coalescing, progress
  de-duplication, pre-iOS 18 `callAsyncJavaScript` routing, nil-frame guards,
  and disposal completion of pending JavaScript callbacks (Android uses the same
  contract).
- `InAppWebViewPreloader`: opt-in single-flight headless prewarm and
  headless-to-inline KeepAlive handoff; measurements pending.
- `ChannelCallStats` (Dart, disabled by default) counts native-to-Dart calls
  per `<controller>.<method>` with rate, optional payload bytes, and handler
  time. It is the before/after gate for channel work.

## Next steps

1. Phase 0 baseline: release/profile builds of the current set, with OS,
   device, WebView package, Flutter, Xcode, and plugin versions per sample.
   No further source change is judged without it.
2. Android A1/A2/A4 validation and follow-ups below.
3. iOS I1-I4 validation and follow-ups below.
4. Release gate: full device matrix, AAB/target-SDK/16 KB checks,
   crash-free lifecycle cycles, published compatibility matrix.

## Measurement

Metrics: cold start to native construction, construction to platform-view
created, created to bridge ready, bridge ready to first paint and
`onLoadStop`; scroll p50/p95 frame time and dropped frames; channel calls per
second and payload bytes; JavaScript latency and error rate; memory after 1, 5,
and 10 WebViews; `dispose()` duration and retention; ANR, renderer loss,
native crash, and callback-loss rate.

Tooling: opt-in Dart `Timeline` spans; Android `android.os.Trace` and Perfetto
with `WebViewCompat.getCurrentWebViewPackage()`; iOS `os_signpost` and
Instruments. Report p50, p95, worst case, memory, and error/timeout counts;
one median is not enough. Instrumentation stays off by default.

Android matrix: API 24, 29, 35, 36; a low-memory, a Pixel-class, and a
Samsung/OEM device; current and one older WebView APK; hybrid and surface
composition; inline, headless, KeepAlive, bridge on/off, 5-9 document-start
scripts; scroll-heavy page, keyboard, fullscreen video, popups, cookie
cleanup, repeated disposal.

iOS matrix: iOS 15 through the latest release on a low-memory and a recent
device (Simulator does not replace devices); current and previous Xcode and
Flutter; keyboard, scroll-to-bottom, fullscreen video, `window.open`,
KeepAlive, `callAsyncJavaScript`, `windowId`, focus, repeated disposal.

## Android work packages

### A1 - Startup and bridge readiness (P0)

Root cause and fix: [#2843/#2849](known-issues.md). Open:

- Compare the current path with AndroidX 1.16 async startup
  (`WebViewStartUpConfig`) on the device matrix.
- Exit: 100/100 cold starts deliver the creation callback; no registration
  before readiness; no duplicate bridge or script registration after retries.

### A2 - Blocking request interception (P0)

The main looper no longer waits; see [#2580](known-issues.md). The unreleased
`shouldInterceptRequestUrlFilter` setting (Android only) sends only matching
URLs to Dart. On a Samsung A16 (WebView 157), a 200-image page sent 19-36
requests to Dart with 351 bypass warnings without a filter, and exactly one
(answered) with a single-pattern filter
(`intercept_url_filter_test.dart`, `UrlRegexFilterTest`). Open:

- Timeout/fallback counters so apps can detect degraded interception.
- Slow-Dart, redirect, nested-navigation, and concurrent-resource tests.
- Exit: no unbounded wait on a WebView callback thread; a slow Dart handler
  cannot freeze the UI or request pipeline.

### A3 - Event-channel pressure (P1)

Problem: scroll, progress, and console callbacks cross the platform channel at
high frequency.

Status (merged, unreleased):

- Phase 1: iOS coalesces scroll changes once per main-loop turn and
  de-duplicates progress and content-size updates. Android drops duplicate
  progress and unchanged scroll payloads and coalesces scroll to the next
  animation frame.
- Phase 2: Android, iOS, and macOS skip fire-and-forget events with no Dart
  listener. Dart sends `skippedEvents` in the platform-view and headless `run`
  params; the native `ChannelEventFilter` intersects it with a fixed allowlist
  (`onConsoleMessage`, `onScrollChanged`, `onProgressChanged`,
  `onTitleChanged`, `onOverScrolled`, `onZoomScaleChanged`) and never filters
  callbacks that wait for a result. Each factory attach re-applies the list
  (KeepAlive and headless transfer follow the current owner); a missing or
  malformed list clears the filter; InAppBrowser is never filtered. Windows and
  Linux are not covered.
- Console hook: iOS/macOS do not inject `ConsoleLogJS` when `onConsoleMessage`
  is skipped. `updateChannelEventFilter` adds or removes the script for the
  next navigation and toggles `_consoleMessagesEnabled` in every known content
  world for the current document. Known limit: `removePluginScripts(with:)`
  removes only the default-world copy, so a custom world keeps the hook until
  the next `prepareAndAddUserScripts()`. Popups are not changed.

Device results (2026-11-21, `channel_pressure_test.dart` in the iOS and
Android examples):

| Device | 5x5000 `console.log`, listener vs none | 301 scroll steps | KeepAlive reattach |
| --- | --- | --- | --- |
| iPhone, iOS 27.2.1, profile | JS median 37-41 ms vs 1-2 ms; 25000 vs 0 channel calls | 300 vs 0 calls | Expected hook states; found and fixed the nil-frame guard (#2771) |
| Samsung A16, Android 16, WebView 157, debug | 25000 vs 0 calls; drain about 20 s vs 2.2 s (no JS hook on Android) | 300 vs 0 calls | 0/1/0/1 messages as expected |

Plugin-script minification and concatenation were measured and rejected:
about 2-4 KB saved per document, while a minifier risks the bridge-secret
placeholder substitution and concatenation breaks per-group removal.

Still open: macOS, Windows, and Linux runtime evidence; bounded console
handling for high-volume pages; the `bridgeEvents` design from
[PR #2794](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2794).

### A4 - Composition, IME, fullscreen, and disposal (P1)

- Benchmark hybrid versus surface composition; keep the default without
  correctness and frame-time evidence.
- Fullscreen exit then keyboard in another Flutter field; renderer and surface
  loss during fullscreen video.
- Measure the main-thread cost of serialized cookie deletion/flush.
- Create, attach, detach, KeepAlive, reattach, dispose cycles. PRs #2614 and
  #2558 are references only.

### A5 - Android release compatibility (P1)

- Android 15/16 deprecation checks (system bars, PR #2729).
- AAB 16 KB page-size check.
- Audit nullable native values and FileProvider changes from PR #2874.

## iOS work packages

### I1 - Keyboard inset and scroll scheduling (P0)

Fix landed ([#2859](known-issues.md), PR #2860). Open: device runs for
keyboard animation, rotation, safe-area changes, nested Flutter scrolling, and
scroll-to-bottom after dismissal. Do not replace KVO with
`scrollViewDidScroll` without reproducing the white-space issue noted in the
source. Exit: no stale inset, no main-queue scroll backlog, no p95 frame-time
or final-position regression.

### I2 - JavaScript evaluation (P0)

Fixes landed (PRs #2871, #2776, #2771, #2574 as input). Open: latency,
Promise serialization, popup teardown, and handler-cleanup measurements on
iOS 15-18; fallback handlers removed after completion, timeout, error, and
disposal even with the public bridge disabled; custom content-world isolation
kept. Exit: no lost completion callback; pending fallback calls stay bounded.

### I3 - Focus, fullscreen, and window lifecycle (P1)

Document-focus tests (PR #2853); fullscreen start/seek/exit and WebKit process
termination; `window.open` ownership, popup disposal, `windowId` evaluation;
KeepAlive URL restoration; `dispose()` releases observers, handlers,
delegates, and pending callbacks exactly once; scene lifecycle on every
supported iOS release.

### I4 - Toolchain and system WebKit (P1)

`WKWebView` ships with the OS, so test OS/Xcode behavior instead of looking
for a package bump. Build with the current and previous Xcode; keep
`swift-collections` and Swift tools updates separate from runtime changes.

## PR triage

| Action | PRs |
| --- | --- |
| Port the idea with local tests | #2844, #2860, #2853, #2776, #2574, #2614, #2558 |
| Already local; validate on devices | #2243, #2871, #2771, #2474 |
| Benchmark before adoption | #2794, #2851, #2864, #2390 |
| Do not cherry-pick (unrelated commits) | #2548 |
| Maintenance batch, separate from runtime changes | #2879, #2870, #2817, #2729 |

## Acceptance criteria

Calibrate against the Phase 0 baseline.

- 100/100 cold-start creation callbacks on the selected release devices.
- No unbounded synchronous wait in Android request interception.
- iOS keyboard hide restores the pre-keyboard inset in every tested layout.
- No lost JavaScript completion during popup, nil-frame, or disposal paths.
- At least 30% fewer scroll channel calls without final-position regressions;
  no lost terminal progress event.
- At most 5% p95 regression in first usable frame, memory, or disposal time.
- 100 create/attach/detach/dispose cycles with no native crash or unbounded
  pending-handler growth.
- Samples carry the WebView package and OS/toolchain metadata.
- Any minSdk increase is a separate, approved release decision with
  migration notes.
