import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' show FramePhase;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_ANDROID_SCREEN_TRANSITION_DIAGNOSTIC',
);
const _captureScreenshots = bool.fromEnvironment(
  'CAPTURE_ANDROID_SCREEN_TRANSITION_SCREENSHOTS',
);
const _useHybridComposition = bool.fromEnvironment(
  'ANDROID_2688_USE_HYBRID_COMPOSITION',
  defaultValue: true,
);
const _useNativeWebView = bool.fromEnvironment(
  'ANDROID_2688_NATIVE_WEBVIEW_BASELINE',
);

const _nativeWebViewType =
    'com.emirkanacar.flutter_inappwebview_forge_example/'
    'android_2688_native_webview';

const _webViewKey = ValueKey<String>('android-2688-diagnostic-webview');
const _transitionButtonKey = ValueKey<String>(
  'android-2688-diagnostic-transition-button',
);
const _destinationKey = ValueKey<String>('android-2688-diagnostic-destination');

const _diagnosticPage = '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    html, body { margin: 0; height: 100%; background: #0d47a1; }
    body { display: grid; place-items: center; font-family: sans-serif; }
    #webview-surface-marker { color: white; font-size: 28px; font-weight: 700; }
  </style>
</head>
<body>
  <div id="webview-surface-marker">WEBVIEW_SURFACE</div>
</body>
</html>
''';

// Opt-in diagnostic for issue #2688. Run it on Android 35 with
// --dart-define=RUN_ANDROID_SCREEN_TRANSITION_DIAGNOSTIC=true. The test
// logs Flutter frame timings around the route transition; screenshot capture
// is opt-in because the Android integration_test capture path can block while
// hybrid composition is active. Set ANDROID_2688_USE_HYBRID_COMPOSITION=false
// for the virtual-display comparison, or
// ANDROID_2688_NATIVE_WEBVIEW_BASELINE=true for the direct native WebView
// baseline. It does not change route-animation behavior.
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2688 WebView-to-Flutter transition diagnostic',
    (WidgetTester tester) async {
      final frameTimings = <Map<String, int>>[];
      void recordFrameTimings(List<FrameTiming> timings) {
        for (final timing in timings) {
          frameTimings.add({
            'frameNumber': timing.frameNumber,
            'buildStartMicros': timing.timestampInMicroseconds(
              FramePhase.buildStart,
            ),
            'buildMicros': timing.buildDuration.inMicroseconds,
            'rasterMicros': timing.rasterDuration.inMicroseconds,
            'totalMicros': timing.totalSpan.inMicroseconds,
            'vsyncOverheadMicros': timing.vsyncOverhead.inMicroseconds,
          });
        }
      }

      SchedulerBinding.instance.addTimingsCallback(recordFrameTimings);
      addTearDown(
        () =>
            SchedulerBinding.instance.removeTimingsCallback(recordFrameTimings),
      );

      final webViewCreated = Completer<void>();
      var loadStopObserved = false;
      await tester.pumpWidget(
        MaterialApp(
          home: _DiagnosticHome(
            onWebViewCreated: () {
              if (!webViewCreated.isCompleted) {
                webViewCreated.complete();
              }
            },
            onLoadStop: () => loadStopObserved = true,
          ),
        ),
      );

      // SurfaceAndroidViewController may need additional Flutter frames before
      // its platform-view callback is delivered. Keep pumping while waiting
      // so the virtual-display comparison is not blocked by the test itself.
      for (
        var second = 0;
        second < 30 && !webViewCreated.isCompleted;
        second++
      ) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        webViewCreated.isCompleted,
        isTrue,
        reason: 'Android #2688 WebView platform view was not created.',
      );
      await webViewCreated.future;
      // The diagnostic must not poll JavaScript: repeated evaluateJavascript
      // calls can retain callbacks while the platform view is settling. A
      // fixed wait gives the WebView time to paint without changing runtime
      // behavior or making onLoadStop a prerequisite for the measurement.
      await tester.pump(const Duration(seconds: 2));
      debugPrint(
        jsonEncode({
          'issue': 2688,
          'webViewCreated': true,
          'loadStopObserved': loadStopObserved,
        }),
      );

      if (_captureScreenshots) {
        // Android integration screenshots require the Flutter surface to be
        // converted before the first capture. On API 35 with hybrid
        // composition this SDK capture path can wait indefinitely; keep it
        // opt-in so the transition measurement itself remains runnable.
        await binding.convertFlutterSurfaceToImage();
        await tester.pump();
        await binding.takeScreenshot('android_2688_before_transition');
      }

      debugPrint(
        jsonEncode({
          'issue': 2688,
          'stage': 'before_transition',
          'compositionMode': _compositionMode,
          'screenshotCaptureEnabled': _captureScreenshots,
        }),
      );

      final transitionStartedAt = DateTime.now().millisecondsSinceEpoch;
      await tester.tap(find.byKey(_transitionButtonKey));

      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (_captureScreenshots &&
            (frame == 0 || frame == 8 || frame == 18 || frame == 30)) {
          await binding.takeScreenshot('android_2688_transition_$frame');
        }
      }

      await tester.pump(const Duration(milliseconds: 500));
      if (_captureScreenshots) {
        await binding.takeScreenshot('android_2688_after_transition');
      }

      debugPrint(
        jsonEncode({
          'issue': 2688,
          'platform': Platform.operatingSystem,
          'compositionMode': _compositionMode,
          'transitionStartedAtMs': transitionStartedAt,
          'screenshotCaptureEnabled': _captureScreenshots,
          'destinationPresent': tester.any(find.byKey(_destinationKey)),
          'webViewPresent': tester.any(find.byKey(_webViewKey)),
          'frameCount': frameTimings.length,
          'frameTimings': frameTimings,
        }),
      );

      expect(find.byKey(_destinationKey), findsOneWidget);
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

class _DiagnosticHome extends StatelessWidget {
  const _DiagnosticHome({
    required this.onWebViewCreated,
    required this.onLoadStop,
  });

  final VoidCallback onWebViewCreated;
  final VoidCallback onLoadStop;

  @override
  Widget build(BuildContext context) {
    final Widget webView = _useNativeWebView
        ? AndroidView(
            key: _webViewKey,
            viewType: _nativeWebViewType,
            onPlatformViewCreated: (_) => onWebViewCreated(),
          )
        : InAppWebView(
            key: _webViewKey,
            initialData: InAppWebViewInitialData(
              data: _diagnosticPage,
              baseUrl: WebUri('https://example.com/'),
            ),
            initialSettings: InAppWebViewSettings(
              useHybridComposition: _useHybridComposition,
            ),
            onWebViewCreated: (_) => onWebViewCreated(),
            onLoadStop: (_, __) => onLoadStop(),
          );

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: webView),
          SizedBox(
            height: 72,
            width: double.infinity,
            child: ElevatedButton(
              key: _transitionButtonKey,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const _DiagnosticDestination(),
                  ),
                );
              },
              child: const Text('OPEN FLUTTER DESTINATION'),
            ),
          ),
        ],
      ),
    );
  }
}

String get _compositionMode {
  if (_useNativeWebView) {
    return 'native-android-webview';
  }
  return _useHybridComposition ? 'hybrid' : 'virtual-display';
}

class _DiagnosticDestination extends StatelessWidget {
  const _DiagnosticDestination();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      key: _destinationKey,
      backgroundColor: Color(0xffe65100),
      body: Center(
        child: Text(
          'FLUTTER_DESTINATION',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
