## 2.1.40 - 2026-08-10

- Android: harden permission-request and permission-cancellation MethodChannel
  payload decoding for [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856), rejecting malformed origin/resources containers without aborting the Dart event dispatcher and filtering unknown resource entries. Focused Android regression coverage passes; device/provider validation remains pending.
- Update the root dependency to Android 1.0.37.

## 2.1.39 - 2026-08-10

- iOS: complete pending popup callAsyncJavaScript callbacks when a new
  navigation starts, preventing a lost callback during window.open,
  shouldOverrideUrlLoading, and navigate-away races ([#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)).
  The iPhone 17 Pro iOS 26.2 Simulator diagnostic passes three
  attach/evaluate/navigate/dispose cycles; physical iOS 15-26/Xcode 16-26
  validation remains pending.
- Update the root dependency to iOS 2.1.22.

## 2.1.38 - 2026-08-10

- iOS and Android: complete pending `callAsyncJavaScript` callbacks with a
  structured `WebView disposed` result before native WebView teardown, and
  ignore late platform callbacks during navigate-away/dispose/recreate cycles
  ([#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)).
  The iPhone 17 Pro iOS 26.2 Simulator and API 35 Android diagnostics pass;
  physical iOS/Android provider validation remains pending.
- Update root dependencies to Android 1.0.36 and iOS 2.1.21.

## 2.1.37 - 2026-08-09

- iOS: restore the pre-keyboard `UIScrollView` zoom/offset and refresh the
  final platform-view layout so WKWebView's DOM viewport recovers after HTML
  input dismissal ([#2787](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2787)). The iPhone 17 Pro iOS 26.2 Simulator diagnostic passes; physical iOS 17/device validation remains pending.
- Update the root dependency to iOS 2.1.20.

## 2.1.36 - 2026-08-09

- Android: restore fullscreen state when the WebView renderer disappears, preventing a stale custom view and missing exit callback in the renderer/surface failure path ([#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819)). MediaTek/gralloc physical-device validation remains pending.
- Update the root dependency to Android 1.0.35.

## 2.1.35 - 2026-08-09

- Android: fix Kotlin-migration JavaScript injection recursion that could grow the main-thread queue and terminate the app with `OutOfMemoryError` during rapid navigation ([#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)). The API 35 AVD/WebView 124 diagnostic passes; physical Android 10/11 OEM/provider validation remains pending.
- Update the root dependency to Android 1.0.34.

## 2.1.34 - 2026-08-09

- Android: harden InAppBrowser and Chrome Custom Tabs activity handoffs with the primitive/nested-`Bundle` codec, correct the manager channel namespace, and preserve Custom Tabs callbacks while the external tab is foreground ([#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)). Android 35 AVD happy-path validation passes; malformed-extra, restore/rotation, and provider-matrix validation remain pending.
- Android: fix the example release build output path and validate the release `syncReleaseLibJars` gate for [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687). The API 35 release APK builds, installs, and launches; clean JDK/provider/AAB/publish validation remains pending.
- Update the root dependency to Android 1.0.33.

## 2.1.33 - 2026-08-09

- Android: port the first deprecation-warning batch from upstream PR [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817), including explicit main-looper callback dispatch and API-level session-cookie compatibility paths ([#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685)). Remaining warning families and release-gate validation stay open.
- Update the root dependency to Android 1.0.32.

## 2.1.32 - 2026-08-09

- Android: prioritize `shouldInterceptRequest` callbacks on the main looper, cancel queued callbacks after timeout, and ignore late results to reduce freeze/deadlock risk during high-volume resource interception ([#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)). Android provider/device validation remains pending.
- Update the root dependency to Android 1.0.31.

## 2.1.31 - 2026-08-09

- iOS/macOS: isolate the `WebAuthenticationSession` presentation provider behind its platform availability boundary, fixing the Xcode 26 compile failure ([#2830](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2830)).
- Update root dependencies to iOS 2.1.19 and macOS 1.1.6.

## 2.1.30 - 2026-08-09

- Android: validate optional native MethodChannel string fields before callback dispatch, preventing malformed provider values from reaching non-null `String` assignments ([#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)). Android device/provider validation remains pending.
- Update the root dependency to Android 1.0.30.

## 2.1.29 - 2026-08-08

- Android: catch provider-specific `forceDarkStrategy` adapter casts, make WebView disposal idempotent, and guard detached Android 10 IME operations ([#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594), [#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555), [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)).
- iOS: make native WebView disposal idempotent before observer/WebKit cleanup ([#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)). Physical iOS/Android provider validation remains pending.
- Update root dependencies to Android 1.0.29 and iOS 2.1.18.

## 2.1.28 - 2026-08-08

- Android: make asynchronous WebView startup restartable after engine detach and ignore stale startup callbacks during reattach ([#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849)). Real-device release/AOT validation remains pending.
- Android: retain bounded `shouldInterceptRequest` and non-blocking `deleteAllCookies` safeguards ([#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718)). Provider/device validation remains pending.
- iOS: harden popup `windowId` KVO and JavaScript lifecycle, including stale-object disposal and page-world fallback ([#2600](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2600), [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867)).
- iOS: serialize concurrent navigation-policy decisions before replacement-header loads ([#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568)).
- iOS: retain the iOS 26 fullscreen and geolocation mitigations ([#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)). Device validation for the iOS/Android runtime paths remains required.
- Update root dependencies to Android 1.0.28 and iOS 2.1.17.

## 2.1.27 - 2026-08-08

- Platform interface: clear stale localhost-server references when the underlying request stream closes or errors, keeping `isRunning()` accurate after external lifecycle termination on iOS and Android ([#2720](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2720)). Full release-mode resume/reload validation remains pending.
- Update the root dependency to platform interface 1.1.3.

## 2.1.26 - 2026-08-08

- iOS: defer `loadUrl` requests issued from `shouldOverrideUrlLoading` until the WebKit navigation decision handler has completed, preventing the white-screen/deadlock path when replacing navigation headers ([#2568](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2568)). Physical iOS navigation/header validation remains pending.
- Update the root dependency to iOS 2.1.16.

## 2.1.25 - 2026-08-08

- Android: refresh hybrid-composition WebView geometry after display-size changes and visibility recovery ([#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721)). Android 16/API 36 and OEM WebView runtime validation remains pending.
- Update the root dependency to Android 1.0.27.

## 2.1.24 - 2026-08-08

- macOS: synchronize native WebView frames with fractional Flutter platform-view bounds to prevent AppKit resize drift ([#2826](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2826)).
- Update the root dependency to macOS 1.1.5.

## 2.1.23 - 2026-08-08

- iOS: bridge iOS 26 geolocation permission decisions to the existing `onGeolocationPermissionsShowPrompt` callback ([#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)).
- Update root dependencies to platform interface 1.1.2 and iOS 2.1.15.

## 2.1.22 - 2026-08-08

- Linux: fall back from failed GtkGLArea initialization to pixel-buffer rendering for GPU/DMA-BUF failures ([#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861)).
- Update the root dependency to Linux 1.0.4.

## 2.1.21 - 2026-08-08

- Android: guard file chooser callback casts during provider and activity lifecycle changes ([#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783)).
- macOS: validate WebStorage cleanup payloads before native record operations ([#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717)).
- Update root dependencies to Android 1.0.25 and macOS 1.1.4.

## 2.1.20 - 2026-08-08

- Android: guard ChromeClient callbacks against unrelated WebView instances ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).
- iOS: validate WebMessageChannel port indices and payloads before message operations (internal boundary hardening; not an upstream #2584 fix).
- Update root dependencies to Android 1.0.24 and iOS 2.1.13.

## 2.1.19 - 2026-08-08

- Android: guard page lifecycle callbacks against unrelated WebView instances ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).
- iOS: validate proxy settings and rule payloads before constructing proxy configurations ([#2805](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2805)).
- Update root dependencies to Android 1.0.23 and iOS 2.1.12.

## 2.1.18 - 2026-08-08

- Android: guard URL-navigation callbacks against unrelated WebView instances ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).
- macOS: guard custom URL-scheme callbacks against unrelated WebView instances ([#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619)).
- Update root dependencies to Android 1.0.22 and macOS 1.1.3.

## 2.1.17 - 2026-08-08

- Android: guard compatibility callbacks against unrelated WebView instances ([#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783)).
- iOS: validate `loadFile` channel payloads before using asset paths (internal boundary hardening; not upstream #2654).
- Update root dependencies to Android 1.0.21 and iOS 2.1.11.

## 2.1.16 - 2026-08-08

- Android: ignore malformed WebStorage origin callback entries ([#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717)).
- iOS: validate `postUrl` and `loadData` channel arguments before URL and typed-data use (internal boundary hardening; not upstream #2654).
- Update root dependencies to Android 1.0.20 and iOS 2.1.10.

## 2.1.15 - 2026-08-08

- Android: clear pending asynchronous WebView startup callbacks during plugin detach ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).
- iOS: validate WebMessageListener creation payloads before force-free construction (internal boundary hardening; not an upstream #2584 fix).
- Update root dependencies to Android 1.0.19 and iOS 2.1.9.

## 2.1.14 - 2026-08-08

- iOS: harden cookie cleanup against missing or provider-specific origin properties (internal boundary hardening; not an upstream #2600 fix).
- Update the root dependency to iOS 2.1.8.

## 2.1.13 - 2026-08-08

- iOS: fail custom URL-scheme tasks safely when the callback WebView is not a Forge WebView ([#2619](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2619)).
- Windows: guard headless WebView size access after controller teardown ([#2778](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2778)).
- Update root dependencies to iOS 2.1.7 and Windows 1.0.7.

## 2.1.12 - 2026-08-08

- Android: guard client-certificate callback ownership and cancel requests from unrelated WebView instances ([#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783)).
- Update the root dependency to Android 1.0.18.

## 2.1.11 - 2026-08-08

- Android: reject popup creation without a live WebView manager before allocating a synthetic window ID or storing a result message ([#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)).
- Record the #2745 JavaScript `eval()` claim as unestablished after source-to-sink review; no plugin-owned direct `eval()` sink was found.
- Update the root dependency to Android 1.0.17.

## 2.1.10 - 2026-08-08

- Linux: add an explicit `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` software-rendering fallback ([#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861)).
- iOS: reject popup WebView creation when the window manager is unavailable ([#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)).
- Update root dependencies to iOS 2.1.6 and Linux 1.0.3.

## 2.1.9 - 2026-08-08

- Android: snapshot activity-result listeners before dispatch to make registration and teardown callbacks mutation-safe ([#2814](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2814), [#2797](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2797), [#2711](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2711), [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709)).
- Windows: avoid calling WebView2 bounds APIs after the browser controller has been released during resize/teardown ([#2736](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2736)).
- Update root dependencies to Android 1.0.16 and Windows 1.0.6.

## 2.1.8 - 2026-08-08

- Android: ignore renderer callbacks for non-plugin WebView instances instead of raising a cast exception ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).
- iOS: retain guarded prompt presentation behavior when no visible presenter exists; runtime validation remains pending for the location-prompt lifecycle ([#2831](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2831)).
- Update root dependencies to Android 1.0.15 and iOS 2.1.5.

## 2.1.7 - 2026-08-08

- Android: ignore malformed allow-list payload entries instead of throwing dynamic cast errors (internal boundary hardening; not an upstream #2698/#2673/#2594 mapping).
- macOS: make popup WebView registry cleanup unconditional during disposal to avoid stale browser-window ownership ([#2707](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2707)).
- Update root dependencies to Android 1.0.14 and macOS 1.1.2.

## 2.1.6 - 2026-08-08

- Android: safely decode nullable/provider-controlled `requestFocusNodeHref` and `requestImageRef` callback values ([#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)).
- Web: preserve current same-origin iframe URLs and return `null` for inaccessible cross-origin URLs ([#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737)).
- Update the root package dependencies to Android 1.0.13 and Web 1.0.2.

## 2.1.5 - 2026-08-07

- Android: reuse a shared main-looper dispatcher for synchronous resource callbacks and cap concurrent waits across WebView, service-worker, and custom asset paths.
- Android: return the existing default `null` response immediately when the bounded callback capacity is exhausted or the dispatcher is unavailable.
- Add regression coverage for shared dispatch capacity and timeout-bounded callback handling.

## 2.1.4 - 2026-08-07

- Android: coalesce scroll channel updates to the next animation frame while preserving the latest position and skip duplicate progress values.
- iOS: skip duplicate progress channel values and coalesce content-size KVO callbacks to one main-loop update while preserving the latest size.
- Add Android and iOS source-level regression coverage for event coalescing and lifecycle cleanup.

## 2.1.3 - 2026-08-07

- Android: stop re-injecting document-start scripts from every progress callback and suppress duplicate progress and scroll channel events.
- Android: make deferred native registration retries and disposal idempotent so startup callbacks cannot target a disposed WebView.
- iOS: complete pending legacy asynchronous JavaScript callbacks with a structured disposal error instead of dropping them during WebView teardown.
- Add Android and iOS source-level regression coverage for the performance and lifecycle changes.

## 2.1.2 - 2026-08-06

- iOS: return a structured error instead of entering WebKit's unsafe content-world evaluation path when the target frame is nil ([#2771](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2771)).
- iOS: route page-world `callAsyncJavaScript` calls through the legacy shim on iOS 15-17, preserve custom-world isolation where supported, and report the iOS 16.0.x limitation explicitly ([#2871](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2871)).
- Android: add a JavaScript bridge fallback for `WebMessageListener` on WebView providers without `WEB_MESSAGE_LISTENER`, including origin checks and ArrayBuffer conversion ([#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474)).
- Add Android and iOS source-level regression coverage for the three compatibility paths.

## 2.1.1 - 2026-08-06

- macOS: support `ContextMenu` across initial creation and runtime `setContextMenu` updates, including lifecycle callbacks and Dart item actions ([#2683](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2683)).
- macOS: render custom `ContextMenu.menuItems` through the native WebKit `NSMenu` hook and forward item actions to Dart ([#2855](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2855)).

- macOS: guard `upgradeKnownHostsToHTTPS` for macOS 11.3 and newer to avoid an unavailable-selector crash ([#2741](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2741)).
- Android: invalidate and relayout WebViews when window visibility returns after a long screen-lock period ([#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837)).
- Android: protect the optimized ProGuard filename from regressing to the unavailable legacy filename ([#2852](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2852)).
- iOS/macOS: terminate the injected `window.print` assignment with a semicolon for strict JavaScript parsers ([#2879](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2879)).
- macOS: prefer the active key window when presenting `WebAuthenticationSession` and fall back to a visible main window ([#2813](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2813)).
- Windows: verify `getTitle()` reads the WebView2 document title ([#2725](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2725)).
- iOS/macOS: add `WebAuthenticationSessionSettings.additionalHeaderFields` on iOS 17.4+ and macOS 14.4+.
- Windows: apply `InAppWebViewSettings.pageZoom` through WebView2 `ZoomFactor`.
- Android: add `InAppWebViewController.setBackgroundColor` for changing the native WebView background color ([#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863)).
- iOS: preserve object data and Error stack/message content when forwarding console arguments ([#2850](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2850)).
- iOS: keep the existing `WKWebView` in a native fullscreen container on iOS 26+ after a video seek or time change, avoiding the WebKit fullscreen surface that can become black or unresponsive.
- iOS: add the `InAppWebViewSettings.useNativeFullscreenContainer` setting, enabled by default, with an opt-out for applications that need the standard WebKit fullscreen path.
- Platform interface: expose and document the iOS-only fullscreen-container setting, including generated capability metadata.
- Add iOS source-level regression coverage for the fullscreen message bridge, dynamic video tracking, native container restoration, and private per-WebView message authentication.
- Document the mitigation and its remaining iOS/WebKit device-validation boundary for [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710).

## 2.0.7 - 2026-08-06

- Web: report the current same-origin iframe URL after navigation instead of the requested `src`; inaccessible cross-origin URLs are reported as `null` rather than stale data.
- Platform interface: document the Web iframe URL nullability and raise the federated dependency to 1.0.4.
- iOS: defer popup WebView JavaScript initialization until Flutter attaches the platform view and use the page-world fallback for popup `evaluateJavaScript` and `callAsyncJavaScript` on iOS 14–17.
- Add Web and iOS regression coverage and update issue triage for [#2710](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2710), [#2737](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2737), and [#2867](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2867).
- Refresh the iOS and Web example lockfiles to the new implementation and platform-interface versions.

## 2.0.6 - 2026-08-06

- Windows: load Flutter assets through a restricted WebView2 virtual HTTPS origin so `loadFile` can resolve relative CSS, JavaScript, media, and fetch/XHR resources without relying on an opaque `file:` origin; update the integration expectation to `https`.
- Windows: validate relative asset paths, reject traversal outside `data/flutter_assets`, and percent-encode virtual asset URLs.
- Linux: improve WPE WebKit CMake diagnostics with supported `pkg-config` names, backend alternatives, and an absolute link to `WPE_BACKEND.md`.
- Android: add a release-artifact checker for 16 KB ELF and APK/AAB alignment, and document that final host artifacts must be validated for transitive native libraries.
- Example Android host: retain Flutter's `android.builtInKotlin=false` and `android.newDsl=false` compatibility flags after the Flutter tool migration.
- Add regression coverage and update the issue triage documentation for [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703), [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862), and [#2872](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2872).

## 2.0.5 - 2026-08-06

- Android: prevent Samsung One UI icon-only selection actions from rendering the placeholder text `false`; native icons are preserved when available and invalid resource metadata is skipped safely.
- Android: catch native action-mode `Resources.NotFoundException` failures so malformed OEM selection resources do not crash the Flutter application.
- Linux: guard the WPE WebKit theme-color call behind `WEBKIT_CHECK_VERSION(2, 50, 0)`, keeping older WebKit development packages buildable.
- Windows: hide the WebView2 child window while the Flutter window is minimized and restore its visibility and position after the window returns.
- Examples: pin the Linux and Windows federated examples to the local platform-interface and annotation packages so their lockfiles resolve the repository versions consistently.
- Examples: regenerate the Linux and Windows plugin registrants with the Forge package names while refreshing their dependency locks.
- Add regression coverage and update the issue triage documentation for [#2868](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2868), [#2780](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2780), and [#2789](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2789).

## 2.0.4 - 2026-08-06

- iOS: restore WebView scroll insets after the keyboard has fully hidden, preventing stale negative insets from stopping scrolling before the bottom.
- iOS: require Flutter 3.38.6 or newer, where the Flutter engine fix for WKWebView gesture conflicts is available.
- Android: remove the deprecated status-bar color API call and continue using edge-to-edge window insets.
- Add iOS and Android regression coverage and update the issue triage documentation.

## 2.0.3 - 2026-08-06

- Windows: prevent process-exit crashes from static WinRT/Composition COM releases during DLL unload and guard platform-view callbacks against disposed widgets and detached render boxes.
- Android: bound synchronous `shouldInterceptRequest` waits and concurrent callbacks, avoid synchronous cookie flushes after asynchronous deletion, and guard IME operations until their views are attached to a window.
- Android: let HTTP/HTTPS main-frame navigations continue natively when `shouldOverrideUrlLoading` returns `ALLOW`, preserving popup and request context while retaining cancellation for the active navigation.
- Platform interface: document the Android navigation-context behavior and update the implementation dependency versions.
- Add regression coverage for the Android lifecycle/interception boundaries and update the Windows/Android issue triage documentation.

## 2.0.2 - 2026-08-06

- Android: ignore `allowUniversalAccessFromFileURLs=true` at the native WebSettings boundary to preserve file-origin isolation; use `WebViewAssetLoader` or a controlled HTTPS origin for local resources.
- Android: coordinate WebView provider startup with AndroidX WebKit before bridge and document-start script registration, and defer normal platform-view registration until Flutter attaches the view.
- Android: retry transient document-start registration failures without blocking the first load indefinitely, preventing cold-start crashes and missing `onWebViewCreated` callbacks.
- Android: restore the Flutter container focus and input connection after HTML5 fullscreen exits, including hybrid-composition WebViews.
- Add regression coverage for the Android universal file-access sink and document the three stability/security fixes.

## 2.0.1 - 2026-08-06

- Platform interface: ignore unknown native values when decoding non-null exchangeable-enum collections, preventing forward-incompatible WebView2 permission resources from crashing the host application while preserving known resources.
- Platform interface: add regression coverage for unknown WebView2 permission resource values.
- Android: guard nullable MethodChannel event fields before constructing non-null WebView callback values, preventing malformed geolocation, permission, safe-browsing, touch-icon, and context-menu payloads from crashing the Dart dispatcher.
- Android: add regression coverage for omitted callback fields, including the reported null context-menu title.
- Android: clean up an active fullscreen custom view before WebView disposal and send a guarded `onExitFullscreen` fallback when renderer/GPU failures skip `onHideCustomView`.

## 2.0.0 - 2026-08-06

- iOS: add UIScene-aware plugin registration and replace AppDelegate window access with active `UIWindowScene` resolution for iOS 15+.
- iOS: raise the minimum deployment target to iOS 15.0 and remove pre-scene window and legacy authentication-session compatibility paths.
- iOS: add Swift Package Manager support through the FlutterFramework package while preserving CocoaPods and existing resources.
- Apple packages: update the Swift Collections SPM baseline to `1.6.0` for current Xcode package-trait resolution.
- iOS examples: migrate AppDelegate registration to `FlutterImplicitEngineDelegate` and add the Flutter SceneDelegate configuration.
- macOS: complete the Swift Package Manager manifest while preserving the existing CocoaPods dependency path.
- Raise the Flutter baseline to `>=3.38.0`, where the UIScene plugin registration APIs are available.

- Breaking: the root package now requires iOS 15.0 or newer.

## 1.0.1 - 2026-08-06

- Android: release the complete Java-to-Kotlin and Kotlin DSL migration for the Forge implementation, preserving public Dart/channel contracts and WebView behavior.
- Android: publish the null-safe WebView interface alignment, namespace migration, FileProvider hardening, and Android build verification completed for this release.
- Android: verify the plugin Kotlin compilation, root/platform example debug APK builds, and FileProvider unit tests.

- Android: complete the migration of the final seven native Java classes to Kotlin, preserving WebView lifecycle, channel, callback, navigation, permission, file chooser, dialog, and fullscreen behavior with explicit nullability.
- Android: remove the remaining Java source files from the native implementation and verify that the migrated Kotlin code uses neither `!!` nor `@JvmSuppressWildcards`.

- Android migration groundwork: switch both example Android hosts to Kotlin DSL and add the local internal-annotations override required to regenerate plugin metadata from the Forge packages.
- Android migration: begin the staged Java-to-Kotlin conversion with the settings contract, FileProvider, platform utility, and Web Storage channel implementations, preserving their public channel behavior.
- Android migration: remove temporary `!!`/wildcard interop from the converted classes and add lifecycle-safe messenger and channel argument handling.
- Android migration: convert WebView feature checks and print adapter callbacks to Kotlin.
- Android migration: convert find-interaction, tracing, pull-to-refresh, proxy, and context-menu settings models to Kotlin with explicit nullable parsing and Java-compatible map serialization.
- Android migration: convert the Android resource, content-world, user-script, plugin-script, disposable, navigation-policy, and injection-time native types to Kotlin while preserving Java-visible factories and accessors.
- Android migration: convert content-blocker enums and models to Kotlin with explicit map validation and Java-compatible list signatures.
- Android migration: convert InAppBrowser, Chrome Custom Tabs, Print Job, and Process Global Config settings models to Kotlin while preserving public Java fields and channel map contracts.
- Android migration: convert callback/channel delegates to Kotlin with lifecycle-safe channel disposal and nullable callback result decoding.
- Android migration: convert URL protection, authentication challenge, and authentication response types to Kotlin while preserving Java-visible constructors, accessors, map contracts, and array signatures.
- Android migration: convert credential database contracts, SQLite helper/DAO classes, and the credential database channel handler to Kotlin with explicit nullable handling and cursor lifecycle management.
- Android migration: convert WebMessage, Print Job manager, and Custom Tabs service connection types to Kotlin while preserving public Java fields and callback signatures.
- Android migration: convert JavaScript dialog responses, permission/file chooser models, and download start requests to Kotlin while preserving Java-visible constructors, accessors, and map contracts.
- Android migration: convert Custom Tabs action/menu/toolbar models, custom scheme responses, find sessions, geolocation permission responses, hit-test results, Safe Browsing responses, and Size2D to Kotlin while preserving Java-visible boolean and map APIs.
- Android migration: convert print attributes/job payloads, media size/resolution/margins, SSL/proxy/web-resource errors, and authentication challenges to Kotlin while preserving API-level guards and Java-visible map contracts.
- Android migration: convert URLRequest, NavigationAction/CreateWindowAction, JavaScript handler data, and InAppWebViewRect to Kotlin while preserving navigation payloads and boolean accessor names.
- Android migration: convert WebMessage port/compat models, WebResourceRequest/Response extensions, and InAppBrowserMenuItem to Kotlin while preserving public port fields, callback exceptions, byte-array, and header map contracts.
- Android migration: convert WebMessageChannel to Kotlin while preserving Java channel delegate integration, public list/field surfaces, AndroidX WebKit callbacks, and messenger lifecycle checks.
- Android migration: convert WebMessageListener to Kotlin while preserving AndroidX listener/reply proxy callbacks, origin-rule validation, public fields, and dispose behavior.
- Android migration: convert WebMessage channel delegates and the PreferredContentModeOptionType enum to Kotlin with explicit argument validation and Java-visible static factories.
- Android migration: convert Chrome Custom Tabs receiver/single-instance classes, `ActivityResultListener`, `DisplayListenerProxy`, and `ProcessGlobalConfigManager` to Kotlin while preserving intent extras, API/reflection guards, and messenger lifecycle behavior.
- Android migration: convert Find Interaction, Tracing, Print Job, and InApp Browser channel delegates to Kotlin while preserving callback payloads, static manager calls, and dispose cleanup.
- Android migration: convert Pull-to-refresh, Headless WebView, and Service Worker channel delegates to Kotlin with nullable-safe method argument validation, WebView feature checks, and synchronous callback exception compatibility.
- Android migration: convert OnLoadResource, window focus/blur, print script generators, and `PluginScriptsUtil` to Kotlin while preserving Java-visible static constants/factories and JavaScript placeholder payloads.
- Android migration: convert Find Interaction, Tracing, and Print Job controller/manager classes to Kotlin with preserved static factory calls, channel lifecycle cleanup, and nullable print-job handling.
- Android migration: convert Service Worker, Pull-to-refresh, and Proxy manager/layout classes to Kotlin while preserving API/feature guards, callback flows, and proxy rule map contracts.
- Android migration: convert `WebViewAssetLoaderExt` and its custom path-handler callback bridge to Kotlin while preserving asset/resource handler selection, API 21 response guards, and synchronous callback exception behavior.
- Android migration: convert the keep-alive service, no-history Custom Tabs activity callbacks, and Headless WebView manager to Kotlin while preserving lifecycle callback fields and nullable WebView map cleanup.
- Android migration: convert the CookieManager channel implementation to Kotlin while preserving API 19/21 cookie/sync flows, Java-visible static manager state, and cookie map payloads; required channel arguments now return explicit errors.
- Android migration: convert `PlatformWebView`, `InAppBrowserDelegate`, `InAppWebViewInterface`, and the platform-view factory to Kotlin while preserving Java implementer overloads, callback/throws contracts, and generic collection signatures.
- Android migration: convert `CustomTabsHelper` and `CustomTabActivityHelper` to Kotlin while preserving static package selection, keep-alive extras, overloads, and service connection callbacks.
- Android migration: convert `TrustedWebActivity`, `HeadlessInAppWebView`, `ChromeSafariBrowserManager`, and `InAppBrowserManager` to Kotlin while preserving Trusted Web Activity settings, headless lifecycle, browser registries, system-browser chooser behavior, and activity extras.
- Android migration: update the headless WebView channel delegate to call the Kotlin `getSize()` method explicitly after the JavaBean property interop changed.
- Android migration: convert `FlutterWebView`, the renderer-process callback client, `InputAwareWebView`, and the threaded input-connection proxy view to Kotlin while preserving platform-view initial-load deferral, renderer callbacks, pre-N IME threading, and keyboard/focus reset behavior.
- Android migration: convert `WebViewChannelDelegateMethods` and `ChromeCustomTabsChannelDelegate` to Kotlin while preserving method/event payload contracts, nullable channel inputs, and activity lifecycle cleanup.
- Android migration: convert `ContentBlockerHandler` to Kotlin while preserving URL/domain/top-frame filtering, CSS injection, HTTPS rewriting, and resource-type detection.
- Android migration: convert `JavaScriptBridgeInterface` to Kotlin while preserving bridge secret and origin/frame checks, internal handlers, print/callback flows, and dispose behavior.
- Android migration: convert `InAppWebViewManager` to Kotlin while preserving Safe Browsing, WebView package/debugging, cache, KeepAlive, and JavaScript bridge-name channel methods.
- Android migration: convert `Util` to Kotlin while preserving asset, certificate, network, JSON, screen, reflection, Java-static, and nested certificate-container APIs.
- Android migration: convert `UserContentController` to Kotlin while preserving document-start/end script generation, content-world wrappers, origin/frame checks, and AndroidX `ScriptHandler` lifecycle.
- Android migration: convert `InAppWebViewSettings` to Kotlin while preserving public Java fields, `parse`/`toMap`/`getRealSettings` map keys, API guards, and boxed nullable settings.
- Android migration: convert `PromisePolyfillJS` to Kotlin while preserving the JavaScript source payload and Java-visible static group/source/factory APIs.
- Android migration: convert `InterceptAjaxRequestJS` and `InterceptFetchRequestJS` to Kotlin while preserving interception JavaScript payloads, origin/frame settings, and Java-visible static factories/flags.
- Android migration: convert `JavaScriptBridgeJS` to Kotlin while preserving the bridge name, utility/web-message variables, platform-ready script, bridge JavaScript payload, and static API.
- Android build: remove legacy Jetifier/buildConfig flags and use AndroidX Multidex with the fully qualified Kotlin Gradle plugin ID in the example host.

## 1.0.0

- First release of `flutter_inappwebview_forge`, a maintained fork of Flutter InAppWebView.
- Reset the fork's package version line and federated package dependencies to `1.0.0`.
- Updated the Android and iOS dependency/stability baseline for the initial Forge release.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
- See [ATTRIBUTION.md](https://github.com/emirkanacar/flutter_inappwebview/blob/main/ATTRIBUTION.md) and the retained Apache License 2.0 notices for licensing information.
