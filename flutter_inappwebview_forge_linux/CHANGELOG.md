## 1.0.10 - 2026-11-14

- Add `WebStorageManager.deleteBrowsingData()` and
  `deleteBrowsingDataForSite(site:)`. The full variant clears
  `WEBKIT_WEBSITE_DATA_ALL` from the default network session; the site
  variant matches `webkit_website_data_get_name` against the host and its
  parent domains (the same rule as iOS/macOS, in the standard-library-only
  `utils/website_data_site_matcher.cc`) and removes those records. Missing or
  invalid `site` and a missing data manager reply `null` / `false` instead of
  erroring.
- Fix `removeDataModifiedSince`: the native handler passed the since date's
  Unix seconds to `webkit_website_data_manager_clear` as the `GTimeSpan`
  (microseconds), so only roughly the last half hour of data was cleared.
  It now passes the age of the date (`now - since`) in microseconds and
  replies without clearing when the date is in the future, instead of
  passing `0` (which means "all data"). The channel payload is unchanged.

## 1.0.9 - 2026-11-13

- Resolve the `flutter analyze` infos reported by the pub.dev static
  analysis check (`this.` qualifiers, empty catches, `print` replaced by
  `debugPrint`, overridden fields replaced by typed getters, super
  parameters, collection literals). No public API or behavior change.

## 1.0.8 - 2026-08-13

- Add `InAppWebViewSettings.disableAutocorrection` support for editable
  content in Linux WPE WebKit.
- Enable the WPE disposal callback gate before native cleanup and replace
  duplicate headless/keep-alive owners explicitly.
- Use an internal lifecycle coordinator for WPE disposal and keep-alive
  reattachment so callbacks are rejected across ownership transfer.
- Apply WebKit/WPE settings only when their values change and skip duplicate
  asynchronous content-blocker compilation using a canonical settings snapshot.
- Gate all channel event and callback dispatch through the WPE lifecycle state,
  preserving default callback behavior while dropping stale post-dispose events.

## 1.0.7 - 2026-08-13

- Scope cookie operations with `webViewController` to the WebView's network
  session and apply per-WebView proxy settings to container sessions.

## 1.0.6 - 2026-08-12

- Add persistent WPE WebKit data containers through `ContainerController` and
  `InAppWebViewSettings.containerId`.

## 1.0.5 - 2026-08-08

- Make `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` force software WPE buffers before startup and skip DMA-BUF/EGL import in the pixel-buffer path, addressing white/transparent output reports on affected Intel/X11 systems ([#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861)).
- Add static regression coverage for the no-GL software-buffer contract.

## 1.0.4 - 2026-08-08

- Fall back from GtkGLArea to pixel-buffer rendering when GL initialization fails at runtime, with an actionable diagnostic for affected X11/Intel configurations ([#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861)).

## 1.0.3 - 2026-08-08

- Add `FLUTTER_INAPPWEBVIEW_LINUX_DISABLE_GL=1` to force the software/pixel-buffer rendering path for GPU/DMA-BUF issues ([#2861](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2861)).

## 1.0.2 - 2026-08-06

- Improve WPE WebKit CMake errors with all supported `pkg-config` candidates, backend alternatives, diagnostic commands, and an absolute link to `WPE_BACKEND.md`.
- Add Linux README prerequisite guidance for WPEPlatform and the legacy FDO backend across distro package layouts.
- Add static regression coverage for the dependency diagnostics and update the issue triage documentation for [#2862](https://github.com/pichillilorenzo/flutter_inappwebview/issues/2862).

## 1.0.1 - 2026-08-06

- Guard `webkit_web_view_get_theme_color` with `WEBKIT_CHECK_VERSION(2, 50, 0)` so Linux builds using older WPE WebKit headers and libraries no longer fail with an undefined reference.
- Preserve the existing theme-color behavior on WebKit 2.50 and newer while returning no theme color on older versions.
- Add a standalone source regression check for the WebKit version guard.
- Keep the Linux example's local federated dependency overrides aligned with the repository packages.
- Align the Linux implementation dependency on the federated platform interface with the current `1.0.3` contract.

## 1.0.0

- First `flutter_inappwebview_forge_linux` release as part of the Forge federated plugin.
- Reset the Linux implementation version to `1.0.0`.
- Original project attribution: [Lorenzo Pichilli and contributors](https://github.com/pichillilorenzo/flutter_inappwebview).
