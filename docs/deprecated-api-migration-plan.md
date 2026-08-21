# Deprecated API Migration Plan

Last reviewed: 2026-08-21
Status: Inventory and consumer docs are in place; public shims stay until a
major-version decision; native Android SDK-deprecated paths stay until an
explicit minSdk increase
Scope: public Dart compatibility shims, host-app migration, and native SDK
deprecation cleanup gated on minSdk

## Objective

Keep the 5.x `Options`, `androidOn*` / `iosOn*`, and `IOS*` / `Android*`
compatibility shims working while new code uses current names. Do not remove a
public shim, MethodChannel name, or minSdk 19 native fallback in a patch or
minor release.

Application-facing mapping:
[Deprecated APIs](../documentation/deprecated-api.md).

Upstream package rename:
[Migration and upstream](../documentation/migration-from-upstream.md).

## Current state

| Layer | State | Removal gate |
| --- | --- | --- |
| Public Dart `*Options`, prefixed callbacks, `IOS*` / `Android*` types | Present and `@Deprecated` | Intentional major version |
| `saveFormData` | Present; message now names Android Autofill and no Dart replacement | Keep while minSdk is below 26 or the public setting remains |
| Example / tests | Storage screen uses `onReceivedError`; focused source tests lock current names | Keep examples on current names |
| Android SDK-deprecated WebView/cookie/print/forceDark paths | Isolated with `@file:Suppress("DEPRECATION")` | Explicit minSdk increase (21+ or 24+), tracked by #2641 / #2685 |
| iOS `canOpenURL` | Removed from `openWithSystemBrowser` | Done in iOS 2.1.33 / root 2.1.74 |
| Analyzer ignore of `deprecated_member_use` | Enabled in plugin packages | Keep while shims call each other |

## Non-goals

- Do not delete public Dart shims in 2.1.x.
- Do not rename MethodChannel methods (`clearCache`, `findAll`, `setOptions`).
- Do not raise Android `minSdkVersion` as part of this plan.
- Do not treat `shouldAllowDeprecatedTLS` as a deprecated API; the name refers
  to TLS 1.0/1.1.
- Do not mark `useHybridComposition` deprecated until a replacement contract
  is chosen.

## Host-app migration (do this now)

New application code should use current names. Deprecated names still compile.

1. Replace `initialOptions` / `InAppWebViewGroupOptions` with
   `initialSettings` / `InAppWebViewSettings`.
2. Replace `setOptions` / `getOptions` with `setSettings` / `getSettings`.
3. Replace `onLoadError` / `onLoadHttpError` with `onReceivedError` /
   `onReceivedHttpError`.
4. Replace `onDownloadStart` / `onDownloadStartRequest` with
   `onDownloadStarting`.
5. Drop `androidOn*` and `iosOn*` prefixes (`androidOnPermissionRequest` to
   `onPermissionRequest`, `iosOnNavigationResponse` to
   `onNavigationResponse`, and the rest of the table in
   [Deprecated APIs](../documentation/deprecated-api.md)).
6. Move find-in-page from `findAllAsync` / widget `onFindResultReceived` to
   `FindInteractionController`.
7. Replace `clearCache()` with `InAppWebViewController.clearAllCache`.
8. Replace `JavaScriptHandlerCallback` with `JavaScriptHandlerFunction`.
9. Replace `IOS*` / `Android*` type names with the unprefixed type.
10. Stop setting `forceDark` / `forceDarkStrategy`; use
    `algorithmicDarkeningAllowed`.
11. Do not depend on `saveFormData` on API 26+. There is no Dart replacement.
12. Do not set `allowUniversalAccessFromFileURLs: true` for local files; use
    `WebViewAssetLoader` or a controlled HTTPS origin.

Host apps that do not ignore `deprecated_member_use` will see analyzer
warnings until they finish this list. Plugin packages ignore that lint so
internal shims can keep calling each other.

## Implementation phases

### Phase 0 — Inventory and docs (complete in 2.1.75)

- Publish the current-name table in `documentation/deprecated-api.md`.
- Record empty `@Deprecated('')` messages as real rationale for `saveFormData`
  and Android cache helpers.
- Keep public shims; do not change channel contracts.

### Phase 1 — Example and test alignment (complete in 2.1.75)

- Example widgets use current callback and settings names.
- Source-contract tests fail if `saveFormData` or native cache helpers go back
  to an empty deprecation message, or if the storage example returns to
  `onLoadError`.

### Phase 2 — Consumer migration window (current)

- Each minor changelog that touches a deprecated surface must name the old
  API and the current replacement.
- Do not count a host app as migrated until its own analyzer no longer reports
  `deprecated_member_use` from this plugin.

### Phase 3 — Native SDK cleanup (blocked)

- Raise Android minSdk only with a separate release decision.
- After minSdk 21, remove pre-Lollipop `CookieManager.removeSessionCookie` /
  `removeAllCookie`.
- After minSdk 24+, re-evaluate `forceDark`, `saveFormData`,
  `WebView.clearCache`, AbsoluteLayout, and legacy print/fullscreen.
- Keep file-level `@file:Suppress("DEPRECATION")` until that decision.

### Phase 4 — Public shim removal (major version only)

- Remove `*Options`, prefixed callbacks, and `IOS*` / `Android*` types from
  the public Dart API.
- Keep MethodChannel compatibility or publish a breaking channel revision in
  the same major.
- Update [Deprecated APIs](../documentation/deprecated-api.md) from a mapping
  table to a removed-API record.

## Changelog rule

When a change documents, redirects, or later removes a deprecated surface,
the affected package `CHANGELOG.md` and `documentation/changelog.md` must
name:

- the deprecated symbol;
- the current replacement, or "no replacement" when none exists;
- whether the symbol is still present.

Do not describe this only as "compatibility shims" without the old names.

## Acceptance

- New application code can migrate using only
  [Deprecated APIs](../documentation/deprecated-api.md) and this plan.
- 2.1.x still compiles existing 5.x Options and prefixed-callback call sites.
- Native Android SDK-deprecated paths remain for minSdk 19 until Phase 3.
- A major-version removal has an explicit changelog section listing every
  deleted public symbol.

## Related records

- [#2641 / #2685](known-issues.md#2641-and-2685--android-javawebview-deprecation-warning-backlog)
  Android Java/WebView deprecation warning backlog
- [#2728](known-issues.md#2728--android-15-deprecated-system-bar-apis)
  Android 15 status-bar APIs already removed from plugin bytecode
- [#2882](known-issues.md#2882--ios-27-canopenurl-deprecation)
  iOS `canOpenURL` already replaced in `openWithSystemBrowser`
