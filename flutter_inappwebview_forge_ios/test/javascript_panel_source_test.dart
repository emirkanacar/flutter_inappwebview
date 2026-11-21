import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

String _functionBody(String source, String signature) {
  final start = source.indexOf(signature);
  expect(start, isNonNegative, reason: '$signature is missing');
  final end = source.indexOf('\n    }\n', start);
  return source.substring(start, end);
}

void main() {
  test('JavaScript alert, confirm, and prompt panels are always answered', () {
    // Upstream PR #2943: WebKit raises NSInternalInconsistencyException when a
    // panel completion handler is released without being called.
    final source = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/'
      'InAppWebView/InAppWebView.swift',
    ).readAsStringSync();

    // A released web view must still answer the panel with its default value.
    for (final dialog in ['Alert', 'Confirm', 'Prompt']) {
      expect(source, isNot(contains('self?.create${dialog}Dialog(')));
    }

    // A second alert while timers are paused must not drop the first handler,
    // and dispose must answer the held handler instead of releasing it.
    expect(source, contains('previousPausedTimersCompletionHandler?()'));
    expect(
      _functionBody(source, 'public func dispose() {'),
      contains('pausedTimersCompletionHandler?()'),
    );

    // Panels present from the topmost controller and answer at once when
    // UIKit cannot present them.
    expect(source, contains('func presentJavaScriptPanel('));
    expect(source, isNot(contains(': window?.rootViewController else {')));
  });

  test('enableNativePromptDialog=false cancels unhandled prompts', () {
    // Upstream PR #2901.
    final source = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/'
      'InAppWebView/InAppWebView.swift',
    ).readAsStringSync();
    final settings = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/'
      'InAppWebView/InAppWebViewSettings.swift',
    ).readAsStringSync();

    expect(settings, contains('var enableNativePromptDialog = true'));
    final prompt = _functionBody(
      source,
      'runJavaScriptTextInputPanelWithPrompt message: String',
    );
    expect(
      prompt,
      contains(
        'guard self.settings?.enableNativePromptDialog != false else {\n'
        '                    completionHandler(nil)\n'
        '                    return\n'
        '                }',
      ),
    );
  });
}
