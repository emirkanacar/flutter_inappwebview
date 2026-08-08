# Runtime Validation Pending

Last reviewed: 2026-08-08

This register contains issue records whose local implementation or mitigation
is complete, but whose target device, provider, browser, native runtime, or
release artifact has not yet been exercised. These records are not active
implementation work and are excluded from the counts in
[open-work-plan.md](open-work-plan.md). Their root-cause notes and acceptance
details remain in [known-issues.md](known-issues.md).

## Current counts

| Local status | Issue records | Count | Meaning |
| --- | --- | ---: | --- |
| Locally implemented or mitigated; runtime validation pending | Issue register below | 65 | Source, regression, and host/build checks pass; real validation remains. |
| Closed by source review | [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | 1 | No plugin-owned security sink was found; no package runtime test is required. |
| Open implementation or reproduction | [open work plan](open-work-plan.md) | 59 | No complete local implementation boundary has been established. |
| **Issue export total** | 125 | **125** | Historical export count; upstream `OPEN` state is unchanged. |

Three PR-only records also have local implementations but remain outside the
125-issue count: [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771),
[#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), and
[#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474).

### Count by exported category

| Category | Export | Runtime pending | Source-review closed | Still open | Technical open after showcase |
| --- | ---: | ---: | ---: | ---: | ---: |
| Bugs | 98 | 51 | 1 | 46 | 46 |
| Enhancements | 16 | 6 | 0 | 10 | 10 |
| Unlabelled | 8 | 8 | 0 | 0 | 0 |
| Showcase | 3 | 0 | 0 | 3 | 0 |
| **Total** | **125** | **65** | **1** | **59** | **56** |

## Issue register

The following 65 issue records have moved out of the active implementation
queue. They remain release gates until the required real validation is
recorded:

`#2536`, `#2555`, `#2580`, `#2584`, `#2594`, `#2600`, `#2619`, `#2654`,
`#2673`, `#2697`, `#2698`, `#2700`, `#2703`, `#2707`, `#2709`, `#2710`,
`#2711`, `#2717`, `#2718`, `#2721`, `#2725`, `#2728`, `#2733`, `#2736`, `#2737`,
`#2741`, `#2762`, `#2763`, `#2778`, `#2780`, `#2782`, `#2783`, `#2789`,
`#2791`, `#2797`, `#2805`, `#2812`, `#2813`, `#2814`, `#2819`, `#2826`, `#2831`,
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
4. Do not change or comment on the upstream GitHub issue state as part of
   these local transitions.
