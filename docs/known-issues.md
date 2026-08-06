# Known Issues and Upstream Triage

Last reviewed: 2026-08-06

Source: the provided `issues.csv` snapshot and the [flutter_inappwebview issue tracker](https://github.com/pichillilorenzo/flutter_inappwebview/issues). The CSV is a metadata/title export and contains 125 rows, all marked `OPEN`: 98 bugs, 16 enhancements, 3 showcase entries, and 8 records without a label. All 125 rows were screened; promoted items below are explicitly classified as resolved locally, mitigated, validation-pending, or still requiring reproduction. The upstream `OPEN` value is retained as export metadata and must not be read as the current local implementation status.

The confidence labels below describe the evidence available during this review:

- **Confirmed path**: the report is consistent with a concrete code path in this repository.
- **Strong report**: the report contains a reproducible scenario and useful native/platform evidence, but the root cause still needs a regression test.
- **Needs reproduction**: the symptom is important, but the report does not yet contain enough evidence to safely change the implementation.

For the actionable backlog, priorities, work packages, and acceptance criteria, see the [open work plan](open-work-plan.md).

## Resolution summary

| Local status | Issues | Meaning |
| --- | --- | --- |
| Resolved in code | [#2873](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2873), [#2875](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2875), [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856), [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878), [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819), [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880), [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762), [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849), [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2848](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2848), [#2700](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2700), [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555), [#2791](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2791), [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789), [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780), [#2850](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2850), [#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863), [#2835](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2835), [#2812](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2812), [#2813](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2813), [#2725](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2725) | The local implementation contains the fix and focused regression coverage. Native/device/build validation is listed in the detailed entry when still required. |
| Mitigated locally | [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733), [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728), [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867), [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | A safe local behavior or targeted workaround exists, but the upstream/runtime boundary or final artifact still needs validation. |
| Open or needs reproduction | [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831), [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763), [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745), [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | No additional shared code change is justified from the available evidence. Reproduce on the affected platform or establish a source-to-sink path first. |

## Remaining validation and follow-up

| Priority | Issues | Reason |
| --- | --- | --- |
| Device/native validation | [#2840](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2840), [#2733](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2733), [#2878](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2878), [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819), [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789), [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867), [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) | The local fix exists; run the affected Windows, Android OEM, iOS/WebKit, or fullscreen matrix before declaring runtime behavior fully validated. |
| Build/artifact validation | [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780), [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) | Check the consuming Android AAB/APK, Linux WPE configurations, older WebKit builds, and Windows WebView2 asset trees. |
| Reproduction required | [#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831), [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) | Do not change shared rendering, prompt, or multi-window code without a platform-specific reproduction and diagnostic evidence. |
| Security claim validation | [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745), [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) | Validate the actual JavaScript/source-to-sink path and threat model before labeling either report as a package vulnerability. |

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

### #2850 — iOS console arguments lose object and Error data

**Status:** Fixed in iOS 2.1.1. **Impact:** `console.log` converted objects to `[object Object]` and omitted useful `Error` message/stack data. **Confidence:** Confirmed local JavaScript bridge path.

The iOS console plugin script now serializes object arguments with `JSON.stringify` and preserves `Error.stack` or the error name/message fallback. Primitive values retain their string representation, and serialization failures fall back safely instead of preventing the console callback. Source-level regression assertions cover object and Error handling.

### #2863 — Android native WebView background color

**Status:** Fixed in Android 1.0.8 and root 2.1.1. **Impact:** Applications could not change the native Android WebView background independently of the page content. **Confidence:** Confirmed API gap.

`InAppWebViewController.setBackgroundColor` is now exposed through the platform interface and root controller, with Android-only capability metadata. The Android implementation sends the color through the per-WebView channel and calls `View.setBackgroundColor`; missing or malformed values return structured platform errors. Android channel regression coverage and the plugin Kotlin compilation pass.

### #2835 — WebAuthenticationSession additional headers

**Status:** Fixed in iOS 2.1.1 and macOS 1.1.1. **Impact:** Authentication requests could not attach provider-specific HTTP headers on supported Apple OS versions. **Confidence:** Confirmed API capability.

`WebAuthenticationSessionSettings.additionalHeaderFields` is now available on iOS 17.4+ and macOS 14.4+. The native sessions apply the map only on OS versions exposing `ASWebAuthenticationSession.additionalHeaderFields` and report the effective values through real-settings inspection. Older Apple versions retain the existing behavior without attempting the unavailable API.

### #2812 — Windows WebView2 page zoom

**Status:** Fixed in Windows 1.0.5 and root 2.1.1. **Impact:** The shared `pageZoom` setting was unavailable on Windows even though WebView2 exposes a controller zoom factor. **Confidence:** Confirmed capability gap.

Windows now maps `InAppWebViewSettings.pageZoom` to `ICoreWebView2Controller.ZoomFactor` during creation and settings updates, and reads the effective factor from WebView2 in `getRealSettings`. Static Windows regression coverage checks both setter and getter paths.

### #2813 — macOS WebAuthenticationSession presentation anchor

**Status:** Fixed in macOS 1.1.1. **Impact:** Tahoe/Xcode authentication sessions could be presented from an invalid or stale window when the key window was not the first window returned by AppKit. **Confidence:** Confirmed lifecycle path.

The presentation anchor now prefers `NSApp.keyWindow`, then a visible main window, then any visible window, and finally an empty anchor. The fallback chain avoids force-unwrapping AppKit window state while preserving the existing macOS 10.15 availability boundary.

### #2725 — Windows WebView2 title lookup

**Status:** Fixed in Windows 1.0.5 and covered by Windows regression assertions. **Impact:** Calling `getTitle()` could return the current URL instead of the document title. **Confidence:** Confirmed native method path.

The native implementation uses `ICoreWebView2.get_DocumentTitle` and converts the result to the Dart response. Static Windows coverage now protects this method from regressing to URL lookup.

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

**Status:** Fixed in iOS 2.0.0; the scene/window regression is covered by the iOS static regression suite in 2.0.1. **Impact:** Future iOS SDK/lifecycle changes can leave the plugin without a valid window or prevent launch. **Confidence:** Confirmed path for legacy API usage; device validation remains.

Issue [#2880](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2880) calls out legacy `UIApplication.shared.delegate?.window` access. The Forge implementation now replaces those lookups with an active-scene key-window helper, registers the plugin with Flutter's scene lifecycle delegate, and raises the iOS minimum to 15.0. Flutter’s [UIScene migration guide](https://docs.flutter.dev/release/breaking-changes/uiscenedelegate) documents the same plugin migration contract.

**Remaining validation:** run the scene-aware example on multiple active/inactive iOS scenes and confirm browser presentation and authentication-session anchoring on physical devices.

### #2762 — Flutter engine gesture conflict on older Flutter versions

**Status:** Fixed in root 2.0.4 and iOS 2.0.1 by requiring Flutter `>=3.38.6`. **Impact:** iOS taps can be ignored or pass through the WebView on Flutter versions before the engine fix. **Confidence:** Strong report with an external dependency cause.

Issue [#2762](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2762) identifies the fix as landing in Flutter 3.38.6. The root package, iOS implementation, and their example applications now declare that minimum explicitly, so incompatible Flutter versions fail dependency resolution instead of reaching the broken gesture path.

**Remaining validation:** test taps, scroll gestures, and gesture recognizers on Flutter 3.38.6 and the current stable release across iOS 15+ devices.

### #2868 — Samsung One UI custom selection toolbar renders `false`

**Status:** Fixed in Android 1.0.6; Samsung One UI device validation remains. **Impact:** Visible Android text-selection UI corruption on Samsung One UI when the custom context menu is used. **Confidence:** Strong report; code path confirmed.

The custom action-mode implementation in `InAppWebView.kt` clears the native menu and rebuilds it as Flutter/plugin UI. It previously converted every native item title with `menuItem.title.toString()` and rendered it as a `TextView`. An OEM item that is icon-only or has a non-user-facing title could therefore appear as the literal string `false`. Hybrid composition avoids the custom toolbar in the reported configuration, but has a performance cost.

**Implementation:** Android 1.0.6 preserves a native icon for icon-only entries, skips entries with neither a usable title nor icon, and treats the OEM placeholder `false` as non-user-facing metadata. Native action-mode creation and title/icon lookups also catch `Resources.NotFoundException` so malformed OEM resources do not escape as an application crash. A Samsung One UI regression test matrix is still required.

**Relation to the reported `Resources$NotFoundException`:** the supplied crash also enters `InAppWebView.startActionMode` through Chromium’s selection popup. It is not proof that #2868 has the same root cause, but both symptoms make the custom action-mode path a high-value shared investigation target. The Samsung issue is a UI rendering defect; the supplied stack is a resource lookup failure.

### #2862 — Linux WPE WebKit build prerequisites are easy to miss

**Status:** Mitigated in Linux 1.0.2; Ubuntu 24.04/26.04 backend builds remain to be exercised. **Impact:** Ubuntu builds fail during CMake configuration when WPE WebKit development packages are absent or expose an unexpected `pkg-config` name. **Confidence:** Confirmed build requirement.

`flutter_inappwebview_forge_linux/linux/CMakeLists.txt` intentionally searches for WPE WebKit and stops with a fatal error when no supported package is found. Issue [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862) shows that this is not obvious on newer Ubuntu installations.

**Implementation:** Linux 1.0.2 adds a prerequisite matrix and `pkg-config` commands to the README. CMake now reports all supported WPE WebKit package names, the recommended and legacy backend package names, and the absolute path to `WPE_BACKEND.md` when configuration fails. This makes missing packages and mismatched `pkg-config` installations actionable on newer Ubuntu releases.

**Remaining validation:** run the generated example on Ubuntu 24.04/26.04 with both the WPEPlatform and legacy FDO configurations.

### #2861 — Linux Intel/X11 GPU fallback can render white or transparent

**Impact:** On Fedora/X11 with Intel i915, the default DMA-BUF/EGL path can show a black screen; disabling GL can result in a white/transparent but interactive view. **Confidence:** Needs reproduction; reporter supplied a plausible rendering-path analysis.

The reported workaround combines `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` with `LIBGL_ALWAYS_SOFTWARE=1`, which forces a software/SHM-style path but may have a substantial performance cost.

**Recommended action:** document the workaround and its performance trade-off, add a diagnostic log identifying the selected rendering backend, and reproduce on supported Fedora/X11/Intel combinations before changing the default renderer.

### #2872 — Windows `loadFile` and WebView2 file-origin semantics

**Status:** Fixed in Windows 1.0.4; validate on a Windows WebView2 runtime. **Impact:** `loadFile("assets/.../index.html")` can produce an unusable page because local subresources are blocked under the `file:` origin. **Confidence:** Strong report; the original file-navigation path is confirmed.

The Windows implementation resolves the Flutter asset to `data/flutter_assets/...` and passes the filesystem path to WebView2 `Navigate`. Issue [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) reports that the resulting `file:` page has a unique security origin and cannot load the expected resources.

**Implementation:** Windows now validates that the requested Flutter asset is relative and stays inside `data/flutter_assets`, maps that directory to `https://flutter-inappwebview-forge.local` with WebView2's `DENY_CORS` access mode, percent-encodes the asset URL, and navigates through the virtual origin. Relative CSS, JavaScript, media, and fetch/XHR references therefore stay within a normal origin. Older WebView2 runtimes without `ICoreWebView2_3` retain the legacy file-navigation fallback and emit a diagnostic log.

**Remaining validation:** load an asset tree containing relative CSS, JavaScript, images, and nested URLs on Windows 10/11 with the supported WebView2 runtime.

### #2867 — iOS/Xcode-specific `EXC_BAD_ACCESS` in multi-window navigation

**Status:** Mitigated for the known iOS 14–17 popup content-world path in iOS 2.0.2; iOS 18/Xcode 26 device validation remains. **Impact:** Potential native crash during `window.open`/multi-window flows. **Confidence:** The issue identifies a plausible evaluation path, but the report still lacks a usable symbolicated stack trace.

Issue [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) reports different behavior across Xcode 16/26 and iOS 18/26 while a popup WebView overrides JavaScript evaluation and handles `shouldOverrideUrlLoading`. The affected popup can receive KVO/navigation callbacks before Flutter attaches its platform view, and iOS 14–17 can crash when a shared popup configuration evaluates JavaScript in an uninitialized custom content world.

**Implementation:** popup window-ID JavaScript initialization now stops until the platform view is attached. On iOS 14–17, popup `evaluateJavaScript` and `callAsyncJavaScript` use the initialized page-world overload, following the upstream workaround in [PR #2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776). This is a targeted mitigation, not proof that every Xcode 26/iOS 18 crash is resolved.

**Remaining validation:** run `window.open` with popup navigation, `shouldOverrideUrlLoading`, both JavaScript APIs, and popup disposal across iOS 14–18 with Xcode 16 and 26; collect a symbolicated crash if the failure persists.

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

### #2728 — Android 15 deprecated system-bar APIs

**Status:** Mitigated in Android 1.0.5. **Impact:** Play Console can report deprecated edge-to-edge/status-bar APIs in Android 15 builds. **Confidence:** Confirmed plugin call site; the complete warning may also include Flutter or host-app code.

Issue [#2728](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2728) reports `Window.setStatusBarColor` and related system-bar APIs in a target-SDK 35 release. Android 15 enforces edge-to-edge, makes status-bar color ineffective, and deprecates the legacy color APIs; the [Android 15 behavior-change documentation](https://developer.android.com/about/versions/15/behavior-changes-15) recommends applying system-bar insets instead.

The Forge `InAppBrowserActivity` no longer emits a direct `statusBarColor` assignment. The existing `WindowCompat` edge-to-edge setup and toolbar `WindowInsetsCompat` listener remain responsible for safe top-bar layout without putting the deprecated API in the plugin bytecode.

**Remaining validation:** inspect a target-SDK 35/36 AAB in Play Console and separate plugin warnings from Flutter framework and host-application warnings.

### #2703 — Android 16 KB page-size support

**Status:** Mitigated in Android 1.0.7 and root 2.0.6; validate each host application's produced AAB before submission. **Impact:** A Play submission can be rejected or restricted if its native libraries are not compatible with 16 KB pages. **Confidence:** The package-owned Android code has no JNI/NDK library; the final application's transitive native libraries still require artifact validation.

Issue [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703) tracks Android's 16 KB page-size policy. The Forge Android module does not currently ship its own NDK-built library, so support must be verified across the Flutter engine, transitive AARs, and the final application bundle rather than assumed from Kotlin compilation.

**Implementation:** `tool/check_android_16k_alignment.sh` checks every `.so` in a release APK/AAB for 16 KB ELF `PT_LOAD` alignment. It also runs `zipalign -P 16` for APKs and requires an AAB `PAGE_ALIGNMENT_16K` bundle configuration through `bundletool`. The Android README records the host-app responsibility for AGP, NDK, Flutter-engine, and device validation.

**Remaining validation:** run the checker against the release AAB produced by every consuming application and test the artifact on a 16 KB Android 15/16 emulator or device.

### #2859 — iOS keyboard dismissal leaves a stale scroll inset

**Status:** Fixed in iOS 2.0.1; validate on iOS 17.2+ devices. **Impact:** After dismissing the keyboard, scrolling can stop before the bottom because the WebView retains a negative keyboard compensation inset. **Confidence:** Confirmed local path and static regression coverage.

Issue [#2859](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2859) identifies a regression of the keyboard/content-inset workaround originally added for #1947. The old restoration point ran from `keyboardWillHide`, while UIKit could still report the keyboard-inclusive `adjustedContentInset`; copying that value back produced a stale negative bottom inset.

The Forge implementation now only clears the keyboard-adjusted state in `keyboardWillHide` and restores the WebView inset after `keyboardDidHide`, with one main-queue turn for UIKit's final layout pass. The iOS regression test asserts that restoration is not performed from the early notification.

**Remaining validation:** exercise keyboard show/hide, focus changes between HTML inputs, interactive dismissal, and scroll-to-bottom on iOS 17.2 through the latest supported iOS release.

### #2710, #2831, and #2763 — iOS fullscreen, prompt, and multi-window behavior

**Status:** #2710 is mitigated in iOS 2.1.0; #2831 and #2763 remain open pending reproductions. **Impact:** User-visible iOS regressions: fullscreen video can turn black/unresponsive, location prompts may not close, and `onCreateWindow` results can be ignored. **Confidence:** Strong symptoms; several are likely iOS/WebKit/Flutter-version dependent.

[Issue #2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) has a concrete iOS 26 report: after an inline HTML5 video is scrubbed and enters native fullscreen, playback can become black or unresponsive. The report also reproduces with `webview_flutter` and remains after testing the available inline/PiP/fullscreen settings, which points to the WebKit/GPU layer rather than a package-only path.

**Forge mitigation:** on iOS 26 and later, `InAppWebViewSettings.useNativeFullscreenContainer` is enabled by default. After the injected iOS video monitor observes a seek/time change followed by fullscreen, Forge closes the WebKit media presentation and moves the same `WKWebView` into a full-screen UIKit container. The video element is temporarily styled to fill that container, and the original Flutter view hierarchy, constraints, frame, and media attributes are restored on exit. Set `useNativeFullscreenContainer` to `false` to opt out and retain the standard WebKit fullscreen path. The fallback remains available when a presenter or native handoff cannot be established.

This is a targeted mitigation rather than a claim that WebKit is fixed: it requires iOS 26+, JavaScript-enabled pages, and device validation across inline videos, iframe videos, orientation changes, and media controls. For affected paths on older iOS versions, forcing inline playback or using a native player/Safari remains an application-level workaround.

[#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) and [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) still need OS/SDK-specific reproductions before changing shared navigation or permission code. Maintain an iOS matrix for Flutter, Xcode, iOS, keyboard, fullscreen, and multi-window flows; do not present these as one common root cause.

### #2737 — Web platform reports stale navigation URLs

**Status:** Mitigated in Web 1.0.1; browser integration validation remains. **Impact:** Applications cannot reliably track the current page on the web platform. **Confidence:** Strong report; the source path and browser limitation are now explicit.

Issue [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) reports that iframe-based `onLoadStart`, `onLoadStop`, `onProgressChanged`, and `getUrl()` continue to expose the initial URL after navigation. The Web implementation now reads `contentWindow.location.href` for same-origin documents and forwards that value through load/history events and `getUrl()`.

For a cross-origin document, the browser's same-origin policy can make `contentWindow.location.href` unreadable to the parent page. The implementation returns `null` in that case instead of repeating the iframe's initial `src`; an exact cross-origin URL still requires cooperation from the embedded page. Add a browser integration test covering same-origin redirects/history and cross-origin privacy behavior.

### #2789 and #2780 — Windows overlay and Linux WPE compatibility

**Status:** Fixed in Windows 1.0.3 and Linux 1.0.1; native Windows and Linux validation remains. **Impact:** A minimized Windows WebView can continue intercepting desktop clicks; Linux builds can fail against WebKit versions below 2.50. **Confidence:** Strong report for #2789; confirmed compile-risk path for #2780.

Issue [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789) is a reproducible platform-view hit-test/overlay regression after minimizing a Windows app. Issue [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780) matches an unguarded `webkit_web_view_get_theme_color` call in the Linux C++ source, which can cause an undefined-reference failure on older WPE WebKit versions.

**Implementation:** Windows 1.0.3 emits explicit minimize/restore events from `WM_SIZE`, hides the WebView2 controller and parent child window while minimized, and restores visibility plus the current Flutter position afterward. Linux 1.0.1 compiles `webkit_web_view_get_theme_color` only when `WEBKIT_CHECK_VERSION(2, 50, 0)` is true and returns no theme color on older WPE WebKit versions. Windows hit-testing and Linux builds still require native CI/device validation.

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
