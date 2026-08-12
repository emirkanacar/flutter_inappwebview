# Known Issues and Upstream Triage

Last reviewed: 2026-08-12

Source: the provided `issues.csv` snapshot and the [flutter_inappwebview issue tracker](https://github.com/pichillilorenzo/flutter_inappwebview/issues). The CSV is a metadata/title export and contains 125 rows, all marked `OPEN`: 98 bugs, 16 enhancements, 3 showcase entries, and 8 records without a label. All 125 rows were screened; 74 issue records have local implementations or mitigations awaiting real runtime validation, #2709 is source-validated with a focused Dart regression test and has no native runtime gate, #2745 is closed by source review, #2570, #2584, #2598, #2636, #2659, #2680, #2688, #2698, #2713, #2723, #2727, #2753, #2796, #2815, and #2831 are host/platform- or dependency-specific boundaries with no Forge-owned fix, and 34 remain active implementation or reproduction work. The upstream `OPEN` value is retained as export metadata and must not be read as the current local implementation status.

The confidence labels below describe the evidence available during this review:

- **Confirmed path**: the report is consistent with a concrete code path in this repository.
- **Strong report**: the report contains a reproducible scenario and useful native/platform evidence, but the root cause still needs a regression test.
- **Needs reproduction**: the symptom is important, but the report does not yet contain enough evidence to safely change the implementation.
- **Host/platform boundary**: the evidence identifies an external runtime or
  provider failure with no package-owned control point; the upstream record
  remains open for host updates or additional evidence.

For the active backlog, priorities, work packages, and acceptance criteria, see the [open work plan](open-work-plan.md). For locally implemented issues that still need real device, provider, browser, native, or artifact tests, see [runtime-validation-pending.md](runtime-validation-pending.md).

## Resolution summary

| Local status | Count | Meaning |
| --- | ---: | --- |
| Resolved locally; runtime validation pending | 74 issues | The source, regression, and host/build boundary is complete; the remaining real validation is tracked in [runtime-validation-pending.md](runtime-validation-pending.md). |
| Resolved locally; no runtime gate | 1 issue ([#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709)) | The pure Dart serialization path and regression test pass; no device/provider behavior is involved. |
| Closed by source review | 1 issue ([#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745)) | No plugin-owned security sink was found; no package runtime gate is required. |
| Host/platform-specific boundary | 15 issues ([#2570](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2570), [#2584](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2584), [#2598](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2598), [#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636), [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659), [#2680](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2680), [#2688](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2688), [#2698](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2698), [#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713), [#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723), [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727), [#2753](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2753), [#2796](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2796), [#2815](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2815), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)) | The issue remains visible for host/provider/engine/application/site/dependency tracking, but no Forge-owned code change is justified by the available evidence. |
| Open implementation or reproduction | 34 issues | The active queue and acceptance criteria are tracked in [open-work-plan.md](open-work-plan.md). |

#### #2673, #2594 - Android provider-specific `forceDarkStrategy` casts

**Local status:** Implemented and source-validated; provider/device validation pending. **Affected package:** Android native WebSettings compatibility boundary. **Impact:** affected WebView providers can report `FORCE_DARK_STRATEGY` as supported while their `WebSettingsWrapper` cannot be converted to the provider's internal `ContentSettingsAdapter`, causing a `ClassCastException` during WebView creation or settings readback. **Fix:** `forceDarkStrategy` setter and getter calls now fail open: provider exceptions are logged, the requested strategy is left at the provider default, and real-settings readback omits the unavailable value. **Required evidence:** Huawei/HONOR and OnePlus devices on the reported Android/WebView versions, with `forceDarkStrategy` set and read during create/update/dispose cycles.

#### #2707 - macOS browser-window teardown ownership

**Local status:** Implemented and source-validated; macOS/Xcode runtime validation pending. **Affected package:** macOS native WebView. **Impact:** a popup WebView could remain in the manager registry when its ownership state changed before disposal, leaving stale references during browser-window teardown. **Fix:** popup window IDs are removed unconditionally before the WebView releases its plugin reference. **Required evidence:** create/present/dismiss/recreate popup windows on macOS 11 through Tahoe with Xcode 26.

#### #2826 - macOS fractional platform-view frame drift

**Local status:** Implemented and source-validated; macOS runtime validation pending. **Affected package:** macOS platform-view container. **Impact:** AppKit autoresizing could round the native `WKWebView` width and origin away from Flutter's stable fractional platform-view bounds, causing content to resize or zoom across frames. **Fix:** the native WebView and controller no longer use autoresizing masks for sizing; the WebView frame is synchronized to finite controller bounds during initialization, layout, frame-size, bounds-size, and subview-resize callbacks. The source regression test passes, and the Xcode 27 macOS example build passes with a temporary `MACOSX_DEPLOYMENT_TARGET=12.0` command-line override. **Required evidence:** reproduce the fractional-width example on Retina macOS across supported macOS versions and confirm the native frame remains equal to the Flutter platform-view bounds during resize and refresh cycles.

#### #2697 - Android renderer callback type boundary

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android renderer-process client. **Impact:** a renderer callback delivered for a non-Forge WebView instance could throw a cast exception before the callback reached the channel layer. **Fix:** renderer callbacks now use a nullable type check and return for unrelated WebView instances. **Required evidence:** renderer unresponsive/responsive and renderer-gone flows across API 19/21/29/35/36 and OEM providers.

#### #2831 - iOS 26 geolocation permission prompt

**Local status:** Host/platform boundary; no Forge-owned iOS 26 fix is available through the public WebKit API. **Affected scope:** iOS/WebKit system geolocation prompt. **Impact:** the upstream report says the native location dialog appears but its buttons cannot be tapped. The installed WebKit SDK declares `WKUIDelegate.webView(_:requestGeolocationPermissionFor:initiatedByFrame:decisionHandler:)` at iOS 27.0, not iOS 26.0. The iPhone 17 Pro iOS 26.2 diagnostic loads a secure HTTPS page but leaves `callbackOrigin=null`; no public iOS 26 delegate lets Forge decide or dismiss that prompt. **Implementation boundary:** the bridge is compiled and advertised for iOS 27+, where a fresh 2026-08-10 HTTPS deny-path diagnostic receives `https://example.com` in Dart and returns `error:1`. Platform-interface metadata and source tests now match the SDK availability. A private WebKit selector or JavaScript geolocation replacement would violate the plugin's public-API and security contracts, so iOS 26 prompt behavior remains an Apple/WebKit boundary. **Required evidence:** Apple should validate the interactive grant/deny prompt on physical iOS 26 devices; Forge's iOS 27 path remains covered by the Simulator diagnostic.

#### #2797 - Android InAppBrowser activity-result ownership

**Local status:** Implemented and source-validated; Android activity/provider validation pending. **Affected package:** Android `InAppWebViewChromeClient` and `InAppBrowserActivity`. **Impact:** the file chooser listener could return `true` with no active chooser or clear a pending chooser for an unrelated request code, allowing it to consume another plugin's activity result. **Fix:** the ChromeClient now returns `false` for unclaimed or unknown results; only picker request codes clear file callbacks, and browser dispatch continues to iterate a snapshot of its listener list. **Required evidence:** keep an InAppBrowser foreground while a permission/activity-result plugin completes a request, then cover file chooser cancel/capture flows on Android API 35/36 and OEM providers.

#### #2709 - Android internal-storage path-handler serialization

**Local status:** Resolved locally; source and focused Dart regression tests pass; no native runtime gate. **Affected package:** Android Dart asset-loader API. **Impact:** `AndroidInternalStoragePathHandler.toMap()` could recursively call itself and overflow the stack. **Fix:** the override calls `super.toMap()` once and adds `directory`; the regression test verifies the base fields and directory are serialized without recursion.

#### #2711 - iOS missing-plugin error from a stale `goBack()` call

**Local status:** Implemented locally; runtime validation pending. **Affected package:** iOS Dart controller and native platform-view channel lifecycle. **Impact:** the upstream report contains a production `MissingPluginException` for `goBack` on the WebView channel, affecting a reported subset of users after navigation/back handling. **Root cause boundary:** native `ChannelDelegate.dispose()` removes the method handler while a Dart controller can remain reachable during scene/platform-view teardown. **Fix:** iOS `goBack()` now catches only `MissingPluginException` from that stale channel path and treats it as an idempotent no-op; normal native errors remain unchanged. The regression test fails against the original implementation and passes after the fix. iOS package tests (2/2), SwiftPM manifest validation, and the iOS Simulator build pass. The iPhone 17 Pro disposal diagnostic now accepts the safe `WebView navigation started` result as well as `WebView disposed` and completes four teardown cycles without a missing-plugin failure or app crash. **Required evidence:** run a #2711-specific physical/device matrix with `PopScope`, scene background/foreground, platform-view removal/recreation, stale-controller calls, and channel/engine reattachment tracing.

#### #2814 - Windows child-window teardown

**Local status:** Implemented and source-validated; Windows/WebView2 runtime validation pending. **Affected package:** Windows WebView2/FindInteraction teardown. **Impact:** closing a child window in the reported multi-window setup exits the host process, with logs pointing at `FindInteractionController` and WebView2 environment teardown. **Root cause:** the controller removed its WebView2 find event handlers after `Stop()`/`Close()`, when the WebView2 object could already be in an invalid state. **Fix:** `InAppWebView::~InAppWebView()` now disposes and releases `FindInteractionController` before stopping, destroying, or closing the WebView2 controller. Static source regression coverage passes. **Required evidence:** reproduce the reported Windows 11 multi-window flow with and without `FindInteractionController`, then run child-window close/recreate cycles on supported WebView2 versions and confirm the host process remains alive.

#### #2839 - Windows Visual Studio 2026/MSVC 14.5x build failure

**Local status:** Implemented and source-validated; affected Windows toolchain build/runtime validation pending. **Affected package:** Windows native CMake target. **Impact:** Visual Studio 2026/MSVC 14.5x can fail with STL1011 from `<experimental/coroutine>`, intermittent C1041 PDB contention under parallel `/MP` builds, and older WIL headers that do not compile cleanly with Windows SDK 10.0.26100. **Fix:** Windows 1.0.9 updates WIL to `1.0.260126.7`, adds `/FS` to serialize PDB writes, and defines Microsoft's `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` compatibility escape hatch for the current C++17 target. The WebView2 dependency was already at PR #2869's `1.0.4078.44` version. Static CMake source coverage passes. **Required evidence:** build the Windows example and a consuming app with Visual Studio 2026/MSVC 14.5x and Windows SDK 10.0.26100, then run clean and incremental builds and WebView navigation/runtime smoke tests; confirm VS 2022 compatibility remains intact.

#### #2736 - Windows InAppBrowser resize after teardown

**Local status:** Implemented and source-validated; Windows native validation pending. **Affected package:** Windows InAppBrowser. **Impact:** a late `WM_SIZE` callback could reach a released WebView2 controller during focus/resize or window teardown. **Fix:** the resize path now checks both the browser wrapper and WebView2 controller before updating bounds. **Required evidence:** minimize/restore, close/resize races, focus transitions, and release builds on supported Windows/WebView2 versions.

#### #2861 - Linux software-rendering fallback

**Local status:** Implemented and source-validated; Fedora/X11/Intel runtime validation pending. **Affected package:** Linux rendering backend. **Impact:** the default GL/DMA-BUF path may produce black, white, or transparent output on affected Intel/X11 configurations. **Fix:** `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` now selects the pixel-buffer/SHM fallback, sets `LIBGL_ALWAYS_SOFTWARE=1` before WPE starts, and skips EGL import when software rendering is requested so DMA-BUF frames are converted to CPU-readable pixels. **Required evidence:** Fedora/X11 with Intel i915, backend logs, and before/after frame output.

The runtime GL realize path now also switches to the same fallback when GtkGLArea initialization reports an error. This is containment, not proof that every DMA-BUF/driver failure is resolved; Fedora/X11/Intel runtime evidence remains required.

#### #2763 - iOS popup WebView manager lifecycle

**Local status:** Implemented and source-validated; the rejected-popup path is validated on iOS 26.0, 26.2, and 27.0 Simulators, while physical iOS popup validation remains pending. **Affected package:** iOS `WKUIDelegate` popup creation. **Impact:** the rejected popup target was previously loaded into the caller WebView even when `onCreateWindow` returned `false`, so an external launch caused a duplicate embedded navigation. **Fix:** rejected or unhandled popup callbacks now remove the pending transport without loading the target; explicit `controller.loadUrl` from the callback remains available for same-window handling. Missing managers still return `nil` instead of synthesizing window ID `0`. **Evidence:** the opt-in `ios_popup_default_handling_diagnostic_test.dart` receives `https://example.com/popup` in `onCreateWindow`, returns `false`, and keeps the caller at `https://example.com/` on all three runtimes. **Required evidence:** `window.open`, `onCreateWindow` returning `false`/`true`, returned child attachment, navigation, disposal, and scene transitions on physical iOS 15-26.

#### #2745 - JavaScript `eval()` security claim

**Local status:** Closed by source review; no package vulnerability established. **Affected scope:** JavaScript bridge and generated plugin scripts. **Source review:** the only dynamic evaluation sites are the explicit Android content-world and Web iframe `evaluateJavascript` API wrappers, each receiving the caller-supplied `source` argument. Static regression tests pin those API boundaries and prevent accidental additional dynamic sinks. `evaluateJavascript` is an explicit public API and is not evidence of a package vulnerability by itself. A future claim still requires a concrete untrusted source-to-privileged-sink path and exploit reproduction.

#### #2536 - Android `Bundle.getSerializable` scanner finding

**Local status:** Fixed in source and Android 35 happy-path validated; negative/runtime matrix pending. **Affected package:** Android InAppBrowser and Chrome Custom Tabs activity handoff. **Impact:** plugin-owned activity extras previously used Java serialization for Flutter maps/lists, matching the scanner's `Bundle.getSerializable` trace. **Fix:** all browser activity maps/lists now use a recursive `Bundle` primitive/nested-`Bundle` codec; no `getSerializable`, `putSerializable`, or `java.io.Serializable` references remain in Android native source. During the Android 35 validation the Custom Tabs manager channel typo was corrected and its service session was kept bound until activity destruction so lifecycle callbacks survive the external tab transition. Activities remain `android:exported="false"`. **Evidence:** Android package tests pass (42 tests), the opt-in `emulator-5554` API 35 diagnostic passes for nested InAppBrowser and Chrome Custom Tabs payloads (`browserCreated`, `firstPageLoaded`, `opened`, `loaded`, and `closed`), and the debug APK launches Chrome's Custom Tab with the requested URL. **Remaining evidence:** physical/provider matrix, activity restore/rotation, and malformed external extras.

#### #2687 - Android release JAR synchronization

**Local status:** Mitigated in the example release path; JDK/provider/publish validation pending. **Affected scope:** Android example Gradle output discovery and plugin release artifact synchronization. **Impact:** Flutter could report no APK or a stale release registrant could retain the dev-only `integration_test` plugin, masking the actual plugin release gate. **Fix:** the example Gradle script now resolves its root build directory from the project directory (`../build`), so release output is placed under `example/build` as Flutter expects. A normal `flutter build apk --release` regenerates release tooling without the dev-only `integration_test` registrant; with JDK 21, `flutter build apk --release --no-pub` produces `build/app/outputs/flutter-apk/app-release.apk`, and `:flutter_inappwebview_forge_android:syncReleaseLibJars` succeeds. The APK installs on the API 35 `emulator-5554`; `MainActivity` remains resumed and no fatal crash appears in the smoke log. **Remaining validation:** clean JDK 17/21 matrix, real provider/device, AAB/publish artifact inspection, and ensuring the first release-tooling regeneration is run after pub changes. The remaining #2685/#2641 deprecation warning families are separate active work.

#### #2782, #2783 - Android callback ownership and input stability

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android client-certificate callback boundary. **Impact:** a provider callback delivered for a non-Forge WebView could be force-cast before the certificate request was completed. **Fix:** the callback now uses a nullable Forge-WebView cast and cancels the request for unrelated WebViews. **Required evidence:** client-certificate and input/focus transitions across supported Android API levels and OEM providers.

#### #2619 - iOS custom scheme callback ownership

**Local status:** Implemented and source-validated; iOS WebKit runtime validation pending. **Affected package:** iOS custom URL-scheme handler. **Impact:** a scheme callback for a non-Forge WebView could force-cast the WebView and terminate the process. **Fix:** the handler now rejects unrelated WebViews with a structured URL-scheme task error and removes the task from its pending map. **Required evidence:** custom schemes, disposal during an outstanding task, and WebKit callback ordering on supported iOS versions.

#### #2778 - Windows headless WebView controller teardown

**Local status:** Implemented and source-validated; Windows/WebView2 runtime validation pending. **Affected package:** Windows headless WebView. **Impact:** a late size callback could dereference a released WebView2 controller during startup or renderer teardown. **Fix:** size setters/getters now require both the WebView wrapper and controller before accessing bounds. **Required evidence:** create, resize, renderer restart, dispose, and recreate cycles on supported WebView2 runtimes.

#### #2584 - iOS 18.4 Simulator/WebKit startup crash

**Local status:** Host/platform boundary; no Forge-owned source fix. **Affected scope:** iOS Simulator, Xcode, and WebKit startup. **Impact:** the upstream report describes an iOS 18.4 Simulator crash while loading `libswiftWebKit.dylib`; issue comments identify newer Simulator/Xcode/WebKit combinations as the relevant variable rather than a Forge call path. **Required evidence:** reproduce with the reported Xcode/iOS Simulator matrix, compare a minimal native `WKWebView` host and a physical device, and retain a symbolicated stack. The record is intentionally excluded from the runtime-validation implementation count and is not related to the internal WebMessage payload checks below.

#### #2698 - Android System WebView renderer crash after provider update

**Local status:** Host/platform boundary; no Forge-owned source fix. **Affected scope:** Android System WebView/Chromium provider. **Impact:** the upstream report contains Chromium renderer-termination logs on a Redmi Note 13 Pro 5G after a specific Android System WebView update and says rolling the provider back stopped the symptom. It provides no Forge package version, plugin stack frame, or plugin-owned callback/control point. **Required evidence:** compare the reported provider versions with a minimal native WebView host and the Forge example on the same device, then retain a symbolicated Chromium trace before considering a package change. This record is excluded from the runtime-validation implementation count.

#### #2600 - iOS `windowId` popup `EXC_BAD_ACCESS`

**Local status:** Implemented and source-validated; iOS device/Xcode runtime validation pending. **Affected package:** iOS popup `WKWebView` lifecycle. **Impact:** a popup created with `windowId` could receive stale KVO callbacks or evaluate JavaScript through a transient shared content-world/frame and terminate with `EXC_BAD_ACCESS`. **Fix:** popup window-ID initialization is deferred onto the main queue, deduplicated per navigation, protected by `windowCreated`/dispose guards, and routed through the initialized page world; KVO now verifies the observed object before touching WebKit state. **Required evidence:** iOS 15–26 physical devices, Xcode 16/26, `window.open`, popup attach/dispose/recreate, `evaluateJavaScript`, `callAsyncJavaScript`, and navigation callbacks.

#### #2654 - iOS/Android WebView disposal crash boundary

**Local status:** Implemented and source/runtime-diagnostic validated; physical iOS/Android provider validation pending. **Affected packages:** iOS and Android native WebView lifecycle. **Impact:** the upstream report describes an iOS `EXC_BAD_ACCESS` while navigating away and disposing the WebView, plus an Android renderer termination during the same teardown flow. **Fix:** iOS disposal is idempotent before observer/WebKit cleanup and completes both native-content-world and legacy async JavaScript callbacks with a structured `WebView disposed` error; late WebKit callbacks are ignored after the pending table is cleared. Android disposal is idempotent, completes pending async JavaScript callbacks before releasing the channel, and keeps fullscreen teardown before native WebView destruction. The iPhone 17 Pro iOS 26.2 Simulator previously completed four navigate-away/dispose/recreate cycles; a fresh iOS 27 Simulator run also completed four cycles with safe `WebView navigation started`/`WebView disposed` outcomes. A fresh 2026-08-10 Android `flutter drive` run and the 2026-08-11 Samsung A16 run complete four cycles across the tested composition modes with exit code 0 and `WebView disposed` outcomes. Android's renderer exit code `-1` during explicit WebView destruction is recorded as expected teardown evidence, with no app `AndroidRuntime`, fatal, or ANR failure. External [#2491](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2491), which is outside the supplied export, reports the same renderer signature after back navigation; its exact affected-OEM path remains pending. **Required evidence:** repeated create/load/navigate-away/dispose cycles on physical iOS 17+ and Android API 33+ OEM/provider matrices, including hybrid composition and renderer teardown logs.

#### Internal iOS cookie property decoding (no upstream issue mapping)

**Local status:** Implemented and source-validated; iOS WebKit cookie runtime validation pending. **Affected package:** iOS cookie manager. **Impact:** cookie cleanup could force-unwrap or force-cast an absent or provider-specific `originURL` property, or assume the website data type set cast succeeded. **Fix:** origin values and website data types are decoded with optional checks and return a safe failure when the platform shape is unsupported. **Required evidence:** cookie deletion with String/URL/missing origin properties across iOS 15-26. This internal hardening must not be read as a fix for upstream #2600.

#### Internal iOS WebMessageListener payload validation (no upstream issue mapping)

**Local status:** Implemented and source-validated; iOS WebKit/provider validation pending. **Affected package:** iOS WebMessageListener creation. **Impact:** malformed platform-channel maps could force-cast listener IDs, JavaScript object names, or origin rules and terminate the app. **Fix:** listener creation now validates all required fields and returns `nil` for malformed payloads. **Required evidence:** listener creation with missing/null/wrong-type fields and disposal during message delivery. This internal hardening must not be read as a fix for upstream #2584.

#### #2697 - Android asynchronous startup callback lifetime

**Local status:** Implemented and source-validated; Android cold-start/device validation pending. **Affected package:** Android WebView startup coordinator. **Impact:** callbacks queued for asynchronous WebView provider startup could run after plugin detach and target disposed WebViews. **Fix:** plugin detach marks the coordinator disposed, clears pending callbacks, removes main-handler work, and shuts down the startup executor. **Required evidence:** headless and regular WebView cold start, detach/reattach, and release/AOT cycles.

#### #2717 - Android WebStorage provider callback entries

**Local status:** Implemented and source-validated; Android provider validation pending. **Affected package:** Android WebStorage manager. **Impact:** provider callback maps containing unexpected entries could throw a cast exception while enumerating origins. **Fix:** entries are decoded with a nullable `WebStorage.Origin` cast and malformed values are skipped. **Required evidence:** origins/quota/usage calls across Android API levels and WebView providers.

#### Internal iOS navigation channel payload validation (no upstream issue mapping)

**Local status:** Implemented and source-validated; iOS device validation pending. **Affected package:** iOS WebView channel delegate. **Impact:** malformed `postUrl` or `loadData` payloads could force-cast typed data or force-unwrap invalid URLs. **Fix:** required values are validated and a structured `invalid_arguments` error is returned. **Required evidence:** malformed/null payloads and valid POST/data navigation across iOS 15-26. This internal hardening is not associated with upstream #2654, whose report is a disposal crash.

The same validation now covers `loadFile`'s required asset path, preventing a null channel value from reaching native file resolution.

#### #2619 - macOS custom scheme callback ownership

**Local status:** Implemented and source-validated; macOS WebKit runtime validation pending. **Affected package:** macOS custom URL-scheme handler. **Impact:** a non-Forge WebView callback could be force-cast and crash the application. **Fix:** unsupported WebViews now receive a structured task error and are removed from the pending task map. **Required evidence:** custom scheme loading and disposal during outstanding tasks on macOS 10.14+.

#### #2697 - Android URL callback ownership

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android navigation client. **Impact:** an unrelated WebView callback could be force-cast during URL navigation. **Fix:** navigation callbacks now return the platform default behavior for non-Forge WebViews. **Required evidence:** navigation and renderer callback flows across supported providers.

The same ownership guard now covers page-started, page-finished, document-start, document-end, and main-frame error callbacks.

#### #2805 - iOS proxy payload validation

**Local status:** Implemented and source-validated; iOS 17+ proxy runtime validation pending. **Affected package:** iOS proxy manager. **Impact:** malformed proxy settings or rules could force-cast rule lists/URLs or unwrap invalid rule objects. **Fix:** proxy settings use optional map decoding and discard malformed rules safely. **Required evidence:** valid, empty, malformed, and mixed proxy rule lists on iOS 17+.

#### Internal iOS WebMessageChannel payload and index validation (no upstream issue mapping)

**Local status:** Implemented and source-validated; iOS WebKit runtime validation pending. **Affected package:** iOS WebMessageChannel delegate. **Impact:** malformed port indices or message maps could index outside the ports array or force-cast channel payloads. **Fix:** indices are bounds-checked and malformed messages return structured argument errors. **Required evidence:** valid/invalid port indices, null messages, closed ports, and disposal during message delivery. This internal hardening is separate from upstream #2584's Simulator/WebKit startup crash.

#### #2697 - Android Chrome callback ownership

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android WebChromeClient. **Impact:** progress, title, icon, or touch-icon callbacks could force-cast unrelated WebViews. **Fix:** callbacks now ignore non-Forge WebViews safely. **Required evidence:** provider callback flows during navigation, renderer restart, and teardown.

#### #2783 - Android file chooser callback ownership

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android file chooser callback bridge. **Impact:** provider/activity lifecycle changes could make the generic callback shape incompatible with an unchecked `ValueCallback` cast. **Fix:** callback casts are nullable and unsupported shapes return without invoking a stale callback. **Required evidence:** single/multiple selection, capture mode, cancellation, rotation, and dispose/recreate flows.

#### #2717 - macOS WebStorage cleanup payload validation

**Local status:** Implemented and source-validated; macOS runtime validation pending. **Affected package:** macOS WebStorage manager. **Impact:** malformed data type, record, timestamp, or display-name payloads could force-cast and terminate the app. **Fix:** required fields are validated and malformed records are skipped or rejected with structured errors. **Required evidence:** fetch/remove records with valid, empty, missing, and mixed-type payloads.

### 2026-08-08 issue work

#### #2856 - Android nullable and malformed callback payloads

**Local status:** Hardened in Android 1.0.37 (root 2.1.40); device/provider validation pending. **Affected package:** Android Dart controller. **Environment:** Flutter 3.44.8/Dart 3.12.2 development baseline; published package compatibility minimum remains Flutter 3.38.6. **User impact:** malformed or nullable WebView provider fields could cause a Dart type error while converting request results or dispatching normal callbacks. **Hypothesis:** dynamic channel values were passed directly to `WebUri`, nullable public fields, non-null `String` locals, or an unchecked `List` cast. **Fix:** optional URL, title, source, origin, callback ID, touch-icon, safe-browsing, print-job, and context-menu values are accepted only when they are strings; permission request and cancellation payloads now also reject a non-map payload, non-string origin, or non-list resources container before decoding, while filtering unknown resource entries. Invalid values return the existing native default behavior or empty-title behavior; the public channel and result contracts are unchanged. **Regression evidence:** the Android nullability test reproduces the prior `String`-to-`List` cast failure with a valid origin and malformed resources container, and passes after the guard; null/malformed cancellation payloads are also ignored safely. **Required evidence:** Android API/provider matrix covering null, empty, malformed, and wrong-type callback fields.

#### #2737 - Web iframe URL tracking

**Local status:** Existing implementation source-validated; browser integration validation pending. **Affected package:** Web. **User impact:** same-origin iframe navigation must report the current location, while cross-origin reads must not leak or repeat the initial `src`. **Fix reviewed:** the JavaScript helper reads the current iframe location where same-origin access permits it and returns `null` for cross-origin access; load events carry nullable URLs and `getUrl` avoids falling back to the initial source after a document has loaded. Regression assertions protect these boundaries. **Required evidence:** same-origin redirect/history and cross-origin browser integration tests.

### #2636 — iOS 18.4/18.5 Simulator missing `libswiftWebKit.dylib`

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Apple Simulator runtime, WebKit, Xcode, and deployment-target configuration. **Impact:** the application can abort at launch because the Simulator dyld cannot resolve the system Swift WebKit library. **Confidence:** Host-specific boundary.

The upstream crash is a `DYLD 1 Library missing` failure for `/usr/lib/swift/libswiftWebKit.dylib`, not a Swift symbol or plugin-owned library bundled by Forge. The upstream investigation reports that the failure is specific to iOS 18.4/18.5 Simulator combinations when the deployment target is below the affected runtime requirement; iOS 18.6 Simulator and physical devices work, and newer/older Xcode or Simulator configurations are available workarounds. Forge intentionally supports iOS 15.0, so raising the package deployment target to 18.4 would break the supported contract and is not an acceptable fix.

**Required evidence:** if the host failure is reported again, capture the exact Xcode/Simulator runtime, architecture, deployment target, and whether the same app runs on a physical device. Re-test on a current Apple Simulator runtime before changing package code.

### #2659 — Android HTML time input picker NPE

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Android framework/OEM WebView time picker. **Impact:** tapping the plus/minus controls for `<input type="time">` can terminate the process on affected Android 34+ Samsung devices. **Confidence:** Host/platform boundary from the native stack and source ownership review.

The supplied stack terminates in Android's `android.widget.TimePickerSpinnerDelegate.updateInputState` while handling a `NumberPicker` click. Forge's Android implementation delegates WebView UI to the platform and contains no `TimePickerDialog`, `DatePickerDialog`, or `TimePickerSpinnerDelegate` implementation to guard. The available plugin-owned file chooser callbacks are unrelated to HTML time input, so a speculative interception or replacement picker would change WebView behavior without a reproducible compatibility contract.

**Required evidence:** reproduce on the reported Samsung/API/WebView-provider matrix and compare the same HTML page in a minimal native Android WebView. Only add a Forge workaround if the failure is shown to cross the native WebView boundary and a stable interception API exists.

### #2727 — iOS modal sheet/dialog leaves WebView unresponsive

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Flutter iOS platform-view gesture lifecycle. **Impact:** after dismissing `showModalBottomSheet` or `showDialog`, WebView JavaScript/touch handling can stop responding on older Flutter/iOS 26 combinations. **Confidence:** Host/platform boundary from the upstream reproduction history.

The upstream report has multiple confirmations that upgrading Flutter to 3.41/3.41.3 restores WebView interaction, while the failure appears across WebView plugins and is linked to Flutter platform-view gesture issues. Forge's iOS WebKit layer cannot safely reset Flutter's gesture arena or platform-view state. The repository keeps its Flutter compatibility baseline at 3.38.6; this record therefore remains a host/engine compatibility boundary rather than a speculative native patch.

**Required evidence:** if the failure is still reported on the supported baseline, capture the exact Flutter/Xcode/iOS versions and compare `flutter_inappwebview_forge` with a minimal native platform-view reproduction before considering a compatibility change.

### #2723 — iOS ListView/NestedScrollView taps stop after scrolling

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Flutter iOS platform-view gesture arbitration. **Impact:** links inside a WebView can stop receiving taps after the containing ListView or ScrollView is scrolled. **Confidence:** Strong host-boundary evidence from the issue reproducer and linked framework workaround.

The upstream reproducer uses Flutter 3.35.5 and reports the failure only after parent scrolling. The linked [workaround](https://khal.it/blog/flutter-webview-tap-gestures-break-nestedscrollview-ios-fix) identifies this as a Flutter framework bug fixed by upgrading to Flutter 3.38.6+, which is Forge's compatibility baseline. Forge's iOS widget passes the caller's `gestureRecognizers` directly to Flutter's `UiKitView`; its native Swift layer can coordinate WebKit recognizers but cannot repair Flutter's gesture arena. Making `preventGestureDelay` or an eager recognizer the default would change public gesture arbitration for every iOS WebView and is not justified by the current evidence.

**Required evidence:** if the symptom reproduces on Flutter 3.38.6 or newer, capture a minimal example without `shouldOverrideUrlLoading` or external URL launching, compare a plain `UiKitView` and another WebView plugin, and record the exact iOS/Xcode/Flutter versions before considering a package-level change.

### #2713 — iOS Drawer dismissal leaves WebView touch unresponsive

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Flutter iOS platform-view hit testing and gesture lifecycle. **Impact:** after a Drawer is dismissed, WebView taps and JavaScript-driven interaction can stop responding. **Confidence:** Strong host-boundary evidence from the upstream issue history.

The report aligns with Flutter's iOS platform-view gesture issue chain ([#175099](https://github.com/flutter/flutter/issues/175099), [#158961](https://github.com/flutter/flutter/issues/158961)). The reported PointerInterceptor/overlay workarounds act in Flutter's hit-testing layer, and the symptom is consistent with platform-view gesture state rather than a Forge WebKit callback or channel contract. Forge's iOS native layer cannot safely reset Flutter's gesture arena after a Drawer transition, so no speculative package patch is justified.

**Required evidence:** if the symptom reproduces on the supported Flutter 3.38.6 baseline, capture the exact Flutter/Xcode/iOS versions and a minimal platform-view reproduction, then compare another Flutter platform-view plugin or a native view. Only implement a Forge change if the failure crosses that host boundary and a stable plugin-owned control point is identified.

### #2598 — iOS draggable overlay scrolls the WebView

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Flutter iOS platform-view hit testing and gesture arbitration. **Impact:** dragging a Flutter `Draggable`/`Positioned` widget above an iOS WebView can also scroll the WebView underneath. **Confidence:** Strong host-boundary evidence from the iOS 18/18.6 reports and source ownership review.

The report's moving overlay is owned by the host Flutter widget tree, while the Forge iOS widget passes `gestureRecognizers` directly to `UiKitView`. The native `gestureRecognizer` delegate permits simultaneous recognition, and the existing opt-in `preventGestureDelay` code only disables Flutter's delaying recognizer when the WebView itself is hit-tested; it cannot claim or cancel a pointer already targeted at an overlay. Changing that behavior globally would alter gesture arbitration for every iOS WebView and could break scrolling, links, and nested Flutter gestures.

**Required evidence:** reproduce a minimal overlay/WebView example on Flutter 3.38.6 and current stable across iOS 18+, compare a plain `UiKitView`, another WebView plugin, and a native view, and record whether the underlying scroll begins before or after the overlay's drag recognizer wins. Only add a Forge change if the failure crosses the Flutter hit-testing boundary and a stable plugin-owned control point is identified.

### #2815 — Android Firebase Auth reports missing initial state

**Local status:** Host/application/Firebase configuration boundary; no Forge
package fix. **Affected scope:** Android WebView auth redirects, Firebase
Authorized Domains, the consuming app's custom JavaScript, and the identity
provider flow. **Impact:** the reported Google sign-in flow reaches a white
page with `Unable to process request due to missing initial state` after the
account-selection redirect. **Confidence:** Strong host-boundary evidence;
the report uses Flutter 3.41.6/Android 12 and includes app-specific scripts
that rewrite the viewport, install a MutationObserver, save/restore auth
state, and reload the Firebase auth handler.

The supplied log also contains a `404` for the app's
`__/firebase/init.json`. A follow-up comment reports that adding the Android
package name to Firebase Authentication's Authorized Domains resolved the
same symptom. Forge exposes Web Storage and DOM storage through the Android
WebView, but does not automatically clear `sessionStorage` during navigation;
the reported snippet itself controls the auth-page reload and state restore.
There is therefore no reproducible plugin-owned storage or channel failure to
patch, and changing WebView storage semantics would risk breaking unrelated
OAuth flows.

**Required evidence:** reproduce with a minimal Firebase app and no custom
auth-page injection; verify the exact Firebase project, Authorized Domains,
OAuth redirect URI, SHA-1/package configuration, and WebView DOM-storage
settings; compare Android WebView with a native browser and a minimal
`InAppWebView` host. Reopen implementation work only if the minimal host still
loses state with valid Firebase configuration.

### #2793 — Typed JavaScript bridge events and handlers

**Local status:** Implemented additively in platform-interface 1.1.8 and root
2.1.57; WebView/browser runtime validation pending. **Impact:** applications
must currently repeat low-level `evaluateJavascript` and handler boilerplate
for event-style communication and typed payload conversion. **Fix:** the new
`InAppWebViewController.bridgeEvents` helper installs an event API on the
runtime-configured bridge name, supports Dart and JavaScript listener
registration, dispatches JavaScript events through the existing handler
contract, and provides JSON/serialized typed handler codecs. Existing
`addJavaScriptHandler`, bridge readiness, forbidden-name, and native channel
contracts remain unchanged.

**Regression evidence:** platform-interface tests cover one-time installation,
duplicate listener suppression, JavaScript-to-Dart event dispatch, Dart-to-
JavaScript dispatch, and typed request/response conversion. Platform-interface
tests pass 7/7 and changed-file analysis reports no issues.

**Required validation:** Android, iOS, Web, Windows, macOS, and Linux examples
must verify bridge readiness, event ordering, listener removal, page reload,
disposal, handler exceptions, JSON-compatible payloads, and backpressure under
rapid emits. The helper must not be used before the WebView can evaluate
JavaScript.

### #2570 — iOS Password AutoFill is not offered in `InAppWebView`

**Local status:** Host/application/site configuration boundary; no Forge package fix. **Affected scope:** iOS Password AutoFill, WKWebView, host-app entitlements, and the login site's HTML/domain association. **Impact:** iCloud Keychain suggestions appear in `ChromeSafariBrowser` but not in the reported `InAppWebView` login flow. **Confidence:** Needs host/device reproduction; the report has no HTML markup, Associated Domains entitlement, AASA response, or native comparison.

Apple's [Password AutoFill guidance](https://developer.apple.com/documentation/security/password-autofill) requires both the app's associated-domain setup and correctly identified fields; its [HTML guidance](https://developer.apple.com/documentation/security/enabling-password-autofill-on-an-html-input-element) calls for values such as `autocomplete="username"` and `autocomplete="current-password"`. Forge's iOS `preWKWebViewConfiguration` creates the standard `WKWebViewConfiguration`, process pool, and website data store, but exposes no plugin-owned Password AutoFill switch. The plugin also cannot add the consuming app's `webcredentials` entitlement, serve the site's `apple-app-site-association` file, or change a third-party login page's markup.

The different `ChromeSafariBrowser` result does not by itself establish a Forge regression: the two paths can use different app/domain association and browser credential contexts. No speculative native injection or credential bridge is justified without a physical-device comparison using the same domain, associated-domain entitlement, AASA response, and HTML form.

**Required evidence:** on a physical iOS device, verify the consuming app has `webcredentials:<domain>`, the domain serves a valid `apple-app-site-association`, the username/password fields use the required `autocomplete` values, and the same credential is available. Compare `InAppWebView`, `ChromeSafariBrowser`, and a minimal native `WKWebView` with the same URL and form; only implement a Forge change if the failure remains after those host/site prerequisites pass.

## Remaining validation and follow-up

The complete pending-runtime register is now maintained in
[runtime-validation-pending.md](runtime-validation-pending.md). It contains
74 locally implemented or mitigated issue records and seven PR-only records.
This section remains as a pointer so the detailed findings below can retain
the root cause and acceptance evidence without creating a second status list.

## Detailed findings

### PR #2243 - Android file chooser private-sandbox URI

**Local status:** Implemented in Android 1.0.41 and root 2.1.46; hostile
picker/provider runtime validation pending. **Impact:** A malicious third-party
file picker could return a `file://` URI into the host app's private data
directory, allowing the WebView to read and expose that file to page content.
**Confidence:** Confirmed native callback boundary from the upstream security
report.

The Android `InAppWebViewChromeClient` now canonicalizes file chooser paths to
collapse traversal segments, rejects paths under the host application's
canonical `ApplicationInfo.dataDir`, and applies a `/data/` defense-in-depth
check. The guard covers legacy single-URI results, modern single-select
results, and `ClipData` multi-select results. `content://` results and the
plugin's FileProvider capture URIs are not rejected.

The Android package suite passes 48/48 tests, `compileDebugKotlin`, and the
`assembleDebug` AAR task. **Remaining validation:** use an
external picker under test control to return private `file://` URIs, including
`../` traversal, mixed safe/private multi-select results, and API 19-35
provider variants; confirm the WebView receives no rejected URI and normal
content/capture selection still works. PR #2243 remains open upstream; no
upstream comment or state change was made.

### PR #2823 - Android audio capture file chooser

**Local status:** Implemented in Android 1.0.44 and root 2.1.51; audio
recorder/provider runtime validation pending. **Impact:** A page requesting
`audio/*` could open only the generic picker because the native chooser did not
offer or directly launch an audio recorder. **Confidence:** Confirmed missing
native intent path in the upstream PR and the Forge chooser implementation.

The Android `InAppWebViewChromeClient` now recognizes audio MIME types for
single-string and array accept lists. Capture-only audio requests use
`MediaStore.Audio.Media.RECORD_SOUND_ACTION` when the host has a recorder
provider; mixed chooser requests add the same intent only when it resolves.
Audio capture is intentionally independent of the camera permission guard used
for image and video capture. Recorder results continue through the existing
`Uri` callback path, so no channel or public Dart contract changes are needed.

**Remaining validation:** test `audio/*` and `audio/* capture`, mixed
`image/*,audio/*`, cancellation, returned `content://` URIs, missing recorder
providers, and camera-permission denied states on Android 10-16 and OEM WebView
providers. PR #2823 remains open upstream; no upstream state or comment was
changed.

### PR #2743 - Android WebAuthn support setting

**Local status:** Implemented in Android 1.0.45, platform interface 1.1.5,
and root 2.1.53; physical WebView-provider validation pending. **Impact:**
Android WebView pages can explicitly opt into WebAuthn support for the
embedding app or, where the host has the required privileges, browser-wide
support. **Confidence:** Confirmed AndroidX WebKit API and feature-gated
settings path; runtime credential behavior is not yet validated.

The platform interface now exposes `WebAuthenticationSupport.NONE`,
`FOR_APP`, and `FOR_BROWSER`, together with `WebViewFeature.WEB_AUTHENTICATION`.
Android preserves WebView's default disabled behavior when the setting is
`null`, applies the selected level only after the AndroidX feature check, and
round-trips the effective value through `getRealSettings`. Unsupported WebView
providers therefore keep the existing default path rather than receiving an
unguarded compat call.

**Remaining validation:** on Android 12-16 and representative OEM WebView
providers, verify `NONE`, `FOR_APP` with valid Digital Asset Links, and
`FOR_BROWSER` only for an appropriately privileged host. Exercise successful,
cancelled, and unavailable authenticator flows and confirm the effective
setting reported by `getRealSettings`. PR #2743 remains open upstream; no
upstream state or comment was changed.

### #2660 - Android Payment Request / Google Pay

**Local status:** Implemented in Android 1.0.46, platform interface 1.1.6,
and root 2.1.54; WebView-provider and physical-device validation pending.
**Impact:** Android WebView keeps the Payment Request API disabled by default,
so Google Pay pages cannot reach the Android WebView payment bridge unless the
embedding app explicitly enables the capability and satisfies Google's host,
provider, and merchant requirements. **Fix:** the public nullable
`InAppWebViewSettings.paymentRequestEnabled` setting is serialized through the
platform interface, exposed by `WebViewFeature.PAYMENT_REQUEST`, applied only
after `WebViewFeature.isFeatureSupported`, and returned by `getRealSettings`.
The Android library manifest declares the Chromium `PAY`, `IS_READY_TO_PAY`,
and `UPDATE_PAYMENT_DETAILS` intent queries required by the Payment Request
bridge. When the feature is unavailable or the setting is `null`, the plugin
does not make an unguarded compat call and preserves the WebView default.

**Required validation:** exercise enabled and disabled Payment Request flows
on Android 12-16 with current Google WebView and representative OEM providers;
verify `IS_READY_TO_PAY`, successful and cancelled transactions, missing or
unavailable payment apps, merchant/host publication requirements, and the
`GOOGLE_PAY_SUPPORTED` suffix when a host supplies a custom user agent. The
manifest queries are plugin support; merchant configuration, Google Pay
publication, and any host-app permissions or policy remain the consuming
application's responsibility. The focused platform-interface and Android
tests plus `compileDebugKotlin` and `assembleDebug` pass.

### #2834 - Android Sec-CH-UA and Client Hints customization

**Local status:** Implemented in Android 1.0.47, platform interface 1.1.7,
and root 2.1.55; WebView-provider and physical-device validation pending.
**Impact:** Android WebView can emit `Sec-CH-UA` and related User-Agent Client
Hints while the plugin previously exposed only the legacy User-Agent string.
**Fix:** the Android-only nullable `InAppWebViewSettings.userAgentMetadata`
map accepts `brandVersionList`, `fullVersion`, `platform`, `platformVersion`,
`architecture`, `model`, `mobile`, `bitness`, and `wow64`; malformed brand
entries are filtered and `WebSettingsCompat.setUserAgentMetadata` is called
only when `WebViewFeature.USER_AGENT_METADATA` is available. Unknown fields
are ignored and unsupported WebViews retain their previous behavior.

This is a metadata customization API, not a guarantee that all Client Hints
headers can be suppressed: Chromium and the installed WebView still control
final header generation. **Required validation:** Android 12-16 with current
Google WebView and representative OEM providers, comparing configured
metadata with request headers and `navigator.userAgentData`, including custom
User-Agent strings, empty/partial metadata, feature-unavailable providers,
and navigation/request interception behavior.

### #2846 - Android AGP 9 built-in Kotlin compatibility

**Local status:** Implemented in Android 1.0.48 and root 2.1.56; AGP 9,
Flutter >=3.47, and consuming-app validation pending. **Impact:** AGP 9's
built-in Kotlin model rejects plugins that force-apply the Kotlin Gradle
plugin. **Fix:** the Android library and both Forge example application
modules no longer apply `org.jetbrains.kotlin.android` from the `plugins`
block. They apply it only when the AGP major version is below 9 and configure
the Kotlin JVM target through `KotlinAndroidProjectExtension`. The root
example also no longer forces `android.builtInKotlin=false` or
`android.newDsl=false`.

**Required validation:** Flutter >=3.47 with AGP 9, Gradle 9, JDK 17, and
`android.builtInKotlin=true`; the legacy AGP 8/Flutter 3.44 path; both example
applications; plugin compile, release, and AAB tasks; and generated plugin
registrants. The Android static migration regression passes, but the current
environment does not provide the target Flutter/AGP 9 matrix.

### PR #2853 - iOS platform-view focus recovery

**Local status:** Implemented in iOS 2.1.25 and root 2.1.52; physical focus
validation pending. **Impact:** `requestFocus()` could return `false` and leave
`document.hasFocus()` false when an iOS WebView was embedded as a Flutter
platform view. **Confidence:** Confirmed native responder-selection path in
the upstream PR and the Forge implementation.

The iOS `InAppWebView.requestFocus()` implementation now walks the WebView
subtree, selects the first view that can become first responder, and falls back
to the WebView itself. Dart, platform-interface, and channel contracts remain
unchanged; `clearFocus()` is intentionally outside this focused fix.

**Remaining validation:** exercise `requestFocus()` after tab/platform-view
reattachment, verify `document.hasFocus()` and window focus events without a
physical tap, and compare iOS 15-26 device behavior with a minimal native
`WKWebView`. PR #2853 remains open upstream; no upstream state or comment was
changed.

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

**Status:** Hardened in Android 1.0.37 (root 2.1.40); device/provider validation pending. **Impact:** Runtime crash after upgrading to the 6.2 beta line. **Confidence:** Confirmed path.

Issue [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856) reports `type 'Null' is not a subtype of type 'String'`. The Android event handlers currently read platform-channel values as non-null strings, for example `origin` and `resources` in `InAppWebViewController`’s `onPermissionRequest` handler, and `url` in the safe-browsing handler. Native WebView callbacks can omit or change optional fields across OS/WebView versions.

The Android Dart event dispatcher now validates nullable and non-string `origin`, `url`, title, callback IDs, and other optional string values before constructing public types or dispatching callbacks. The permission request and cancellation paths additionally validate the channel map and resources container, normalize string resource entries, and return native default behavior for malformed payloads. It filters unknown permission-resource entries and uses an empty title for a context-menu item when Android omits or corrupts its optional title. Missing data in geolocation, permission, and safe-browsing callbacks returns control to the native default behavior. Regression coverage exercises null and wrong-type callback payloads, including a valid-origin/non-list-resources payload and malformed cancellation payloads.

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

### #2830 — Xcode 26 `WebAuthenticationSession` availability compile failure

**Local status:** Implemented in iOS 2.1.19 and macOS 1.1.6; source-validated with the Xcode 27 iOS example build passing. Exact Xcode 26.4.1 and macOS consuming-app validation remain pending. **Affected package:** iOS/macOS native `WebAuthenticationSession`. **Impact:** Xcode 26 diagnoses the direct `ASWebAuthenticationPresentationContextProviding` conformance because the `presentationAnchor(for:)` witness has a narrower platform availability boundary than the enclosing session class. **Confidence:** Confirmed build compatibility path from upstream [PR #2809](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2809).

The Forge implementation now keeps `WebAuthenticationSession` as a plain disposable session and supplies a retained, availability-gated presentation-provider object only on iOS 13+ or macOS 10.15+. The existing active-window and visible-window fallback behavior is preserved, and the provider is released during disposal. iOS/macOS source tests and Swift Package manifest checks pass. The macOS example build is currently blocked by the existing Xcode 27 project/Pods deployment target mismatch (`10.15` versus the toolchain's supported `12.0` minimum), which is separate from this Swift source fix.

**Required evidence:** build the iOS and macOS consuming examples with Xcode 26.4.1 and the supported CocoaPods/SPM configurations, then start/cancel/complete authentication sessions across the supported deployment targets and confirm the presentation anchor remains valid after scene/window changes.

### #2725 — Windows WebView2 title lookup

**Status:** Fixed in Windows 1.0.5 and covered by Windows regression assertions. **Impact:** Calling `getTitle()` could return the current URL instead of the document title. **Confidence:** Confirmed native method path.

The native implementation uses `ICoreWebView2.get_DocumentTitle` and converts the result to the Dart response. Static Windows coverage now protects this method from regressing to URL lookup.

### #2741 — macOS `upgradeKnownHostsToHTTPS` unavailable selector

**Status:** Fixed in macOS 1.1.1. **Impact:** Accessing `WKWebViewConfiguration.upgradeKnownHostsToHTTPS` on macOS versions before 11.3 could crash with an unavailable-selector error. **Confidence:** Confirmed API availability mismatch.

The initial configuration path, runtime settings update path, and real-settings readback now guard the property with `if #available(macOS 11.3, *)`. Older macOS versions retain the default behavior without sending the unsupported selector.

### #2852 — Android ProGuard default file

**Status:** Fixed and protected in Android 1.0.8. **Impact:** Android release builds can fail when a legacy or unavailable `proguard-android.txt` filename is used. **Confidence:** Confirmed build configuration path.

The Android Gradle configuration uses the available `proguard-android-optimize.txt` default file for release and profile configurations. A package test asserts that the optimized filename remains present and the legacy filename does not regress into the build configuration.

### #2837 — Android WebView white screen after screen lock

**Status:** Fixed in Android 1.0.8; validate on Android 10 and affected OEM/device combinations. **Impact:** After a long screen-lock period, the WebView could remain visually blank until a touch or scroll triggered a redraw. **Confidence:** Strong report with a lifecycle rendering path.

When the WebView window becomes visible again, the Android implementation now schedules an animation invalidation and requests layout after forwarding the visibility callback. This keeps the redraw explicit without forcing a navigation or destroying the WebView state. A static regression assertion protects the visibility recovery path. The opt-in [`android_screen_lock_redraw_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_screen_lock_redraw_diagnostic_test.dart) reached a real ADB lock/unlock checkpoint on the API 35 `emulator-5554`; the DOM marker and URL survived and no AndroidRuntime, fatal, or renderer crash appeared in the captured log. On 2026-08-11, the Samsung A16 passes the same checkpoint in hybrid and virtual-display composition with clean test exits; the hybrid run has one system ActivityManager freeze warning but no app failure. Android 10 and affected OEM/device validation remain required.

#### #2721 — Android WebView display-size recovery

**Local status:** Implemented and source-validated; Android 16/API 36 and OEM WebView runtime validation pending. **Affected package:** Android hybrid-composition WebView geometry/lifecycle. **Impact:** after returning from Android accessibility or display-size settings, the WebView could retain stale geometry or redraw state; the report also includes a provider renderer crash during the visibility/dispose/recreate sequence. **Confidence:** Strong report; the geometry path is confirmed, while the renderer-crash cause remains provider-specific.

`InAppWebView` now shares an idempotent geometry-refresh helper between visibility recovery and `onSizeChanged`. A real size change calls `super.onSizeChanged`, invalidates the view, and requests layout; visibility recovery uses the same helper and ignores disposed instances. This keeps the native WebView bounds and redraw path synchronized when Android changes display metrics without forcing navigation or recreating the WebView. The Android source regression test and example APK/AAR build pass; this mitigation does not claim to eliminate a provider-owned Chromium renderer crash without device evidence.

The opt-in [`android_display_size_recovery_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_display_size_recovery_diagnostic_test.dart) builds and starts on the API 35 AVD. Host-driven `adb shell wm size` change/reset operations temporarily make the AVD report `offline` and disconnect the Flutter VM service before the geometry assertion; no Forge/native crash is present in the captured log. On 2026-08-11 and again on 2026-08-12, the same reversible override on the Samsung A16 restarted the example activity/VM service before the geometry assertion; the Activity remained up, no app crash or ANR was recorded, but no geometry result was produced. This is a display-override/harness limitation, not runtime proof of the fix.

**Required evidence:** Android 16/API 36 accessibility/display-size changes with hybrid composition, API 35/36 and OEM WebView providers, native frame/bounds before and after the settings change, no renderer crash, no stale size, and no duplicate navigation/dispose callbacks.

### #2855 — macOS custom context-menu items do not render

**Status:** Fixed in macOS 1.1.1; validate on macOS 10.14+ with native right-click menus. **Impact:** Dart-provided `ContextMenu.menuItems` were never added to the native `WKWebView` menu and their actions could not reach Dart. **Confidence:** Confirmed missing native hook.

The macOS `WKWebView` now receives the initial and runtime `ContextMenu` configuration, uses AppKit’s `willOpenMenu`/`didCloseMenu` hooks to add custom `NSMenuItem` instances, and forwards `onCreateContextMenu`/`onHideContextMenu` lifecycle events. Targets are retained only while the menu is open, each action forwards its id/title through `onContextMenuActionItemClicked`, and numeric item identifiers are normalized without force-casting. The optional setting to hide default menu items is also honored.

### #2878 — Keyboard remains unavailable after exiting HTML5 fullscreen

**Status:** Source-hardened in Android 1.0.34 (root 2.1.35); the workaround-free Samsung A16 diagnostic passes, while Android 10/OEM and broader physical-device validation remain pending. **Impact:** The soft keyboard stops opening throughout the host app until the app is backgrounded/resumed or restarted. **Confidence:** Strong report.

The issue reproduces after `onShowCustomView`/`onHideCustomView` fullscreen cycles with hybrid composition. The native path removes the custom view, restores system UI/orientation, invokes `onExitFullscreen`, and clears fullscreen state in `InAppWebViewChromeClient.onHideCustomView()`. The repository also has custom IME proxy/focus handling in `InputAwareWebView.kt`. Together, this points to an IME/window association that is not restored when the fullscreen view is detached.

The reported workaround is invoking Flutter’s `TextInput.show` after exiting fullscreen, but that only masks the native lifecycle problem. The Forge implementation now retains the Flutter container view for hybrid composition and, after custom-view removal, requests focus and restarts the input connection on that actual Flutter view. The existing non-hybrid input proxy is reset as part of the same path.

An opt-in diagnostic is available at
[`flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_fullscreen_keyboard_diagnostic_test.dart).
It uses a real HTML5 fullscreen request from a tapped page button, exits through
the page API, then focuses a separate Flutter `TextField`. The existing API 35
pass (`insetBeforeFocus=0.0`, `insetAfterFocus=24.0`) invokes
`SystemChannels.textInput.show`, so it is not independent proof of the native
restoration path. Two workaround-free attempts on `emulator-5554` with WebView
124 lost the Flutter VM service and then reported the AVD offline before the
keyboard assertion; no AndroidRuntime, ANR, or app crash was captured. On
2026-08-11, the workaround-free diagnostic passes on the Samsung A16
(`SM-A165F`, Android 16/API 36, WebView 150.0.7871.181), with
`insetBeforeFocus=0.0`, `insetAfterFocus=346.31`, and an active Flutter focus
node. Android 10/OEM and broader physical-device validation remain required.

**Remaining validation:** run a real-device regression covering fullscreen → exit → text input in a different Flutter widget, especially Samsung One UI and WebView 150+.

### #2819 — MediaTek fullscreen surface failure leaves a frozen WebView

**Status:** Hardened in Android 1.0.29 and Android 1.0.35; the Android package suite passes 49/49 tests as of 2026-08-10, while MediaTek/gralloc runtime validation remains pending. **Impact:** On affected MediaTek devices, a GPU/gralloc failure during fullscreen video can remove the native surface without firing the normal exit/error callbacks. The screen then remains black/white and fullscreen state is stale. **Confidence:** Strong report.

Issue [#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819) includes native gralloc errors and reports that neither `onExitFullscreen`, `onRenderProcessGone`, nor `onReceivedError` is delivered. The upstream follow-up identifies the reproducible shape as the Vimeo content on `https://iframely.com/domains/vimeo` entering fullscreen, internet being disabled, and a banner or popup overlay being shown. This is a different failure mode from a normal `onHideCustomView` callback: cleanup must also be robust when the renderer or surface disappears first.

`FlutterWebView.dispose()` now checks the fullscreen state before destroying the WebView, asks the chrome client to remove the custom view, and emits the exit callback/state reset fallback if the activity or custom-view callback is already unavailable. The renderer-loss callback now uses the same idempotent fullscreen cleanup before forwarding `onRenderProcessGone`, covering the path where a renderer/surface failure arrives before `onHideCustomView()`. The normal fullscreen/exit path passes on the Samsung A16 (`SM-A165F`, Android 16/API 36, MediaTek MT6789, WebView 150.0.7871.181) through the #2878 diagnostic. On 2026-08-12, the opt-in [`android_renderer_fullscreen_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_renderer_fullscreen_diagnostic_test.dart) also enters the IFramely-generated direct Vimeo iframe in hybrid composition; after Wi-Fi is disabled during fullscreen, a black/loading surface is observed, but `onExitFullscreen` is delivered, `onRenderProcessGone` is not delivered, `fullscreenState=false`, and the test exits without an app crash or ANR. The upstream banner/popup plus forced MediaTek gralloc/renderer-loss path was not reproduced. A physical test using that exact page, network loss, overlay, and renderer teardown remains required before release.

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

**Status:** Mitigated in Linux 1.0.5; Fedora/X11/Intel runtime validation remains pending. **Impact:** On Fedora/X11 with Intel i915, the default DMA-BUF/EGL path can show a black screen; disabling GL previously could result in a white/transparent but interactive view. **Confidence:** The reported rendering-path analysis is consistent with the native source.

The local implementation makes `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` select software WPE buffers, sets `LIBGL_ALWAYS_SOFTWARE=1` before WPE starts, and skips EGL import so the pixel-buffer path receives CPU-readable frames. This may have a substantial performance cost.

**Remaining validation:** reproduce on supported Fedora/X11/Intel combinations, collect backend logs, and compare before/after frame output.

### #2688 — Android first navigation to a Flutter screen flickers

**Local status:** Host/platform-specific boundary; no Forge package fix. **Affected scope:** Android WebView/platform-view transition, Flutter route animation, and Android surface ordering. **Impact:** the upstream report says the first navigation from a WebView page to a native Flutter screen briefly displays WebView content and that subsequent transitions are noticeably slow. **Confidence:** Android 35 behavioral and visual evidence does not reproduce the reported failure, and source review found no Forge-owned route-animation or surface-ordering control point.

The opt-in diagnostic at
[`flutter_inappwebview_forge/example/integration_test/android_screen_transition_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_screen_transition_diagnostic_test.dart)
passes on `emulator-5554` (API 35) with hybrid composition
(`webViewCreated=true`, `destinationPresent=true`, `webViewPresent=false`,
45 frame timings), virtual-display composition
(`loadStopObserved=true`, `destinationPresent=true`,
`webViewPresent=false`, 45 frame timings), and the example's direct native
`android.webkit.WebView` baseline (`destinationPresent=true`,
`webViewPresent=false`, 45 frame timings). The virtual-display run logs a
roughly 2.97-second startup `Davey`/GC stall before the WebView is hosted, but
this is a startup performance signal, not the reported transition flicker.

The latest hybrid run was also captured externally with ADB. The sampled
frames show a direct blue WebView-surface to orange Flutter-destination
transition with no blank, black, or returning WebView frame. The
`integration_test` screenshot API remains unsuitable for this run because it
blocked on the hybrid path; the external capture is the visual evidence used
for this local classification. This is not an upstream closure or a Forge
code fix. If the symptom recurs, capture the exact host app, Flutter version,
Android SDK/System WebView provider, composition mode, route animation, and a
minimal host comparison before reopening implementation work.

### #2680 — Android audio `ERR_FAILED` on mobile data

**Local status:** Host/provider boundary; no Forge-owned fix identified. **Affected scope:** Android WebView media/network delivery. **Impact:** the report describes an MP3 request that works on Wi-Fi but fails with `ERR_FAILED` on mobile data after an upgrade to target SDK 35; follow-up evidence identifies a Cloudflare `206 Partial Content` response whose body is empty in WebView inspection, while `webview_flutter` succeeds. The upstream record was stale-closed on 2026-08-07; the supplied export remains historical metadata and this local classification is not an upstream state change.

Source review found no Forge-owned audio transport or default interception change that can be safely patched: `shouldInterceptRequest` only returns a response when the application enables the callback and supplies one, otherwise Android WebView continues the request. The issue therefore remains visible for provider/carrier tracking, but is not counted as active Forge implementation work. Reopen the local implementation boundary only if the exact URL with request/range headers, Android System WebView version, API level, carrier, and `useShouldInterceptRequest` state reproduces in Forge while a native `WebView` and `webview_flutter` do not.

### #2872 — Windows `loadFile` and WebView2 file-origin semantics

**Status:** Fixed in Windows 1.0.4; validate on a Windows WebView2 runtime. **Impact:** `loadFile("assets/.../index.html")` can produce an unusable page because local subresources are blocked under the `file:` origin. **Confidence:** Strong report; the original file-navigation path is confirmed.

The Windows implementation resolves the Flutter asset to `data/flutter_assets/...` and passes the filesystem path to WebView2 `Navigate`. Issue [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872) reports that the resulting `file:` page has a unique security origin and cannot load the expected resources.

**Implementation:** Windows now validates that the requested Flutter asset is relative and stays inside `data/flutter_assets`, maps that directory to `https://flutter-inappwebview-forge.local` with WebView2's `DENY_CORS` access mode, percent-encodes the asset URL, and navigates through the virtual origin. Relative CSS, JavaScript, media, and fetch/XHR references therefore stay within a normal origin. Older WebView2 runtimes without `ICoreWebView2_3` retain the legacy file-navigation fallback and emit a diagnostic log.

**Remaining validation:** load an asset tree containing relative CSS, JavaScript, images, and nested URLs on Windows 10/11 with the supported WebView2 runtime.

### #2867 — iOS/Xcode-specific `EXC_BAD_ACCESS` in multi-window navigation

**Status:** Hardened in iOS 2.1.22; iOS 15–26/Xcode 16/26 device validation remains. **Impact:** Potential native crash or lost JavaScript callback during `window.open`/multi-window flows. **Confidence:** The issue identifies a plausible evaluation/KVO path, but the report still lacks a usable symbolicated stack trace.

Issue [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867) reports different behavior across Xcode 16/26 and iOS 18/26 while a popup WebView overrides JavaScript evaluation and handles `shouldOverrideUrlLoading`. The affected popup can receive KVO/navigation callbacks before Flutter attaches its platform view, and shared popup configurations can crash when WebKit evaluates against an uninitialized content world or stale frame.

**Implementation:** popup window-ID JavaScript initialization now stops until the platform view is attached, defers evaluation off KVO, deduplicates initialization per navigation, and ignores stale KVO objects after disposal. Popup `evaluateJavaScript`, `callAsyncJavaScript`, and generated content-world injections use the initialized page world across the supported iOS range, following the upstream workaround in [PR #2776](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2776). Pending native and legacy async JavaScript callbacks are also drained with a structured `WebView navigation started` error before a new provisional navigation, so the Dart future cannot remain unresolved when WebKit cancels the old document. A fresh 2026-08-10 `flutter drive` run of `ios_multi_window_navigation_diagnostic_test.dart` passes three cycles on the iPhone 17 Pro iOS 26.2 Simulator, including popup attach/dispose, page/custom-world evaluation, `shouldOverrideUrlLoading`, and an async-navigation race; no `EXC_BAD_ACCESS`, `SIGSEGV`, `SIGABRT`, or fatal Simulator log is present. This is a targeted mitigation, not proof that every Xcode 26/iOS 18 crash is resolved.

**Remaining validation:** run `window.open` with popup navigation, `shouldOverrideUrlLoading`, both JavaScript APIs, generated content-world scripts, and popup disposal across iOS 15–26 with Xcode 16 and 26; collect a symbolicated crash if the failure persists.

### #2771 — iOS `evaluateJavaScript` receives a nil frame

**Status:** Fixed in iOS 2.1.2; run the iPad and multi-frame device matrix. **Impact:** WebKit can terminate the application when the content-world evaluation overload receives a nil `WKFrameInfo`. **Confidence:** Confirmed native call boundary and upstream fix.

Issue [#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771) identifies the iPad crash path as an unsafe `evaluateJavaScript(_:in:in:)` call with no frame. The Forge implementation now keeps the existing page-world popup fallback, then returns a structured `NSError` before reaching the native content-world overload when a regular WebView still has no frame. This turns a process-level WebKit failure into a reportable JavaScript evaluation error.

**Remaining validation:** exercise `evaluateJavascript` from the main frame, an iframe, and an iPad `onCreateWindow` flow on iOS 15–18. Confirm that the Dart callback receives an error and the process remains alive when the frame is unavailable.

### #2871 — iOS `callAsyncJavaScript` crashes before iOS 18

**Status:** Fixed in iOS 2.1.2; validate on iOS 15–17 and iOS 16.0.x. **Impact:** Page-world async JavaScript could enter WebKit's unstable content-world implementation, while popup and legacy result delivery could lose the callback. **Confidence:** Confirmed compatibility split from the upstream patch.

The iOS implementation now registers a native result message handler for the pre-iOS 14 compatibility shim, routes page-world calls through that shim on iOS 15–17, preserves native custom-world isolation on iOS 16.1+ and iOS 18+, and returns an explicit error for custom worlds on iOS 16.0.x. Popup WebViews continue to use the page world because their shared configuration does not reliably expose the bridge handler. Result messages carry the WebView window id so popup callbacks resolve on the correct transport.

**Remaining validation:** run page-world and custom-world calls with resolved and rejected promises, JSON-serialization failures, popup WebViews, and disposal during an outstanding call on iOS 15, 16.0, 16.1, 17, and 18.

### #2474 — Android WebMessageListener on older WebView providers

**Status:** Fixed in Android 1.0.9; validate with Android 10 and older provider versions. **Impact:** `addWebMessageListener` returned success but did not create the JavaScript object when `WEB_MESSAGE_LISTENER` was unavailable, so JavaScript `postMessage` callbacks never reached Dart. **Confidence:** Confirmed missing fallback path.

When AndroidX WebKit does not expose the native listener feature, the Android implementation now installs a document-start JavaScript listener object and dispatches its messages through the existing bridge channel. Origin rules are checked in JavaScript and again in Kotlin, and ArrayBuffer payloads are converted to `ByteArray` before the normal `WebMessageCompatExt`/Dart serialization path. Native providers keep using the official `JavaScriptReplyProxy` implementation.

**Remaining validation:** test Android 10 or below with the system WebView and Chrome providers, explicit and wildcard origin rules, main-frame and iframe messages, string and ArrayBuffer payloads, and a disabled JavaScript bridge.

## Additional findings from the full CSV review

### #2849 and #2843 — Android cold-start initialization race

**Status:** Hardened in Android 1.0.38 (root 2.1.41); API 35 headless validation now passes, while physical-device and release/provider validation remain. **Impact:** A headless WebView can crash with `Must be started before we block!`; a release/AOT build can also fail to fire `onWebViewCreated` on roughly half of cold starts. **Confidence:** Strong report; the relevant synchronous initialization path is present in the repository.

Issue [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849) identifies `WebViewCompat.addDocumentStartJavaScript` being called before the Chromium engine is ready. In the review baseline, `InAppWebView.prepare()` synchronously registered the JavaScript bridge and called `prepareAndAddUserScripts()`, while `UserContentController` invoked `addDocumentStartJavaScript` directly. Issue [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) additionally reports that this synchronous platform-view work can prevent the Dart platform-view-created callback from arriving in release builds when the JavaScript bridge is enabled.

This is directly relevant to the dependency update: the issue proposes the stable asynchronous startup API from `androidx.webkit:webkit:1.16.0`, but that would require a `minSdk` decision because this package still declares `minSdkVersion 19` and currently uses WebKit `1.14.0`.

**Implementation:** the Android plugin now requests AndroidX WebKit’s asynchronous provider startup at engine attach, waits for that callback before headless bridge/document-start registration, defers regular platform-view registration until Flutter attaches the view, retries transient script-registration failures, and waits for registration before the first load. If a provider leaves the startup callback pending, the coordinator now releases the first-load gate after a bounded five-second timeout and lets the existing bridge/document-start retry path continue. The coordinator also recreates its executor after engine detach and ignores stale startup generations during reattach. The WebKit dependency remains `1.14.0` so the package can keep its `minSdkVersion 19`; do not upgrade to 1.16.0 without deciding whether the minimum SDK can change. The opt-in profile/AOT diagnostic passes four clean installs on the API 35 AVD with WebView 124 (`created=true`, `loaded=true`, bridge and document-start values both `object`). On 2026-08-11, the opt-in [`android_headless_cold_start_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/android_headless_cold_start_diagnostic_test.dart) also passes four headless create/load/dispose cycles with an `AT_DOCUMENT_START` bridge marker (`bridgeType=object`, `bridgeAtDocumentStart=object` for every cycle); the general headless suite passes 6/6. No app `AndroidRuntime`, ANR, or native fatal was captured. Explicit headless disposal emits the known Chromium renderer exit code `-1`, matching the teardown signature tracked separately under external #2491, but the test exits 0. **Remaining validation:** run release/R8 and provider cold starts on physical Android devices, including detach/reattach cycles.

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

**Status:** #2580 is source-fixed in Android 1.0.34 and passes the fresh 2026-08-10 API 35/WebView 124 rapid-navigation diagnostic without an app `AndroidRuntime`, fatal, ANR, or OOM log; physical Android 10/11 OEM/provider validation remains pending. #2718 is source-fixed in Android 1.0.43: asynchronous cookie mutations avoid the UI-thread flush and the explicit `flush` MethodChannel result now completes; Android 10/provider and Play Console validation gates remain. #2555 retains its separate Android 10 IME validation gate; fresh API 35 and 2026-08-11 Samsung A16 runs pass both composition modes and restore the Flutter keyboard after WebView disposal without an AndroidRuntime, fatal, or IME NPE. **Impact:** WebView deadlock/freeze, cookie-cleanup ANR, or Android 10 IME crash. **Confidence:** Strong report for #2580/#2718; #2555 is an older device-specific crash.

For [#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), the native `shouldInterceptRequest` path can synchronously wait for a Dart result through `Util.invokeMethodAndWaitResult`, which posts to the main looper and then blocks on a latch. This is a plausible deadlock when WebView resource callbacks and UI-thread work depend on each other. [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718) shows a Play Console native trace through `MyCookieManager.deleteAllCookies`, where `removeAllCookies` was followed immediately by `flush`. Android 1.0.42 removes the same blocking persistence call after asynchronous `setCookie`, `deleteCookie`, and `deleteCookies` mutations; Android 1.0.43 also completes the explicit `flush` result so the Dart future cannot remain pending after the native request. [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555) reports an `InputMethodManager` null crash on Android 10 and is related to the same general focus/lifecycle surface as #2878.

The API 35 diagnostic then exposed a second Forge-owned failure in the rapid-navigation path: the Kotlin migration's `injectDeferredObject` implementation called the plugin's three-argument `evaluateJavascript` overload from inside itself instead of the platform two-argument `WebView.evaluateJavascript` method. Each evaluation re-entered the injection queue, and 24 rapid `loadData` navigations grew the main-thread heap until `OutOfMemoryError`. Android 1.0.34 now calls `super.evaluateJavascript`, with a source regression test covering the overload boundary. On `emulator-5554` (API 35, WebView 124), the fresh 2026-08-10 opt-in diagnostic completes all rapid navigations, reports `finalLoaded=true`, reaches the `final` DOM marker, records 31 interception callbacks, and exits without an app fatal crash, ANR, or OOM. The same diagnostic passes on 2026-08-11 on the Samsung A16 (`SM-A165F`, Android 16/API 36, WebView 150.0.7871.181); the filtered log contains only Chromium tile-memory warnings, not an app crash, ANR, or OOM.

The Forge implementation now caps concurrent synchronous resource-interception callbacks at two, dispatches `shouldInterceptRequest` and Service Worker interception to the front of the main looper queue, and uses a 250 ms callback timeout for this path. Queued dispatches are removed after timeout and late callback results are ignored; saturated or timed-out requests fall back to normal WebView loading. Android cookie mutations no longer call the blocking `flush()` immediately after asynchronous updates, and the explicit Flutter `flush` API now receives a successful completion result after the native request. The input-aware WebView requires both the container and target views to have an attached window/token before touching the IME connection, catches stale Android 10 IME runtime failures, and ignores detached delayed callbacks. The source regression suite covers the timeout, priority dispatch, backpressure, no-immediate-flush, explicit-flush completion, and detached-IME contracts.

The opt-in [`android_ime_lifecycle_diagnostic_test.dart`](../flutter_inappwebview/example/integration_test/android_ime_lifecycle_diagnostic_test.dart) passes on the API 35 AVD for both virtual-display and hybrid composition, including a fresh 2026-08-10 run: the HTML input becomes active, the WebView is cleared/disposed, and a separate Flutter input reopens the keyboard with a `24.0` bottom inset. No `AndroidRuntime`, fatal, or `InputMethodManager` NPE appears. This supports the lifecycle guard on a modern provider; Android 10 and OEM validation remains a release gate.

The existing remote-URL Cookie Manager integration test built and installed on
the API 35 `emulator-5554`, but timed out after 60 seconds before reaching its
cookie assertions. A fresh isolated `flutter drive` attempt on 2026-08-10
installed the test but Flutter 3.44.8 failed during VM-service setup with
`registerService: (-32000) Service connection disposed`. Neither attempt
captured an app fatal AndroidRuntime or ANR, but neither completed the cookie
flow, so this is not accepted as runtime proof. The new local diagnostic does
not depend on that remote page: on 2026-08-11 it completes 10/10 mutation and
explicit-flush cycles on the Samsung A16 (`SM-A165F`, Android 16/API 36,
MediaTek MT6789, WebView 150.0.7871.181), with durations from 21 to 279 ms and
an empty final cookie list. The filtered log contains only Chromium tile-memory
warnings. Android 10/provider and Play Console validation remain required.

The Android example build was also checked with the configured Flutter
toolchain. JDK 24 plus Gradle 8.13 fails before plugin Kotlin compilation while
creating `:app:outgoingVariants` (`OutgoingVariantsReportTask`, `Type T not
present`), while JDK 21 completes `assembleDebug` and the plugin's Kotlin
compilation. The JDK 21 release path reaches and completes the plugin's
`syncReleaseLibJars`, then fails at the generated example registrant because
the dev-only `integration_test` class is not on the release Java classpath.
Repeat release validation on the documented JDK 17 baseline with a clean
example/test harness before treating the final artifact gate as complete.

**Remaining validation:** run rapid back/forward navigation with `shouldInterceptRequest` on Android 10/11 physical OEM devices (including the reported Xiaomi/WebView provider family), repeat against current and updated System WebView providers, run Play Console cookie-clear scenarios, and run Android 10 text-input tests on physical devices.

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

### #2757 — pub.dev Pana analysis fails on disabled lint overrides

**Local status:** Implemented in the federated analysis configuration; full pub.dev/publish validation pending. **Affected scope:** package analysis and pub.dev platform-support scoring. **Impact:** Pana 0.23.3 crashes before analysis when a package's `linter.rules` map uses the string `ignore` value, preventing analysis results and platform badges from being generated. **Confidence:** Confirmed tool failure and configuration fix.

The related upstream [PR #2758](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2758) changes disabled linter overrides from `ignore` to boolean `false`. Forge applies the same compatibility fix across the federated package analysis options. In an isolated package, Pana 0.23.3 reproduces the `type 'String' is not a subtype of type 'bool'` failure with the old form and passes static analysis with the boolean form. The current Pana 0.23.17 tool also no longer contains that type assumption.

**Remaining validation:** run Pana against the published Forge package set (or a complete local package graph with all dependency overrides) and retain the publish/platform-badge report. This record remains in the runtime validation register until that release gate passes.

### #2641 and #2685 — Android Java/WebView deprecation warning backlog

**Local status:** Implemented in Android 1.0.40; release/provider/publish validation pending. **Affected scope:** Android Kotlin/WebView compatibility and package release tooling. **Impact:** Android/Flutter upgrades exposed deprecated API warnings and obscured package-owned compatibility problems in analysis or publish output. **Confidence:** Confirmed warning paths; the compatibility boundaries are now explicit and validated at source/build level.

GitHub CLI review of upstream PR [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817) maps the current implementation to the maintained Kotlin package: the shared callback handler uses `Looper.getMainLooper()`, session-cookie clearing uses `removeSessionCookies(null)` on API 21+ and the legacy synchronous method only below API 21, and legacy cookie, WebView, print, fullscreen, and API-level compatibility paths are isolated with file-level deprecation boundaries. The public method-channel contract and API 19 fallback are unchanged; `forceDark`, `saveFormData`, `AbsoluteLayout`, legacy print, and deprecated WebView callbacks are retained where no behavior-preserving replacement exists for the supported API range.

The Android package suite passes 47/47 tests. `compileDebugKotlin` and the example debug APK build pass without package-owned Java/Android deprecation diagnostics. A direct release compile is still blocked by the generated dev-only `integration_test` registrant, and the normal Flutter release command is blocked in this environment by Flutter's stale configured Android Studio JDK path; these are release/toolchain gates rather than new plugin source failures.

**Required evidence:** regenerate a clean release registrant with a valid configured JDK, run JDK 17/21 Android release and AAB builds, inspect generated artifacts, complete provider/device coverage, and retain the publish dry-run output. Until those gates pass, #2641/#2685 remain in the runtime-validation register rather than being treated as fully resolved.

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

### #2787 — iOS keyboard dismissal leaves a reduced `visualViewport`

**Local status:** Source-fixed in iOS 2.1.20; a fresh iPhone 17 Pro iOS 26.2 Simulator run passes, with physical iOS 17/device validation pending. **Affected scope:** iOS WebKit visual viewport and Flutter platform-view geometry. **Impact:** after an HTML keyboard was dismissed, `visualViewport.height` could remain smaller than the Flutter WebView and fixed-position page elements could appear offset from the bottom. **Confidence:** Confirmed Forge-owned path with source regression coverage and repeatable Simulator evidence; physical-device confidence remains pending.

This report is distinct from #2859. #2859 covers stale native `UIScrollView.contentInset` restoration; #2787 exposed a second state mismatch where UIKit restored the frame and inset but WebKit retained a keyboard-induced zoom scale and DOM viewport. The fix retains the pre-keyboard `zoomScale` and `contentOffset`, restores them after `keyboardDidHide`, and refreshes the final platform-view frame/layout so WebKit recalculates its visual viewport. Upstream PR #2860 remains associated with the separate #2859 inset regression.

The opt-in diagnostic deliberately uses `resizeToAvoidBottomInset: false` and blurs the HTML input before hiding Flutter's text input channel. A fresh default-DDS iPhone 17 Pro iOS 26.2 Simulator run on 2026-08-10 measured `visualViewport.height` as `778.0 -> 435.4375 -> 778.0`, restored `visualViewport.scale` from `0.93925` to `1.0`, and returned the page offset to zero. The native frame was `402x778` before and after dismissal, with a transient `402x812` Flutter layout while the keyboard was visible. Earlier simulator reruns were inconclusive because of WebKit metrics and software-keyboard harness conditions; no product crash was captured.

**Remaining validation:** exercise HTML input focus changes, interactive dismissal, custom page zoom, and scroll-to-bottom on physical iOS 17 through the latest supported iOS release, and compare with a minimal native `WKWebView` host.

An opt-in integration diagnostic is available at
[`flutter_inappwebview_forge/example/integration_test/ios_keyboard_viewport_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_keyboard_viewport_diagnostic_test.dart).
Run it from `flutter_inappwebview_forge/example` with
`fvm flutter drive --no-pub --driver=test_driver/integration_test.dart --target=integration_test/ios_keyboard_viewport_diagnostic_test.dart -d <ios-device> --dart-define=RUN_IOS_KEYBOARD_VIEWPORT_DIAGNOSTIC=true`.
A fresh default-DDS iPhone 17 Pro iOS 26.2 run on 2026-08-10 passed the full
show/dismiss assertion with `778.0 -> 435.4375 -> 778.0` viewport heights and
zero offset after dismissal. Earlier clean DDS reruns on the current host did
not reproduce the transition: iOS 26.2 reported zero WebKit viewport metrics,
while the iOS 27 Simulator reached the initial `778px` viewport but did not
expose a software-keyboard transition (`keyboardDelta=0`). CoreSimulatorService
also reported intermittent connection failures during that validation. No
product crash was captured. Physical iOS 17 runtime evidence, custom page-zoom
coverage, and the native frame/inset comparison remain required.

### #2753 — iOS iframe subresource failures do not reach `onReceivedError`

**Local status:** Host/WebKit capability boundary; no Forge-owned fix identified. **Affected scope:** iOS `WKNavigationDelegate` error reporting for iframe and other subresource requests. **Impact:** the report expects `onReceivedError` for an offline iframe request, matching Android behavior, but iOS only exposes navigation-level failure callbacks through the public WebKit delegate. **Confidence:** Strong platform-boundary evidence; the upstream report has no Forge stack or API that can supply the missing callback.

The iOS implementation forwards `webView(_:didFailProvisionalNavigation:withError:)` and `webView(_:didFail:withError:)` to the existing channel event. Apple's [`WKNavigationDelegate` documentation](https://developer.apple.com/documentation/webkit/wknavigationdelegate) defines these as navigation tracking/error callbacks and describes the delegate in terms of the main frame, not arbitrary HTTPS iframe subresources. A JavaScript error listener would be incomplete for cross-origin frames, media, opaque fetches, and failures below JavaScript, so adding one would not preserve the public `onReceivedError` contract. The issue remains visible for Apple/WebKit capability tracking and would require a documented API decision or new WebKit callback before implementation.

### #2796 — Android Pigeon build errors belong to an external dependency

**Local status:** Dependency attribution boundary; no Forge-owned fix identified. **Affected scope:** `webview_flutter_android` Pigeon-generated Java sources. **Impact:** the report's compiler errors reference missing `webview_flutter_android` 4.10.13 base classes, but the Forge package graph and source tree contain no `webview_flutter_android` dependency or its generated Pigeon classes. The only `webview_flutter` reference in this repository is an optional example test script.

Reproduce this locally only with a package graph that actually includes `webview_flutter_android`; the issue is not a Forge Android build path and is excluded from the active implementation count.

### #2720 — iOS localhost server is stale after background/resume

**Local status:** Implemented and source-validated; iOS/Android runtime validation pending. **Affected package:** shared platform-interface localhost server used by iOS and Android. **Impact:** after the OS terminates the local HTTP listener while the app is backgrounded, `isRunning()` could continue to return `true` and prevent an application from deciding whether the server must be started again. **Confidence:** Confirmed stale-reference path; the complete release-mode WebView resume failure remains unverified.

The default server now listens for the `HttpServer` request stream's `onDone` and `onError` events and clears its reference only when the callback belongs to the current server instance. This keeps intentional close, external listener termination, and replacement-server races idempotent. The platform-interface regression suite also covers normal close, controlled restart, and independent server lifecycles. The fix does not silently restart a server or reload a WebView, because the public API does not own the application's server instances or initial URL lifecycle.

**Required evidence:** run iOS and Android release builds through background/lock/resume with a local HTML asset, verify `isRunning()` becomes `false` after listener termination, explicitly restart the server, and reload the WebView. Confirm shared/non-shared ports and multiple server instances do not cross-clear each other's state.

### #2568 — iOS `shouldOverrideUrlLoading` header replacement deadlock

**Local status:** Hardened in iOS 2.1.17; physical iOS navigation/header validation pending. **Affected package:** iOS WebKit navigation delegate and method channel. **Impact:** when `shouldOverrideUrlLoading` cancels a navigation after calling `controller.loadUrl` with replacement headers, the WebView could turn white and remain in a navigation deadlock. **Confidence:** Confirmed callback-ordering path from the upstream reproducer.

While `WKNavigationDelegate.decidePolicyFor` waits for the Dart policy result, a nested `loadUrl` call is now queued instead of starting a second WebKit navigation immediately. Pending decisions are counted so concurrent policy callbacks cannot release the queue early; malformed URL requests are ignored safely. The queue is flushed only after the final decision handler receives `.allow` or `.cancel`, and queued requests are discarded during disposal. This preserves the existing public callback/policy contract while allowing the reported cancel-and-reload-with-headers flow to release the WebKit decision handler first. The iOS source regression and package tests pass.

**Required evidence:** physical iOS 18+ navigation with `useShouldOverrideUrlLoading`, HTTPS redirects and repeated taps, cancel-then-load with custom headers, normal allow behavior, back/forward, popup/window IDs, and disposal during a pending navigation callback.

### #2710, #2831, and #2763 — iOS fullscreen, prompt, and multi-window behavior

**Status:** #2710 is hardened in iOS 2.1.17; #2831 is classified as an iOS 26 WebKit boundary because the public decision delegate starts at iOS 27, and #2763 is source-fixed with the rejected-popup path validated on iOS 26.0, 26.2, and 27.0 Simulators. **Impact:** User-visible iOS regressions: fullscreen video can turn black/unresponsive, location prompts may not close, and rejected `onCreateWindow` targets could navigate the caller. **Confidence:** The targeted #2710 mitigation now passes a three-cycle seek/fullscreen Simulator diagnostic; the physical iOS/GPU symptom remains an Apple/WebKit runtime gate, while #2763 still requires the physical popup matrix.

[Issue #2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) has a concrete iOS 26 report: after an inline HTML5 video is scrubbed and enters native fullscreen, playback can become black or unresponsive. The report also reproduces with `webview_flutter` and remains after testing the available inline/PiP/fullscreen settings, which points to the WebKit/GPU layer rather than a package-only path.

**Forge mitigation:** on iOS 26 and later, `InAppWebViewSettings.useNativeFullscreenContainer` is enabled by default. After the injected iOS video monitor observes a seek/time change followed by fullscreen, Forge closes the WebKit media presentation and moves the same `WKWebView` into a full-screen UIKit container. The video element is temporarily styled to fill that container, and the original Flutter view hierarchy, constraints, frame, and media attributes are restored on exit. Set `useNativeFullscreenContainer` to `false` to opt out and retain the standard WebKit fullscreen path. The fallback remains available when a presenter or native handoff cannot be established.

This is a targeted mitigation rather than a claim that WebKit is fixed: it requires iOS 26+, JavaScript-enabled pages, and device validation across inline videos, iframe videos, orientation changes, and media controls. For affected paths on older iOS versions, forcing inline playback or using a native player/Safari remains an application-level workaround.

On 2026-08-11, the opt-in [`ios_fullscreen_video_seek_diagnostic_test.dart`](../flutter_inappwebview_forge/example/integration_test/ios_fullscreen_video_seek_diagnostic_test.dart) passed three cycles on the iPhone 17 Pro iOS 26.2 Simulator: a bundled H.264/AAC video played, seeked, entered the native fullscreen container, dismissed through the runtime opt-out, and re-entered. Each cycle produced the expected fullscreen state, the test exited with code 0, and the iOS package tests passed 2/2. Simulator evidence does not prove the physical iOS 26/GPU path; physical-device, HLS/iframe, orientation, and media-control validation remain required, so #2710 stays runtime-pending and the counts are unchanged.

[#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) has an iOS 27 public decision bridge, but iOS 26 does not expose that callback and the iPhone 17 Pro iOS 26.2 run confirms the Dart callback is not invoked. A fresh 2026-08-10 iOS 27 deny-path diagnostic passes with `callbackOrigin=https://example.com` and `error:1`; the iOS 26 prompt remains an Apple/WebKit boundary. [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) now has a source fix and passing iOS 26.0, 26.2, and 27.0 Simulator rejected-popup diagnostics; the physical popup device matrix remains required. Maintain an iOS matrix for Flutter, Xcode, iOS, keyboard, fullscreen, geolocation, and multi-window flows; do not present these as one common root cause.

### #2737 — Web platform reports stale navigation URLs

**Status:** Mitigated in Web 1.0.1; browser integration validation remains. **Impact:** Applications cannot reliably track the current page on the web platform. **Confidence:** Strong report; the source path and browser limitation are now explicit.

Issue [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737) reports that iframe-based `onLoadStart`, `onLoadStop`, `onProgressChanged`, and `getUrl()` continue to expose the initial URL after navigation. The Web implementation now reads `contentWindow.location.href` for same-origin documents and forwards that value through load/history events and `getUrl()`.

For a cross-origin document, the browser's same-origin policy can make `contentWindow.location.href` unreadable to the parent page. The implementation returns `null` in that case instead of repeating the iframe's initial `src`; an exact cross-origin URL still requires cooperation from the embedded page. Add a browser integration test covering same-origin redirects/history and cross-origin privacy behavior.

### #2789 and #2780 — Windows overlay and Linux WPE compatibility

**Status:** Fixed in Windows 1.0.3 and Linux 1.0.1; native Windows and Linux validation remains. **Impact:** A minimized Windows WebView can continue intercepting desktop clicks; Linux builds can fail against WebKit versions below 2.50. **Confidence:** Strong report for #2789; confirmed compile-risk path for #2780.

Issue [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789) is a reproducible platform-view hit-test/overlay regression after minimizing a Windows app. Issue [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780) matches an unguarded `webkit_web_view_get_theme_color` call in the Linux C++ source, which can cause an undefined-reference failure on older WPE WebKit versions.

**Implementation:** Windows 1.0.3 emits explicit minimize/restore events from `WM_SIZE`, hides the WebView2 controller and parent child window while minimized, and restores visibility plus the current Flutter position afterward. Linux 1.0.1 compiles `webkit_web_view_get_theme_color` only when `WEBKIT_CHECK_VERSION(2, 50, 0)` is true and returns no theme color on older WPE WebKit versions. Windows hit-testing and Linux builds still require native CI/device validation.

### Security claims requiring validation before labeling as vulnerabilities

- [#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745) is closed locally by source review: dynamic evaluation is confined to explicit `evaluateJavascript` wrappers and no plugin-owned remote-data sink was found.
- [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) is fixed locally by replacing activity-extra Java serialization with a primitive/nested-`Bundle` codec; Android source tests and the Android 35 InAppBrowser/Chrome Custom Tabs happy-path diagnostic pass. Restore/rotation, malformed-extra, physical/provider validation remains a release gate.

### Other crash and regression candidates retained for follow-up

These CSV entries are notable enough to keep in the engineering backlog. The
records already listed in [runtime-validation-pending.md](runtime-validation-pending.md)
have a documented local implementation or mitigation boundary; their next
action is target validation, not speculative code change. The remaining
active examples that still need a reproducible matrix before implementation
are [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752),
[#2732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2732),
and [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615).
Duplicate `forceDarkStrategy` provider-cast reports [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673)
and [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594)
are already covered by the runtime register and should be validated together.

## Full CSV screening notes

The remaining CSV records were screened but not promoted to the incident-focused list because they are feature requests, showcases, duplicate/low-detail reports, or platform-specific warnings without enough evidence. Examples include SPM/Kotlin migration requests, WebAssembly support, proxy/payment-request features, page zoom/pull-to-refresh requests, showcase entries, and isolated build warnings. They should not be treated as evidence that the package itself is crashing until a reproducible package-level failure is available.

In particular, [#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863), [#2846](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2846), [#2842](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2842), [#2835](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2835), [#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834), [#2811](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2811), [#2793](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2793), [#2769](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2769), [#2760](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2760), [#2712](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2712), [#2690](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2690), and [#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660) are not error-rate priorities. This remains true whether a record is active or already has a local source boundary; runtime-pending records still retain their required platform gate.

## General engineering themes

1. Treat native platform values as versioned, nullable input. Avoid force-unwrapping enum conversions and unchecked `String` casts at the channel boundary.
2. Treat renderer, surface, fullscreen, and input lifecycles as independently failing state machines. Normal callbacks are not guaranteed during GPU or process failure.
3. Keep security-sensitive filesystem mappings least-privilege by default.
4. Publish a tested Flutter/OS/WebView/device compatibility matrix; dependency upgrades alone cannot resolve Flutter engine, OEM WebView, WebKit, or WPE backend regressions.
