import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge/flutter_inappwebview_forge.dart';
import 'package:integration_test/integration_test.dart';

const _runDiagnostic = bool.fromEnvironment(
  'RUN_IOS_FULLSCREEN_VIDEO_SEEK_DIAGNOSTIC',
);

String _diagnosticPage(String base64VideoData) =>
    '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script>
    window.__forgeSeekStatus = 'script-loaded';
    async function seekAndEnterFullscreen() {
      const video = document.getElementById('video');
      if (!video) {
        window.__forgeSeekStatus = 'missing-video';
        return 'missing-video';
      }
      window.__forgeSeekStatus = 'waiting-metadata';
      if (video.readyState < 1) {
        await new Promise(function(resolve) {
          video.addEventListener('loadedmetadata', resolve, { once: true });
        });
      }
      window.__forgeSeekStatus = 'metadata:' + video.readyState + ':' + video.duration;
      video.muted = true;
      try {
        await video.play();
        window.__forgeSeekStatus = 'playing:' + video.readyState;
      } catch (error) {
        window.__forgeSeekStatus = 'play-error:' + String(error);
        return 'play-error';
      }
      const target = Math.min(0.75, Math.max(0.1, video.duration / 2));
      if (!Number.isFinite(target)) {
        window.__forgeSeekStatus = 'invalid-target:' + video.duration;
        return 'invalid-target';
      }
      await new Promise(function(resolve) {
        let completed = false;
        const enter = function() {
          if (completed) return;
          completed = true;
          window.__forgeSeekStatus = 'seeked:' + video.currentTime;
          resolve();
        };
        video.addEventListener('seeked', enter, { once: true });
        window.__forgeSeekStatus = 'seeking:' + target;
        video.currentTime = target;
        if (video.readyState >= 3 && Math.abs(video.currentTime - target) < 0.01) {
          window.setTimeout(enter, 0);
        }
      });
      const request = video.webkitEnterFullscreen || video.requestFullscreen;
      if (!request) {
        window.__forgeSeekStatus = 'fullscreen-api-missing';
        return 'fullscreen-api-missing';
      }
      try {
        window.__forgeSeekStatus = 'requesting:' +
            (video.webkitEnterFullscreen ? 'webkit' : 'standard');
        request.call(video);
        window.__forgeSeekStatus = 'requested';
        return 'requested';
      } catch (error) {
        window.__forgeSeekStatus = 'request-error:' + String(error);
        return 'request-error:' + String(error);
      }
    }
  </script>
</head>
<body style="margin:0;background:#000">
  <video id="video" controls playsinline autoplay preload="auto" muted style="width:100%;height:auto">
    <source src="data:video/mp4;charset=utf-8;base64,$base64VideoData">
  </video>
</body>
</html>
''';

Future<bool> _waitForEvent(WidgetTester tester, Completer<void> event) async {
  for (var second = 0; second < 30 && !event.isCompleted; second++) {
    await tester.pump(const Duration(seconds: 1));
  }
  return event.isCompleted;
}

// Opt-in diagnostic for issue #2710. It exercises the affected iOS 26 path:
// seek an HTML5 video, enter fullscreen, dismiss the native container by
// changing the setting at runtime, then repeat without a host crash or stale
// fullscreen state.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'iOS #2710 seek then fullscreen remains responsive',
    (WidgetTester tester) async {
      final videoData = await rootBundle.load('test_assets/sample_video.mp4');
      final base64VideoData = base64Encode(Uint8List.view(videoData.buffer));
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      Completer<void>? enterFullscreen;
      Completer<void>? exitFullscreen;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: InAppWebView(
              initialData: InAppWebViewInitialData(
                data: _diagnosticPage(base64VideoData),
                baseUrl: WebUri('https://example.com/'),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useNativeFullscreenContainer: true,
              ),
              onWebViewCreated: controllerCompleter.complete,
              onLoadStop: (controller, url) {
                if (!pageLoaded.isCompleted) {
                  pageLoaded.complete();
                }
              },
              onEnterFullscreen: (controller) {
                final event = enterFullscreen;
                if (event != null && !event.isCompleted) {
                  event.complete();
                }
              },
              onExitFullscreen: (controller) {
                final event = exitFullscreen;
                if (event != null && !event.isCompleted) {
                  event.complete();
                }
              },
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      expect(
        await _waitForEvent(tester, pageLoaded),
        isTrue,
        reason: 'iOS #2710 did not receive page load within 30 seconds.',
      );

      final cycles = <int>[];
      for (var cycle = 0; cycle < 3; cycle++) {
        final enterEvent = Completer<void>();
        final exitEvent = Completer<void>();
        enterFullscreen = enterEvent;
        exitFullscreen = exitEvent;
        final requestResult = await controller.evaluateJavascript(
          source: 'seekAndEnterFullscreen();',
        );
        debugPrint(
          'iOS #2710 cycle=$cycle seek/fullscreen request=$requestResult',
        );
        final entered = await _waitForEvent(tester, enterEvent);
        if (!entered) {
          final status = await controller.evaluateJavascript(
            source:
                "window.__forgeSeekStatus + '|' + "
                "document.readyState + '|' + "
                "document.getElementById('video').readyState + '|' + "
                "document.getElementById('video').duration + '|' + "
                "document.getElementById('video').currentTime",
          );
          debugPrint('iOS #2710 fullscreen entry timeout state=$status');
        }
        expect(
          entered,
          isTrue,
          reason:
              'iOS #2710 did not receive fullscreen entry within 30 seconds.',
        );
        expect(await controller.isInFullscreen(), isTrue);

        await controller.setSettings(
          settings: InAppWebViewSettings(useNativeFullscreenContainer: false),
        );
        expect(
          await _waitForEvent(tester, exitEvent),
          isTrue,
          reason:
              'iOS #2710 did not receive fullscreen exit within 30 seconds.',
        );
        expect(await controller.isInFullscreen(), isFalse);

        await controller.setSettings(
          settings: InAppWebViewSettings(useNativeFullscreenContainer: true),
        );
        cycles.add(cycle);
      }

      debugPrint('iOS #2710 diagnostic: cycles=$cycles');
      expect(cycles, [0, 1, 2]);
    },
    skip: !_runDiagnostic || !Platform.isIOS,
    timeout: const Timeout(Duration(minutes: 4)),
  );
}
