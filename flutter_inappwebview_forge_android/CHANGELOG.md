## 1.0.47 - 2026-08-12

- Add feature-gated Android User-Agent Client Hints metadata customization
  through `WebSettingsCompat.setUserAgentMetadata`
  ([#2834](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2834)).
  The setting is additive and does not promise suppression of all Chromium
  Client Hints headers.

## 1.0.46 - 2026-08-12

- Add feature-gated Android Payment Request support through
  `WebSettingsCompat.setPaymentRequestEnabled` for Google Pay integrations
  ([#2660](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2660)).
  The required Chromium payment intent queries are included in the plugin
  manifest; host app/provider and physical-device validation remains pending.

## 1.0.45 - 2026-08-12

- Add feature-gated WebAuthn support configuration through
  `WebSettingsCompat.setWebAuthenticationSupport` ([PR #2743](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2743)).
  The default remains Android WebView's disabled WebAuthn behavior until the
  new setting is explicitly selected; device/provider validation remains
  pending.

## 1.0.44 - 2026-08-12

- Android: add audio capture intents to file chooser requests for
  `audio/*`, including direct capture for `capture` inputs and a chooser
  option when supported ([PR #2823](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2823)).
  Audio capture remains independent of camera permission checks and runtime
  validation on devices with recorder providers is pending.

## 1.0.43 - 2026-08-11

- Android: complete the explicit `CookieManager.flush()` MethodChannel result
  for [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718),
  preventing a caller-side future from hanging after the native flush request.
  Asynchronous cookie mutations still avoid forcing a UI-thread flush.

## 1.0.42 - 2026-08-10

- Android: avoid UI-thread `CookieManager.flush()` calls after asynchronous
  cookie mutations for [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718).
  `setCookie`, `deleteCookie`, and `deleteCookies` now leave persistence
  asynchronous while the explicit `flush` API remains available. The package
  suite passes 49/49 tests, `compileDebugKotlin`, and `assembleDebug`; Android
  10/provider and Play Console runtime validation remains pending.

## 1.0.41 - 2026-08-10

- Reject private-sandbox `file://` URIs returned by Android file choosers, including canonicalized `..` paths and `/data/` paths, across single-select, multi-select, and legacy callbacks ([PR #2243](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2243)). `content://` selections and FileProvider capture URIs remain supported. The Android package suite passes 48/48 tests, `compileDebugKotlin`, and `assembleDebug`; hostile picker/provider runtime validation remains pending.

## 1.0.40 - 2026-08-10

- Complete the local Android deprecation-warning boundary for [#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641) and [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685): API 19/20 cookie, WebView, print, fullscreen, and compatibility fallbacks remain SDK-gated and are explicitly isolated from package compiler diagnostics. The Android package suite passes 47/47 tests, `compileDebugKotlin`, and the debug APK build pass without package-owned Java/Android deprecation warnings. Clean release, provider, AAB, and publish validation remains pending.

## 1.0.39 - 2026-08-10

- Preserve Android activity results owned by other Flutter plugins for [#2797](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2797): the WebView file chooser now returns `false` when no chooser is active or when the request code is unrelated, and only clears callbacks for handled picker results.
- Add a regression test for the Android internal-storage path-handler serialization fix in [#2709](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2709). The pure Dart path now calls `super.toMap()` once and requires no device runtime gate.

## 1.0.38 - 2026-08-10

- Harden Android cold-start initialization for [#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843) and [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849): if an asynchronous WebView provider startup callback remains pending, the first platform-view load now continues after a bounded timeout and uses the existing native bridge/document-start retry path. The API 35/WebView 124 profile/AOT diagnostic passes four clean cold-start cycles; physical, headless, and release/provider validation remains pending.

## 1.0.37 - 2026-08-10

- Harden Android permission-request and permission-cancellation MethodChannel
  payload decoding for [#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856): a missing or non-string origin, or a non-list resources value, now returns native default behavior instead of aborting the event dispatcher. Unknown resource entries are filtered while valid entries and the public callback contract are preserved. Focused regression coverage passes; API/provider validation remains pending.

## 1.0.36 - 2026-08-10

- Complete pending `callAsyncJavaScript` callbacks with a structured
  `WebView disposed` result before native WebView teardown ([#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)).
  The API 35 AVD diagnostic passes four navigate-away/dispose/recreate cycles
  across virtual-display and hybrid composition; physical Android 33+/OEM
  validation remains pending.
- Add an opt-in Android disposal lifecycle diagnostic.

## 1.0.35 - 2026-08-09

- Restore Android fullscreen state before forwarding `onRenderProcessGone`, so a renderer or surface failure cannot leave the custom fullscreen view and exit state stuck ([#2819](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2819)). The cleanup is idempotent and retains the pre-destroy fallback; MediaTek/gralloc physical-device validation remains pending.
- Add Android source regression coverage for renderer-loss fullscreen cleanup.

## 1.0.34 - 2026-08-09

- Fix Android JavaScript injection recursion introduced by the Kotlin migration: `injectDeferredObject` now invokes the platform `WebView.evaluateJavascript` overload instead of re-entering the plugin overload. This prevents rapid-navigation OOM/freeze behavior and preserves the callback contract ([#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)).
- Android source tests and the opt-in API 35/WebView 124 rapid-navigation diagnostic pass; physical Android 10/11 OEM/provider validation remains pending.

## 1.0.33 - 2026-08-09

- Replace Android activity-extra Java serialization with the recursive primitive/nested-`Bundle` codec for InAppBrowser and Chrome Custom Tabs ([#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)).
- Fix the Chrome Custom Tabs manager channel namespace and keep its service session bound until the hosting activity is destroyed, preserving Custom Tabs lifecycle callbacks on Android 35.
- Android package tests and the opt-in Android 35 activity-handoff diagnostic pass; malformed-extra, restore/rotation, and provider-matrix validation remain pending.
- Validate the Android release `syncReleaseLibJars` path and example release APK on the API 35 AVD for [#2687](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2687); the remaining JDK/provider/AAB/publish matrix stays in runtime validation.

## 1.0.32 - 2026-08-09

- Port the first Android deprecation-warning batch from upstream PR [#2817](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2817): bind the shared callback handler to the main looper, isolate legacy cookie APIs behind API-level compatibility paths, and route session-cookie clearing through the asynchronous API on API 21+ ([#2641](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2641), [#2685](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2685)).
- Keep the remaining WebView/Java deprecation families and release-gate warnings tracked as open work; this release is batch 1, not a claim that all warnings are removed.
- Android source tests, analysis, and the example `compileDebugKotlin` build pass.

## 1.0.31 - 2026-08-09

- Prioritize Android `shouldInterceptRequest` MethodChannel dispatch on the main looper, cancel queued callbacks after timeout, and ignore late results to reduce freeze/deadlock risk during high-volume resource interception ([#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580)). Android provider/device validation remains pending.
- Apply the same priority dispatch to Service Worker interception callbacks and extend static regression coverage.

## 1.0.30 - 2026-08-09

- Validate optional Android MethodChannel string fields by runtime type before dispatching callbacks, so null or malformed provider values cannot abort `_handleMethod` with a `String` cast error ([#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)). Device/provider validation remains pending.
- Extend regression coverage to malformed context-menu, geolocation, safe-browsing, permission, and injected-script callback values.

## 1.0.29 - 2026-08-08

- Catch provider-specific `WebSettingsCompat` adapter failures when applying or reading `forceDarkStrategy`, leaving the WebView provider's default intact ([#2673](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2673), [#2594](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2594)). Provider/device validation remains pending.
- Make Android WebView disposal idempotent and absorb stale Android 10 IME operations after detachment ([#2555](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2555), [#2654](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2654)). Physical-device validation remains pending.

## 1.0.28 - 2026-08-08

- Recreate the asynchronous WebView startup executor after engine detach and ignore stale startup generations during reattach, closing the lifecycle gap in release/AOT and headless cold-start flows ([#2843](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2843), [#2849](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2849)). Real-device validation remains pending.
- Preserve bounded synchronous `shouldInterceptRequest` backpressure and asynchronous cookie deletion without an immediate blocking flush ([#2580](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2580), [#2718](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2718)). Android provider/device validation remains pending.
- Add source regression coverage for startup reattachment and retryable document-start script registration.

## 1.0.27 - 2026-08-08

- Refresh native WebView geometry after display-size changes and visibility recovery ([#2721](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2721)). Android 16/API 36 and OEM WebView runtime validation remains pending.

## 1.0.26 - 2026-08-08

- Replace Java-serialized InAppBrowser and Chrome Custom Tabs activity extras with primitive and nested-`Bundle` values, eliminating the `Bundle.getSerializable`/`putSerializable` boundary ([#2536](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2536)).
- Add source regression coverage for the activity-extra codec and the explicit JavaScript evaluation boundary.
- Keep the non-Forge `shouldOverrideUrlLoading` fallback Boolean-returning so Android native compilation remains valid.

## 1.0.25 - 2026-08-08

- Guard Android file chooser callback casts and return safely when the platform callback shape is unsupported ([#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783)).

## 1.0.24 - 2026-08-08

- Guard Android ChromeClient progress, title, icon, and touch-icon callbacks against unrelated WebView instances ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).

## 1.0.23 - 2026-08-08

- Guard Android page lifecycle callbacks against unrelated WebView instances instead of force-casting provider callbacks ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).

## 1.0.22 - 2026-08-08

- Ignore URL-navigation callbacks delivered for unrelated WebView instances instead of force-casting them to the Forge WebView type ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).

## 1.0.21 - 2026-08-08

- Guard Android compatibility callbacks against non-Forge WebViews, preserving safe browsing fallback behavior instead of force-casting provider callback views ([#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783)).

## 1.0.20 - 2026-08-08

- Ignore malformed Android WebStorage origin entries instead of force-casting provider callback values ([#2717](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2717)).

## 1.0.19 - 2026-08-08

- Clear pending asynchronous WebView provider-startup callbacks when the Android plugin detaches, preventing startup work from targeting disposed WebViews ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).

## 1.0.18 - 2026-08-08

- Safely cancel Android client-certificate requests delivered for non-Forge WebView instances instead of force-casting the callback view ([#2782](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2782), [#2783](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2783)).

## 1.0.17 - 2026-08-08

- Reject Android popup creation when the WebView manager is unavailable instead of synthesizing window ID `0` and retaining an incomplete result message ([#2763](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2763)).

## 1.0.16 - 2026-08-08

- Android: snapshot InAppBrowser activity-result listeners before dispatch so a listener can unregister itself without invalidating the iteration (internal lifecycle hardening).

## 1.0.15 - 2026-08-08

- Ignore renderer callbacks delivered for non-plugin WebView instances instead of throwing a cast exception during renderer lifecycle events ([#2697](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2697)).

## 1.0.14 - 2026-08-08

- Ignore malformed non-string values in Android allow-list settings instead of throwing dynamic channel casts (internal boundary hardening; not an upstream #2698/#2673/#2594 mapping).

## 1.0.13 - 2026-08-08

- Validate nullable and provider-controlled values before decoding `requestFocusNodeHref` and `requestImageRef` results, preventing malformed payloads from reaching `WebUri` or non-null public fields ([#2856](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2856)).

## 1.0.12 - 2026-08-07

- Reuse one main-looper dispatcher for synchronous resource callbacks instead of allocating a `Handler` per request.
- Cap concurrent synchronous channel callbacks across WebView, service-worker, and custom asset paths; return the safe default when capacity is exhausted.
- Keep method-specific timeout bounds and add static regression coverage for the shared dispatcher.

## 1.0.11 - 2026-08-07

- Coalesce scroll channel updates to the next animation frame and preserve only the latest pending position.
- Continue suppressing duplicate progress and unchanged scroll-position events without dispatching after disposal.
- Add static regression coverage for frame-based scroll dispatch and callback cleanup.

## 1.0.10 - 2026-08-07

- Avoid re-injecting document-start scripts from every `onProgressChanged` callback on providers without native document-start support.
- Suppress duplicate progress and unchanged scroll-position channel events to reduce platform-channel pressure.
- Make deferred native registration retries and disposal idempotent for cold-start and teardown paths.
- Add static regression coverage for progress, scroll, registration, and disposal behavior.

## 1.0.9 - 2026-08-06

- Add a JavaScript bridge fallback for `WebMessageListener` when the AndroidX WebView provider does not expose `WEB_MESSAGE_LISTENER` ([#2474](https://github.com/pichillilorenzo/flutter_inappwebview/pull/2474)).
- Preserve listener origin rules and convert JavaScript ArrayBuffer payloads to Dart-compatible byte arrays.
- Add static regression coverage for the fallback registration, bridge dispatch, and payload conversion path.

## 1.0.8 - 2026-08-06

- Protect the optimized ProGuard filename with a regression test ([#2852](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2852)).
- Invalidate and relayout WebViews when window visibility returns after a long screen-lock period ([#2837](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2837)).
- Add `InAppWebViewController.setBackgroundColor` for changing the native WebView background color ([#2863](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2863)).
- Document that the Kotlin/Java-only plugin has no package-owned JNI/NDK library, while the consuming application must validate Flutter-engine and transitive native libraries for Android 16 KB page-size support.
- Add the repository release-artifact checker for ELF `PT_LOAD`, APK ZIP, and AAB bundle alignment validation.
- Add Android 16 KB release-validation guidance and update the issue triage documentation for [#2703](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2703).

## 1.0.6 - 2026-08-06

- Avoid rendering Samsung One UI icon-only action-mode items as the literal `false` text; preserve the native icon when available and omit unusable entries.
- Catch native action-mode `Resources.NotFoundException` failures to prevent malformed OEM resource metadata from crashing text selection.
- Add static regression coverage for icon-only placeholder handling and safe native action-mode creation.

## 1.0.5 - 2026-08-06

- Remove the direct `Window.statusBarColor` call, avoiding Android 15 system-bar API warnings while retaining edge-to-edge toolbar inset handling.
- Add a regression assertion for the Android 15 API guard.

## 1.0.4 - 2026-08-06

- Bound synchronous `shouldInterceptRequest` waits and concurrent callback pressure so repeated resource interception cannot indefinitely occupy WebView threads.
- Stop flushing cookies synchronously immediately after asynchronous `removeAllCookies` and `removeSessionCookies` operations.
- Guard custom input-connection and fullscreen recovery operations until the Flutter/container and target views are attached to a window.
- Preserve native HTTP/HTTPS main-frame navigation context when `shouldOverrideUrlLoading` returns `ALLOW`; use `stopLoading` for a current native navigation when Dart returns `CANCEL`.
- Add static regression coverage for interception, cookie, IME, and navigation lifecycle boundaries.

## 1.0.3 - 2026-08-06

- Harden Android file-origin security by ignoring `allowUniversalAccessFromFileURLs=true` instead of enabling the deprecated WebSettings sink; use `WebViewAssetLoader` or a controlled HTTPS origin for local resources.
- Coordinate AndroidX WebView provider startup before bridge/document-start registration, defer normal platform-view registration until attach, and retry transient script-registration failures during cold starts.
- Restore the Flutter container focus and IME input connection after HTML5 fullscreen exits, including hybrid composition.
- Add a regression test that prevents the universal file-access WebSettings assignment from returning.

## 1.0.2 - 2026-08-06

- Guard nullable Android MethodChannel event fields before constructing non-null WebView callback values; malformed security-sensitive payloads now use native default behavior and omitted context-menu titles are represented as empty text.
- Add regression coverage for null geolocation, permission, safe-browsing, and context-menu payload fields.
- Clean up active fullscreen state before disposing a WebView and emit a guarded exit callback when native surface failures bypass `onHideCustomView`.

## 1.0.1 - 2026-08-06

- Android: release the complete migration of the native implementation to Kotlin and the Android hosts to Kotlin DSL.
- Android: preserve the WebView, channel, lifecycle, callback, FileProvider, permission, file chooser, dialog, fullscreen, and navigation contracts while removing native Java sources.
- Android: verify `compileDebugKotlin`, both example `assembleDebug` builds, and the FileProvider path test.

- Android: migrate the final seven native Java classes (`ChromeCustomTabsActivity`, `InAppBrowserActivity`, `WebViewChannelDelegate`, `InAppWebView`, `InAppWebViewChromeClient`, `InAppWebViewClient`, and `InAppWebViewClientCompat`) to Kotlin with explicit null-safe lifecycle, navigation, WebView settings, messaging, dialog, permission, file chooser, and fullscreen handling.
- Android: align `InAppWebViewInterface` nullable signatures with inherited WebView APIs and verify that the native source tree contains no Java files, `!!` assertions, or `@JvmSuppressWildcards` annotations.

- Android: start the Kotlin/Kotlin DSL migration by moving native sources to the Forge namespace and converting Android host build scripts to `.gradle.kts`.
- Android: convert the first low-risk native group (`ISettings`, `InAppWebViewFileProvider`, `PlatformUtil`, and `MyWebStorage`) to Kotlin while preserving Java-accessible static fields and channel contracts.
- Android: replace the temporary Kotlin wildcard/null-assertion bridge with lifecycle-checked messenger access, invariant Java `Map` signatures, and explicit channel argument validation.
- Android: convert `WebViewFeatureManager` and the print document adapter/callback bridge to Kotlin with nullable callback handling.
- Android: convert the find-interaction, tracing, pull-to-refresh, proxy, and context-menu settings models to Kotlin with explicit nullable parsing and mutable Java-compatible map serialization.
- Android: convert the `AndroidResource`, `ContentWorld`, `UserScript`, `PluginScript`, `Disposable`, navigation-policy, and user-script-injection-time native types to Kotlin while preserving Java-visible factories and accessors.
- Android: convert the content-blocker enums and `ContentBlocker`/`ContentBlockerAction`/`ContentBlockerTrigger` models to Kotlin with explicit map validation and Java-compatible list signatures.
- Android: convert the InAppBrowser, Chrome Custom Tabs, Print Job, and Process Global Config settings models to Kotlin while preserving public Java fields and channel map contracts.
- Android: convert the callback/channel delegate infrastructure to Kotlin with lifecycle-safe channel disposal and nullable callback result decoding.
- Android: convert the URL protection, authentication challenge, and authentication response types to Kotlin while preserving Java-visible constructors, accessors, map contracts, and array signatures.
- Android: convert credential database contracts, SQLite helper/DAO classes, and the credential database channel handler to Kotlin with explicit nullable handling and cursor lifecycle management.
- Android: convert WebMessage, Print Job manager, and Custom Tabs service connection types to Kotlin while preserving public Java fields and callback signatures.
- Android: convert JavaScript dialog responses, permission/file chooser models, and download start requests to Kotlin while preserving Java-visible constructors, accessors, and map contracts.
- Android: convert Custom Tabs action/menu/toolbar models, custom scheme responses, find sessions, geolocation permission responses, hit-test results, Safe Browsing responses, and Size2D to Kotlin while preserving Java-visible boolean and map APIs.
- Android: convert print attributes/job payloads, media size/resolution/margins, SSL/proxy/web-resource errors, and authentication challenges to Kotlin while preserving API-level guards and Java-visible map contracts.
- Android: convert URLRequest, NavigationAction/CreateWindowAction, JavaScript handler data, and InAppWebViewRect to Kotlin while preserving navigation payloads and boolean accessor names.
- Android: convert WebMessage port/compat models, WebResourceRequest/Response extensions, and InAppBrowserMenuItem to Kotlin while preserving public port fields, callback exceptions, byte-array, and header map contracts.
- Android: convert WebMessageChannel to Kotlin while preserving Java channel delegate integration, public list/field surfaces, AndroidX WebKit callbacks, and messenger lifecycle checks.
- Android: convert WebMessageListener to Kotlin while preserving AndroidX listener/reply proxy callbacks, origin-rule validation, public fields, and dispose behavior.
- Android: convert WebMessage channel delegates and the PreferredContentModeOptionType enum to Kotlin with explicit argument validation and Java-visible static factories.
- Android: convert Chrome Custom Tabs receiver/single-instance classes, `ActivityResultListener`, `DisplayListenerProxy`, and `ProcessGlobalConfigManager` to Kotlin while preserving intent extras, API/reflection guards, and messenger lifecycle behavior.
- Android: convert Find Interaction, Tracing, Print Job, and InApp Browser channel delegates to Kotlin while preserving callback payloads, static manager calls, and dispose cleanup.
- Android: convert Pull-to-refresh, Headless WebView, and Service Worker channel delegates to Kotlin with nullable-safe method argument validation, WebView feature checks, and synchronous callback exception compatibility.
- Android: convert OnLoadResource, window focus/blur, print script generators, and `PluginScriptsUtil` to Kotlin while preserving Java-visible static constants/factories and JavaScript placeholder payloads.
- Android: convert Find Interaction, Tracing, and Print Job controller/manager classes to Kotlin with preserved static factory calls, channel lifecycle cleanup, and nullable print-job handling.
- Android: convert Service Worker, Pull-to-refresh, and Proxy manager/layout classes to Kotlin while preserving API/feature guards, callback flows, and proxy rule map contracts.
- Android: convert `WebViewAssetLoaderExt` and its custom path-handler callback bridge to Kotlin while preserving asset/resource handler selection, API 21 response guards, and synchronous callback exception behavior.
- Android: convert the keep-alive service, no-history Custom Tabs activity callbacks, and Headless WebView manager to Kotlin while preserving lifecycle callback fields and nullable WebView map cleanup.
- Android: convert the CookieManager channel implementation to Kotlin while preserving API 19/21 cookie/sync flows, Java-visible static manager state, and cookie map payloads; required channel arguments now return explicit errors.
- Android: convert `PlatformWebView`, `InAppBrowserDelegate`, `InAppWebViewInterface`, and the platform-view factory to Kotlin while preserving Java implementer overloads, callback/throws contracts, and generic collection signatures.
- Android: convert `CustomTabsHelper` and `CustomTabActivityHelper` to Kotlin while preserving static package selection, keep-alive extras, overloads, and service connection callbacks.
- Android: convert `TrustedWebActivity`, `HeadlessInAppWebView`, `ChromeSafariBrowserManager`, and `InAppBrowserManager` to Kotlin while preserving Trusted Web Activity settings, headless lifecycle, browser registries, system-browser chooser behavior, and activity extras.
- Android: update the headless WebView channel delegate to call the Kotlin `getSize()` method explicitly after the JavaBean property interop changed.
- Android: convert `FlutterWebView`, the renderer-process callback client, `InputAwareWebView`, and the threaded input-connection proxy view to Kotlin while preserving platform-view initial-load deferral, renderer callbacks, pre-N IME threading, and keyboard/focus reset behavior.
- Android: convert `WebViewChannelDelegateMethods` and `ChromeCustomTabsChannelDelegate` to Kotlin while preserving method/event payload contracts, nullable channel inputs, and activity lifecycle cleanup.
- Android: convert `ContentBlockerHandler` to Kotlin while preserving URL/domain/top-frame filtering, CSS injection, HTTPS rewriting, and resource-type detection.
- Android: convert `JavaScriptBridgeInterface` to Kotlin while preserving bridge secret and origin/frame checks, internal handlers, print/callback flows, and dispose behavior.
- Android: convert `InAppWebViewManager` to Kotlin while preserving Safe Browsing, WebView package/debugging, cache, KeepAlive, and JavaScript bridge-name channel methods.
- Android: convert `Util` to Kotlin while preserving asset, certificate, network, JSON, screen, reflection, Java-static, and nested certificate-container APIs.
- Android: convert `UserContentController` to Kotlin while preserving document-start/end script generation, content-world wrappers, origin/frame checks, and AndroidX `ScriptHandler` lifecycle.
- Android: convert `InAppWebViewSettings` to Kotlin while preserving public Java fields, `parse`/`toMap`/`getRealSettings` map keys, API guards, and boxed nullable settings.
- Android: convert `PromisePolyfillJS` to Kotlin while preserving the JavaScript source payload and Java-visible static group/source/factory APIs.
- Android: convert `InterceptAjaxRequestJS` and `InterceptFetchRequestJS` to Kotlin while preserving interception JavaScript payloads, origin/frame settings, and Java-visible static factories/flags.
- Android: convert `JavaScriptBridgeJS` to Kotlin while preserving the bridge name, utility/web-message variables, platform-ready script, bridge JavaScript payload, and static API.
- Android example: add the local internal-annotations path override so the Forge platform interface can resolve while regenerating plugin metadata.
- Android: remove legacy Jetifier/buildConfig global flags and migrate example multidex dependency/plugin IDs to AndroidX and the fully qualified Kotlin Gradle plugin ID.
- Android: preserve the existing `flutter_inappwebview_android.fileprovider` authority while changing the native package namespace, keeping capture URI compatibility during the migration.
- Android: restore the missing `android.util.Log` import exposed while compiling the moved `UserContentController` source.
- Android: restrict `FileProvider` access to the app-specific `Captures` directory and the legacy `Pictures`/`Movies` directories, while keeping camera and video capture uploads working.
- Android: create API 23+ capture files inside the restricted app-specific directory instead of the external storage root.

## 1.0.0

- First `flutter_inappwebview_forge_android` release as part of the Forge federated plugin.
- Reset the Android implementation version to `1.0.0`.
- Includes the Android dependency, startup, bridge, and lifecycle stability improvements prepared for the Forge baseline.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
