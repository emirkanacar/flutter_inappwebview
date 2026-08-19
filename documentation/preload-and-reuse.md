# Preload and reuse

Opening a WebView can require provider startup, native view creation, bridge
registration, initial scripts, and the first navigation. If the destination
route is known in advance, start that work before the route is displayed.

## Recommended flow

Create the preloader outside `build()`, prewarm it before navigation, and pass
the same object to the inline WebView:

```dart
class BrowserCoordinator {
  BrowserCoordinator()
    : preloader = InAppWebViewPreloader(
        headlessWebView: HeadlessInAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri('https://example.com'),
          ),
        ),
      );

  final InAppWebViewPreloader preloader;

  Future<void> prepare() => preloader.prewarm();

  Future<void> dispose() => preloader.dispose();
}
```

Then use it in the destination route:

```dart
InAppWebView(
  preloader: browserCoordinator.preloader,
  onWebViewCreated: (controller) {
    // This is the controller for the transferred native WebView.
  },
)
```

## Important ownership rules

- Keep the `InAppWebViewPreloader` alive until the inline WebView has taken
  ownership.
- Do not construct a second `InAppWebViewKeepAlive` for the same handoff.
- Do not call `dispose()` while the route still uses the WebView.
- Dispose the preloader when the application no longer needs the retained
  native WebView.
- `prewarm()` starts navigation but does not wait for `onLoadStop`.
- A failed prewarm can be retried; concurrent calls are coalesced.

## When not to prewarm

Prewarming consumes memory and may start network work before the user opens
the screen. Avoid it when:

- the destination is rarely opened;
- the URL or profile is not known yet;
- the page contains user-specific data that should not be prepared early;
- the device is under a strict memory budget.

For those cases, use a normal inline WebView and keep a stable
`InAppWebViewKeepAlive` only across temporary widget detaches.

## Measuring the benefit

Compare the same release/profile build with and without prewarming. Measure:

1. time from route push to first usable WebView frame;
2. time to the target page's readiness signal;
3. memory before and after prewarm;
4. duplicate navigation or callback counts;
5. behavior after repeated attach, detach, and dispose cycles.

Prewarming is an optimization, not a guarantee that the page is fully loaded
when the route appears.
