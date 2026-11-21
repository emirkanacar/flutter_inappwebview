# Open Work Plan

Last reviewed: 2026-11-21

Active implementation and reproduction backlog: only records with no complete
local implementation. Implemented records that still need device, provider,
browser, or artifact evidence are in
[`runtime-validation-pending.md`](runtime-validation-pending.md). Root cause
and evidence for every record are in [`known-issues.md`](known-issues.md).

## Counts

The `issues.csv` / `pr.csv` export has 125 issues and 73 PRs. Every export row
is `OPEN`; that is historical metadata, not the local status.

| Category | Export | Runtime pending | No runtime gate | Source-review closed | Host/platform boundary | Active open |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Bugs | 98 | 56 | 1 | 1 | 15 | 25 |
| Enhancements | 16 | 13 | 0 | 0 | 0 | 3 |
| Unlabelled | 8 | 8 | 0 | 0 | 0 | 0 |
| Showcase | 3 | 0 | 0 | 0 | 0 | 3 |
| **Total** | **125** | **77** | **1** | **1** | **15** | **31** |

The status lists behind these columns are in the
[runtime register](runtime-validation-pending.md#current-counts). Showcase
records are excluded from engineering metrics (28 active technical records).

## Status rules

- **P0:** crash, security, data-loss, or deadlock risk. Reproduce or add a safe guard before feature work.
- **P1:** confirmed runtime, lifecycle, build, or release problem.
- **P2:** needs a public API, platform capability, or product decision.
- **P3:** low-detail, duplicate, environment-specific, or unconfirmed report.
- **Runtime pending:** source, regression, and host/build checks pass; target runtime evidence is missing. Lives in the runtime register.
- **Host/platform boundary:** the failure belongs to an external runtime, provider, or host app with no package-owned control point. Not a local fix.
- **Locally resolved:** acceptance criteria, regression coverage, native build, and runtime (or documented host-limitation) evidence all pass. A source-only patch is not enough.

## Priority queue

### P0

None open.

### P1: Native stability

| Issues | Work package | Plan |
| --- | --- | --- |
| [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615), [#2807](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2807) | Linux/Windows startup and renderer failures | Reproduce on Arch Linux/WPE and affected Windows machines with native logs. Test create/destroy/recreate, graphics-context loss, bundled/system WPE, and WebView2 runtime versions. |
| [#2735](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2735), [#2692](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2692), [#2682](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2682), [#2642](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2642), [#2577](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2577) | Windows focus, transparency, hit testing, release behavior | Windows smoke matrix for focus, minimize/restore, transparent backgrounds, Google Sheets menus, and release packaging. Check child-window state after every async callback. |
| [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | iOS fullscreen video after seek | Back from the runtime register: the 2026-08-12 physical iOS run got `request=null` after seek and no `onEnterFullscreen`, failing the first cycle (Simulator passes 3/3). Reproduce on a physical iOS 26 device with native logs, then fix or classify as a WebKit/GPU boundary. |
| [#2590](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2590) | Missing plugin | Reproduce with generated registrants. #2732 (video screenshot) is resolved ([details](known-issues.md#2026-11-22-android-screenshot-of-a-playing-video-2732)). |
| [#2950](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2950), [#2889](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2889), [#2904](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2904), [#2939](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2939) | Post-export reports: Android hybrid-composition repaint, Linux dispose crash, Impeller black screen | Device reproduction before changing layer type or teardown order. Windows teardown (#2884) moved to the runtime register. #2950, #2889, #2939: not reproduced on a Samsung Android 17 device (2026-11-21). Details in [known-issues](known-issues.md#2026-11-21-post-export-upstream-triage-2884-2958). |

### P1: Build and release gates

| Issues | Plan | Exit criterion |
| --- | --- | --- |
| [#2820](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2820), [#2672](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2672) | Reproduce Xcode 26, CMake, and Windows/Linux warning failures; pin or gate toolchain-specific settings. | Clean debug/release builds on the supported matrix; unsupported toolchains fail with a clear message. |
| [#2691](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2691) | Stabilize the remaining Windows build-warning and release-artifact path. | Analyze, publish dry-run, release build, and metadata checks pass without package-owned warnings. |
| [#2788](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2788), [#2695](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2695), [#2686](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2686) | Triage vague initialization, warning, network, Safari, and packaging reports. | A reproducible command, environment, and stack trace, or a host-specific classification. |

### P2: API decisions

Do not copy an upstream PR directly; each item changes a public contract.

| Issue | Request | Next step |
| --- | --- | --- |
| [#2712](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2712) | DNS-level request blocking | Decide whether URL/resource interception is enough; do not promise DNS control. Threat model before API work. |
| [#2706](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2706) | H5 input-operation interception | Turn the request into a concrete DOM event/API and test case; security and event-volume review first. |

### P3: Needs reporter data

`#2824`, `#2821`, `#2804`, `#2798`, `#2795`, `#2742`, `#2730`, `#2702`,
`#2681`, `#2667`. Before any work, record platform, OS/runtime version,
minimal reproduction, expected and actual behavior, and a native stack trace.

Showcase: [#2822](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2822),
[#2769](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2769),
[#2716](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2716).

## PR queue

The PR export is also `OPEN`; check the current Forge source before reusing
any of these.

| Work package | Related PRs |
| --- | --- |
| Linux rendering/build | [#2881](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2881) (EGL re-import; evidence for #2861, not merged), [#2832](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2832), [#2829](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2829) |
| iOS/macOS crashes and APIs | [#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879), [#2870](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2870), [#2836](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2836), [#2828](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2828), [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809), [#2671](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2671) |
| Cross-platform stability | [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817), [#2756](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2756), [#2722](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2722) |
| Windows stability/API | [#2869](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2869), [#2838](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2838), [#2806](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2806), [#2786](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2786), [#2768](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2768), [#2708](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2708) |
| Web and JavaScript bridge | [#2794](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2794), [#2792](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2792), [#2715](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2715), [#2495](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2495) |
| Toolchain and migration | [#2575](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2575), [#2574](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2574) |

PRs already implemented locally (#2243, #2474, #2743, #2758, #2771, #2823,
#2825, #2853, #2866, #2871, #2901, #2909-#2911, #2948, #2952, #2953) are tracked in the runtime register.

## Leaving this plan

An issue moves to the runtime register when:

1. The scenario has a failing-then-passing regression test or a documented host/platform limitation.
2. The fix is in the owning package and keeps channel/API contracts.
3. Affected native builds and source tests pass.
4. The missing runtime gate is listed in the runtime register.
5. The changelog, `known-issues.md`, and the runtime register agree.

A failed runtime gate moves the issue back here with the failing environment.
