import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';

class _FakeHeadlessInAppWebView extends PlatformHeadlessInAppWebView {
  _FakeHeadlessInAppWebView()
    : super.implementation(const PlatformHeadlessInAppWebViewCreationParams());

  int runCalls = 0;
  int disposeCalls = 0;
  bool running = false;

  @override
  String get id => 'fake_headless';

  @override
  Future<void> run() async {
    runCalls++;
    await Future<void>.delayed(Duration.zero);
    running = true;
  }

  @override
  bool isRunning() => running;

  @override
  Future<void> dispose() async {
    disposeCalls++;
    running = false;
  }
}

void main() {
  test(
    'coalesces concurrent prewarm calls and disposes headless ownership',
    () async {
      final platformHeadlessWebView = _FakeHeadlessInAppWebView();
      final headlessWebView = HeadlessInAppWebView.fromPlatform(
        platform: platformHeadlessWebView,
      );
      final preloader = InAppWebViewPreloader(headlessWebView: headlessWebView);

      final firstPrewarm = preloader.prewarm();
      final secondPrewarm = preloader.prewarm();

      expect(identical(firstPrewarm, secondPrewarm), isTrue);
      await Future.wait([firstPrewarm, secondPrewarm]);
      expect(platformHeadlessWebView.runCalls, 1);
      expect(preloader.isReady, isTrue);

      await preloader.dispose();
      await preloader.dispose();

      expect(platformHeadlessWebView.disposeCalls, 1);
      expect(preloader.isDisposed, isTrue);
      expect(preloader.isReady, isFalse);
    },
  );

  test('passes the preloader ownership pair to InAppWebView', () {
    final headlessWebView = HeadlessInAppWebView.fromPlatform(
      platform: _FakeHeadlessInAppWebView(),
    );
    final preloader = InAppWebViewPreloader(headlessWebView: headlessWebView);

    final webView = InAppWebView(preloader: preloader);
    final params = webView.platform.params;

    expect(params.headlessWebView, same(headlessWebView.platform));
    expect(params.keepAlive, same(preloader.keepAlive));
  });

  test('takes ownership of an already running headless WebView', () async {
    final platformHeadlessWebView = _FakeHeadlessInAppWebView()..running = true;
    final headlessWebView = HeadlessInAppWebView.fromPlatform(
      platform: platformHeadlessWebView,
    );
    final preloader = InAppWebViewPreloader(headlessWebView: headlessWebView);

    await preloader.prewarm();
    await preloader.dispose();

    expect(platformHeadlessWebView.runCalls, 0);
    expect(platformHeadlessWebView.disposeCalls, 1);
  });
}
