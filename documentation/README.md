# flutter_inappwebview_forge Documentation

This directory is the user-facing documentation for `flutter_inappwebview_forge`.
It is organized as a small product guide: start with installation, then choose
the WebView model and platform details that match your application.

## Start here

- [Getting started](getting-started.md) - install the plugin and render your first WebView.
- [Inline WebView](in-app-webview.md) - configure navigation, settings, callbacks, and controllers.
- [Preload and reuse](preload-and-reuse.md) - reduce route-open latency with headless prewarming.
- [Examples and recipes](examples.md) - copyable browser, bridge, navigation, and lifecycle patterns.
- [Feature guide](features.md) - in-app browser, cookies, storage, localhost, and auth workflows.
- [Changelog](changelog.md) - release highlights and compatibility policy.
- [Migration and upstream](migration-from-upstream.md) - package mapping, attribution, and fork context.
- [Platform guide](platforms.md) - platform requirements and capability differences.
- [Lifecycle and performance](lifecycle-and-performance.md) - keep WebViews alive safely and avoid cold starts.
- [Troubleshooting](troubleshooting.md) - common build, runtime, keyboard, permission, and signing problems.
- [Contributing](contributing.md) - repository workflow for code and documentation changes.
- [API reference](api-reference.md) - generated from the public Dart package.

## Run the documentation site

```sh
npm install --prefix documentation
npm run docs:site:dev
```

For a production build, including the generated Dart API reference:

```sh
npm run docs:site:build
```

## Documentation boundaries

The separate [`docs/`](../docs/README.md) directory contains engineering
records rather than end-user guides:

- architecture and migration plans;
- issue and pull-request triage;
- known issues and runtime validation status;
- performance investigation notes;
- development and release checklists.

When a behavior is useful to application developers, document it here first
and link to the deeper engineering record only when necessary.

## Package scope

The documentation covers the federated packages shipped by this repository:

| Package | Responsibility |
| --- | --- |
| `flutter_inappwebview_forge` | Public Dart widgets, controllers, and callbacks |
| `flutter_inappwebview_forge_platform_interface` | Shared types and platform contracts |
| `flutter_inappwebview_forge_android` | Android WebView implementation |
| `flutter_inappwebview_forge_ios` | iOS WKWebView implementation |
| `flutter_inappwebview_forge_macos` | macOS WKWebView implementation |
| `flutter_inappwebview_forge_windows` | Windows WebView2 implementation |
| `flutter_inappwebview_forge_linux` | Linux WPE WebKit implementation |
| `flutter_inappwebview_forge_web` | Browser iframe implementation |
