# Open Work Plan

Last reviewed: 2026-08-08

This is the active implementation and reproduction backlog for work that is
not yet resolved in the local Forge repository. Locally implemented records
that still need real runtime evidence are tracked separately in
[`runtime-validation-pending.md`](runtime-validation-pending.md). The plan is
derived from the supplied `issues.csv` and `pr.csv` snapshots, the current
source tree, package changelogs, and [`known-issues.md`](known-issues.md).

## Scope and counts

The export contains 125 issues and 73 PRs. Seventy-two issue records have a
documented local implementation, mitigation, source-review, or host/platform
boundary: 66 await real runtime validation, #2745 is closed by source review,
and #2636/#2659/#2713/#2723/#2727 have no Forge-owned fix because their
failures belong to the Apple/WebKit Simulator, Android framework/provider, and
Flutter engine/platform-view layers respectively. The other 53 issue records
remain in this active plan. Three additional PR-only records
(`#2771`, `#2871`, and `#2474`) are implemented locally and await runtime
validation; they do not change the issue counts below.

| Category | Export | Runtime pending | Source-review closed | Host/platform boundary | Active open | Treatment |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Bugs | 98 | 52 | 1 | 5 | 40 | Technical work, validation, or reproduction required |
| Enhancements | 16 | 6 | 0 | 0 | 10 | API/design decision and implementation required |
| Unlabelled | 8 | 8 | 0 | 0 | 0 | Triage before implementation |
| Showcase | 3 | 0 | 0 | 0 | 3 | Product examples, not plugin engineering work |
| **Total issue records** | **125** | **66** | **1** | **5** | **53** | **50 active technical records after excluding showcase entries** |

The upstream export marks every record `OPEN`. That value is historical metadata; this plan uses local code evidence to decide whether a record is resolved, mitigated, validation-only, or still open.

## Status rules

- **P0 containment:** crash, security, data-loss, or deadlock risk. Reproduce or add a safe guard before feature work.
- **P1 stability:** confirmed runtime, lifecycle, build, or release compatibility problem.
- **P2 API/feature:** requires a public API, platform capability, or product decision.
- **P3 triage:** low-detail, duplicate, environment-specific, or unconfirmed report.
- **Runtime validation pending:** the local implementation, regression coverage, and host/build checks pass, but the target device, provider, browser engine, native runtime, or release artifact still needs real validation. These records live in [`runtime-validation-pending.md`](runtime-validation-pending.md), not in this active queue.
- **Host/platform boundary:** available evidence identifies an external runtime or provider failure with no package-owned control point. These records remain visible in [`known-issues.md`](known-issues.md) and the resolution log, but are not counted as local fixes or active implementation work.
- **Locally resolved:** the acceptance criteria, regression coverage, affected native build, and required device/runtime or documented host-limitation evidence all pass. A source-only patch is not enough.
- **Active open work:** no complete local implementation boundary has been established, or a runtime failure has returned the issue to implementation/reproduction.

## Local resolutions outside this plan

The 66 implementation or mitigation records awaiting real validation are
listed in [`runtime-validation-pending.md`](runtime-validation-pending.md),
along with the three PR-only records. They are resolved implementation work,
not active queue items, and therefore are excluded from the active counts
above. [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745)
is closed by source review and has no package runtime gate. Android [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721)
now has an idempotent native WebView geometry refresh for display-size changes
and visibility recovery; its Android 16/API 36 and OEM provider validation is
tracked in the runtime register.

iOS [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568)
now defers `loadUrl` calls made during `shouldOverrideUrlLoading` until the
WebKit navigation decision is released. Source/regression, SwiftPM, and Xcode
example validation pass; physical iOS navigation/header validation remains in
the runtime register.

The iOS compatibility work from PRs [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771) and [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), together with the Android compatibility work from PR [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474), is also implemented locally. These are PR-only export records rather than issue rows, so they are tracked in the resolution log and known-issues validation matrix instead of the issue counts above.

Their remaining device/build checks are included in the runtime register. Do
not reopen their implementation without new failing evidence.

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

## Priority queue

### P0: Contain and reproduce

No unresolved P0 implementation item is currently in the active queue. The
former P0 records, including [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831),
are locally implemented and awaiting real validation in the
[runtime register](runtime-validation-pending.md).

### P1: Native stability and compatibility

#### Apple platforms

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | Apple keyboard viewport and accessibility layout | Use the opt-in iOS diagnostic to capture WebKit viewport metrics and the Flutter WebView frame. The iOS 26.0 simulator build/baseline passes, but automated platform-view input did not open the software keyboard and iOS 17 is unavailable locally; obtain physical/iOS 17 frame, `contentInset`, and `adjustedContentInset` evidence before applying a geometry fix. |
| [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720), [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598), [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570), [#2577](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2577) | iOS interaction, resume, headers, autofill, and focus behavior | The shared localhost server liveness guard is source-validated; complete iOS release resume/restart/reload evidence is still required. Create one matrix for iOS 15–26, Flutter 3.38.6/current stable, ListView/modal transitions, local HTML resume, form autofill, and navigation headers. Keep #2713 and #2723 in the host/platform register and separate Flutter-engine regressions from plugin channel behavior. |

#### Android

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688), [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680) | Android renderer, multi-window, startup, and network regressions | Test API 19/21/23/29/35/36, low-memory devices, OEM WebViews, lock/resume, multi-window, mobile data, and repeated navigation. Add only reproducible lifecycle guards or fallback paths. |

#### Windows and Linux

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752), [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615), [#2807](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2807) | Native startup and renderer failures | Reproduce on Arch Linux/WPE and affected Windows machines with full native logs. Test create/destroy/recreate, graphics-context invalidation, bundled/system WPE, and WebView2 runtime versions. |
| [#2735](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2735), [#2692](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2692), [#2682](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2682), [#2642](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2642) | Windows focus, transparency, hit testing, and release behavior | Add a Windows native smoke matrix for focus, minimize/restore, transparent backgrounds, Google Sheets menus, and release packaging. Verify C++ child-window state after every async callback. |
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
| [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793) | Typed `bridgeEvents` API | Define event ordering, backpressure, payload typing, and compatibility with current JavaScript handlers. | Additive platform-interface API, all bridge implementations, generated metadata, and integration tests. |
| [#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760) | Windows pull-to-refresh without a scrollbar | Confirm WebView2 gesture support and whether this is a plugin overlay or native capability. | Windows-only capability with an explicit unsupported fallback. |
| [#2712](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2712) | DNS-level request blocking | Define whether URL/resource interception is sufficient; do not promise DNS control from an iframe/WebView callback. | Threat model, platform feasibility decision, and documentation before API work. |
| [#2706](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2706) | H5 input-operation interception | Convert the vague request into a concrete DOM event/API and test case. | JavaScript bridge only after security and event-volume review. |
| [#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690) | Apple Intelligence Writing Tools | Confirm public WebKit/UIKit API availability and deployment targets. | iOS/macOS settings only if a stable native API exists. |
| [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) | Android Payment Request / Google Pay | Validate Android WebView feature availability, permissions, and app/browser requirements. | Android feature check, callback contract, and a real-device integration test. |

### P3: Low-detail and product backlog

These records remain listed so they are not lost, but they should not consume implementation time before P0/P1 work has evidence:

`#2824`, `#2821`, `#2804`, `#2798`, `#2795`, `#2753`, `#2742`, `#2730`, `#2702`, `#2681`, `#2667`.

For each P3 item, first add the platform, OS/runtime version, minimal reproduction, expected behavior, actual behavior, and native stack trace to the triage record. A title-only report is not enough for a shared implementation change.

Showcase records [#2822](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2822), [#2769](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2769), and [#2716](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2716) remain community/product references and are excluded from engineering completion metrics.

## Runtime validation register

Runtime-pending records are resolved implementation work, not active queue
items. The complete register contains 66 issue records and three PR-only
records; counts, issue IDs, and platform gates are maintained in
[`runtime-validation-pending.md`](runtime-validation-pending.md). This plan
keeps only the 53 issue records that still need implementation, design, or
reproduction. Five host/platform boundaries are tracked above and are not
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

The 2026-08-08 status pass has 66 locally implemented or mitigated issue
records awaiting runtime validation, one issue (#2745) closed by source
review, five host/platform boundaries (#2636, #2659, #2713, #2723, and #2727), and 53 active issue
records in this plan. The runtime-pending records and host boundaries are
deliberately not counted as active implementation work; their status notes
live in [`runtime-validation-pending.md`](runtime-validation-pending.md) and
[`known-issues.md`](known-issues.md). The active queue contains 40 bugs, 10
enhancements, 0 unlabelled records, and 3 showcase records (50 active
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
