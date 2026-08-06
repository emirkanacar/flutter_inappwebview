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
