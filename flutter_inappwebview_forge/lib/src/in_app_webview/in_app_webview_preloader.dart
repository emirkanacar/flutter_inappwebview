import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

import 'headless_in_app_webview.dart';
import 'in_app_webview_controller.dart';

/// Coordinates an opt-in headless-to-inline WebView handoff.
///
/// A preloader does not create a second WebView. It starts the supplied
/// [headlessWebView] once and exposes the same [keepAlive] instance for the
/// later [InAppWebView] attachment. This moves WebView/provider startup and
/// the initial navigation before the route that displays the WebView.
///
/// Call [prewarm] before building an [InAppWebView] and pass this instance to
/// its `preloader` parameter:
///
/// ```dart
/// final preloader = InAppWebViewPreloader(
///   headlessWebView: HeadlessInAppWebView(
///     initialUrlRequest: URLRequest(url: WebUri('https://example.com')),
///   ),
/// );
/// await preloader.prewarm();
///
/// // Later, in the route that displays the WebView:
/// InAppWebView(preloader: preloader);
/// ```
///
/// The prewarm operation makes the native WebView available and starts the
/// initial navigation. It does not wait for `onLoadStop`; configure that
/// callback on the supplied [HeadlessInAppWebView] or on the inline widget as
/// usual.
///
/// This helper is intended for native WebView platforms. Web support is
/// limited by the platform's KeepAlive disposal capability.
class InAppWebViewPreloader {
  /// Creates a preloader around an existing [HeadlessInAppWebView].
  InAppWebViewPreloader({
    required this.headlessWebView,
    InAppWebViewKeepAlive? keepAlive,
  }) : keepAlive = keepAlive ?? InAppWebViewKeepAlive();

  /// The headless WebView that will be started by [prewarm].
  final HeadlessInAppWebView headlessWebView;

  /// The ownership token used when the headless WebView is attached inline.
  ///
  /// Pass this object to the same [InAppWebView] through `preloader`; do not
  /// create a second KeepAlive object for the handoff.
  final InAppWebViewKeepAlive keepAlive;

  Future<void>? _prewarmFuture;
  Future<void>? _disposeFuture;
  bool _disposed = false;

  /// Whether the native headless WebView is ready to be attached.
  bool get isReady => !_disposed && headlessWebView.isRunning();

  /// Whether this preloader has begun disposal.
  bool get isDisposed => _disposed;

  /// The controller exposed by the headless WebView, when available.
  InAppWebViewController? get controller => headlessWebView.webViewController;

  /// Starts the native WebView exactly once for concurrent callers.
  ///
  /// Calling this method after a successful prewarm is a no-op. If the native
  /// start fails, a later call is allowed to retry.
  Future<void> prewarm() {
    if (_disposed) {
      return Future<void>.error(
        StateError('InAppWebViewPreloader has already been disposed.'),
      );
    }
    if (headlessWebView.isRunning()) {
      return _prewarmFuture ??= Future<void>.value();
    }
    return _prewarmFuture ??= _startHeadlessWebView();
  }

  Future<void> _startHeadlessWebView() async {
    try {
      await headlessWebView.run();
    } catch (_) {
      _prewarmFuture = null;
      rethrow;
    }
  }

  /// Disposes the retained WebView exactly once.
  ///
  /// Before inline attachment, the headless owner is disposed. After the
  /// inline widget takes ownership, the KeepAlive disposal path is used so
  /// the transferred native WebView is not leaked.
  Future<void> dispose() => _disposeFuture ??= _dispose();

  Future<void> _dispose() async {
    _disposed = true;

    final prewarmFuture = _prewarmFuture;
    if (prewarmFuture != null) {
      try {
        await prewarmFuture;
      } catch (_) {
        // The failed prewarm has no retained native WebView to dispose.
      }
    }

    if (headlessWebView.isRunning()) {
      await headlessWebView.dispose();
      return;
    }

    if (_prewarmFuture == null ||
        !InAppWebViewController.isMethodSupported(
          PlatformInAppWebViewControllerMethod.disposeKeepAlive,
        )) {
      return;
    }

    await InAppWebViewController.disposeKeepAlive(keepAlive);
  }
}
