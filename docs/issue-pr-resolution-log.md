# Issue and PR Resolution Log

Last reviewed: 2026-11-21

This document records the issue and pull-request exports supplied for the Forge maintenance work and relates them to the implementation already present in this repository.

## How to read this log

- The supplied `issues.csv` snapshot contains 125 issue records. Every exported issue has state `OPEN` because that is the upstream state at export time.
- The supplied `pr.csv` snapshot contains 73 PR records. Every exported PR has state `OPEN` for the same reason.
- `OPEN` in the export is not evidence that the local Forge implementation is unfixed. Local status is based on code, regression tests, changelogs, and the commit history in this repository.
- The CSV files contain title-level metadata only. They do not contain merge commits, review decisions, issue bodies, or complete issue-to-PR relationships.
- Where a PR clearly matches an issue by title or adjacent report, the relationship is listed. Otherwise the issue and PR are kept as separate records rather than inferred as a false one-to-one mapping.
- “Fixed”, “mitigated”, and “validation pending” describe the local implementation boundary. They do not change upstream GitHub state.

The detailed root-cause notes are in [known-issues.md](known-issues.md). Package release notes are in the root and platform `CHANGELOG.md` files.

## Status

Current counts and the status of every record are in
[runtime-validation-pending.md](runtime-validation-pending.md#current-counts)
and [open-work-plan.md](open-work-plan.md). Root cause, fix, and evidence are
in [known-issues.md](known-issues.md). This log is only an index of local
changes by date; it does not repeat their details.

## Local resolution history

| Date | Change | Upstream record | Release |
| --- | --- | --- | --- |
| 2026-11-22 | iOS popups fail closed for named content worlds; legacy async wrapper fix; Android public `FileProvider` paths removed; #2914-#2934 triaged ([details](known-issues.md#2026-11-22-upstream-hardening-prs-2914-2934-and-popup-content-worlds)) | PR #2931, #2932 | Unreleased (runtime pending) |
| 2026-11-22 | Windows: WebView2 closed before its host window at application quit; plugin messenger detached at teardown ([details](known-issues.md#2026-11-22-windows-teardown-at-application-quit-2884-2956-2957)) | #2884, PR #2956 (already covered), PR #2957 | Unreleased (runtime pending) |
| 2026-11-22 | Opt-in `enableAccessibilityFocus`: keyboard and screen reader focus into and out of the page on macOS and Windows ([details](known-issues.md#2026-11-22-keyboard-and-screen-reader-focus-on-macos-and-windows-2952-2953)) | PRs #2952, #2953 | Unreleased (runtime pending) |
| 2026-11-21 | `JavaScriptHandlerJsonResult`; handler results parsed with `JSON.parse` instead of run as code ([details](known-issues.md#2026-11-21-pre-encoded-json-handler-results-2948)) | PR #2948 | Unreleased (runtime pending) |
| 2026-11-21 | JavaScript dialogs always answered on Android; `enableNativePromptDialog` setting ([details](known-issues.md#2026-11-21-javascript-dialog-answers-and-native-prompt-control-2901)) | PR #2901 | Unreleased (runtime pending) |
| 2026-11-21 | Android `takeScreenshot` off the UI thread, `cancellationSignal`, `drawScaled`, `usePixelCopy` ([details](known-issues.md#2026-11-21-android-screenshot-encoder-cancellation-and-pixelcopy-2909-2911)) | PR #2909, #2910, #2911 | Unreleased (runtime pending) |
| 2026-11-21 | JavaScript panels always answered (iOS, macOS) and Android `takeScreenshot` compress/bitmap fixes ([details](known-issues.md#2026-11-21-javascript-panel-answers-and-android-screenshot-robustness-2943-2908)) | PR #2943, #2908 | Unreleased (runtime pending) |
| 2026-11-21 | iOS, macOS, and root package require Flutter 3.41.0 for the SwiftPM `FlutterFramework` dependency ([details](known-issues.md#2026-11-21-apple-swiftpm-flutter-341-baseline-2951)) | [#2951](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2951) | Unreleased |
| 2026-11-21 | Windows MSVC 18 conformance fixes ([details](known-issues.md#2026-11-21-windows-msvc-18-conformance-2936-2937)) | PR #2936, #2937 | Unreleased |
| 2026-11-21 | Linux and Windows CMake plugin target name fix ([details](known-issues.md#2026-11-21-linux-and-windows-cmake-plugin-target-name)) | Forge-only | Unreleased |
| 2026-11-21 | Post-export upstream triage: Android, iOS/macOS, Linux, Windows, Web, and platform interface fixes ([details](known-issues.md#2026-11-21-post-export-upstream-triage-2884-2958)) | #2893, #2896, #2940, #2945, #2955, PR #2898, #2900, #2912, #2913, #2938, #2954 | Unreleased |
| 2026-11-21 | iOS fullscreen video after seek moved back to the open plan (failed physical iOS run) | [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | - |
| 2026-11-13 | Xcode 27 / Swift 6.4 iOS and macOS build fix | [Forge #2](https://github.com/emirkanacar/flutter_inappwebview/issues/2) | root 2.1.78, iOS 2.1.36, macOS 1.1.11 |
| 2026-11-13 | Android example build directory | [Forge PR #1](https://github.com/emirkanacar/flutter_inappwebview/pull/1) (not merged; fixed on master) | example only |
| 2026-11-13 | Web `Sandbox.ALLOW_ALL` iframe sandbox | - | Web 1.0.5 |
| 2026-08-21 | Native WebView API gaps follow-up | - | root 2.1.77, platform-interface 1.1.22, Android 1.0.56, iOS 2.1.35, Windows 1.0.15 |
| 2026-08-21 | Native WebView API gaps | - | root 2.1.76, platform-interface 1.1.21, Android 1.0.55, iOS 2.1.34, macOS 1.1.10 |
| 2026-08-21 | Deprecated compatibility inventory | - | root 2.1.75, platform-interface 1.1.20, Android 1.0.54 |
| 2026-08-21 | iOS 27 `canOpenURL` deprecation [#2882](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2882) | - | iOS 2.1.33, root 2.1.74 |
| 2026-08-21 | Pub.dev lints_core static analysis | [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757) | root 2.1.73, platform-interface 1.1.19 |
| 2026-08-21 | Flutter web WASM compilation | [#2811](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2811) | platform-interface 1.1.18, Web 1.0.4, root 2.1.72 |
| 2026-08-13 | Universal Link navigation policy | [#2866](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2866) | - |
| 2026-08-10 | Android file chooser private-sandbox URI | [#2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243) | Android 1.0.41 |
| 2026-08-12 | Android audio capture file chooser | [#2823](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2823) | Android 1.0.44 |
| 2026-08-12 | Android WebAuthn support setting | [#2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743) | Android 1.0.45, platform-interface 1.1.5 |
| 2026-08-12 | Android Payment Request / Google Pay | [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) | Android 1.0.46, root 2.1.54, platform-interface 1.1.6 |
| 2026-08-12 | Android Sec-CH-UA and Client Hints customization | [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834) | Android 1.0.47, platform-interface 1.1.7, root 2.1.55 |
| 2026-08-12 | Android AGP 9 built-in Kotlin compatibility | [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846) | Android 1.0.48, root 2.1.56 |
| 2026-08-12 | iOS platform-view focus recovery | [#2853](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2853) | iOS 2.1.25 |
| 2026-08-10 | Android cookie mutation ANR [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | - | Android 1.0.42 |
| 2026-08-11 | Android explicit cookie flush completion [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | - | Android 1.0.43 |
| 2026-08-11 | Android cold-start and startup reattach [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) | [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) | Android 1.0.38 |
| 2026-08-09 | iOS/macOS Xcode authentication availability [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830) | [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809) | iOS 2.1.19, macOS 1.1.6 |
| 2026-08-10 | Android interception freeze and cookie ANR [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | - | - |
| 2026-08-09 | Android interception dispatch hardening [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | [#2773](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2773) (closed, not merged) | Android 1.0.31 |
| 2026-08-09 | Android rapid-navigation JavaScript injection OOM [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | - | Android 1.0.34 |
| 2026-08-10 | Android fullscreen exit keyboard restoration [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878) | - | Android 1.0.34 |
| 2026-08-10 | iOS popup/window-ID crashes [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | - | - |
| 2026-08-08 | iOS header replacement navigation [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | - | - |
| 2026-08-11 | iOS 26 fullscreen and geolocation behavior [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | - | - |
| 2026-08-10 | iOS keyboard `visualViewport` restoration [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860) addresses the separate #2859 inset regression | iOS 2.1.20 |
| 2026-08-08 | iOS draggable overlay gesture ownership [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598) | - | - |
| 2026-08-08 | iOS Password AutoFill ownership [#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570) | - | - |
| 2026-08-08 | iOS navigation decision/load ordering [#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568) | - | - |
| 2026-08-08 | iOS Simulator dyld failure [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636) | - | - |
| 2026-08-08 | Android HTML time input picker crash [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659) | - | - |
| 2026-08-08 | iOS modal-sheet gesture lifecycle [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727) | - | - |
| 2026-08-08 | iOS Drawer/WebView touch lifecycle [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713) | - | - |
| 2026-08-08 | iOS ListView/NestedScrollView gesture lifecycle [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723) | - | - |
| 2026-08-08 | iOS/Android localhost server liveness [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720) | - | - |
| 2026-08-08 | Android display-size WebView geometry [#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721) | - | - |
| 2026-08-09 | Android activity-extra deserialization [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | - | Android 1.0.33 |
| 2026-08-10 | iOS popup default handling [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | - | - |
| 2026-08-12 | Android Firebase Auth missing initial state [#2815](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2815) | - | - |
| 2026-08-12 | Typed JavaScript bridge events and handlers [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793) | - | platform-interface 1.1.8, root 2.1.57 |
| 2026-08-12 | Android 16/OEM text-selection resource crash [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868) | - | Android 1.0.49 |
| 2026-08-08 | Linux no-GL buffer path [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | - | - |
| 2026-08-08 | JavaScript evaluation source review [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | - | - |
| 2026-08-10 | iOS geolocation availability correction [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | - | - |
| 2026-08-08 | macOS fractional platform-view frame sync [#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826) | - | - |
| 2026-08-09 | Android nullable and malformed callback payloads [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856); Web iframe URL tracking [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | - | - |
| 2026-08-08 | Android provider-specific setting casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594); macOS browser-window teardown [#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707) | - | - |
| 2026-08-08 | Android renderer callback boundary [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); iOS location prompt lifecycle [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) | - | - |
| 2026-08-10 | Android InAppBrowser activity-result ownership [#2797](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2797) | - | - |
| 2026-08-10 | Android internal-storage path-handler recursion [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709) | - | - |
| 2026-08-10 | iOS missing-plugin `goBack` report [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711) | - | - |
| 2026-08-12 | Windows child-window teardown [#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814) | - | - |
| 2026-08-12 | Windows Visual Studio 2026/MSVC 14.5x build compatibility [#2839](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2839) | [#2869](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2869) | Windows 1.0.9 |
| 2026-08-12 | Windows WebView2 resize/teardown access violation [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752) | - | Windows 1.0.10 |
| 2026-08-08 | Windows resize teardown [#2736](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2736) | - | - |
| 2026-08-08 | Linux rendering fallback [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861); iOS popup lifecycle [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | - | - |
| 2026-08-08 | Android popup lifecycle [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763); JavaScript security claim [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) | - | - |
| 2026-08-08 | Android callback ownership [#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783) | - | - |
| 2026-08-08 | iOS custom scheme ownership [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619); Windows headless teardown [#2778](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2778) | - | - |
| 2026-08-08 | Internal iOS cookie property decoding; Android startup callback lifetime | - | - |
| 2026-08-08 | Internal iOS WebMessageListener payloads; internal iOS WebMessageChannel payloads | - | - |
| 2026-08-08 | iOS 18.4 Simulator startup crash [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584) | - | - |
| 2026-08-08 | iOS popup `windowId` lifetime hardening [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | - | - |
| 2026-08-08 | Android WebStorage callback entries [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717); internal iOS navigation payload validation | - | - |
| 2026-08-08 | Android compatibility callback ownership [#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783); internal iOS load-file payload validation | - | - |
| 2026-08-08 | macOS custom scheme ownership [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619); Android navigation ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697) | - | - |
| 2026-08-08 | Android page lifecycle ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); iOS proxy payloads [#2805](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2805) | - | - |
| 2026-08-08 | Android Chrome callback ownership [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697); internal iOS WebMessageChannel payloads | - | - |
| 2026-08-08 | Android file chooser callback ownership [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783); macOS WebStorage payloads [#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717) | - | - |
| 2026-08-08 | Linux GL runtime fallback [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | - | - |
| 2026-08-08 | Android provider `forceDarkStrategy` casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594) | - | - |
| 2026-08-10 | iOS/Android disposal crash [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | - | - |
| 2026-08-10 | Android 10 IME lifecycle crash [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | - | - |
| 2026-08-08 | Android System WebView renderer termination [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698) | - | - |
| 2026-08-09 | Android screen-transition flicker [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688) | - | - |
| 2026-08-10 | Android fullscreen renderer/surface cleanup [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) | - | Android 1.0.35 |
| 2026-08-09 | Android mobile-data audio provider boundary [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680) | - | - |
| 2026-08-09 | iOS iframe subresource error callback boundary [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753) | - | - |
| 2026-08-09 | Android Pigeon build attribution [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796) | - | - |
| 2026-08-10 | Android deprecation-warning compatibility boundary [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685) | [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817) | Android 1.0.40 |
| 2026-08-09 | Android release JAR gate review [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687) | - | - |
| 2026-08-09 | Pub.dev Pana analysis compatibility [#2757](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2757) | [#2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758) | - |
| Local release | Issue/report scope | Related PR records | - |
| --- | --- | --- | - |
| 2.1.77 / Android 1.0.56 / iOS 2.1.35 / Windows 1.0.15 / platform-interface 1.1.22 | Native WebView API gaps follow-up | - | - |
| 2.1.76 / Android 1.0.55 / iOS 2.1.34 / macOS 1.1.10 / platform-interface 1.1.21 | Native WebView API gaps | - | - |
| 2.1.75 / Android 1.0.54 / platform-interface 1.1.20 | Deprecated compatibility inventory | - | - |
| 2.1.74 / iOS 2.1.33 | iOS 27 `canOpenURL` deprecation [#2882](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2882) | - | root 2.1.74, ios 2.1.33 |
| 2.1.48 / Android 1.0.43 | Android cookie mutation ANR [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) | - | - |
| 2.1.40 / Android 1.0.37 | Android nullable and malformed permission callback payloads [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856) | [#2857](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2857) | - |
| 2.1.39 / iOS 2.1.22 | iOS popup `EXC_BAD_ACCESS` and async callback ownership [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776) | - |
| 2.1.38 / iOS 2.1.21 / Android 1.0.36 | iOS/Android WebView disposal and pending async JavaScript callbacks [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654) | No direct PR relationship was present in the export | - |
| 2.1.37 / iOS 2.1.20 | iOS keyboard `visualViewport` restoration [#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860) addresses the separate #2859 inset regression | root 2.1.37, ios 2.1.20 |
| 2.1.35 / Android 1.0.34 | Android interception and rapid-navigation OOM [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580) | - | root 2.1.35, android 1.0.34 |
| 2.1.34 / Android 1.0.33 | Android activity-extra deserialization [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536); Android release JAR gate [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687) | - | root 2.1.34, android 1.0.33 |
| 2.1.33 | Android deprecation warning batch 1 [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685) | [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817) | root 2.1.33, android 1.0.32 |
| 2.1.31 | iOS/macOS WebAuthenticationSession Xcode availability [#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830) | [#2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809) | root 2.1.31, ios 2.1.19, macos 1.1.6 |
| 2.1.29 | Android `forceDarkStrategy` provider casts [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594); iOS/Android disposal [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654); Android IME lifecycle [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | No direct PR relationship was present in the export | root 2.1.29, android 1.0.29, ios 2.1.18 |
| 2.0.0 | iOS AppDelegate window access and SPM requests: [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880), [#2842](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2842), [#2841](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2841) | No direct PR relationship was present in the export | - |
| 2.0.1 | FileProvider paths [#2873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2873), unknown WebView2 permission values [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875), nullable Android callbacks [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856), fullscreen renderer cleanup [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) | [#2874](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2874), [#2876](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2876), [#2857](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2857) | - |
| 2.0.2 | Android universal file access [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848), [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700); cold-start races [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843); fullscreen keyboard [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878) | [#2844](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2844) | - |
| 2.0.3 | Windows lifetime crashes [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733); Android interception/cookie/IME reports [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555); navigation context [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791) | [#2838](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2838), [#2614](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2614), [#2558](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2558) | - |
| 2.0.4 | iOS keyboard inset [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), Flutter gesture baseline [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762), Android 15 API warnings [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728) | [#2860](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2860), [#2729](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2729) | - |
| 2.0.5 | Samsung selection UI [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), Linux WPE symbol compatibility [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780), Windows minimized overlay [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789) | [#2781](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2781), [#2790](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2790) | - |
| 2.0.6 | Android 16 KB artifacts [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), Linux build prerequisites [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), Windows `loadFile` [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) | [#2829](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2829) | - |
| 2.0.7 | Web stale iframe URL [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737), iOS popup crash path [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | [#2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776), [#2792](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2792) | - |
| 2.1.2 | iOS nil-frame evaluation [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), iOS pre-iOS 18 async JavaScript [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), Android WebMessageListener fallback [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474) | [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771), [#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871), [#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474) | - |
| 2.1.1 | macOS custom context menu [#2855](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2855), Android screen-lock redraw [#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837), iOS/macOS PrintJS semicolon [#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879), iOS console serialization [#2850](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2850), Android WebView background color [#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863), Apple authentication headers [#2835](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2835), Windows page zoom [#2812](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2812), macOS presentation anchor [#2813](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2813), Windows title lookup [#2725](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2725), macOS API availability [#2741](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2741), Android ProGuard configuration [#2852](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2852), and iOS 26 fullscreen video [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | [#2683](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2683), [#2851](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2851), [#2864](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2864), [#2836](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2836), [#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879) | - |

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
