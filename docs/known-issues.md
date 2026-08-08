# Known Issues and Upstream Triage

Last reviewed: 2026-08-08

Source: the provided `issues.csv` snapshot and the [flutter_inappwebview issue tracker](https://github.com/pichillilorenzo/flutter_inappwebview/issues). The CSV is a metadata/title export and contains 125 rows, all marked `OPEN`: 98 bugs, 16 enhancements, 3 showcase entries, and 8 records without a label. All 125 rows were screened; 66 issue records have local implementations or mitigations awaiting real runtime validation, #2745 is closed by source review, #2636, #2659, and #2727 are host/platform-specific boundaries with no Forge-owned fix, and 55 remain active implementation or reproduction work. The upstream `OPEN` value is retained as export metadata and must not be read as the current local implementation status.

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
| Resolved locally; runtime validation pending | 66 issues | The source, regression, and host/build boundary is complete; the remaining real validation is tracked in [runtime-validation-pending.md](runtime-validation-pending.md). |
| Closed by source review | 1 issue ([#2745](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2745)) | No plugin-owned security sink was found; no package runtime gate is required. |
| Host/platform-specific boundary | 3 issues ([#2636](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2636), [#2659](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2659), [#2727](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2727)) | The issue remains visible for host/provider/engine tracking, but no Forge-owned code change is justified by the available evidence. |
| Open implementation or reproduction | 55 issues | The active queue and acceptance criteria are tracked in [open-work-plan.md](open-work-plan.md). |

#### #2698, #2673, #2594 - Android provider-specific setting casts

**Local status:** Implemented and source-validated; provider/device validation pending. **Affected package:** Android native settings parser. **Impact:** malformed or implementation-specific channel values could throw a `ClassCastException` while parsing allow-list settings. **Fix:** list payloads are treated as unknown provider input and only string entries are retained; invalid entries are ignored without changing channel names or public settings. **Required evidence:** Android API/provider matrix with malformed list values and all supported allow-list settings.

#### #2707 - macOS browser-window teardown ownership

**Local status:** Implemented and source-validated; macOS/Xcode runtime validation pending. **Affected package:** macOS native WebView. **Impact:** a popup WebView could remain in the manager registry when its ownership state changed before disposal, leaving stale references during browser-window teardown. **Fix:** popup window IDs are removed unconditionally before the WebView releases its plugin reference. **Required evidence:** create/present/dismiss/recreate popup windows on macOS 11 through Tahoe with Xcode 26.

#### #2826 - macOS fractional platform-view frame drift

**Local status:** Implemented and source-validated; macOS runtime validation pending. **Affected package:** macOS platform-view container. **Impact:** AppKit autoresizing could round the native `WKWebView` width and origin away from Flutter's stable fractional platform-view bounds, causing content to resize or zoom across frames. **Fix:** the native WebView and controller no longer use autoresizing masks for sizing; the WebView frame is synchronized to finite controller bounds during initialization, layout, frame-size, bounds-size, and subview-resize callbacks. The source regression test passes, and the Xcode 27 macOS example build passes with a temporary `MACOSX_DEPLOYMENT_TARGET=12.0` command-line override. **Required evidence:** reproduce the fractional-width example on Retina macOS across supported macOS versions and confirm the native frame remains equal to the Flutter platform-view bounds during resize and refresh cycles.

#### #2697 - Android renderer callback type boundary

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android renderer-process client. **Impact:** a renderer callback delivered for a non-Forge WebView instance could throw a cast exception before the callback reached the channel layer. **Fix:** renderer callbacks now use a nullable type check and return for unrelated WebView instances. **Required evidence:** renderer unresponsive/responsive and renderer-gone flows across API 19/21/29/35/36 and OEM providers.

#### #2831 - iOS 26 geolocation permission decision bridge

**Local status:** Implemented and source-validated; physical iOS 26 runtime validation pending. **Affected scope:** iOS/WebKit system geolocation prompt. **Impact:** the upstream report says the native location dialog appears but its buttons cannot be tapped. The iOS 26 SDK adds `WKUIDelegate.webView(_:requestGeolocationPermissionFor:initiatedByFrame:decisionHandler:)`; the plugin previously did not implement it, so the existing Dart `onGeolocationPermissionsShowPrompt` callback could not decide the WebKit request. **Fix:** iOS 26+ now forwards the origin through the existing channel callback, maps `allow` to `WKPermissionDecision.grant`/`.deny`, calls the decision handler once, and safely denies missing/malformed responses. Platform-interface capability metadata now marks the callback as iOS 26+; iOS source tests, platform-interface tests, and the Xcode 27 iOS example build pass. **Required evidence:** run the minimal HTTPS geolocation page on a physical iOS 26 device and verify grant/deny, repeat requests, active/inactive scenes, popup presentation, dismissal, and background/foreground transitions.

#### #2814, #2797, #2711, #2709 - Android activity-result listener lifecycle

**Local status:** Implemented and source-validated; Android activity/provider validation pending. **Affected package:** Android InAppBrowser activity result dispatch. **Impact:** a listener unregistering itself during callback dispatch could mutate the active listener list and invalidate iteration or skip later callbacks. **Fix:** dispatch uses a snapshot of the listener list, preserving callback ownership while allowing safe registration teardown. **Required evidence:** activity result flows across create, rotate, detach, reattach, and dispose transitions.

#### #2736 - Windows InAppBrowser resize after teardown

**Local status:** Implemented and source-validated; Windows native validation pending. **Affected package:** Windows InAppBrowser. **Impact:** a late `WM_SIZE` callback could reach a released WebView2 controller during focus/resize or window teardown. **Fix:** the resize path now checks both the browser wrapper and WebView2 controller before updating bounds. **Required evidence:** minimize/restore, close/resize races, focus transitions, and release builds on supported Windows/WebView2 versions.

#### #2861 - Linux software-rendering fallback

**Local status:** Implemented and source-validated; Fedora/X11/Intel runtime validation pending. **Affected package:** Linux rendering backend. **Impact:** the default GL/DMA-BUF path may produce black, white, or transparent output on affected Intel/X11 configurations. **Fix:** `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` now selects the pixel-buffer/SHM fallback, sets `LIBGL_ALWAYS_SOFTWARE=1` before WPE starts, and skips EGL import when software rendering is requested so DMA-BUF frames are converted to CPU-readable pixels. **Required evidence:** Fedora/X11 with Intel i915, backend logs, and before/after frame output.

The runtime GL realize path now also switches to the same fallback when GtkGLArea initialization reports an error. This is containment, not proof that every DMA-BUF/driver failure is resolved; Fedora/X11/Intel runtime evidence remains required.

#### #2763 - iOS popup WebView manager lifecycle

**Local status:** Implemented and source-validated; iOS popup device validation pending. **Affected package:** iOS `WKUIDelegate` popup creation. **Impact:** the rejected popup target was previously loaded into the caller WebView even when `onCreateWindow` returned `false`, so an external launch caused a duplicate embedded navigation. **Fix:** rejected or unhandled popup callbacks now remove the pending transport without loading the target; explicit `controller.loadUrl` from the callback remains available for same-window handling. Missing managers still return `nil` instead of synthesizing window ID `0`. **Required evidence:** `window.open`, `onCreateWindow` returning `false`/`true`, returned child attachment, navigation, disposal, and scene transitions on iOS 15-26.

#### #2745 - JavaScript `eval()` security claim

**Local status:** Closed by source review; no package vulnerability established. **Affected scope:** JavaScript bridge and generated plugin scripts. **Source review:** the only dynamic evaluation sites are the explicit Android content-world and Web iframe `evaluateJavascript` API wrappers, each receiving the caller-supplied `source` argument. Static regression tests pin those API boundaries and prevent accidental additional dynamic sinks. `evaluateJavascript` is an explicit public API and is not evidence of a package vulnerability by itself. A future claim still requires a concrete untrusted source-to-privileged-sink path and exploit reproduction.

#### #2536 - Android `Bundle.getSerializable` scanner finding

**Local status:** Fixed in Android source; compile and static regression validation passed. **Affected package:** Android InAppBrowser and Chrome Custom Tabs activity handoff. **Impact:** plugin-owned activity extras previously used Java serialization for Flutter maps/lists, matching the scanner's `Bundle.getSerializable` trace. **Fix:** all browser activity maps/lists now use a recursive `Bundle` primitive/nested-`Bundle` codec; no `getSerializable`, `putSerializable`, or `java.io.Serializable` references remain in Android native source. Activities remain `android:exported="false"`. **Required evidence:** Android API/provider matrix covering InAppBrowser and Custom Tabs launch, restore, rotation, and malformed extras.

#### #2782, #2783 - Android callback ownership and input stability

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android client-certificate callback boundary. **Impact:** a provider callback delivered for a non-Forge WebView could be force-cast before the certificate request was completed. **Fix:** the callback now uses a nullable Forge-WebView cast and cancels the request for unrelated WebViews. **Required evidence:** client-certificate and input/focus transitions across supported Android API levels and OEM providers.

#### #2619 - iOS custom scheme callback ownership

**Local status:** Implemented and source-validated; iOS WebKit runtime validation pending. **Affected package:** iOS custom URL-scheme handler. **Impact:** a scheme callback for a non-Forge WebView could force-cast the WebView and terminate the process. **Fix:** the handler now rejects unrelated WebViews with a structured URL-scheme task error and removes the task from its pending map. **Required evidence:** custom schemes, disposal during an outstanding task, and WebKit callback ordering on supported iOS versions.

#### #2778 - Windows headless WebView controller teardown

**Local status:** Implemented and source-validated; Windows/WebView2 runtime validation pending. **Affected package:** Windows headless WebView. **Impact:** a late size callback could dereference a released WebView2 controller during startup or renderer teardown. **Fix:** size setters/getters now require both the WebView wrapper and controller before accessing bounds. **Required evidence:** create, resize, renderer restart, dispose, and recreate cycles on supported WebView2 runtimes.

#### #2600 - iOS cookie property decoding

**Local status:** Implemented and source-validated; iOS WebKit cookie runtime validation pending. **Affected package:** iOS cookie manager. **Impact:** cookie cleanup could force-unwrap or force-cast an absent or provider-specific `originURL` property, or assume the website data type set cast succeeded. **Fix:** origin values and website data types are decoded with optional checks and return a safe failure when the platform shape is unsupported. **Required evidence:** cookie deletion with String/URL/missing origin properties across iOS 15-26.

#### #2584 - iOS WebMessageListener payload validation

**Local status:** Implemented and source-validated; iOS WebKit/provider validation pending. **Affected package:** iOS WebMessageListener creation. **Impact:** malformed platform-channel maps could force-cast listener IDs, JavaScript object names, or origin rules and terminate the app. **Fix:** listener creation now validates all required fields and returns `nil` for malformed payloads. **Required evidence:** listener creation with missing/null/wrong-type fields and disposal during message delivery.

#### #2697 - Android asynchronous startup callback lifetime

**Local status:** Implemented and source-validated; Android cold-start/device validation pending. **Affected package:** Android WebView startup coordinator. **Impact:** callbacks queued for asynchronous WebView provider startup could run after plugin detach and target disposed WebViews. **Fix:** plugin detach marks the coordinator disposed, clears pending callbacks, removes main-handler work, and shuts down the startup executor. **Required evidence:** headless and regular WebView cold start, detach/reattach, and release/AOT cycles.

#### #2717 - Android WebStorage provider callback entries

**Local status:** Implemented and source-validated; Android provider validation pending. **Affected package:** Android WebStorage manager. **Impact:** provider callback maps containing unexpected entries could throw a cast exception while enumerating origins. **Fix:** entries are decoded with a nullable `WebStorage.Origin` cast and malformed values are skipped. **Required evidence:** origins/quota/usage calls across Android API levels and WebView providers.

#### #2654 - iOS navigation channel payload validation

**Local status:** Implemented and source-validated; iOS device validation pending. **Affected package:** iOS WebView channel delegate. **Impact:** malformed `postUrl` or `loadData` payloads could force-cast typed data or force-unwrap invalid URLs. **Fix:** required values are validated and a structured `invalid_arguments` error is returned. **Required evidence:** malformed/null payloads and valid POST/data navigation across iOS 15-26.

The same validation now covers `loadFile`'s required asset path, preventing a null channel value from reaching native file resolution.

#### #2619 - macOS custom scheme callback ownership

**Local status:** Implemented and source-validated; macOS WebKit runtime validation pending. **Affected package:** macOS custom URL-scheme handler. **Impact:** a non-Forge WebView callback could be force-cast and crash the application. **Fix:** unsupported WebViews now receive a structured task error and are removed from the pending task map. **Required evidence:** custom scheme loading and disposal during outstanding tasks on macOS 10.14+.

#### #2697 - Android URL callback ownership

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android navigation client. **Impact:** an unrelated WebView callback could be force-cast during URL navigation. **Fix:** navigation callbacks now return the platform default behavior for non-Forge WebViews. **Required evidence:** navigation and renderer callback flows across supported providers.

The same ownership guard now covers page-started, page-finished, document-start, document-end, and main-frame error callbacks.

#### #2805 - iOS proxy payload validation

**Local status:** Implemented and source-validated; iOS 17+ proxy runtime validation pending. **Affected package:** iOS proxy manager. **Impact:** malformed proxy settings or rules could force-cast rule lists/URLs or unwrap invalid rule objects. **Fix:** proxy settings use optional map decoding and discard malformed rules safely. **Required evidence:** valid, empty, malformed, and mixed proxy rule lists on iOS 17+.

#### #2584 - iOS WebMessageChannel payload and index validation

**Local status:** Implemented and source-validated; iOS WebKit runtime validation pending. **Affected package:** iOS WebMessageChannel delegate. **Impact:** malformed port indices or message maps could index outside the ports array or force-cast channel payloads. **Fix:** indices are bounds-checked and malformed messages return structured argument errors. **Required evidence:** valid/invalid port indices, null messages, closed ports, and disposal during message delivery.

#### #2697 - Android Chrome callback ownership

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android WebChromeClient. **Impact:** progress, title, icon, or touch-icon callbacks could force-cast unrelated WebViews. **Fix:** callbacks now ignore non-Forge WebViews safely. **Required evidence:** provider callback flows during navigation, renderer restart, and teardown.

#### #2783 - Android file chooser callback ownership

**Local status:** Implemented and source-validated; Android provider/device validation pending. **Affected package:** Android file chooser callback bridge. **Impact:** provider/activity lifecycle changes could make the generic callback shape incompatible with an unchecked `ValueCallback` cast. **Fix:** callback casts are nullable and unsupported shapes return without invoking a stale callback. **Required evidence:** single/multiple selection, capture mode, cancellation, rotation, and dispose/recreate flows.

#### #2717 - macOS WebStorage cleanup payload validation

**Local status:** Implemented and source-validated; macOS runtime validation pending. **Affected package:** macOS WebStorage manager. **Impact:** malformed data type, record, timestamp, or display-name payloads could force-cast and terminate the app. **Fix:** required fields are validated and malformed records are skipped or rejected with structured errors. **Required evidence:** fetch/remove records with valid, empty, missing, and mixed-type payloads.

### 2026-08-08 issue work

#### #2856 - Android nullable request-result payloads

**Local status:** Implemented and source-validated; device/provider validation pending. **Affected package:** Android Dart controller. **Environment:** Flutter 3.44.8/Dart 3.12.2 development baseline; published package compatibility minimum remains Flutter 3.38.6. **User impact:** malformed or nullable WebView provider fields could cause a Dart type error while converting `requestFocusNodeHref` or `requestImageRef` results. **Hypothesis:** dynamic channel values were passed directly to `WebUri` and nullable public fields without runtime type checks. **Fix:** optional URL, title, and source values are accepted only when they are strings; invalid values are ignored. The public channel and result contracts are unchanged. **Required evidence:** Android API/provider matrix covering null, empty, and malformed callback fields.

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

## Remaining validation and follow-up

The complete pending-runtime register is now maintained in
[runtime-validation-pending.md](runtime-validation-pending.md). It contains
66 locally implemented or mitigated issue records and three PR-only records.
This section remains as a pointer so the detailed findings below can retain
the root cause and acceptance evidence without creating a second status list.

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

### #2741 — macOS `upgradeKnownHostsToHTTPS` unavailable selector

**Status:** Fixed in macOS 1.1.1. **Impact:** Accessing `WKWebViewConfiguration.upgradeKnownHostsToHTTPS` on macOS versions before 11.3 could crash with an unavailable-selector error. **Confidence:** Confirmed API availability mismatch.

The initial configuration path, runtime settings update path, and real-settings readback now guard the property with `if #available(macOS 11.3, *)`. Older macOS versions retain the default behavior without sending the unsupported selector.

### #2852 — Android ProGuard default file

**Status:** Fixed and protected in Android 1.0.8. **Impact:** Android release builds can fail when a legacy or unavailable `proguard-android.txt` filename is used. **Confidence:** Confirmed build configuration path.

The Android Gradle configuration uses the available `proguard-android-optimize.txt` default file for release and profile configurations. A package test asserts that the optimized filename remains present and the legacy filename does not regress into the build configuration.

### #2837 — Android WebView white screen after screen lock

**Status:** Fixed in Android 1.0.8; validate on Android 10 and affected OEM/device combinations. **Impact:** After a long screen-lock period, the WebView could remain visually blank until a touch or scroll triggered a redraw. **Confidence:** Strong report with a lifecycle rendering path.

When the WebView window becomes visible again, the Android implementation now schedules an animation invalidation and requests layout after forwarding the visibility callback. This keeps the redraw explicit without forcing a navigation or destroying the WebView state. A static regression assertion protects the visibility recovery path; physical lock/unlock validation remains required.

#### #2721 — Android WebView display-size recovery

**Local status:** Implemented and source-validated; Android 16/API 36 and OEM WebView runtime validation pending. **Affected package:** Android hybrid-composition WebView geometry/lifecycle. **Impact:** after returning from Android accessibility or display-size settings, the WebView could retain stale geometry or redraw state; the report also includes a provider renderer crash during the visibility/dispose/recreate sequence. **Confidence:** Strong report; the geometry path is confirmed, while the renderer-crash cause remains provider-specific.

`InAppWebView` now shares an idempotent geometry-refresh helper between visibility recovery and `onSizeChanged`. A real size change calls `super.onSizeChanged`, invalidates the view, and requests layout; visibility recovery uses the same helper and ignores disposed instances. This keeps the native WebView bounds and redraw path synchronized when Android changes display metrics without forcing navigation or recreating the WebView. The Android source regression test and example APK/AAR build pass; this mitigation does not claim to eliminate a provider-owned Chromium renderer crash without device evidence.

**Required evidence:** Android 16/API 36 accessibility/display-size changes with hybrid composition, API 35/36 and OEM WebView providers, native frame/bounds before and after the settings change, no renderer crash, no stale size, and no duplicate navigation/dispose callbacks.

### #2855 — macOS custom context-menu items do not render

**Status:** Fixed in macOS 1.1.1; validate on macOS 10.14+ with native right-click menus. **Impact:** Dart-provided `ContextMenu.menuItems` were never added to the native `WKWebView` menu and their actions could not reach Dart. **Confidence:** Confirmed missing native hook.

The macOS `WKWebView` now receives the initial and runtime `ContextMenu` configuration, uses AppKit’s `willOpenMenu`/`didCloseMenu` hooks to add custom `NSMenuItem` instances, and forwards `onCreateContextMenu`/`onHideContextMenu` lifecycle events. Targets are retained only while the menu is open, each action forwards its id/title through `onContextMenuActionItemClicked`, and numeric item identifiers are normalized without force-casting. The optional setting to hide default menu items is also honored.

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

**Status:** Mitigated in Linux 1.0.5; Fedora/X11/Intel runtime validation remains pending. **Impact:** On Fedora/X11 with Intel i915, the default DMA-BUF/EGL path can show a black screen; disabling GL previously could result in a white/transparent but interactive view. **Confidence:** The reported rendering-path analysis is consistent with the native source.

The local implementation makes `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` select software WPE buffers, sets `LIBGL_ALWAYS_SOFTWARE=1` before WPE starts, and skips EGL import so the pixel-buffer path receives CPU-readable frames. This may have a substantial performance cost.

**Remaining validation:** reproduce on supported Fedora/X11/Intel combinations, collect backend logs, and compare before/after frame output.

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

### #2787 — iOS keyboard dismissal leaves a reduced `visualViewport`

**Local status:** Active; needs iOS 17 device/Simulator reproduction. **Affected scope:** iOS WebKit visual viewport and Flutter platform-view geometry. **Impact:** after an HTML keyboard is dismissed, `visualViewport.height` can remain smaller than the Flutter WebView and fixed-position page elements can appear offset from the bottom. **Confidence:** Needs reproduction for a Forge-owned root cause.

This report is not treated as the same defect as #2859. The existing iOS 2.0.1 keyboard change restores the native `UIScrollView` content inset after `keyboardDidHide` and addresses the documented scroll-to-bottom regression; it does not prove that WebKit's DOM `visualViewport` state is restored on iOS 17. The upstream report has no native stack, minimal reproduction project, or before/after native frame data, so injecting JavaScript or changing WebKit geometry would be speculative.

**Required evidence:** reproduce with `resizeToAvoidBottomInset` and `SafeArea` combinations on iOS 17 and current supported iOS, capture `window.innerHeight`, `visualViewport.height/offsetTop`, WebView frame, `contentInset`, and `adjustedContentInset` before/after keyboard dismissal, then compare with a minimal native `WKWebView` host.

### #2720 — iOS localhost server is stale after background/resume

**Local status:** Partial mitigation implemented and source-validated; the issue remains active until release-mode resume/reload behavior is validated. **Affected package:** shared platform-interface localhost server used by iOS and Android. **Impact:** after the OS terminates the local HTTP listener while the app is backgrounded, `isRunning()` could continue to return `true` and prevent an application from deciding whether the server must be started again. **Confidence:** Confirmed stale-reference path; the complete WebView resume failure still needs runtime reproduction.

The default server now listens for the `HttpServer` request stream's `onDone` and `onError` events and clears its reference only when the callback belongs to the current server instance. This keeps intentional close, external listener termination, and replacement-server races idempotent. The fix does not silently restart a server or reload a WebView, because the public API does not own the application's server instances or initial URL lifecycle.

**Required evidence:** run iOS and Android release builds through background/lock/resume with a local HTML asset, verify `isRunning()` becomes `false` after listener termination, explicitly restart the server, and reload the WebView. Confirm shared/non-shared ports and multiple server instances do not cross-clear each other's state.

### #2568 — iOS `shouldOverrideUrlLoading` header replacement deadlock

**Local status:** Implemented and source-validated; physical iOS navigation/header validation pending. **Affected package:** iOS WebKit navigation delegate and method channel. **Impact:** when `shouldOverrideUrlLoading` cancels a navigation after calling `controller.loadUrl` with replacement headers, the WebView could turn white and remain in a navigation deadlock. **Confidence:** Confirmed callback-ordering path from the upstream reproducer.

While `WKNavigationDelegate.decidePolicyFor` waits for the Dart policy result, a nested `loadUrl` call is now queued instead of starting a second WebKit navigation immediately. The queue is flushed only after the original decision handler receives `.allow` or `.cancel`, and queued requests are discarded during disposal. This preserves the existing public callback/policy contract while allowing the reported cancel-and-reload-with-headers flow to release the WebKit decision handler first. The iOS source regression, `flutter analyze`, SwiftPM manifest check, and Xcode example build pass.

**Required evidence:** physical iOS 18+ navigation with `useShouldOverrideUrlLoading`, HTTPS redirects and repeated taps, cancel-then-load with custom headers, normal allow behavior, back/forward, popup/window IDs, and disposal during a pending navigation callback.

### #2710, #2831, and #2763 — iOS fullscreen, prompt, and multi-window behavior

**Status:** #2710 is mitigated in iOS 2.1.0; #2831 has an iOS 26 decision-bridge fix pending physical-device validation and #2763 is fixed in source pending popup-device validation. **Impact:** User-visible iOS regressions: fullscreen video can turn black/unresponsive, location prompts may not close, and rejected `onCreateWindow` targets could navigate the caller. **Confidence:** The #2831 callback gap is confirmed locally; the original button-tap symptom still requires iOS 26 runtime confirmation.

[Issue #2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710) has a concrete iOS 26 report: after an inline HTML5 video is scrubbed and enters native fullscreen, playback can become black or unresponsive. The report also reproduces with `webview_flutter` and remains after testing the available inline/PiP/fullscreen settings, which points to the WebKit/GPU layer rather than a package-only path.

**Forge mitigation:** on iOS 26 and later, `InAppWebViewSettings.useNativeFullscreenContainer` is enabled by default. After the injected iOS video monitor observes a seek/time change followed by fullscreen, Forge closes the WebKit media presentation and moves the same `WKWebView` into a full-screen UIKit container. The video element is temporarily styled to fill that container, and the original Flutter view hierarchy, constraints, frame, and media attributes are restored on exit. Set `useNativeFullscreenContainer` to `false` to opt out and retain the standard WebKit fullscreen path. The fallback remains available when a presenter or native handoff cannot be established.

This is a targeted mitigation rather than a claim that WebKit is fixed: it requires iOS 26+, JavaScript-enabled pages, and device validation across inline videos, iframe videos, orientation changes, and media controls. For affected paths on older iOS versions, forcing inline playback or using a native player/Safari remains an application-level workaround.

[#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831) now has a source-level iOS 26 geolocation decision bridge and needs the physical-device grant/deny and scene matrix. [#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763) now has a source fix and needs only the iOS popup device matrix. Maintain an iOS matrix for Flutter, Xcode, iOS, keyboard, fullscreen, geolocation, and multi-window flows; do not present these as one common root cause.

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
- [#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536) is fixed locally by replacing activity-extra Java serialization with a primitive/nested-`Bundle` codec; Android compile and static regression tests pass.

### Other crash and regression candidates retained for follow-up

These CSV entries are notable enough to keep in the engineering backlog. The
records already listed in [runtime-validation-pending.md](runtime-validation-pending.md)
have a documented local implementation or mitigation boundary; their next
action is target validation, not speculative code change. The remaining
active examples that still need a reproducible matrix before implementation
are [#2752](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2752),
[#2732](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2732),
[#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787),
[#2723](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2723),
[#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720),
[#2713](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2713),
and [#2615](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2615).
Duplicate cast reports [#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673)
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
