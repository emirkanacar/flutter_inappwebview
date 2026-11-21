import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_macos/$relativePath'),
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
      'macos/flutter_inappwebview_forge_macos/Sources/flutter_inappwebview_forge_macos/'
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
  });
}
