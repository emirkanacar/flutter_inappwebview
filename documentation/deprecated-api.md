# Deprecated APIs

The 5.x `Options` classes, platform-prefixed callbacks, and `IOS*`/`Android*`
type names remain in the public Dart API as compatibility shims. New code
should use the current names in this table. Removing a shim is a major-version
breaking change; MethodChannel names, payload keys, and native fallbacks stay
in place until that decision is explicit.

`shouldAllowDeprecatedTLS` is not a deprecated API. The name refers to TLS 1.0
and 1.1 connections.

## Options to Settings

| Deprecated | Current |
| --- | --- |
| `initialOptions` | `initialSettings` |
| `InAppWebViewGroupOptions`, `InAppWebViewOptions`, `AndroidInAppWebViewOptions`, `IOSInAppWebViewOptions` | `InAppWebViewSettings` |
| `setOptions` / `getOptions` | `setSettings` / `getSettings` |
| `InAppBrowserClassOptions`, `InAppBrowserOptions`, Android/iOS variants | `InAppBrowserClassSettings` / `InAppBrowserSettings` |
| `ChromeCustomTabsOptions`, `SafariOptions`, `ChromeSafariBrowserClassOptions` | `ChromeSafariBrowserSettings` |
| `PullToRefreshOptions` | `PullToRefreshSettings` |
| `ContextMenuOptions` | `ContextMenuSettings` |

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
  ),
)
```

## Widget and controller callbacks

| Deprecated | Current |
| --- | --- |
| `onLoadError` | `onReceivedError` |
| `onLoadHttpError` | `onReceivedHttpError` |
| `onDownloadStart`, `onDownloadStartRequest` | `onDownloadStarting` |
| `onLoadResourceCustomScheme` | `onLoadResourceWithCustomScheme` |
| widget `onFindResultReceived` | `FindInteractionController.onFindResultReceived` |
| `onPrint` | `onPrintRequest` |
| `onReceivedIcon` (old signature) | `onFaviconChanged` |
| `androidOnSafeBrowsingHit` | `onSafeBrowsingHit` |
| `androidOnPermissionRequest` | `onPermissionRequest` |
| `androidOnGeolocationPermissionsShowPrompt` / `HidePrompt` | unprefixed names |
| `androidShouldInterceptRequest` | `shouldInterceptRequest` |
| `androidOnRenderProcessGone` / `Responsive` / `Unresponsive` | unprefixed names |
| `androidOnFormResubmission` | `onFormResubmission` |
| `androidOnScaleChanged` | `onZoomScaleChanged` |
| `androidOnReceivedIcon` / `TouchIconUrl` / `JsBeforeUnload` / `ReceivedLoginRequest` | unprefixed names |
| `iosOnWebContentProcessDidTerminate` | `onWebContentProcessDidTerminate` |
| `iosOnDidReceiveServerRedirectForProvisionalNavigation` | unprefixed name |
| `iosOnNavigationResponse` | `onNavigationResponse` |
| `iosShouldAllowDeprecatedTLS` | `shouldAllowDeprecatedTLS` |

## Controller methods and related APIs

| Deprecated | Current |
| --- | --- |
| `clearCache()` | `InAppWebViewController.clearAllCache` |
| `findAllAsync` / `findNext` / `clearMatches` | `FindInteractionController` |
| `getScale` | `getZoomScale` |
| `setSafeBrowsingWhitelist` | `setSafeBrowsingAllowlist` |
| `iosWKPdfConfiguration` | `pdfConfiguration` |
| `iosAllowingReadAccessTo` | `allowingReadAccessTo` |
| `androidHistoryUrl` | `historyUrl` |
| `iosAnimated` | `animated` |
| CookieManager `iosBelow11WebViewController` | `webViewController` |
| Chrome Custom Tabs `addDefaultShareMenuItem` | `shareState` |
| action button `action` | `onClick` |
| `JavaScriptHandlerCallback` | `JavaScriptHandlerFunction` |
| `AndroidInAppWebViewController`, `IOSInAppWebViewController` | `InAppWebViewController` |
| `AndroidWebStorageManager`, `IOSWebStorageManager` | `WebStorageManager` |
| `AndroidCookieManager` | `CookieManager` |
| `AndroidServiceWorkerController` / `AndroidServiceWorkerClient` | unprefixed classes |

## Settings fields that remain for compatibility

| Deprecated setting | Current guidance |
| --- | --- |
| `clearCache` | Call `InAppWebViewController.clearAllCache` |
| `clearSessionCache` | Call `CookieManager.removeSessionCookies` |
| `forceDark` / `forceDarkStrategy` | Use `algorithmicDarkeningAllowed`. On Android 13+ the old force-dark APIs are no-ops. |
| `saveFormData` | No Dart replacement. Android Autofill replaced WebView form-data saving; the setting is a no-op on API 26+ and is kept only for older Android versions. |

`IOS*` and `Android*` type names (`IOSSafariDismissButtonStyle`,
`AndroidWebViewFeature`, `IOSWKNavigationType`, and the same pattern for other
enums) map 1:1 to the unprefixed type. Use the unprefixed name in new code.

## Native SDK deprecations that stay on purpose

Android still declares `minSdkVersion 24` (raised from 19 in 2.1.77). Legacy WebView, cookie, print,
fullscreen, `forceDark`, and `saveFormData` call sites are isolated with
file-level deprecation suppressions because there is no behavior-preserving
replacement for that API range. Those native paths are not removed until an
explicit minSdk increase. See the `#2641` and `#2685` record in
[`docs/known-issues.md`](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/known-issues.md)
in the repository engineering docs.

`allowUniversalAccessFromFileURLs=true` remains on the Dart settings object
for federated compatibility, but Android ignores `true` at the native
boundary. Use `WebViewAssetLoader` or a controlled HTTPS origin for local
resources.

Linux maps `WKWebsiteDataTypeWebSQLDatabases` to local storage because WPE
does not provide WebSQL.

## Analyzer notes

The plugin packages ignore `deprecated_member_use` so the shims can keep
calling each other. Host applications that do not ignore those lints will see
warnings until they migrate to the current names.

The engineering sequence, minSdk gate, and major-version removal rule are in
the [Deprecated API migration plan](https://github.com/emirkanacar/flutter_inappwebview/blob/master/docs/deprecated-api-migration-plan.md).
