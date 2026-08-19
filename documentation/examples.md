# Examples and recipes

These examples are intentionally small and composable. They show the common
application patterns; the generated [API reference](/api/index.html) contains
the complete list of settings, callbacks, and platform methods.

## A small browser screen

Keep the controller in a `State` object, not in `build()`. This lets the
screen rebuild without creating a new native WebView.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';

class BrowserScreen extends StatefulWidget {
  const BrowserScreen({super.key});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  InAppWebViewController? _controller;
  WebUri? _url;
  int _progress = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_url?.host ?? 'Browser'),
        actions: [
          IconButton(
            tooltip: 'Back',
            onPressed: () async {
              if (await _controller?.canGoBack() ?? false) {
                await _controller!.goBack();
              }
            },
            icon: const Icon(Icons.arrow_back),
          ),
          IconButton(
            tooltip: 'Forward',
            onPressed: () async {
              if (await _controller?.canGoForward() ?? false) {
                await _controller!.goForward();
              }
            },
            icon: const Icon(Icons.arrow_forward),
          ),
          IconButton(
            tooltip: 'Reload',
            onPressed: _controller?.reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri('https://example.com'),
            ),
            onWebViewCreated: (controller) {
              _controller = controller;
            },
            onLoadStart: (controller, url) {
              if (mounted) setState(() => _url = url);
            },
            onLoadStop: (controller, url) {
              if (mounted) setState(() => _url = url);
            },
            onProgressChanged: (controller, progress) {
              if (mounted) setState(() => _progress = progress);
            },
          ),
          if (_progress < 100)
            LinearProgressIndicator(value: _progress / 100),
        ],
      ),
    );
  }
}
```

`onLoadStop` means that navigation finished according to the platform WebView;
it is not the same as an application-specific “ready” signal. For a single
page app, expose a small JavaScript readiness signal as shown below.

## Configure settings for a form-heavy page

Settings should be chosen when the WebView is created. Disable autocorrection
affects editable HTML elements; it does not configure a native Flutter
`TextField` or remove the keyboard's emoji key.

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptBridgeEnabled: true,
    disableAutocorrection: true,
    mediaPlaybackRequiresUserGesture: true,
  ),
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com/checkout'),
  ),
)
```

Keep profile-defining settings such as `incognito`, storage container, and
data-store configuration stable. Changing those settings usually means that
the native WebView must be recreated.

## Call Dart from JavaScript

Register the handler in `onWebViewCreated`, validate the arguments, and return
only data the page is allowed to receive.

```dart
InAppWebView(
  onWebViewCreated: (controller) {
    controller.addJavaScriptHandler(
      handlerName: 'appBridge',
      callback: (arguments) {
        final action = arguments.isNotEmpty && arguments.first is Map
            ? (arguments.first as Map)['action']
            : null;

        if (action == 'getVersion') {
          return {'ok': true, 'version': '1.0'};
        }
        return {'ok': false, 'error': 'unsupported action'};
      },
    );
  },
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

Call the handler from the page:

```javascript
const result = await window.flutter_inappwebview.callHandler(
  'appBridge',
  {action: 'getVersion'},
);
console.log(result.version);
```

Do not expose privileged operations to arbitrary pages. Combine a trusted
origin policy with argument validation when the WebView can navigate outside
your own content.

## Inject a document-start user script

Use `initialUserScripts` for code that must be available before the page's
application JavaScript starts. Keep the script small and restrict its origins
when the WebView can navigate to untrusted content.

```dart
import 'dart:collection';

InAppWebView(
  initialUserScripts: UnmodifiableListView<UserScript>([
    UserScript(
      source: "window.appShell = {version: '1.0'};",
      injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START,
      forMainFrameOnly: true,
      allowedOriginRules: {'https://example.com/*'},
    ),
  ]),
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

Use `AT_DOCUMENT_END` for code that needs the document body. Do not register
the same script repeatedly after every rebuild; define initial scripts once or
use the controller's add/remove methods with a stable group name.

## Send a readiness event from the page

This pattern avoids treating `onLoadStop` as proof that a JavaScript app has
finished booting.

```dart
onWebViewCreated: (controller) {
  controller.addJavaScriptHandler(
    handlerName: 'pageReady',
    callback: (arguments) {
      final payload = arguments.isNotEmpty ? arguments.first : null;
      debugPrint('Page ready: $payload');
      return {'accepted': true};
    },
  );
},
```

```javascript
// Call this after the page has mounted its interactive UI.
window.flutter_inappwebview.callHandler('pageReady', {
  route: window.location.pathname,
});
```

If the page can call the handler more than once, make the Dart side
idempotent or ignore duplicate readiness events.

## Use a WebMessage channel

WebMessage channels are useful when a page already has a structured message
protocol and a JavaScript handler would add unnecessary global functions.

```dart
final channel = await controller.createWebMessageChannel();
if (channel == null) {
  debugPrint('WebMessage channels are not supported here');
  return;
}

final nativePort = channel.port1;
final pagePort = channel.port2;

await nativePort.setWebMessageCallback((message) {
  debugPrint('Page message: ${message?.data}');
});

await controller.postWebMessage(
  message: WebMessage(data: 'capture-port', ports: [pagePort]),
  targetOrigin: WebUri('*'),
);

// Dispose the channel with the WebView owner.
channel.dispose();
```

The page must receive the transferred port and attach an `onmessage` handler:

```javascript
window.addEventListener('message', (event) => {
  const port = event.ports[0];
  if (!port || event.data !== 'capture-port') return;

  port.onmessage = (message) => console.log(message.data);
  port.postMessage('hello from the page');
});
```

Prefer a narrow `targetOrigin` instead of `*` in production.

## Allow only trusted navigation

Enable the navigation callback and cancel schemes or hosts that the app does
not own. Add a separate external-app flow if links such as `mailto:` or
`tel:` are required.

```dart
InAppWebView(
  initialSettings: InAppWebViewSettings(
    useShouldOverrideUrlLoading: true,
  ),
  shouldOverrideUrlLoading: (controller, navigationAction) async {
    final url = navigationAction.request.url;
    if (url == null) return NavigationActionPolicy.CANCEL;

    final isHttp = url.scheme == 'http' || url.scheme == 'https';
    final isTrustedHost =
        url.host == 'example.com' || url.host.endsWith('.example.com');

    return isHttp && isTrustedHost
        ? NavigationActionPolicy.ALLOW
        : NavigationActionPolicy.CANCEL;
  },
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

This is an application policy, not a replacement for server-side
authentication or content security policy. Validate redirects and links from
the page as well.

## Reject popup windows safely

If the application has no child-window UI, explicitly reject `window.open`
requests. Returning `false` avoids creating an unowned native WebView.

```dart
InAppWebView(
  onCreateWindow: (controller, action) async {
    debugPrint('Blocked popup: ${action.request.url}');
    return false;
  },
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

If popups are required, create a child `InAppWebView` using the supplied
`windowId`, keep it owned by the parent feature, and handle `onCloseWindow`.

## Handle downloads without silently losing them

The callback is a decision point. Either hand the request to an application
download service or return a cancellation response and show the user why the
download was not started.

```dart
InAppWebView(
  onDownloadStarting: (controller, request) async {
    final url = request.url;
    debugPrint('Download requested: $url');

    // Start your authenticated downloader here, or cancel explicitly.
    return DownloadStartResponse(
      handled: true,
      action: DownloadStartResponseAction.CANCEL,
    );
  },
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com/files'),
  ),
)
```

Do not pass a WebView cookie or authorization header to another downloader
without checking the server's security model.

## Load HTML data or an asset

Use `initialData` for the first document, or use the controller later when the
content is produced by the app.

```dart
final controller = /* controller from onWebViewCreated */;

await controller.loadData(
  data: '<!doctype html><html><body><h1>Offline</h1></body></html>',
  mimeType: 'text/html',
  encoding: 'utf-8',
  baseUrl: WebUri('https://example.com/'),
);
```

For a bundled Flutter asset:

```dart
await controller.loadFile(assetFilePath: 'assets/website/index.html');
```

Declare the asset in the application `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/website/
```

Keep relative URLs inside the asset tree. For more complex local content, see
the localhost and asset-loader APIs in the generated reference.

## Show a recoverable page error

Keep the WebView alive after a navigation error and render fallback UI in
Flutter. The exact error code is platform-specific, so log the description
instead of matching only one numeric value.

```dart
String? lastPageError;

InAppWebView(
  onReceivedError: (controller, request, error) {
    if (request.isForMainFrame != true) return;
    if (mounted) setState(() => lastPageError = error.description);
  },
  onLoadStart: (controller, url) {
    if (lastPageError != null && mounted) {
      setState(() => lastPageError = null);
    }
  },
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

Use a retry button that calls `reload()` or `loadUrl()` rather than rebuilding
the entire screen and losing the controller reference.

## Pull to refresh

Create the controller once, reload the page from its callback, and stop the
indicator after the load completes.

```dart
late final PullToRefreshController pullToRefreshController;

void initializePullToRefresh() {
  pullToRefreshController = PullToRefreshController(
    settings: PullToRefreshSettings(enabled: true),
    onRefresh: () async {
      await webViewController?.reload();
    },
  );
}

InAppWebView(
  pullToRefreshController: pullToRefreshController,
  onLoadStop: (controller, url) async {
    await pullToRefreshController.endRefreshing();
  },
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

Check support before showing platform-specific controls. Dispose auxiliary
controllers from the owning `State` when the screen is removed.

## Preserve state across a route replacement

Use one `InAppWebViewKeepAlive` instance for the complete ownership period.
Do not create it inside `build()`.

```dart
class WebViewOwner {
  WebViewOwner() : keepAlive = InAppWebViewKeepAlive();

  final InAppWebViewKeepAlive keepAlive;

  Widget buildWebView() {
    return InAppWebView(
      keepAlive: keepAlive,
      initialUrlRequest: URLRequest(
        url: WebUri('https://example.com/account'),
      ),
    );
  }

  Future<void> dispose() {
    return InAppWebViewController.disposeKeepAlive(keepAlive);
  }
}
```

If a route is only temporarily detached, retain the owner. Call
`disposeKeepAlive` when the feature no longer needs the native WebView.

## Prewarm a known destination

When the destination is known before navigation, use the same preloader for
headless startup and inline attachment:

```dart
final preloader = InAppWebViewPreloader(
  headlessWebView: HeadlessInAppWebView(
    initialUrlRequest: URLRequest(
      url: WebUri('https://example.com/dashboard'),
    ),
  ),
);

await preloader.prewarm();

// In the destination route:
InAppWebView(preloader: preloader);

// When the feature is finished:
await preloader.dispose();
```

Prewarming reduces native startup work but consumes memory and may start
network activity early. Measure first usable frame, page readiness, and
memory on the target Android or Apple runtime. See
[Preload and reuse](preload-and-reuse.md) for ownership details.

## Debug lifecycle and performance

Use a small event log while investigating route transitions:

```dart
void logWebViewEvent(String name, [Object? value]) {
  debugPrint('[WebView] $name${value == null ? '' : ': $value'}');
}

InAppWebView(
  onWebViewCreated: (controller) => logWebViewEvent('created'),
  onLoadStart: (controller, url) => logWebViewEvent('load-start', url),
  onLoadStop: (controller, url) => logWebViewEvent('load-stop', url),
  onUpdateVisitedHistory: (controller, url, isReload) =>
      logWebViewEvent('history', url),
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
)
```

For meaningful measurements, use profile or release mode and record the
Android WebView provider or Apple OS version. Compare a stable WebView with a
recreated one rather than comparing debug hot reload timings.
