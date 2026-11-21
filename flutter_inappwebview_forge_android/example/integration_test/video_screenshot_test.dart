// Device diagnostic for takeScreenshot of a playing video (upstream #2732).
// Run on a physical device:
//
//   fvm flutter test integration_test/video_screenshot_test.dart -d <device>
//
// A generated H.264 clip (test_assets/screenshot_video.mp4, ffmpeg testsrc2)
// is served through shouldInterceptRequest and played muted in a loop. Each
// case takes a screenshot and measures how much of the video rectangle is
// not black. The page background is white, so a black rectangle means the
// video frame was not captured.
//
// Only the PixelCopy results are asserted. draw() never contains the decoded
// video frame (the rectangle stays the page colour); that is logged only.

import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _baseUrl = 'https://page.forge.invalid/';
const _videoUrl = '${_baseUrl}video.mp4';

const _html =
    '''
<!DOCTYPE html><html><head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<style>html, body { margin: 0; background: #fff; }
video { display: block; width: 320px; height: 240px; margin: 40px; }</style>
</head><body>
<video id="v" src="$_videoUrl" muted autoplay loop playsinline></video>
<script>
window.videoState = 'loading';
var v = document.getElementById('v');
v.addEventListener('playing', function() { window.videoState = 'playing'; });
v.addEventListener('error', function() { window.videoState = 'error'; });
v.play().catch(function(e) { window.videoState = 'play-rejected: ' + e; });
</script></body></html>
''';

void _log(String line) {
  // ignore: avoid_print
  print('[video_screenshot] $line');
}

class _Probe {
  AndroidInAppWebViewController? controller;
  final loaded = Completer<void>();
}

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<T> _await<T>(WidgetTester tester, Future<T> future) async {
  T? result;
  Object? error;
  var done = false;
  future.then(
    (value) {
      result = value;
      done = true;
    },
    onError: (Object e) {
      error = e;
      done = true;
    },
  );
  final end = DateTime.now().add(const Duration(seconds: 30));
  while (!done && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue, reason: 'timed out');
  if (error != null) throw error!;
  return result as T;
}

Future<_Probe> _open(
  WidgetTester tester,
  Uint8List video, {
  required bool hybridComposition,
}) async {
  final probe = _Probe();
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: KeyedSubtree(
          key: UniqueKey(),
          child: Builder(
            builder: (context) => AndroidInAppWebViewWidget(
              AndroidInAppWebViewWidgetCreationParams(
                initialSettings: InAppWebViewSettings(
                  useHybridComposition: hybridComposition,
                  useShouldInterceptRequest: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                initialData: InAppWebViewInitialData(
                  data: _html,
                  baseUrl: WebUri(_baseUrl),
                ),
                onWebViewCreated: (c) =>
                    probe.controller = c as AndroidInAppWebViewController,
                onLoadStop: (c, url) {
                  if (!probe.loaded.isCompleted) probe.loaded.complete();
                },
                shouldInterceptRequest: (controller, request) async {
                  if (request.url.toString() != _videoUrl) return null;
                  return WebResourceResponse(
                    contentType: 'video/mp4',
                    statusCode: 200,
                    reasonPhrase: 'OK',
                    headers: {'Content-Length': '${video.length}'},
                    data: video,
                  );
                },
              ),
            ).build(context),
          ),
        ),
      ),
    ),
  );
  await _await(tester, probe.loaded.future);
  return probe;
}

Future<String> _videoState(WidgetTester tester, _Probe probe) async {
  final end = DateTime.now().add(const Duration(seconds: 15));
  var state = 'loading';
  while (DateTime.now().isBefore(end)) {
    state =
        '${await _await(tester, probe.controller!.evaluateJavascript(source: 'window.videoState;'))}';
    if (state != 'loading') break;
    await _pumpFor(tester, const Duration(milliseconds: 200));
  }
  return state;
}

/// Fractions of colored (video) and near-black pixels in the video rectangle,
/// and of near-black pixels in the white page area below it.
Future<String> _measure(
  WidgetTester tester,
  _Probe probe,
  Uint8List png,
) async {
  final rect =
      await _await(
            tester,
            probe.controller!.evaluateJavascript(
              source:
                  'var r = document.getElementById("v").getBoundingClientRect();'
                  '[r.left, r.top, r.width, r.height, window.innerWidth];',
            ),
          )
          as List<dynamic>;
  final codec = await ui.instantiateImageCodec(png);
  final image = (await codec.getNextFrame()).image;
  final bytes = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  // Screenshot pixels per CSS pixel.
  final scale = image.width / (rect[4] as num);
  final left = ((rect[0] as num) * scale).round();
  final top = ((rect[1] as num) * scale).round();
  final width = ((rect[2] as num) * scale).round();
  final height = ((rect[3] as num) * scale).round();

  var total = 0, colored = 0, black = 0;
  for (var y = top + 2; y < top + height - 2 && y < image.height; y += 3) {
    for (var x = left + 2; x < left + width - 2 && x < image.width; x += 3) {
      final i = (y * image.width + x) * 4;
      final r = bytes.getUint8(i), g = bytes.getUint8(i + 1);
      final b = bytes.getUint8(i + 2);
      final maxC = r > g ? (r > b ? r : b) : (g > b ? g : b);
      final minC = r < g ? (r < b ? r : b) : (g < b ? g : b);
      total++;
      if (maxC - minC > 60) colored++;
      if (r + g + b < 60) black++;
    }
  }
  var pageTotal = 0, pageBlack = 0;
  final pageTop = top + height + 20;
  for (var y = pageTop; y < pageTop + 200 && y < image.height; y += 5) {
    for (var x = left; x < left + width && x < image.width; x += 5) {
      final i = (y * image.width + x) * 4;
      pageTotal++;
      final sum =
          bytes.getUint8(i) + bytes.getUint8(i + 1) + bytes.getUint8(i + 2);
      if (sum < 60) pageBlack++;
    }
  }
  image.dispose();
  String f(int n, int d) => d == 0 ? '-' : (n / d).toStringAsFixed(2);
  return 'videoColored=${f(colored, total)} videoBlack=${f(black, total)} '
      'pageBlack=${f(pageBlack, pageTotal)}';
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('takeScreenshot captures a playing video', (tester) async {
    final video = (await rootBundle.load(
      'test_assets/screenshot_video.mp4',
    )).buffer.asUint8List();
    final results = <String, String?>{};
    for (final hybrid in [true, false]) {
      final probe = await _open(tester, video, hybridComposition: hybrid);
      final state = await _videoState(tester, probe);
      _log('hybridComposition=$hybrid videoState=$state');
      await _pumpFor(tester, const Duration(seconds: 2));
      for (final pixelCopy in [false, true]) {
        final key = 'hybrid=$hybrid pixelCopy=$pixelCopy';
        final png = await _await(
          tester,
          probe.controller!.takeScreenshot(
            screenshotConfiguration: ScreenshotConfiguration(
              usePixelCopy: pixelCopy,
            ),
          ),
        );
        results[key] = png == null ? null : await _measure(tester, probe, png);
        _log('RESULT $key ${results[key]}');
      }
    }
    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    _log('SUMMARY $results');
    for (final hybrid in [true, false]) {
      final copy = results['hybrid=$hybrid pixelCopy=true'];
      expect(copy, isNotNull);
      final colored = double.parse(
        RegExp(r'videoColored=([0-9.]+)').firstMatch(copy!)!.group(1)!,
      );
      final pageBlack = double.parse(
        RegExp(r'pageBlack=([0-9.]+)').firstMatch(copy)!.group(1)!,
      );
      expect(colored, greaterThan(0.5), reason: 'hybrid=$hybrid: $copy');
      expect(pageBlack, lessThan(0.1), reason: 'hybrid=$hybrid: $copy');
    }
  });
}
