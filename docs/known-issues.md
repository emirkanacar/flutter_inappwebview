# Known Issues and Upstream Triage

Last reviewed: 2026-08-05

Source: the provided `issues.csv` snapshot and the [flutter_inappwebview issue tracker](https://github.com/pichillilorenzo/flutter_inappwebview/issues). The CSV is a metadata/title export and contains 125 rows, all marked `OPEN`: 98 bugs, 16 enhancements, 3 showcase entries, and 8 records without a label. All 125 rows were screened; promoted items use the issue body and local code evidence where available. Only issues with a plausible effect on stability, security, compatibility, or release documentation are promoted below. Issue status and platform behavior can change, so each item should be rechecked before implementation.

The confidence labels below describe the evidence available during this review:

- **Confirmed path**: the report is consistent with a concrete code path in this repository.
- **Strong report**: the report contains a reproducible scenario and useful native/platform evidence, but the root cause still needs a regression test.
- **Needs reproduction**: the symptom is important, but the report does not yet contain enough evidence to safely change the implementation.

## Recommended order

| Priority | Issues | Reason |
| --- | --- | --- |
| P0 | [#2873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2873) | Security hardening: the `FileProvider` currently exposes the entire external storage root. |
| P0 | [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848), [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700) | Security review: universal file-URL access is exposed as a WebView setting and can weaken origin isolation. |
| P1 | [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) | Android cold-start initialization can crash or prevent `onWebViewCreated` from firing in release builds. |
| P1 | [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875), [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856) | Runtime crashes caused by forward-incompatible native values and nullable platform-channel payloads. |
| P1 | [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878), [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) | Android fullscreen failures can leave the app-wide keyboard or the WebView surface unusable. |
| P1 | [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733) | Windows native lifetime failures can terminate the process during WebView creation or shutdown. |
| P1 | [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | Android callback blocking, cookie cleanup, and IME lifecycle paths have freeze/ANR/crash reports. |
| P1 | [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791) | Navigation interception can destroy `window.opener`, referrer, and payment-popup flows. |
| P2 | [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880), [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762) | iOS lifecycle and Flutter-engine compatibility gaps that should be handled before the next platform transition. |
| P2 | [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728) | Android Play/target-SDK compatibility requirements can block releases or create policy warnings. |
| P2 | [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | Cross-platform navigation, keyboard/scroll, and fullscreen behavior affects user-visible functionality. |
| P2 | [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872), [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | OEM-specific UI, Linux installation/rendering, and Windows local-file compatibility issues. |
| Monitor | [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | iOS/Xcode-specific memory failure with insufficient symbolicated evidence. |

## Detailed findings

### #2873 — Restrict `FileProvider` paths

**Impact:** Security finding; no crash is required for this to matter. **Confidence:** Confirmed path.

The issue identifies this current configuration in `flutter_inappwebview_forge_android/android/src/main/res/xml/provider_paths.xml`:

```xml
<external-path name="external_files" path="."/>
```

This grants the provider a broad external-storage root instead of only the files the plugin needs to share. Android’s [FileProvider security guidance](https://developer.android.com/privacy-and-security/risks/file-providers) recommends exposing the smallest possible directory set. The plugin uses the provider for download/file-chooser flows, so this is a shared security boundary rather than an isolated test configuration.

**Recommended action:** identify the exact download and chooser paths, replace the root mapping with narrow `cache-path`/`external-files-path` mappings, and add tests proving that files outside those directories cannot be shared. Verify upgrade behavior for applications that already depend on the current provider authority.

### #2875 — Windows crash on an unknown WebView2 permission resource

**Impact:** Process-level crash on a normal website permission request. **Confidence:** Confirmed path.

WebView2 can provide a permission resource ID that this package does not know yet. In `flutter_inappwebview_forge_platform_interface/lib/src/types/permission_request.g.dart`, `PermissionResourceType.fromNativeValue(e)` is nullable, but the generated conversion force-unwraps the result. Issue [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875) reports resource ID `13` reaching this path and crashing a Windows application.

This is a forward-compatibility bug: the WebView2 enum can grow independently of the Dart enum. An unknown permission should not take down the host application.

**Recommended action:** filter unknown values or preserve them as an explicit `unknown` value; keep the known resources usable; add a platform-interface regression test with an unknown numeric resource ID. Audit other generated enum conversions for the same force-unwrap pattern.

### #2856 — Android `null` values cast to non-null `String`

**Impact:** Runtime crash after upgrading to the 6.2 beta line. **Confidence:** Confirmed path.

Issue [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856) reports `type 'Null' is not a subtype of type 'String'`. The Android event handlers currently read platform-channel values as non-null strings, for example `origin` and `resources` in `InAppWebViewController`’s `onPermissionRequest` handler, and `url` in the safe-browsing handler. Native WebView callbacks can omit or change optional fields across OS/WebView versions.

**Recommended action:** define nullability at the platform-channel boundary, validate payloads before constructing public types, and test missing `origin`, `url`, `title`, and enum fields. This should be treated as a compatibility fix, not only as an application-side workaround.

### #2878 — Keyboard remains unavailable after exiting HTML5 fullscreen

**Impact:** The soft keyboard stops opening throughout the host app until the app is backgrounded/resumed or restarted. **Confidence:** Strong report.

The issue reproduces after `onShowCustomView`/`onHideCustomView` fullscreen cycles with hybrid composition. The native path removes the custom view, restores system UI/orientation, invokes `onExitFullscreen`, and clears fullscreen state in `InAppWebViewChromeClient.onHideCustomView()`. The repository also has custom IME proxy/focus handling in `InputAwareWebView.java`. Together, this points to an IME/window association that is not restored when the fullscreen view is detached.

The reported workaround is invoking Flutter’s `TextInput.show` after exiting fullscreen, but that only masks the native lifecycle problem.

**Recommended action:** add a native cleanup/reattachment path for the input connection after custom-view removal, make it safe when callbacks are skipped, and add an Android regression test covering fullscreen → exit → text input in a different Flutter widget.

### #2819 — MediaTek fullscreen surface failure leaves a frozen WebView

**Impact:** On affected MediaTek devices, a GPU/gralloc failure during fullscreen video can remove the native surface without firing the normal exit/error callbacks. The screen then remains black/white and fullscreen state is stale. **Confidence:** Strong report.

Issue [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) includes native gralloc errors and reports that neither `onExitFullscreen`, `onRenderProcessGone`, nor `onReceivedError` is delivered. This is a different failure mode from a normal `onHideCustomView` callback: cleanup must also be robust when the renderer or surface disappears first.

**Recommended action:** detect WebView/surface disposal while fullscreen, restore the host view and notify Dart exactly once, and test the path on MediaTek hardware with network loss during H.264/HLS playback.

### #2880 — iOS UIScene migration

**Impact:** Future iOS SDK/lifecycle changes can leave the plugin without a valid window or prevent launch. **Confidence:** Confirmed path for legacy API usage; future impact.

Issue [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880) calls out legacy `UIApplication.shared.delegate?.window` access. The Forge implementation now replaces those lookups with an active-scene key-window helper, registers the plugin with Flutter's scene lifecycle delegate, and raises the iOS minimum to 15.0. Flutter’s [UIScene migration guide](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) documents the same plugin migration contract.

**Recommended action:** keep the scene-aware implementation, document the minimum Flutter/iOS versions, and add an iOS multi-scene regression test to the release matrix.

### #2762 — Flutter engine gesture conflict on older Flutter versions

**Impact:** iOS taps can be ignored or pass through the WebView on Flutter versions before the engine fix. **Confidence:** Strong report with an external dependency cause.

The root and iOS packages now declare `flutter: ">=3.38.0"`, while issue [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762) identifies the fix as landing in Flutter 3.38.6. The remaining platform packages should be aligned before a single package-wide Flutter minimum is advertised.

**Recommended action:** either raise the minimum Flutter version or add an explicit compatibility warning and a tested `gestureRecognizers` workaround. Keep this separate from plugin-only gesture fixes because the underlying conflict is in the Flutter engine.

### #2868 — Samsung One UI custom selection toolbar renders `false`

**Impact:** Visible Android text-selection UI corruption on Samsung One UI when the custom context menu is used. **Confidence:** Strong report; code path confirmed.

The custom action-mode implementation in `InAppWebView.java` clears the native menu and rebuilds it as Flutter/plugin UI. It converts every native item title with `menuItem.getTitle().toString()` and renders it as a `TextView`. An OEM item that is icon-only or has a non-user-facing title can therefore appear as the literal string `false`. Hybrid composition avoids the custom toolbar in the reported configuration, but has a performance cost.

**Recommended action:** preserve native icon/visibility semantics when rebuilding items, or expose a setting to use the platform toolbar. Add a Samsung One UI regression test matrix.

**Relation to the reported `Resources$NotFoundException`:** the supplied crash also enters `InAppWebView.startActionMode` through Chromium’s selection popup. It is not proof that #2868 has the same root cause, but both symptoms make the custom action-mode path a high-value shared investigation target. The Samsung issue is a UI rendering defect; the supplied stack is a resource lookup failure.

### #2862 — Linux WPE WebKit build prerequisites are easy to miss

**Impact:** Ubuntu builds fail during CMake configuration when WPE WebKit development packages are absent or expose an unexpected `pkg-config` name. **Confidence:** Confirmed build requirement.

`flutter_inappwebview_forge_linux/linux/CMakeLists.txt` intentionally searches for WPE WebKit and stops with a fatal error when no supported package is found. Issue [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862) shows that this is not obvious on newer Ubuntu installations.

**Recommended action:** add a distro/version prerequisite matrix to the Linux README and CI, include the exact package names and `pkg-config` checks, and make the CMake error point to the backend-specific installation document (`WPE_BACKEND.md`).

### #2861 — Linux Intel/X11 GPU fallback can render white or transparent

**Impact:** On Fedora/X11 with Intel i915, the default DMA-BUF/EGL path can show a black screen; disabling GL can result in a white/transparent but interactive view. **Confidence:** Needs reproduction; reporter supplied a plausible rendering-path analysis.

The reported workaround combines `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` with `LIBGL_ALWAYS_SOFTWARE=1`, which forces a software/SHM-style path but may have a substantial performance cost.

**Recommended action:** document the workaround and its performance trade-off, add a diagnostic log identifying the selected rendering backend, and reproduce on supported Fedora/X11/Intel combinations before changing the default renderer.

### #2872 — Windows `loadFile` and WebView2 file-origin semantics

**Impact:** `loadFile("assets/.../index.html")` can produce an unusable page because local subresources are blocked under the `file:` origin. **Confidence:** Needs reproduction; implementation mismatch is visible.

The Windows implementation resolves the Flutter asset to `data/flutter_assets/...` and passes the filesystem path to WebView2 `Navigate`. Issue [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) reports that the resulting `file:` page has a unique security origin and cannot load the expected resources.

**Recommended action:** reproduce with a minimal asset tree and clarify the API contract. If local assets are supported, use an app-controlled virtual origin/resource mapping or an equivalent controlled loader; if not, correct the Windows documentation and return an actionable error.

### #2867 — iOS/Xcode-specific `EXC_BAD_ACCESS` in multi-window navigation

**Impact:** Potential native crash during `window.open`/multi-window flows. **Confidence:** Needs reproduction.

Issue [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) reports different behavior across Xcode 16/26 and iOS 18/26, but the report does not include a usable symbolicated stack trace. The affected flow also overrides JavaScript evaluation and manages a second WebView, so changing the shared evaluation API without a minimal reproducer would be risky.

**Recommended action:** request a symbolicated crash, exact Xcode/SDK/Flutter/plugin matrix, and a minimal multi-window sample. Then audit WebView/controller lifetime and callback ownership before making an iOS code change.

## Additional findings from the full CSV review

### #2849 and #2843 — Android cold-start initialization race

**Impact:** A headless WebView can crash with `Must be started before we block!`; a release/AOT build can also fail to fire `onWebViewCreated` on roughly half of cold starts. **Confidence:** Strong report; the relevant synchronous initialization path is present in the repository.

Issue [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) identifies `WebViewCompat.addDocumentStartJavaScript` being called before the Chromium engine is ready. In the review baseline, `InAppWebView.prepare()` synchronously registered the JavaScript bridge and called `prepareAndAddUserScripts()`, while `UserContentController` invoked `addDocumentStartJavaScript` directly. Issue [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) additionally reports that this synchronous platform-view work can prevent the Dart platform-view-created callback from arriving in release builds when the JavaScript bridge is enabled.

This is directly relevant to the dependency update: the issue proposes the stable asynchronous startup API from `androidx.webkit:webkit:1.16.0`, but that would require a `minSdk` decision because this package still declares `minSdkVersion 19` and currently uses WebKit `1.14.0`.

**Phase 1 implementation:** platform-view bridge/script registration and the first load are now ordered through `View.post()`, activity-free headless WebViews retain a direct path, and document-start registration failures are logged instead of crashing. **Remaining validation:** test HeadlessInAppWebView and release/AOT cold starts on real Android devices; do not upgrade to WebKit 1.16.0 without deciding whether the minimum SDK can change.

### #2848 and #2700 — universal access from file URLs

**Impact:** Security risk if enabled for untrusted or mixed local content. **Confidence:** Confirmed setting path; security impact requires an explicit use-case review.

The repository applies `allowUniversalAccessFromFileURLs` directly to `WebSettings` during WebView setup and when settings change. Issues [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848) and [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700) are the same security theme: universal file-URL access can weaken origin isolation and was flagged by security assessments.

**Recommended action:** identify which supported feature actually needs this setting, keep it disabled by default, document the risk when explicitly enabled, and prefer `WebViewAssetLoader`/controlled app origins for local resources. Treat the two issues as one security work item rather than two independent fixes.

### #2840 and #2733 — Windows native lifetime crashes

**Impact:** Process termination during WebView creation or application shutdown. **Confidence:** Strong reports; exact root cause needs native repro.

Issue [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840) reports deterministic `MSVCP140.dll` access violations during `InAppWebView` creation on affected machines. Issue [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733) reports an exit-time access violation while static WinRT Composition objects are destroyed. The repository has a process-wide static compositor in `InAppWebViewManager`, so creation and shutdown deserve a shared native lifetime audit.

**Recommended action:** reproduce with matching Windows/WebView2/VC runtime matrices, remove process-lifetime COM objects where possible, and make teardown explicit before DLL detach. Add create/destroy/recreate/exit tests rather than relying only on Dart `dispose` tests.

### #2580, #2718, and #2555 — Android blocking callback and lifecycle failures

**Impact:** WebView deadlock/freeze, cookie-cleanup ANR, or Android 10 IME crash. **Confidence:** Strong report for #2580/#2718; #2555 is an older device-specific crash.

For [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), the native `shouldInterceptRequest` path can synchronously wait for a Dart result through `Util.invokeMethodAndWaitResult`, which posts to the main looper and then blocks on a latch. This is a plausible deadlock when WebView resource callbacks and UI-thread work depend on each other. [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) shows a Play Console native trace through `MyCookieManager.deleteAllCookies`, where `removeAllCookies` is followed immediately by `flush`. [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) reports an `InputMethodManager` null crash on Android 10 and is related to the same general focus/lifecycle surface as #2878.

**Recommended action:** make resource interception non-blocking or bounded by timeout, ensure null/default responses do not hold WebView threads, serialize cookie operations and completion callbacks, and harden IME calls against detached `ViewRootImpl` state.

### #2791 — `shouldOverrideUrlLoading` breaks browsing context

**Impact:** Payment and popup flows can lose `window.opener`, `Referer`, and `Sec-Fetch-Site` even when Dart returns `NavigationActionPolicy.ALLOW`. **Confidence:** Confirmed path.

Issue [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791) identifies the Android interception pattern: the original navigation is cancelled, then `allowShouldOverrideUrlLoading()` starts a new `loadUrl()`. The repository contains that same path in both `InAppWebViewClient.java` and `InAppWebViewClientCompat.java`. A new navigation cannot preserve all browser context from the cancelled one.

**Recommended action:** allow native HTTP(S) navigation to continue when the Dart policy is `ALLOW`, or provide a documented compatibility mode that explicitly trades context preservation for header rewriting. Add a popup/payment regression test covering `window.opener` and request headers.

### #2703 and #2728 — Android release-policy compatibility

**Impact:** Store compliance warnings or installation/runtime compatibility failures on newer Android targets. **Confidence:** Needs validation against the package’s produced AAB.

Issue [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703) tracks Android 16 KB page-size support, while [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728) reports Android 15 deprecated edge-to-edge/status-bar APIs in Play Console. These are release blockers even when the WebView appears to work locally, and they can come from Flutter or transitive native artifacts rather than this package alone.

**Recommended action:** add AAB inspection to CI for 16 KB alignment and Android 15 API warnings, identify whether the warnings originate in this package, Flutter, or Chrome Custom Tabs, and document the minimum Flutter/AGP/target SDK matrix.

### #2859, #2710, #2831, and #2763 — iOS keyboard, fullscreen, prompt, and multi-window behavior

**Impact:** User-visible iOS regressions: scrolling can stop before the bottom after keyboard dismissal, fullscreen video can turn black/unresponsive, location prompts may not close, and `onCreateWindow` results can be ignored. **Confidence:** Strong symptoms; several are likely iOS/WebKit/Flutter-version dependent.

The local iOS implementation has explicit keyboard-driven negative `contentInset` compensation in `InAppWebView.swift`, making [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859) a concrete regression target. [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) reports the same fullscreen family as the Android fullscreen issues but through the iOS WebKit/GPU path. [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) and [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) need OS/SDK-specific reproductions before changing shared navigation or permission code.

**Recommended action:** maintain an iOS matrix for Flutter, Xcode, iOS, keyboard, fullscreen, and multi-window flows; add targeted regression tests around content insets and callback completion; avoid presenting these as one common root cause until each has a minimal reproducer.

### #2737 — Web platform reports stale navigation URLs

**Impact:** Applications cannot reliably track the current page on the web platform. **Confidence:** Strong report; source path needs a browser test.

Issue [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) reports that iframe-based `onLoadStart`, `onLoadStop`, `onProgressChanged`, and `getUrl()` continue to expose the initial URL after navigation. The web element currently forwards URLs from its iframe event bridge, so this should be tested with redirects, history navigation, and cross-origin pages rather than assumed to be an Android/iOS parity problem.

**Recommended action:** add a web integration test that compares iframe `location`, event payloads, and `getUrl()` after navigation; document any cross-origin limitation if the browser sandbox prevents a fully reliable value.

### #2789 and #2780 — Windows overlay and Linux WPE compatibility

**Impact:** A minimized Windows WebView can continue intercepting desktop clicks; Linux builds can fail against WebKit versions below 2.50. **Confidence:** Strong report for #2789; confirmed compile-risk path for #2780.

Issue [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789) is a reproducible platform-view hit-test/overlay regression after minimizing a Windows app. Issue [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780) matches an unguarded `webkit_web_view_get_theme_color` call in the Linux C++ source, which can cause an undefined-reference failure on older WPE WebKit versions.

**Recommended action:** test Windows composition/input hit-testing across minimize/restore, and guard or feature-detect the Linux theme-color API while documenting the supported WPE version range.

### Security claims requiring validation before labeling as vulnerabilities

- [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) asks to replace JavaScript `eval()` with a secure alternative. The title alone does not establish an exploitable sink; validate the actual generated JavaScript and threat model first.
- [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) claims CWE-502 remote code execution, but repository search found no Java object deserialization API such as `ObjectInputStream`. Treat this as a likely scanner/application-context report until a source-to-sink path is supplied.

### Other crash and regression candidates retained for follow-up

These CSV entries are notable enough to keep in the engineering backlog, but their issue bodies do not yet justify a code change without a reproducible matrix: [#2855](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2855), [#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826), [#2778](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2778), [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752), [#2732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2732), [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723), [#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720), [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713), [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697), [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654), [#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619), [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615), [#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), and [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584). Duplicate cast reports [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673) and [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594) should be triaged together.

## Full CSV screening notes

The remaining CSV records were screened but not promoted to the incident-focused list because they are feature requests, showcases, duplicate/low-detail reports, or platform-specific warnings without enough evidence. Examples include SPM/Kotlin migration requests, WebAssembly support, proxy/payment-request features, page zoom/pull-to-refresh requests, showcase entries, and isolated build warnings. They should not be treated as evidence that the package itself is crashing until a reproducible package-level failure is available.

In particular, [#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863), [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846), [#2842](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2842), [#2835](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2835), [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834), [#2811](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2811), [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793), [#2769](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2769), [#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760), [#2712](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2712), [#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690), and [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) are not error-rate priorities.

## General engineering themes

1. Treat native platform values as versioned, nullable input. Avoid force-unwrapping enum conversions and unchecked `String` casts at the channel boundary.
2. Treat renderer, surface, fullscreen, and input lifecycles as independently failing state machines. Normal callbacks are not guaranteed during GPU or process failure.
3. Keep security-sensitive filesystem mappings least-privilege by default.
4. Publish a tested Flutter/OS/WebView/device compatibility matrix; dependency upgrades alone cannot resolve Flutter engine, OEM WebView, WebKit, or WPE backend regressions.
