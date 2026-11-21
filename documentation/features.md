# Feature guide

The original InAppWebView documentation groups the plugin by capability rather
than only by widget. This fork keeps that model in the API while the most
common workflows are collected here.

## Choose the right entry point

| Need | Entry point | Typical platforms |
| --- | --- | --- |
| Embed a page in a Flutter screen | `InAppWebView` | Android, iOS, macOS, Windows, Linux, Web |
| Retain a WebView across route changes | `InAppWebViewKeepAlive` | Platform dependent |
| Start a known page before navigation | `InAppWebViewPreloader` | Native WebView platforms |
| Open a browser-style native window | `InAppBrowser` | Android, iOS, macOS, Windows |
| Share cookies with a WebView | `CookieManager` | Platform dependent |
| Inspect or clear Web Storage | `WebStorageManager` | Platform dependent |
| Serve bundled files over localhost | `InAppLocalhostServer` | Native platforms |
| Configure Android service workers | `ServiceWorkerController` | Android |
| Start an external authentication flow | `WebAuthenticationSession` | Supported Apple platforms |
| Start an opt-in native file download | `onDownloadStarting` + `DownloadJobController` | Android, iOS, macOS, Windows |
| Observe cookie store changes | `CookieManager.addCookieChangedListener` | iOS, macOS |
| Block or allow all cookies for a store | `CookieManager.setCookiePolicy`, `getCookiePolicy` | iOS 17+, macOS 14+ |
| Enable or opt out of Lockdown Mode | `isLockdownModeEnabled` | iOS 16+, macOS 13+ |
| Delete all browsing data, or one site's | `WebStorageManager.deleteBrowsingData`, `deleteBrowsingDataForSite` | Android (provider-gated), iOS, macOS, Linux; Windows (`deleteBrowsingData` only) |
| Add custom items to the native context menu | `ContextMenu` | Android, iOS, macOS, Windows |
| Find text without the system UI | `FindInteractionController.findString` | iOS, macOS |
| Warm a profile origin before navigation | `ContainerController.preconnect` | Android |
| Start a profile renderer process early | `ContainerController.warmUpRendererProcess` | Android (provider-gated) |
| Prefetch a profile URL | `ContainerController.prefetchUrl` | Android |
| Add profile-scoped request headers | `ContainerController.addCustomHeader` | Android |
| Restrict Android WebView construction | `useWebViewBuilder` | Android |
| Tune Android BFCache retention | `backForwardCacheTimeoutSeconds`, `backForwardCacheMaxPagesInCache` | Android |
| Navigate with replace/history and headers | `InAppWebViewController.navigate` | Android (fallback: `loadUrl`) |
| Prerender a URL | `InAppWebViewController.prerenderUrl` | Android |
| Save state with bundle limits | `InAppWebViewController.saveStateWithOptions` | Android |
| Wait for first paint | `postVisualStateCallback` + `onVisualStateReady` | Android |
| Smart Reply context | `InAppWebViewSettings.conversationContext` | iOS 26+ |
| Configure Android startup globally | `ProcessGlobalConfigSettings.uiThreadStartupMode` | Android |

Every capability has a runtime support check. Check support before exposing a
platform-specific action in your UI.

## In-app browser window

Use `InAppBrowser` when the page should be presented as a separate browser-like
window rather than embedded in the current layout:

```dart
final browser = InAppBrowser();

await browser.openUrlRequest(
  urlRequest: URLRequest(
    url: WebUri('https://example.com/account'),
  ),
  settings: InAppBrowserClassSettings(
    browserSettings: InAppBrowserSettings(
      presentationStyle: ModalPresentationStyle.FULL_SCREEN,
    ),
  ),
);

// Later, when the feature is finished:
await browser.close();
```

Browser windows have their own lifecycle and callbacks. Keep the `browser`
instance alive while the window is open and do not assume that an inline
`InAppWebViewController` controls it.

## Set and inspect cookies

Use the shared cookie manager for application-controlled session cookies. Set
the security attributes deliberately:

```dart
final cookies = CookieManager.instance();
final loginUrl = WebUri('https://example.com/');

await cookies.setCookie(
  url: loginUrl,
  name: 'session_hint',
  value: 'signed-value-from-your-server',
  path: '/',
  isSecure: true,
  isHttpOnly: true,
);

final currentCookies = await cookies.getCookies(url: loginUrl);
debugPrint('Cookies available: ${currentCookies.length}');
```

Cookie visibility can depend on the platform data store, third-party cookie
policy, and whether the WebView uses a persistent or private profile. Do not
put access tokens in a cookie unless the server-side session design expects it.

On iOS and macOS, observe `WKHTTPCookieStore` changes. Android has no
equivalent observer; keep polling or your own mutation path there:

```dart
if (CookieManager.isMethodSupported(
  PlatformCookieManagerMethod.addCookieChangedListener,
)) {
  await cookies.addCookieChangedListener((changed) {
    debugPrint('Cookie store changed: ${changed.length}');
  });
}
```

Call `removeCookieChangedListener` when the feature that owns the observer
is disposed.

On iOS 17+ and macOS 14+, `setCookiePolicy` stops a cookie store from storing
and sending cookies without deleting the ones it already has. Pass
`webViewController` to target that WebView's data store (for example a
container); otherwise the default store is used:

```dart
final applied = await cookies.setCookiePolicy(
  policy: HTTPCookieStorePolicy.DISALLOW,
);
if (!applied) {
  // Older OS: the policy API is not available.
}
```

## Lockdown Mode

`isLockdownModeEnabled` controls Apple Lockdown Mode for a WebView on iOS 16+
and macOS 13+. Leave it `null` (the default) to follow the system setting.
Set it to `true` to harden a WebView that renders untrusted content, or to
`false` to exempt a WebView that shows only trusted content and needs a
feature Lockdown Mode disables. Changes made with `setSettings` apply from
the next navigation.

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(isLockdownModeEnabled: true),
)
```

## Delete browsing data

`WebStorageManager.deleteBrowsingData` removes cookies, cache, DOM storage,
IndexedDB, and service workers for every site in the default data store.
`deleteBrowsingDataForSite` removes the same data for one site and its
subdomains and returns the site that was cleared:

```dart
final storage = WebStorageManager.instance();

if (WebStorageManager.isMethodSupported(
  PlatformWebStorageManagerMethod.deleteBrowsingDataForSite,
)) {
  final cleared = await storage.deleteBrowsingDataForSite(
    site: 'https://login.example.com',
  );
  debugPrint('Cleared site: $cleared');
}
```

On Android both calls need a WebView provider that advertises
`DELETE_BROWSING_DATA`; otherwise `deleteBrowsingData` returns `false` and
`deleteBrowsingDataForSite` returns `null`. On iOS, macOS, and Linux the
site is matched against WebKit's website data record names, so the returned
site is the registrable domain WebKit reports, or the host itself when no
record exists. On Windows only `deleteBrowsingData` is available; it clears
the default WebView2 profile and returns `false` on runtimes without
`ICoreWebView2Profile2`. Neither call clears container (profile) stores; use
`ContainerController.clearContainerData` for those.

## Isolate persistent container data

Use a stable `containerId` when the application needs separate persistent
profiles, such as personal and work accounts. The container is selected when
the WebView is created:

```dart
const profileId = 'work-profile';

InAppWebView(
  initialSettings: InAppWebViewSettings(
    containerId: profileId,
  ),
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com/account'),
  ),
)
```

Manage the profile explicitly:

```dart
final containers = ContainerController.instance();
final exists = await containers.hasContainer(profileId);

if (exists) {
  // Clears cookies, storage, and other profile data without deleting the
  // container itself.
  await containers.clearContainerData(profileId);
}
```

Container support depends on the platform and WebView/WebKit version. Check
the runtime capability before showing profile-management UI, and do not
change `containerId` on a live WebView.

On Android, a container can add Profile request headers and prefetch a URL
when the WebView provider advertises the feature:

```dart
if (await WebViewFeature.isFeatureSupported(
  WebViewFeature.CUSTOM_REQUEST_HEADERS,
)) {
  await containers.addCustomHeader(
    containerId: profileId,
    headerName: 'X-App-Profile',
    headerValue: 'work',
  );
}

if (await WebViewFeature.isFeatureSupported(
  WebViewFeature.PROFILE_URL_PREFETCH,
)) {
  await containers.prefetchUrl(
    containerId: profileId,
    url: 'https://example.com/account',
  );
}

if (await WebViewFeature.isFeatureSupported(WebViewFeature.PRECONNECT)) {
  await containers.preconnect(
    containerId: profileId,
    url: 'https://example.com/',
  );
}

// Start the profile's renderer process before the first WebView is shown.
// The provider may ignore the hint; the call returns false when unsupported.
if (await WebViewFeature.isFeatureSupported(
  WebViewFeature.WARM_UP_RENDERER_PROCESS,
)) {
  await containers.warmUpRendererProcess(containerId: profileId);
}
```

## Opt-in native downloads

`onDownloadStarting` is notify-only when the callback returns `null`. Return a
handled `DOWNLOAD` response with an absolute `resultFilePath` to start a native
Android `DownloadManager`, Apple `WKDownload`, or Windows WebView2 job; track it
with `DownloadJobController` when `request.downloadId` is set. Returning
`handled: true` without a path, or `CANCEL`, starts nothing. Linux and Web have
no `DownloadJobController`. Code: [Start a native download](examples.md#start-a-native-download).

## Android navigation, prerender, BFCache, and WebViewBuilder

These need the matching `WebViewFeature`; check it first.

- `navigate` forwards `replaceHistory` and headers through AndroidX
  NavigationParameters and falls back to `loadUrl`
  ([example](examples.md#navigate-with-android-navigationparameters)).
- `prerenderUrl` starts provider-side speculative loading
  ([example](examples.md#prerender-a-likely-next-page)).
- `backForwardCacheTimeoutSeconds` and `backForwardCacheMaxPagesInCache` set
  BFCache depth at creation ([example](examples.md#enable-android-back-forward-cache-depth)).
- `useWebViewBuilder` with `webViewBuilderOriginAllowList` builds an
  immutable WebView for trusted origins only
  ([example](examples.md#opt-in-to-android-webviewbuilder)).
- `saveStateWithOptions` caps the bundle size and can drop forward history;
  without support it delegates to `saveState`
  ([example](examples.md#save-and-restore-webview-state-with-size-limits)).
- `onVisualStateReady` and `postVisualStateCallback` report a painted frame;
  `onLoadStop` does not ([example](examples.md#wait-for-android-first-paint)).

## Find text in the page

`FindInteractionController.findString` (iOS 14+, macOS 11+) selects and
scrolls to a match without the system find UI; other platforms use `findAll`
and `findNext`. Keep one controller per WebView.
Code: [Find text without the system UI](examples.md#find-text-without-the-system-ui).

## iOS 26 conversation context

Pass a WebKit-shaped map through `conversationContext` when Smart Reply or
related features need thread metadata:

```dart
InAppWebViewSettings(
  conversationContext: {
    'type': 'message',
    'threadIdentifier': 'thread-1',
    'entries': [
      {'text': 'Hello', 'senderIdentifier': 'user', 'entryIdentifier': 'e1'},
    ],
  },
)
```

Check `InAppWebViewSettings.isPropertySupported(
InAppWebViewSettingsProperty.conversationContext)` before exposing UI that
depends on it.

## Process-global Android configuration

Apply `ProcessGlobalConfig` once at startup. `uiThreadStartupMode` maps to
AndroidX when the installed WebKit version supports it:

```dart
await ProcessGlobalConfig.instance().apply(
  settings: ProcessGlobalConfigSettings(
    dataDirectorySuffix: 'my_app',
    uiThreadStartupMode: 1,
  ),
);
```

## Mute APIs by platform

Android and iOS/macOS use `setAudioMuted` / `isAudioMuted` (Android also needs
`WebViewFeature.MUTE_AUDIO`); Linux uses `setMuted` / `isMuted`. They are
parallel APIs, not deprecated aliases
([example](examples.md#mute-webview-audio)).

## Inspect Web Storage

`WebStorageManager` is useful for diagnostics and explicit account cleanup:

```dart
final storage = WebStorageManager.instance();
final origins = await storage.getOrigins();

for (final origin in origins) {
  final originValue = origin.origin;
  if (originValue == null) continue;
  final usage = await storage.getUsageForOrigin(origin: originValue);
  debugPrint('$originValue: $usage bytes');
}

// Only call this when the user explicitly requests a full WebView reset.
// await storage.deleteAllData();
```

Clearing storage is not a generic performance optimization. It logs users out,
removes offline data, and can make the next WebView cold start slower.

## Serve local web assets

Use `InAppLocalhostServer` when a local page needs ordinary HTTP semantics,
relative URLs, or APIs that reject `file://` origins:

```dart
final server = InAppLocalhostServer(
  port: 8080,
  documentRoot: 'assets/website/',
);

await server.start();

final webView = InAppWebView(
  initialUrlRequest: URLRequest(
    url: WebUri('http://localhost:8080/index.html'),
  ),
);

// Close the server with the feature that owns it.
await server.close();
```

The document root and asset packaging are application concerns. On Android,
iOS, and macOS, validate localhost behavior with the platform network and
ATS policies used by the release build.

## Android service worker control

Service worker APIs are Android-specific in the current contract. Gate them
before calling them:

```dart
if (ServiceWorkerController.isClassSupported()) {
  final serviceWorkers = ServiceWorkerController.instance();
  await serviceWorkers.setServiceWorkerClient(null);
}
```

Use a real `ServiceWorkerClient` when intercepting requests. Keep callbacks
null-safe and avoid doing blocking work in request interception paths.

## Filter Android request interception

With `useShouldInterceptRequest`, every Android resource request waits for a
Dart reply, and requests above a small native concurrency cap skip Dart
entirely. On pages with many resources this can hide the request you actually
want to handle. Limit interception to the URLs you need with Java regular
expressions (partial match):

```dart
InAppWebViewSettings(
  useShouldInterceptRequest: true,
  shouldInterceptRequestUrlFilter: [r'^https://api\.example\.com/'],
)
```

Requests that do not match continue as if interception were off, so
`resourceCustomSchemes` and content blockers still apply to them. An empty
list (the default) intercepts every request; an invalid pattern disables the
filter and logs a warning. The filter can be changed with `setSettings`.

## Authentication sessions

Use `WebAuthenticationSession` for provider flows that return to the
application through a callback URL scheme. The provider must be configured to
redirect to that scheme, and the host application must register it on the
target platform.

```dart
final session = await WebAuthenticationSession.create(
  url: WebUri('https://login.example.com/authorize'),
  callbackURLScheme: 'myapp',
  onComplete: (url, error) async {
    debugPrint('Auth callback: $url, error: $error');
  },
);

if (await session.canStart()) {
  await session.start();
}
```

Never treat a callback URL as proof of authentication without validating the
state, nonce, and authorization response with the identity provider.

## Debugging checklist

When a feature works on one platform but not another, record:

1. Flutter and plugin versions.
2. OS version and device or emulator type.
3. Android WebView provider/version or Apple WebKit version.
4. Whether the WebView is persistent, private, headless, or inline.
5. The first lifecycle event that differs from the expected sequence.
6. Whether the feature is supported by the runtime capability check.

Then compare the platform-specific notes in [Platform guide](platforms.md) and
the generated [API reference](/api/index.html).
