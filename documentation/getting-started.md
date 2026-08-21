# Getting started

## Requirements

- Dart SDK `^3.8.0`
- Flutter `>=3.38.6`
- Android `minSdkVersion >= 19`
- iOS 15.0 or newer
- macOS 10.14 or newer
- Windows with the WebView2 runtime and NuGet tooling
- Linux with WPE WebKit 2.0 development packages

Use the platform requirements in [Platform guide](platforms.md) before
building a release application.

## WebView or browser?

An embedded WebView displays web content inside your application. It is not a
complete browser: tabs, extensions, browser history UI, developer tools, and
some security or storage controls are application responsibilities. If the
application needs a browser-like experience, define those responsibilities
explicitly and test them on every target platform.

## Install

Add the root package to `pubspec.yaml`:

```yaml
dependencies:
  flutter_inappwebview_forge: ^2.1.76
```

Then fetch packages:

```sh
flutter pub get
```

If the application needs a platform channel or plugin before `runApp`,
initialize Flutter bindings first:

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}
```

The endorsed platform packages are selected through Flutter's federated
plugin mechanism. They normally do not need to be added manually.

## First WebView

```dart
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';

class BrowserPage extends StatelessWidget {
  const BrowserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://example.com'),
          ),
        ),
      ),
    );
  }
}
```

For callbacks, remove `const` and add handlers such as `onWebViewCreated`
and `onLoadStop`. Prefer `onReceivedError` over the deprecated `onLoadError`.
See [Deprecated APIs](deprecated-api.md) when migrating older Options or
platform-prefixed callback names.

```dart
InAppWebView(
  initialUrlRequest: URLRequest(
    url: WebUri('https://example.com'),
  ),
  onWebViewCreated: (controller) {
    // Keep this controller if the screen needs to issue commands later.
  },
  onLoadStop: (controller, url) {
    debugPrint('Loaded: $url');
  },
);
```

## Navigation commands

The controller exposes navigation and JavaScript operations after
`onWebViewCreated`:

```dart
late InAppWebViewController controller;

InAppWebView(
  onWebViewCreated: (value) => controller = value,
);

// Later:
await controller.loadUrl(
  urlRequest: URLRequest(url: WebUri('https://example.com/next')),
);
await controller.goBack();
final currentUrl = await controller.getUrl();
```

Do not issue commands before the controller has been created. Navigation
callbacks may be delivered more than once during redirects, so use the URL
and your own state to identify the terminal page you need.

## Android setup

The host application must allow network access:

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />

    <application
        android:label="my_app"
        android:name="${applicationName}">
        <!-- Flutter's v2 embedding is required by modern Flutter projects. -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
</manifest>
```

Use an AndroidX project and keep `minSdkVersion` at least `19`. For cleartext
HTTP, prefer a scoped network security configuration instead of enabling
cleartext traffic for every domain:

```xml
<!-- android/app/src/main/res/xml/network_security_config.xml -->
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">dev.example.com</domain>
    </domain-config>
</network-security-config>
```

Reference it from the `<application>` element only for builds that genuinely
need that development endpoint:

```xml
<application
    android:networkSecurityConfig="@xml/network_security_config">
</application>
```

Camera, microphone, media capture, downloads, and file uploads require the
host app to declare and request the corresponding Android permissions. The
plugin cannot grant a missing application permission at runtime.

## iOS setup

The iOS implementation uses `WKWebView`. For HTTP content, configure ATS for
the smallest possible domain scope in the application `Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSExceptionDomains</key>
    <dict>
        <key>dev.example.com</key>
        <dict>
            <key>NSIncludesSubdomains</key>
            <true/>
            <key>NSTemporaryExceptionAllowsInsecureHTTPLoads</key>
            <true/>
        </dict>
    </dict>
</dict>
```

Camera and microphone features also need usage descriptions:

```xml
<key>NSCameraUsageDescription</key>
<string>Camera access is required for document capture.</string>
<key>NSMicrophoneUsageDescription</key>
<string>Microphone access is required for media capture.</string>
```

Do not disable ATS globally just to make one development URL work. Verify
scene transitions, keyboard behavior, popup windows, and WebKit process
termination on the iOS versions you support.

## macOS setup

Enable the App Sandbox capability and allow `Outgoing Connections (Client)`
for network WebViews. The setting belongs to the application target in Xcode,
not to the Dart widget. Validate the selected WebKit data store and persistent
container behavior if the app uses multiple profiles.

## Windows setup

Windows uses WebView2. Install the WebView2 runtime on the target machine and
make the NuGet CLI available on `PATH` when building the native example or
application. The runtime version is independent of the Flutter package
version, so record it when diagnosing a Windows-only issue.

## Web setup

The Web implementation uses an iframe. Include the plugin support script in
the application's `web/index.html` when the integration requires it:

```html
<script
  src="/assets/packages/flutter_inappwebview_forge_web/assets/web/web_support.js"
  defer>
</script>
```

The exact asset URL can change with the Flutter web asset layout; inspect the
generated `build/web/assets` directory if the script is served from a custom
base path. Cross-origin iframe documents remain subject to browser same-origin
rules. If Flutter widgets are placed over an iframe and stop receiving
pointer events, use a pointer-interception solution appropriate for the host
application.

## Bundle local assets

Local HTML, CSS, JavaScript, and images must be declared in the application
`pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/website/
    - assets/images/logo.png
```

Then load the entry document with the controller:

```dart
await controller.loadFile(
  assetFilePath: 'assets/website/index.html',
);
```

Keep relative links inside the declared asset directory. See [Examples and
recipes](examples.md) for `loadData` and local asset examples.
