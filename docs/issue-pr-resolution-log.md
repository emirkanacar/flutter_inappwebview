# Issue and PR Resolution Log

Last reviewed: 2026-08-06

This document records the issue and pull-request exports supplied for the Forge maintenance work and relates them to the implementation already present in this repository.

## How to read this log

- The supplied `issues.csv` snapshot contains 125 issue records. Every exported issue has state `OPEN` because that is the upstream state at export time.
- The supplied `pr.csv` snapshot contains 73 PR records. Every exported PR has state `OPEN` for the same reason.
- `OPEN` in the export is not evidence that the local Forge implementation is unfixed. Local status is based on code, regression tests, changelogs, and the commit history in this repository.
- The CSV files contain title-level metadata only. They do not contain merge commits, review decisions, issue bodies, or complete issue-to-PR relationships.
- Where a PR clearly matches an issue by title or adjacent report, the relationship is listed. Otherwise the issue and PR are kept as separate records rather than inferred as a false one-to-one mapping.
- “Fixed”, “mitigated”, and “validation pending” describe the local implementation boundary. They do not change upstream GitHub state.

The detailed root-cause notes are in [known-issues.md](known-issues.md). Package release notes are in the root and platform `CHANGELOG.md` files.

## Local resolution history

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
| 2.1.0 | iOS console serialization [#2850](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2850), Android WebView background color [#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863), Apple authentication headers [#2835](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2835), Windows page zoom [#2812](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2812), macOS presentation anchor [#2813](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2813), Windows title lookup [#2725](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2725), and iOS 26 fullscreen video [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | [#2851](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2851), [#2864](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2864), [#2836](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2836) | iOS console objects/Errors retain useful data, Android exposes an Android-only native background-color API, Apple authentication sessions support additional headers, Windows maps page zoom to WebView2, macOS prefers the active presentation window, and Windows title lookup is protected by regression assertions. The fullscreen change remains a targeted WebKit mitigation and still needs device validation. |

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
