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
  'RUN_ANDROID_FULLSCREEN_KEYBOARD_DIAGNOSTIC',
);

const _flutterInputKey = ValueKey<String>('android-2878-flutter-input');
const _webViewKey = ValueKey<String>('android-2878-fullscreen-webview');

String _fullscreenPage(String base64VideoData) =>
    '''
<!doctype html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <script>
    function play() {
      document.getElementById('video').play();
    }

    function enterFullscreen() {
      const video = document.getElementById('video');
      const request = video.requestFullscreen || video.webkitRequestFullscreen;
      if (request) {
        request.call(video);
      }
    }

    function exitFullscreen() {
      if (document.exitFullscreen) {
        document.exitFullscreen();
      } else if (document.webkitExitFullscreen) {
        document.webkitExitFullscreen();
      }
    }
  </script>
</head>
<body onload="play();">
  <button id="fullscreen" type="button" onclick="enterFullscreen();">
    Enter fullscreen
  </button>
  <video controls autoplay playsinline id="video">
    <source src="data:video/mp4;charset=utf-8;base64,$base64VideoData">
  </video>
</body>
</html>
''';

double _bottomInset() {
  final view = WidgetsBinding.instance.platformDispatcher.views.first;
  return view.viewInsets.bottom / view.devicePixelRatio;
}

// Opt-in diagnostic for issue #2878. It exercises the reported app-wide path:
// HTML5 fullscreen, fullscreen exit, then a Flutter TextField outside the
// WebView. Run it on an Android runtime with the software keyboard enabled.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Android #2878 fullscreen exit restores Flutter keyboard',
    (WidgetTester tester) async {
      final videoData = await rootBundle.load('test_assets/sample_video.mp4');
      final base64VideoData = base64Encode(Uint8List.view(videoData.buffer));
      final page = _fullscreenPage(base64VideoData);
      final pageBase64 = base64Encode(const Utf8Encoder().convert(page));
      final controllerCompleter = Completer<InAppWebViewController>();
      final pageLoaded = Completer<void>();
      final enterFullscreen = Completer<void>();
      final exitFullscreen = Completer<void>();
      final flutterFocusNode = FocusNode();

      addTearDown(flutterFocusNode.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            resizeToAvoidBottomInset: true,
            body: Column(
              children: [
                Expanded(
                  child: InAppWebView(
                    key: _webViewKey,
                    initialUrlRequest: URLRequest(
                      url: WebUri(
                        'data:text/html;charset=utf-8;base64,$pageBase64',
                      ),
                    ),
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      mediaPlaybackRequiresUserGesture: false,
                      allowsInlineMediaPlayback: false,
                    ),
                    onWebViewCreated: controllerCompleter.complete,
                    onLoadStop: (controller, url) {
                      if (!pageLoaded.isCompleted) {
                        pageLoaded.complete();
                      }
                    },
                    onEnterFullscreen: (controller) {
                      if (!enterFullscreen.isCompleted) {
                        enterFullscreen.complete();
                      }
                    },
                    onExitFullscreen: (controller) {
                      if (!exitFullscreen.isCompleted) {
                        exitFullscreen.complete();
                      }
                    },
                  ),
                ),
                TextField(
                  key: _flutterInputKey,
                  focusNode: flutterFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Flutter input after fullscreen',
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      final controller = await controllerCompleter.future;
      for (var second = 0; second < 30 && !pageLoaded.isCompleted; second++) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        pageLoaded.isCompleted,
        isTrue,
        reason: 'Android #2878 diagnostic page did not finish loading.',
      );

      final webViewRenderBox = tester.renderObject<RenderBox>(
        find.byKey(_webViewKey),
      );
      final webViewOrigin = webViewRenderBox.localToGlobal(Offset.zero);
      await tester.tapAt(webViewOrigin + const Offset(80, 28));
      await tester.pump();

      for (
        var second = 0;
        second < 30 && !enterFullscreen.isCompleted;
        second++
      ) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        enterFullscreen.isCompleted,
        isTrue,
        reason: 'Android #2878 HTML5 video did not enter fullscreen.',
      );

      await controller.evaluateJavascript(source: 'exitFullscreen();');
      for (
        var second = 0;
        second < 30 && !exitFullscreen.isCompleted;
        second++
      ) {
        await tester.pump(const Duration(seconds: 1));
      }
      expect(
        exitFullscreen.isCompleted,
        isTrue,
        reason: 'Android #2878 HTML5 video did not exit fullscreen.',
      );

      await tester.pump(const Duration(milliseconds: 500));
      final insetBeforeFocus = _bottomInset();
      flutterFocusNode.requestFocus();
      await SystemChannels.textInput.invokeMethod<void>('TextInput.show');

      double? insetAfterFocus;
      for (var attempt = 0; attempt < 20; attempt++) {
        await tester.pump(const Duration(milliseconds: 250));
        final inset = _bottomInset();
        if (inset > 20) {
          insetAfterFocus = inset;
          break;
        }
      }

      debugPrint(
        'Android #2878 diagnostic: insetBeforeFocus=$insetBeforeFocus '
        'insetAfterFocus=$insetAfterFocus '
        'focused=${flutterFocusNode.hasFocus}',
      );
      expect(
        insetAfterFocus,
        isNotNull,
        reason:
            'The fullscreen exit did not restore the Flutter keyboard. '
            'Run this diagnostic on an Android device/AVD with the software '
            'keyboard enabled; insetBeforeFocus=$insetBeforeFocus '
            'focused=${flutterFocusNode.hasFocus}.',
      );
    },
    skip: !_runDiagnostic || !Platform.isAndroid,
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
