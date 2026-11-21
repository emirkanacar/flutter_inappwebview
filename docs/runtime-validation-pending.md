# Runtime Validation Pending

Last reviewed: 2026-11-21

Records whose local implementation or mitigation is complete but whose target
device, provider, browser, native runtime, or release artifact has not been
exercised. They are release gates, not active work, and are excluded from the
[open work plan](open-work-plan.md) counts. Root cause, fix, and full evidence
are in [known-issues.md](known-issues.md); this file keeps only the status and
the remaining gate.

## Current counts

| Local status | Issue records | Count |
| --- | --- | ---: |
| Implemented or mitigated; runtime validation pending | [Issue register](#issue-register) | 78 |
| Resolved locally; no runtime gate (pure Dart serialization) | [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709) | 1 |
| Closed by source review (no plugin-owned sink) | [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | 1 |
| Host/platform boundary (Apple/WebKit Simulator or callback limits, Android framework/provider/dependency, host app/site/Firebase config, Flutter engine/platform view) | #2570, #2584, #2598, #2636, #2659, #2680, #2688, #2698, #2713, #2723, #2727, #2753, #2796, #2815, #2831 | 15 |
| Open implementation or reproduction | [open work plan](open-work-plan.md) | 30 |
| **Issue export total** (upstream `OPEN` state unchanged) | | **125** |

Outside the 125-issue count:

- Nine PR-only records with local implementations: #2243, #2474, #2743,
  #2771, #2823, #2825, #2853, #2866, #2871.
- Post-export upstream issue #2882.
- Forge-repository and local-feature records listed under
  [Records outside the CSV export](#records-outside-the-csv-export).

## Issue register

`#2536`, `#2555`, `#2568`, `#2580`, `#2594`, `#2600`, `#2619`, `#2641`,
`#2654`, `#2660`, `#2673`, `#2685`, `#2687`, `#2690`, `#2697`, `#2700`,
`#2703`, `#2707`, `#2710`, `#2711`, `#2717`, `#2718`, `#2720`, `#2721`,
`#2725`, `#2728`, `#2733`, `#2736`, `#2737`, `#2741`, `#2752`, `#2757`,
`#2760`, `#2762`, `#2763`, `#2778`, `#2780`, `#2782`, `#2783`, `#2787`,
`#2789`, `#2791`, `#2793`, `#2797`, `#2805`, `#2811`, `#2812`, `#2813`,
`#2814`, `#2819`, `#2826`, `#2830`, `#2834`, `#2835`, `#2837`, `#2839`,
`#2840`, `#2841`, `#2842`, `#2843`, `#2846`, `#2848`, `#2849`, `#2850`,
`#2852`, `#2855`, `#2856`, `#2859`, `#2861`, `#2862`, `#2863`, `#2867`,
`#2868`, `#2872`, `#2873`, `#2875`, `#2878`, `#2880` (78).

The per-issue gate is the "Required evidence" or "Remaining validation" line
of the issue's record in `known-issues.md`.

### Runtime results recorded so far

Short status only; the full device logs are in `known-issues.md`.
"A16" is a Samsung SM-A165F (Android 16/API 36, MediaTek, WebView 150).

| Record | Passed so far | Still required |
| --- | --- | --- |
| #2536 | API 35 AVD and A16: nested InAppBrowser and Custom Tabs handoff (A16 logs a system IntentRedirect warning only). | Restore/rotation, malformed extras, provider coverage. |
| #2555 | API 35 AVD and A16: IME reopens after dispose, virtual display and hybrid. | Android 10, OEM. |
| #2580 | API 35 and A16: 24 rapid navigations, no OOM/ANR. | Android 10/11 OEM, back/forward. |
| #2641, #2685 | Package tests and debug APK, no package-owned deprecation warnings; dead API <= 24 branches removed in Android 1.0.58. | API 24/29/35/36 cookies, file chooser, printing, fullscreen; clean JDK 17/21 release, AAB, publish dry-run. |
| #2654 | iOS Simulator 100 cycles; physical iOS 4 cycles; API 35 and A16 4 cycles. | Repeated physical 100-cycle runs, iOS 15-26, Android API 33+/OEM. |
| #2660 | Physical API 36 reports `PAYMENT_REQUEST=true`. | Android 12-16/OEM Google Pay flows, merchant config. |
| #2687 | JDK 21 release APK installs and launches on API 35. | Clean JDK 17, provider, AAB, publish. |
| #2690 | Platform-interface and iOS source tests. | iOS 18+ Writing Tools UI, capability fallback, `getSettings()`. |
| #2710 | iOS 26.2 Simulator 3 cycles. **The 2026-08-12 physical iOS run failed the first cycle** (`request=null` after seek, no `onEnterFullscreen`). | Physical iOS 26/GPU, HLS/iframe, orientation, media controls. |
| #2711 | iOS 26.2 Simulator 4 cycles, no missing-plugin failure. | Physical scene reattachment, stale-controller sequence. |
| #2718 | A16: 10/10 mutation and flush cycles. | Android 10/provider, Play Console cookie clear. |
| #2721 | None: display-size override restarts the AVD/A16 activity before the geometry assertion. | Android 16 display-size change with hybrid composition, OEM providers. |
| #2757 | Pana 0.23.3 passes the corrected lint form locally. | Republished Pana 50/50 score. |
| #2763 | iOS 26.0/26.2/27.0 Simulators and one physical iOS run. | Repeated physical iOS 15-26 popup and scene coverage. |
| #2787 | iOS 26.2 Simulator and physical iOS: viewport returns to full height. | Custom page zoom, native `WKWebView` comparison, more devices. |
| #2793 | Physical Android: JS-to-Dart, Dart-to-JS, typed async response. | Provider coverage; iOS, Web, Windows, macOS, Linux. |
| #2811 | `flutter build web --wasm` for both examples. | Chrome WasmGC iframe and bridge, same-origin and cross-origin. |
| #2819 | A16 normal fullscreen/exit; Vimeo network-loss run exits fullscreen cleanly. | Physical MediaTek GPU/surface failure and renderer teardown. |
| #2830 | Xcode 27 iOS example build. | Xcode 26.4.1, macOS consuming app. |
| #2834 | Physical Android: `getHighEntropyValues` returns the configured metadata. | Request-header validation across providers. |
| #2837 | API 35 and A16 lock/unlock keep DOM and URL. | Android 10, affected OEM/provider. |
| #2843, #2849 | Four clean API 35 installs and A16 cold-start plus 4 headless cycles. | Release/R8, broader providers. |
| #2846 | Static migration regression. | Flutter >=3.47/AGP 9/JDK 17 built-in Kotlin; legacy AGP 8 app. |
| #2856 | Dart payload tests. | Android API/provider matrix. |
| #2867 | iOS 26.2 Simulator and physical iOS: 3 popup cycles. | iOS 15-26, Xcode 16/26, symbolicated crash comparison. |
| #2878 | A16 without the `TextInput.show` workaround: keyboard returns. | Android 10/OEM. |
| Lifecycle wave (Android 1.0.53, iOS 2.1.31, desktop/Web ownership) | iOS Simulator and physical iOS 100 cycles plus 50 KeepAlive / 50 headless transfers; API 35 emulator and physical API 36 the same. | Android renderer loss/fullscreen/IME/provider, physical iOS keyboard/scene/popup, macOS/Windows/Linux/Web target runs. |

### PR-only records

| PR | Still required |
| --- | --- |
| #2243 | External picker/provider matrix; Flutter APK wrapper build (blocked by the Gradle 8.13/JDK `OutgoingVariantsReportTask` failure). |
| #2474 | Older WebView providers without WebMessageListener. |
| #2743 | Physical API 36 reports `FOR_APP`; `NONE`/`FOR_APP`/`FOR_BROWSER` with Digital Asset Links and WebAuthn flows. |
| #2771, #2871 | Physical iOS content-world and pre-iOS 18 `callAsyncJavaScript` runs. |
| #2823 | Recorder provider, permission, cancel, returned URI. |
| #2825 | Android WebView 110+ profile separation and deletion, iOS 17+ data stores, desktop target builds. |
| #2853 | Physical iOS focus, `document.hasFocus()`, reattachment. |
| #2866 | An associated app plus a Universal Link domain with a POST/OAuth flow. |

### Records outside the CSV export

Details for each are in `known-issues.md`.

| Record | Still required |
| --- | --- |
| #2882 iOS 27 `canOpenURL` replacement (iOS 2.1.33) | `openWithSystemBrowser` on iOS 27, plus an unopenable URL returning `cannot be opened!`. |
| Web `Sandbox.ALLOW_ALL` (Web 1.0.5) | Browser: no `sandbox` attribute for `ALLOW_ALL`, empty `sandbox` for `ALLOW_NONE`. |
| Android example build directory (Forge PR #1) | `flutter build apk --debug` in the Android example on Flutter 3.44.8. |
| Xcode 27 / Swift 6.4 build (Forge #2; iOS 2.1.36, macOS 1.1.11) | iOS 26+/macOS 26+ `obscuredContentInsets` round trip; CocoaPods-only host build. |
| Method-channel argument validation (iOS 2.1.38, macOS 1.1.13, Windows) | MSVC Windows build; malformed call returns `invalid_arguments` on each platform. |
| Browsing data deletion (root 2.1.80 line) | Android providers with and without `DELETE_BROWSING_DATA`; iOS/macOS site and subdomain removal; Linux WPE and Windows WebView2 builds. |
| `removeDataModifiedSince` timestamp unit | Linux WPE run; Apple device keeps older data. |
| Lockdown Mode and cookie policy (root 2.1.80 line) | iOS 16+/macOS 13+ JIT/WebAssembly toggle; iOS 17+/macOS 14+ `DISALLOW` and `ALLOW`. |
| iOS `writingToolsBehavior` parsing | iOS 18+ device with Apple Intelligence. |
| Android `warmUpRendererProcess` (root 2.1.80 line) | Provider with the feature starts a renderer early; provider without returns `false`. |
| Windows context menu (Windows 1.0.17) | Windows WebView2 build: custom items, hidden defaults, menu types, `disableContextMenu`. |
| Native WebView API gaps (root 2.1.76, 2.1.77) | Providers with `MUTE_AUDIO`, NavigationListener, PRECONNECT, WEBVIEW_BUILDER, BFCache settings; real downloads; cookie observers; iOS 26 helpers. |
| iOS input accessory and `disableAutocorrection` (root 2.1.70) | Physical iOS 15+ focus changes; each platform with input, textarea, contenteditable. |
| `InAppWebViewPreloader` | Release/profile measurements of cold start, first frame, memory. |

## Validation tracks

| Track | Required evidence |
| --- | --- |
| Android | Physical API/provider coverage, activity restore and rotation, cold-start/AOT cycles, malformed extras, IME/fullscreen, APK/AAB checks. |
| iOS/macOS | Physical WebKit/AppKit across supported OS versions, UIScene, popup/presentation, keyboard, authentication, geolocation, SPM and CocoaPods consuming apps. |
| Windows | WebView2 create/resize/dispose/recreate, affected runtime versions, minimize/focus, debug and release builds. |
| Linux | WPE/WebKit build matrix, Fedora/X11/Intel frames, GL-disabled fallback, `pkg-config` configurations. |
| Web | Same-origin and cross-origin browser tests, Chrome WasmGC iframe and bridge runtime. |

A source test, static assertion, host build, or manifest check is supporting
evidence, not a replacement for the target runtime test.

## Status transitions

1. A complete local implementation leaves `open-work-plan.md` and enters this register.
2. A failed runtime gate moves the issue back to the open work plan with the failing environment.
3. When all required validation passes, remove the issue here and mark it locally validated in `known-issues.md` and the resolution log.
4. Host/platform boundaries are neither runtime-pending fixes nor upstream closures.
5. Do not change or comment on the upstream GitHub issue state.
