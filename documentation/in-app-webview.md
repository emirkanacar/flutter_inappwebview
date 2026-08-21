# Inline WebView

`InAppWebView` renders a WebView inside the Flutter widget tree. It is the
right choice when the WebView belongs to a screen and should participate in
that screen's layout and lifecycle.

## Initial content

Use one of the initial content options:

```dart
InAppWebView(
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

```dart
InAppWebView(
  initialFile: 'assets/website/index.html',
)
```

```dart
InAppWebView(
  initialData: InAppWebViewInitialData(
    data: '<h1>Hello</h1>',
    baseUrl: WebUri('https://example.com/'),
  ),
)
```

Use only one initial content source for a WebView. Later navigation should be
performed through the controller.

## Settings

Prefer `initialSettings` for new code:

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: true,
    disableAutocorrection: true,
  ),
)
```

`initialOptions` and the older option classes remain available for
compatibility, but they are deprecated. See [Deprecated APIs](deprecated-api.md)
for the Options-to-Settings, callback, and type-name mapping. Settings that
are not supported by a platform are ignored or use that platform's fallback
behavior. Check runtime capability before depending on a platform-specific
setting.

Useful settings include:

- `disableAutocorrection` for editable HTML elements;
- `containerId` for a named storage profile where the platform supports it;
- `proxySettings` for per-WebView proxy configuration where supported;
- `javaScriptBridgeEnabled` and origin allowlists for bridge control;
- `useHybridComposition` on Android when choosing a platform-view mode;
- `useWebViewBuilder` and `webViewBuilderOriginAllowList` on Android when
  `WebViewFeature.WEBVIEW_BUILDER` is supported;
- `writingToolsBehavior` on Apple platforms where Writing Tools are available;
- `allowsInlinePredictions` on Apple platforms;
- `conversationContext` on iOS 26+ for Smart Reply;
- `backForwardCacheEnabled`, `backForwardCacheTimeoutSeconds`, and
  `backForwardCacheMaxPagesInCache` on Android when BFCache features are
  supported;
- `obscuredContentInsets` on iOS/macOS 26+ when the WebView is under system
  chrome.

## JavaScript

```dart
final result = await controller.evaluateJavascript(
  source: 'document.title',
);
```

For a structured asynchronous JavaScript operation, use
`callAsyncJavaScript`. Treat returned values as nullable and validate their
shape before using them in application logic.

## JavaScript bridge

Register a handler from Dart:

```dart
controller.addJavaScriptHandler(
  handlerName: 'appBridge',
  callback: (arguments) {
    return {'ok': true, 'received': arguments};
  },
);
```

Call it from the page:

```javascript
window.flutter_inappwebview.callHandler('appBridge', {action: 'refresh'});
```

Only expose handlers that the page is allowed to call. For untrusted or
multi-tenant content, use the bridge origin allowlist and validate every
argument in Dart.

## Keep the controller and WebView identity stable

Do not create a new `InAppWebView` controller or `InAppWebViewKeepAlive`
inside `build()`. Rebuilding the widget is normal; recreating the native
WebView is expensive and can reset page state, JavaScript state, and scroll
position. See [Preload and reuse](preload-and-reuse.md) for route transitions.

## Mute, downloads, and first paint

Mute audio when the provider supports it. On Android this is
`WebViewFeature.MUTE_AUDIO`; on iOS/macOS it maps to media playback
suspension:

```dart
if (InAppWebViewController.isMethodSupported(
      PlatformInAppWebViewControllerMethod.setAudioMuted,
    ) ||
    await WebViewFeature.isFeatureSupported(WebViewFeature.MUTE_AUDIO)) {
  await controller.setAudioMuted(muted: true);
}
```

Return `null` from `onDownloadStarting` to keep notify-only behavior. Return
`DownloadStartResponse(handled: true, resultFilePath: absolutePath)` only when
the application wants a native download job (Android, iOS, macOS, Windows).
Android `onVisualStateReady` fires after `postVisualStateCallback` or after a
finished load. Use `saveStateWithOptions` on Android when the provider
supports size or forward-history controls.
