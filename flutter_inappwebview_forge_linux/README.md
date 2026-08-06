# flutter_inappwebview_forge_linux

The Linux WPE WebKit implementation of [`flutter_inappwebview_forge`](https://pub.dev/packages/flutter_inappwebview_forge).

## Usage

This package is [endorsed](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#endorsed-federated-plugin),
which means you can simply use `flutter_inappwebview_forge`
normally. This package will be automatically included in your app when you do,
so you do not need to add it to your `pubspec.yaml`.

However, if you `import` this package to use any of its APIs directly, you
should add it to your `pubspec.yaml` as usual.

## Build prerequisites

The Linux implementation uses WPE WebKit for offscreen rendering. A build
requires GTK 3, libepoxy, libsecret, Wayland server headers, libwpe, and one
supported WPE WebKit backend exposed through `pkg-config`:

- `wpe-webkit-2.0` with `wpe-platform-2.0` and
  `wpe-platform-headless-2.0` (recommended), or
- `wpe-webkit-1.1`/`wpe-webkit-1.0` with `wpebackend-fdo-1.0` (legacy fallback).

Distribution package names vary. On Debian/Ubuntu, the WebKit development
package is commonly named `libwpewebkit-1.0-dev`, while the other development
packages are commonly named `libwpe-1.0-dev`, `libsecret-1-dev`,
`libepoxy-dev`, and `libwayland-dev`. Verify the installed names before
building:

```bash
pkg-config --modversion wpe-webkit-2.0 wpe-platform-2.0 wpe-platform-headless-2.0
pkg-config --modversion wpebackend-fdo-1.0 wpe-1.0 gtk+-3.0 epoxy libsecret-1 wayland-server
```

If configuration fails, the CMake error prints the exact `pkg-config`
candidates it checked. The full package/source-build matrix is in
[`WPE_BACKEND.md`](WPE_BACKEND.md).
