# Known Issues and Upstream Triage

Last reviewed: 2026-08-06

Source: the provided `issues.csv` snapshot and the [flutter_inappwebview issue tracker](https://github.com/pichillilorenzo/flutter_inappwebview/issues). The CSV is a metadata/title export and contains 125 rows, all marked `OPEN`: 98 bugs, 16 enhancements, 3 showcase entries, and 8 records without a label. All 125 rows were screened; promoted items use the issue body and local code evidence where available. Only issues with a plausible effect on stability, security, compatibility, or release documentation are promoted below. Issue status and platform behavior can change, so each item should be rechecked before implementation.

The confidence labels below describe the evidence available during this review:

- **Confirmed path**: the report is consistent with a concrete code path in this repository.
- **Strong report**: the report contains a reproducible scenario and useful native/platform evidence, but the root cause still needs a regression test.
- **Needs reproduction**: the symptom is important, but the report does not yet contain enough evidence to safely change the implementation.

## Recommended order

| Priority | Issues | Reason |
| --- | --- | --- |
| Resolved | [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848), [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700) | Android 2.0.2 keeps universal file-URL access disabled at the native boundary; migrate local resources to a controlled origin. |
| Resolved | [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) | Android 2.0.2 coordinates provider startup and platform-view attach before bridge/document-start registration. |
| Resolved | [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878), [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) | Android 2.0.2 restores the Flutter IME connection after fullscreen exit and keeps the renderer/surface fallback. |
| Mitigated | [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733) | Windows 1.0.2 removes static WinRT/Composition release during DLL unload and guards the reported Dart lifecycle races; affected-machine native creation still needs Windows validation. |
| Fixed | [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) | Android 1.0.4 bounds interception/cookie waits and avoids IME calls against detached views. |
| Fixed | [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791) | Android 1.0.4 preserves native HTTP/HTTPS main-frame navigation context when the Dart policy allows it. |
| P2 | [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880), [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762) | iOS lifecycle and Flutter-engine compatibility gaps that should be handled before the next platform transition. |
| P2 | [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728) | Android Play/target-SDK compatibility requirements can block releases or create policy warnings. |
| P2 | [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) | Cross-platform navigation, keyboard/scroll, and fullscreen behavior affects user-visible functionality. |
| P2 | [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872), [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861) | OEM-specific UI, Linux installation/rendering, and Windows local-file compatibility issues. |
| Monitor | [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) | iOS/Xcode-specific memory failure with insufficient symbolicated evidence. |

## Detailed findings

### #2873 — Restrict `FileProvider` paths

**Status:** Resolved in commit `9eaa2b791`. **Impact:** Security finding; no crash is required for this to matter. **Confidence:** Confirmed path.

The broad external-storage mapping has been removed from `flutter_inappwebview_forge_android/android/src/main/res/xml/provider_paths.xml`. The provider now exposes only the app-owned `Captures/` directory through `external-files-path`, plus the legacy public `Pictures/` and `Movies/` directories used on pre-N Android releases.

```xml
<external-files-path name="app_captures" path="Captures/"/>
<external-path name="pictures" path="Pictures/"/>
<external-path name="movies" path="Movies/"/>
```

The Android test suite covers all three mappings and asserts that the broad `path="."` mapping is absent. Android’s [FileProvider security guidance](https://developer.android.com/privacy-and-security/risks/file-providers) remains the reference for future path additions.

### #2875 — Windows crash on an unknown WebView2 permission resource

**Status:** Fixed in release 2.0.1 (platform interface 1.0.1). **Impact:** Process-level crash on a normal website permission request. **Confidence:** Confirmed path.

WebView2 can provide a permission resource ID that this package does not know yet. In `flutter_inappwebview_forge_platform_interface/lib/src/types/permission_request.g.dart`, `PermissionResourceType.fromNativeValue(e)` is nullable, but the generated conversion force-unwraps the result. Issue [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875) reports resource ID `13` reaching this path and crashing a Windows application.

This was a forward-compatibility bug: the WebView2 enum can grow independently of the Dart enum. The exchangeable-object generator now filters only unsupported values from non-null enum collections, so known permission resources remain usable while a newly introduced native value is ignored. The same generated behavior is applied consistently to the other exchangeable enum collections.

The platform-interface regression test parses a request containing a known camera resource and native value `13`; it verifies that parsing succeeds and retains the known resource. The platform-interface analyzer and full test suite pass. A Windows native build still needs to be run on Windows before release.

### #2856 — Android `null` values cast to non-null `String`

**Status:** Fixed in release 2.0.1 (Android 1.0.2). **Impact:** Runtime crash after upgrading to the 6.2 beta line. **Confidence:** Confirmed path.

Issue [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856) reports `type 'Null' is not a subtype of type 'String'`. The Android event handlers currently read platform-channel values as non-null strings, for example `origin` and `resources` in `InAppWebViewController`’s `onPermissionRequest` handler, and `url` in the safe-browsing handler. Native WebView callbacks can omit or change optional fields across OS/WebView versions.

The Android Dart event dispatcher now validates nullable `origin` and `url` values before constructing non-null public types, filters malformed permission-resource entries, and uses an empty title for a context-menu item when Android omits its optional title. Missing data in geolocation, permission, and safe-browsing callbacks returns control to the native default behavior. Regression coverage exercises the reported null title and representative nullable callback payloads.

### #2878 — Keyboard remains unavailable after exiting HTML5 fullscreen

**Status:** Fixed in release 2.0.2 (Android 1.0.3); validate on the affected Samsung/WebView combinations. **Impact:** The soft keyboard stops opening throughout the host app until the app is backgrounded/resumed or restarted. **Confidence:** Strong report.

The issue reproduces after `onShowCustomView`/`onHideCustomView` fullscreen cycles with hybrid composition. The native path removes the custom view, restores system UI/orientation, invokes `onExitFullscreen`, and clears fullscreen state in `InAppWebViewChromeClient.onHideCustomView()`. The repository also has custom IME proxy/focus handling in `InputAwareWebView.kt`. Together, this points to an IME/window association that is not restored when the fullscreen view is detached.

The reported workaround is invoking Flutter’s `TextInput.show` after exiting fullscreen, but that only masks the native lifecycle problem. The Forge implementation now retains the Flutter container view for hybrid composition and, after custom-view removal, requests focus and restarts the input connection on that actual Flutter view. The existing non-hybrid input proxy is reset as part of the same path.

**Remaining validation:** run a real-device regression covering fullscreen → exit → text input in a different Flutter widget, especially Samsung One UI and WebView 150+.

### #2819 — MediaTek fullscreen surface failure leaves a frozen WebView

**Status:** Fixed in release 2.0.1 (Android 1.0.2). **Impact:** On affected MediaTek devices, a GPU/gralloc failure during fullscreen video can remove the native surface without firing the normal exit/error callbacks. The screen then remains black/white and fullscreen state is stale. **Confidence:** Strong report.

Issue [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) includes native gralloc errors and reports that neither `onExitFullscreen`, `onRenderProcessGone`, nor `onReceivedError` is delivered. This is a different failure mode from a normal `onHideCustomView` callback: cleanup must also be robust when the renderer or surface disappears first.

`FlutterWebView.dispose()` now checks the fullscreen state before destroying the WebView, asks the chrome client to remove the custom view, and emits the exit callback/state reset fallback if the activity or custom-view callback is already unavailable. The fallback is guarded by the fullscreen flag so normal exits notify Dart only once. A MediaTek device test with network loss during H.264/HLS playback is still required before release.

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

**Status:** Fixed in release 2.0.2 (Android 1.0.3); retain real-device and release/AOT validation. **Impact:** A headless WebView can crash with `Must be started before we block!`; a release/AOT build can also fail to fire `onWebViewCreated` on roughly half of cold starts. **Confidence:** Strong report; the relevant synchronous initialization path is present in the repository.

Issue [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) identifies `WebViewCompat.addDocumentStartJavaScript` being called before the Chromium engine is ready. In the review baseline, `InAppWebView.prepare()` synchronously registered the JavaScript bridge and called `prepareAndAddUserScripts()`, while `UserContentController` invoked `addDocumentStartJavaScript` directly. Issue [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) additionally reports that this synchronous platform-view work can prevent the Dart platform-view-created callback from arriving in release builds when the JavaScript bridge is enabled.

This is directly relevant to the dependency update: the issue proposes the stable asynchronous startup API from `androidx.webkit:webkit:1.16.0`, but that would require a `minSdk` decision because this package still declares `minSdkVersion 19` and currently uses WebKit `1.14.0`.

**Implementation:** the Android plugin now requests AndroidX WebKit’s asynchronous provider startup at engine attach, waits for that callback before headless bridge/document-start registration, defers regular platform-view registration until Flutter attaches the view, retries transient script-registration failures, and waits for registration before the first load. The WebKit dependency remains `1.14.0` so the package can keep its `minSdkVersion 19`; do not upgrade to 1.16.0 without deciding whether the minimum SDK can change. **Remaining validation:** test HeadlessInAppWebView and release/AOT cold starts on real Android devices.

### #2848 and #2700 — universal access from file URLs

**Status:** Fixed in release 2.0.2 (Android 1.0.3). **Impact:** Security risk if enabled for untrusted or mixed local content. **Confidence:** Confirmed setting path.

The repository previously applied `allowUniversalAccessFromFileURLs` directly to `WebSettings` during WebView setup and when settings changed. Issues [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848) and [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700) are the same security theme: universal file-URL access can weaken origin isolation and was flagged by security assessments.

The Android Forge implementation now preserves the Dart setting for federated API compatibility but ignores `true` at the native boundary, so the deprecated setter cannot be reached. The public setting documentation explains this Android behavior and recommends `WebViewAssetLoader`/controlled app origins for local resources. Applications that intentionally depended on universal file access must migrate to a controlled origin.

### #2840 and #2733 — Windows native lifetime crashes

**Status:** Mitigated in release 2.0.3 (Windows 1.0.2); run the affected-machine native matrix before calling the creation crash fully resolved. **Impact:** Process termination during WebView creation or application shutdown. **Confidence:** Strong reports; #2733 has a confirmed static lifetime path, while #2840 still needs an affected Windows machine for native confirmation.

Issue [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840) reports deterministic `MSVCP140.dll` access violations during `InAppWebView` creation on affected machines. Issue [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733) reports an exit-time access violation while static WinRT Composition objects are destroyed. The repository has a process-wide static compositor in `InAppWebViewManager`, so creation and shutdown deserve a shared native lifetime audit.

The Forge Windows implementation now keeps shared WinRT/Composition pointers out of static RAII destruction, tracks the last live manager, detaches shared resources before DLL teardown, and shuts down the dispatcher queue without releasing process-lifetime objects during unload. The Dart custom platform view also checks `mounted` after async initialization and `RenderBox.attached` after awaits before reporting size or position.

**Remaining validation:** reproduce #2840 with the reported WebView2/VC runtime matrix and run create/destroy/recreate/exit tests on Windows.

### #2580, #2718, and #2555 — Android blocking callback and lifecycle failures

**Status:** Fixed in release 2.0.3 (Android 1.0.4); retain Android 10 and rapid-navigation device validation. **Impact:** WebView deadlock/freeze, cookie-cleanup ANR, or Android 10 IME crash. **Confidence:** Strong report for #2580/#2718; #2555 is an older device-specific crash.

For [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), the native `shouldInterceptRequest` path can synchronously wait for a Dart result through `Util.invokeMethodAndWaitResult`, which posts to the main looper and then blocks on a latch. This is a plausible deadlock when WebView resource callbacks and UI-thread work depend on each other. [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) shows a Play Console native trace through `MyCookieManager.deleteAllCookies`, where `removeAllCookies` is followed immediately by `flush`. [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) reports an `InputMethodManager` null crash on Android 10 and is related to the same general focus/lifecycle surface as #2878.

The Forge implementation now caps concurrent synchronous resource-interception callbacks at two and uses a 250 ms callback timeout for this path; saturated or timed-out requests fall back to normal WebView loading. Android cookie deletion no longer calls the blocking `flush()` immediately after asynchronous removal, and the input-aware WebView requires both the container and target views to have an attached window/token before touching the IME connection.

**Remaining validation:** run rapid back/forward navigation with `shouldInterceptRequest`, Play Console cookie-clear scenarios, and Android 10 text-input tests on physical devices.

### #2791 — `shouldOverrideUrlLoading` breaks browsing context

**Status:** Fixed in release 2.0.3 (Android 1.0.4); validate popup/payment and cancellation behavior on Android WebView versions in the release matrix. **Impact:** Payment and popup flows can lose `window.opener`, `Referer`, and `Sec-Fetch-Site` even when Dart returns `NavigationActionPolicy.ALLOW`. **Confidence:** Confirmed path.

Issue [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791) identifies the Android interception pattern: the original navigation is cancelled, then `allowShouldOverrideUrlLoading()` starts a new `loadUrl()`. The repository contained that same path in both `InAppWebViewClient.kt` and `InAppWebViewClientCompat.kt`. A new navigation cannot preserve all browser context from the cancelled one.

The Forge Android client now lets HTTP/HTTPS main-frame navigations continue through WebView when the Dart policy returns `ALLOW`, so the original browsing context remains intact. If Dart returns `CANCEL`, the current native navigation is stopped when its navigation token is still current. Non-HTTP(S) schemes retain the asynchronous reload path needed by the existing API contract.

**Remaining validation:** add a device integration test covering `window.opener`, `Referer`, `Sec-Fetch-Site`, POST navigation, and cancellation.

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
