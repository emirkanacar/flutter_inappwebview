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
| Find text without the system UI | `FindInteractionController.findString` | iOS, macOS |
| Warm a profile origin before navigation | `ContainerController.preconnect` | Android |
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
```

## Opt-in native downloads

`onDownloadStarting` is notify-only when the callback returns `null`. To start
a native Android `DownloadManager`, Apple `WKDownload`, or Windows WebView2
download job, return a handled response with an absolute destination path:

```dart
InAppWebView(
  onDownloadStarting: (controller, request) async {
    return DownloadStartResponse(
      handled: true,
      action: DownloadStartResponseAction.DOWNLOAD,
      resultFilePath: '/tmp/${request.suggestedFilename ?? 'download.bin'}',
    );
  },
)
```

Returning `handled: true` without a path, or returning `CANCEL`, does not
start a plugin download. Progress and completion stay on
`DownloadJobController` when a job ID is available.

```dart
DownloadJobController? job;

InAppWebView(
  onDownloadStarting: (controller, request) async {
    final path = '/tmp/${request.suggestedFilename ?? 'download.bin'}';
    final downloadId = request.downloadId;

    if (downloadId != null && DownloadJobController.isClassSupported()) {
      job?.dispose();
      job = DownloadJobController(id: downloadId)
        ..onProgressChanged = (progress) async {
          debugPrint('progress: ${(progress * 100).toStringAsFixed(0)}%');
        }
        ..onComplete = (completed, error) async {
          debugPrint(completed ? 'done' : 'error: $error');
        };
    }

    return DownloadStartResponse(
      handled: true,
      action: DownloadStartResponseAction.DOWNLOAD,
      resultFilePath: path,
    );
  },
)
```

Windows WebView2 follows the same contract as Android and Apple platforms.
Linux and Web do not expose `DownloadJobController`; handle downloads in Dart
or cancel explicitly.

## Android navigation, prerender, and BFCache

`navigate` accepts `replaceHistory` and optional request headers when
AndroidX NavigationParameters is available:

```dart
await controller.navigate(
  url: WebUri('https://example.com/next'),
  replaceHistory: true,
  headers: {'Authorization': 'Bearer token'},
);
```

`prerenderUrl` starts provider-side speculative loading when
`WebViewFeature.PRERENDER_URL` is supported.

BFCache depth is configured at WebView creation:

```dart
InAppWebViewSettings(
  backForwardCacheEnabled: true,
  backForwardCacheTimeoutSeconds: 120,
  backForwardCacheMaxPagesInCache: 6,
)
```

## Android WebViewBuilder

Enable immutable WebView construction only for trusted origins:

```dart
InAppWebViewSettings(
  useWebViewBuilder: true,
  webViewBuilderOriginAllowList: {'https://example.com'},
)
```

## Save state with options

`saveStateWithOptions` forwards AndroidX bundle size and forward-history
controls when supported; otherwise it delegates to `saveState`:

```dart
final bytes = await controller.saveStateWithOptions(
  maxSizeBytes: 1024 * 1024,
  includeForwardHistory: false,
);
if (bytes != null) {
  await controller.restoreState(bytes);
}
```

## Visual state and first paint

On Android, subscribe to `onVisualStateReady` and optionally call
`postVisualStateCallback` when you need an explicit request ID for overlay
timing. Do not equate `onLoadStop` with a painted frame.

## Find text in the page

Use `FindInteractionController.findString` on iOS 14+ and macOS 11+ to select
and scroll to a match without presenting the system find UI:

```dart
final find = FindInteractionController();
final found = await find.findString(find: 'invoice');
```

Keep the same controller instance for the WebView that owns it.

On other platforms, use `findAll` and `findNext` from the same controller.

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

| Platform | Preferred API |
| --- | --- |
| Android | `setAudioMuted` / `isAudioMuted` + `WebViewFeature.MUTE_AUDIO` |
| iOS / macOS | `setAudioMuted` / `isAudioMuted` |
| Linux | `setMuted` / `isMuted` |

These are parallel APIs, not deprecated aliases. Pick the supported method for
the current platform.

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
