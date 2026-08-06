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
