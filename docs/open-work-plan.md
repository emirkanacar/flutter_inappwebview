# Open Work Plan

Last reviewed: 2026-08-08

This is the implementation backlog for work that is not yet resolved in the local Forge repository. It is derived from the supplied `issues.csv` and `pr.csv` snapshots, the current source tree, package changelogs, and [`known-issues.md`](known-issues.md).

## Scope and counts

The export contains 125 issues and 73 PRs. Seventy-five issue records are now resolved or mitigated locally and are documented in the [resolution log](issue-pr-resolution-log.md). Three additional PR-only records (`#2771`, `#2871`, and `#2474`) are implemented locally; they are tracked separately and do not change the issue counts below. The remaining issue records are:

| Category | Count | Treatment |
| --- | ---: | --- |
| Bugs | 38 | Technical work, validation, or reproduction required |
| Enhancements | 10 | API/design decision and implementation required |
| Unlabelled | 2 | Triage before implementation |
| Showcase | 3 | Product examples, not plugin engineering work |
| **Total remaining issue records** | **50** | **47 technical issue records after excluding showcase entries** |

The upstream export marks every record `OPEN`. That value is historical metadata; this plan uses local code evidence to decide whether a record is resolved, mitigated, validation-only, or still open.

## Status rules

- **P0 containment:** crash, security, data-loss, or deadlock risk. Reproduce or add a safe guard before feature work.
- **P1 stability:** confirmed runtime, lifecycle, build, or release compatibility problem.
- **P2 API/feature:** requires a public API, platform capability, or product decision.
- **P3 triage:** low-detail, duplicate, environment-specific, or unconfirmed report.
- **Validation-only:** the local fix exists; do not rewrite working code until the target device, OS, browser engine, or artifact reproduces a remaining failure.

## Already excluded from this plan

These issue records are not open implementation tasks because the local repository contains a fix or mitigation: `#2873`, `#2875`, `#2856`, `#2878`, `#2819`, `#2880`, `#2762`, `#2868`, `#2872`, `#2849`, `#2843`, `#2848`, `#2700`, `#2580`, `#2718`, `#2555`, `#2791`, `#2728`, `#2703`, `#2859`, `#2737`, `#2789`, `#2780`, `#2867`, `#2840`, `#2733`, `#2862`, `#2710`, `#2842`, `#2841`, `#2850`, `#2863`, `#2835`, `#2812`, `#2813`, `#2725`, `#2741`, `#2852`, `#2837`, `#2855`, `#2698`, `#2673`, `#2594`, `#2707`, `#2697`, `#2831`, `#2814`, `#2797`, `#2711`, `#2709`, `#2736`, `#2861`, `#2763`, `#2782`, `#2783`, `#2619`, `#2778`, `#2600`, `#2584`, `#2697`, `#2717`, `#2654`, and the remaining Android compatibility callback paths.

The iOS compatibility work from PRs [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771) and [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), together with the Android compatibility work from PR [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474), is also implemented locally. These are PR-only export records rather than issue rows, so they are tracked in the resolution log and known-issues validation matrix instead of the issue counts above.

Their remaining device/build checks are included below only when they block release confidence. Do not reopen their implementation without new evidence.

## Priority queue

### P0: Contain and reproduce

| Issues | Work | First action | Acceptance criteria |
| --- | --- | --- | --- |
| [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | Linux software-rendering white/transparent output | Reproduce Fedora/X11 + Intel i915 with `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` and `LIBGL_ALWAYS_SOFTWARE=1`; capture backend, EGL, DMA-BUF, and texture logs. | A supported configuration renders correctly, or the fallback documents a known limitation and emits actionable diagnostics. |
| [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | iOS 26 location prompt cannot close | Build a minimal permission page and test iOS 26 with scene transitions, popup presentation, and dismissal. | A reproducible callback/window path exists before changing shared permission code; add a device regression test if confirmed. |
| [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | iOS `onCreateWindow` result ignored | Reproduce `window.open` with a returned child WebView and record the `CreateWindowAction` lifecycle and target frame. | The returned child is attached or a structured unsupported result is delivered exactly once. |
| [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745), [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | Security claims around `eval()` and CWE-502 | Perform a source-to-sink review of generated JavaScript and native deserialization boundaries. | Each claim is either closed with evidence, or has a minimal security fix and regression test. Do not label either report a vulnerability from its title alone. |

### P1: Native stability and compatibility

#### Apple platforms

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707) | macOS browser-window crashes | Local teardown guard exists; run the macOS 11/Tahoe and Xcode 26 create/present/dismiss/release matrix before release closure. |
| [#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826), [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787), [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721) | Apple frame, keyboard viewport, and accessibility layout | Measure fractional platform-view frames, safe-area/inset changes, keyboard transitions, and display-size changes. Apply geometry fixes only after capturing before/after frames on iOS 17+ and macOS 11+. |
| [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619), [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584), [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654), [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636) | iOS/macOS JavaScript, popup, window-ID, startup, and disposal crashes | Run symbolicated tests for `evaluateJavaScript`, `callAsyncJavaScript`, `windowId`, popup navigation, and dispose/recreate. Check frame/content-world initialization and main-actor ownership. Merge only targeted fixes with source-level regression coverage. |
| [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723), [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720), [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713), [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727), [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598), [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568), [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570), [#2577](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2577) | iOS interaction, resume, headers, autofill, and focus behavior | Create one matrix for iOS 15–26, Flutter 3.38.6/current stable, ListView/Drawer/modal transitions, local HTML resume, form autofill, and navigation headers. Separate Flutter-engine regressions from plugin channel behavior. |

#### Android

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594) | System WebView crashes and implementation-specific casts | Local malformed-list fallback exists; run the Android provider/API matrix and retain validation evidence. |
| [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697), [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688), [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680), [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659) | Android renderer, multi-window, startup, network, and input regressions | Test API 19/21/23/29/35/36, low-memory devices, OEM WebViews, lock/resume, multi-window, mobile data, HTML input, and repeated navigation. Add only reproducible lifecycle guards or fallback paths. |
| [#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814), [#2797](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2797), [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711), [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709) | Multi-window, activity result, plugin registration, and path-handler lifecycle | Trace attach/detach/reattach and activity result ownership. Verify channel registration is idempotent and path handlers reject invalid/traversal input. |
| [#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783), [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717), [#2577](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2577) | Android/Windows input, cookies, scroll, and client-certificate callbacks | Build focused channel tests for nullable callbacks and native ownership, then run physical-device/desktop integration tests. Do not broaden callback payloads without platform-interface updates. |

#### Windows and Linux

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2778](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2778), [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752), [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615), [#2807](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2807) | Native startup and renderer failures | Reproduce on Arch Linux/WPE and affected Windows machines with full native logs. Test create/destroy/recreate, graphics-context invalidation, bundled/system WPE, and WebView2 runtime versions. |
| [#2736](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2736), [#2735](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2735), [#2692](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2692), [#2682](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2682), [#2642](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2642) | Windows focus, transparency, hit testing, and release behavior | Add a Windows native smoke matrix for focus, minimize/restore, transparent backgrounds, Google Sheets menus, and release packaging. Verify C++ child-window state after every async callback. |
| [#2732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2732), [#2590](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2590) | Screenshot/video and missing-plugin behavior | Reproduce with hardware video frames and generated plugin registrants. Define whether the native backend can capture video surfaces; otherwise return a documented unsupported result instead of a black image or missing method. |

### P1: Build, packaging, and release gates

| Issues | Plan | Exit criterion |
| --- | --- | --- |
| [#2839](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2839), [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830), [#2820](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2820), [#2672](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2672) | Reproduce MSVC `/await`, Xcode 26, CMake, and Windows/Linux warning failures on the supported toolchain. Pin or conditionally gate toolchain-specific settings. | Clean debug/release builds and actionable diagnostics on the supported matrix; unsupported toolchains fail with a clear prerequisite message. |
| [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796), [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757), [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685), [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2691](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2691) | Stabilize generated Pigeon/build artifacts, pub.dev analysis, Java 17/Flutter deprecation warnings, and release JAR synchronization. | `flutter analyze`, `pana`/publish dry-run, Android release build, and all generated metadata checks pass without package-owned warnings. |
| [#2815](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2815), [#2788](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2788), [#2695](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2695), [#2686](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2686), [#2682](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2682) | Triage vague initialization, Windows warning/release, network, Safari, and packaging reports | Require a reproducible command, environment, and stack trace. Close as host/application-specific in the local log when no package path exists. |

### P2: API and feature decisions

These items must not be implemented by copying an upstream PR directly. Each one changes a public contract or has platform capability differences.

| Issue | Requested capability | Design step | Implementation boundary |
| --- | --- | --- | --- |
| [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846) | AGP 9 built-in Kotlin | Finish the migration tracked in [the Android plan](android-kotlin-kts-migration-plan.md) after the Flutter `>=3.47.0` toolchain decision. | Android Gradle files, examples, CI, namespace/registrant checks, and release builds. |
| [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834) | Sec-CH-UA and Client Hints control | Confirm which headers the native engines permit and document that browser/WebView policy may override them. | Per-platform settings only where supported; no false cross-platform guarantee. |
| [#2811](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2811) | WebAssembly support | Define whether this means browser WASM compilation, embedded WASM execution, or a native backend requirement. | Reproduce with a minimal WASM page before changing plugin code; likely a support/documentation item. |
| [#2805](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2805) | Windows WebView2 `ProxyController` | Audit the existing platform-interface proxy contract and WebView2 proxy APIs. | Windows native implementation, capability checks, proxy reset, and process-lifetime tests. |
| [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793) | Typed `bridgeEvents` API | Define event ordering, backpressure, payload typing, and compatibility with current JavaScript handlers. | Additive platform-interface API, all bridge implementations, generated metadata, and integration tests. |
| [#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760) | Windows pull-to-refresh without a scrollbar | Confirm WebView2 gesture support and whether this is a plugin overlay or native capability. | Windows-only capability with an explicit unsupported fallback. |
| [#2712](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2712) | DNS-level request blocking | Define whether URL/resource interception is sufficient; do not promise DNS control from an iframe/WebView callback. | Threat model, platform feasibility decision, and documentation before API work. |
| [#2706](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2706) | H5 input-operation interception | Convert the vague request into a concrete DOM event/API and test case. | JavaScript bridge only after security and event-volume review. |
| [#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690) | Apple Intelligence Writing Tools | Confirm public WebKit/UIKit API availability and deployment targets. | iOS/macOS settings only if a stable native API exists. |
| [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) | Android Payment Request / Google Pay | Validate Android WebView feature availability, permissions, and app/browser requirements. | Android feature check, callback contract, and a real-device integration test. |

### P3: Low-detail and product backlog

These records remain listed so they are not lost, but they should not consume implementation time before P0/P1 work has evidence:

`#2824`, `#2821`, `#2804`, `#2798`, `#2795`, `#2753`, `#2742`, `#2741`, `#2730`, `#2702`, `#2681`, `#2667`.

For each P3 item, first add the platform, OS/runtime version, minimal reproduction, expected behavior, actual behavior, and native stack trace to the triage record. A title-only report is not enough for a shared implementation change.

Showcase records [#2822](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2822), [#2769](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2769), and [#2716](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2716) remain community/product references and are excluded from engineering completion metrics.

## Validation-only release gates

These issues are not open implementation tasks, but their fixes or mitigations are not release-complete until the target runtime is exercised:

| Platform | Records | Required evidence |
| --- | --- | --- |
| Android | [#2873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2873), [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875), [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878), [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555), [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791), [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728), [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594) | Real-device fullscreen/IME, cold-start AOT, interception timeout, cookies, Android 10 IME, provider cast payloads, Android 15/16 artifact, and 16 KB APK/AAB evidence. |
| iOS/macOS | [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880), [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762), [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867), [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707) | Scene activation, iOS 15+ gestures/insets, popup JavaScript, iOS 26 fullscreen, macOS browser-window teardown, and physical-device WebKit/AppKit evidence. |
| Windows/Linux | [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733), [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789), [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780), [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) | Affected Windows create/destroy/exit matrix, WebView2 asset tree, minimized hit testing, WPE 2.0/1.x build matrix, and Linux backend diagnostics. |
| Web | [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | Same-origin navigation/history and cross-origin URL privacy browser integration tests. |

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

## Implementation sequence

### Phase 0: Reproduction and test harness

- Add issue-specific test case names and environment fields to the example/test runner.
- Create Android, iOS/macOS, Windows, Linux, and Web matrices without changing behavior.
- Capture native logs, WebView/WebKit/WPE versions, composition mode, Flutter version, and platform lifecycle events.
- Mark each record `reproduced`, `not reproduced`, `host-specific`, or `needs reporter data`.

### Phase 1: P0 containment

- Complete the Linux software-rendering reproduction and security source-to-sink review.
- Reproduce iOS location prompt and `onCreateWindow` behavior before modifying shared callbacks.
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

The 2026-08-08 source-validation pass addressed #2856/#2737, hardened Android allow-list parsing for #2698/#2673/#2594, made macOS popup registry cleanup unconditional for #2707, guarded Android renderer callback type boundaries for #2697, reviewed the existing iOS presenter guard for #2831, made Android activity-result dispatch mutation-safe for #2814/#2797/#2711/#2709, guarded Windows resize teardown for #2736, added the Linux software-rendering switch for #2861, rejected unattached iOS popup creation for #2763, rejected Android popup creation without a live manager for #2763, guarded Android client-certificate callback ownership for #2782/#2783, guarded iOS custom-scheme callback ownership for #2619, guarded Windows headless controller lifetime for #2778, hardened iOS cookie property decoding for #2600, validated iOS WebMessageListener payloads for #2584, made Android startup callback cleanup idempotent for #2697, hardened Android WebStorage origin decoding for #2717, validated iOS navigation channel payloads for #2654, completed Android compat callback guards plus iOS load-file argument validation, added macOS custom-scheme plus Android navigation ownership guards, hardened iOS proxy payload decoding, guarded Android Chrome callbacks plus iOS WebMessageChannel operations, guarded Android file chooser callbacks, and validated macOS WebStorage cleanup payloads. The count is now 75 resolved or mitigated issue records and 50 remaining records; #2745 remains open pending security evidence.

An issue leaves this plan only when:

1. The original scenario has a minimal regression test or a documented host/platform limitation.
2. The fix is implemented in the owning federated package and preserves channel/API contracts.
3. Affected native builds and tests pass on the target platform.
4. Device, browser engine, WebView, WebKit, WPE, or artifact validation is recorded separately from static tests.
5. The package changelog, [`known-issues.md`](known-issues.md), and this plan reflect the final status.
