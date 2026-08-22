# Lifecycle and performance

## WebView ownership

There are three useful ownership patterns:

| Pattern | Use case | Native WebView lifetime |
| --- | --- | --- |
| Normal `InAppWebView` | One screen owns the WebView | Ends when the widget/controller is disposed |
| `InAppWebViewKeepAlive` | Temporary widget detach or route replacement | Retained across reattachment |
| `InAppWebViewPreloader` | Known destination that should open faster | Starts headless, then transfers to inline |

The owner must be created outside `build()`. A Flutter rebuild must not be
treated as a request to create a new native WebView.

## Safe lifecycle sequence

```text
create -> prepare -> attach -> ready -> detach/retain -> reattach -> dispose
```

Dispose is idempotent. Once disposal begins, new events and asynchronous
operations should not be sent to the native WebView. Pending callbacks keep
their existing result contract and complete once.

## Avoiding cold starts

- Keep `InAppWebViewKeepAlive` stable while a screen is temporarily removed.
- Use `InAppWebViewPreloader` when the destination and initial settings are
  known before navigation.
- Keep the initial settings stable; changing profile, container, incognito,
  or data-store settings usually requires a new native WebView.
- Do not clear cache or cookies as a generic performance workaround.
- Do not reload a page merely because the Flutter widget rebuilt.

## Event pressure

Scroll, progress, JavaScript bridge, and WebMessage callbacks can be high
frequency. Application callbacks should avoid expensive synchronous work,
large map copies, and unnecessary state updates. Coalesce UI updates when the
application only needs the latest value.

## Memory trade-off

Retaining a WebView preserves page state but also retains its renderer,
JavaScript context, callbacks, and data-store references. Keep only the
WebViews that the user is likely to revisit. Always dispose retained instances
when the owning feature or session ends.

## Performance checklist

- Measure release/profile builds, not only debug builds.
- Record the Android WebView provider or iOS version with measurements.
- Measure first usable frame separately from `onLoadStop`.
- Test repeated attach/detach and dispose/recreate cycles.
- Check memory after navigation to a heavy page and after disposal.
- Treat provider, renderer, and OS behavior as separate from Flutter widget
  rebuild performance.

## Android BFCache and state snapshots

BFCache reduces back-navigation latency when the provider supports it. Tune
timeout and page count together with `backForwardCacheEnabled`:

```dart
InAppWebViewSettings(
  backForwardCacheEnabled: true,
  backForwardCacheTimeoutSeconds: 90,
  backForwardCacheMaxPagesInCache: 5,
)
```

For process restoration without reloading HTML, prefer `saveStateWithOptions`
when available and restore before the WebView builds a conflicting history
list:

```dart
final state = await controller.saveStateWithOptions(
  maxSizeBytes: 256 * 1024,
  includeForwardHistory: false,
);
// Later, on a fresh WebView or before further navigation:
await controller.restoreState(state!);
```

Measure memory alongside latency; retained BFCache entries and saved bundles
both consume device resources.
