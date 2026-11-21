import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_ios/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('iOS callHandler consumes the postMessage promise rejection', () {
    // Upstream #2940: after disposal removes the script message handlers,
    // WebKit's postMessage promise rejects with InvalidAccessError. The bridge
    // must attach a rejection handler so the page gets no unhandledrejection.
    final source = _sourceFile(
      'ios/flutter_inappwebview_forge_ios/Sources/'
      'flutter_inappwebview_forge_ios/PluginScriptsJS/JavaScriptBridgeJS.swift',
    ).readAsStringSync();

    expect(source, contains('_Promise_then = window.Promise.prototype.then;'));
    expect(
      source,
      contains('var _postMessageResult = _postMessage.call(_UserMessageHandler'),
    );
    expect(
      source,
      contains('_Promise_then.call(_postMessageResult, null, function() {'),
    );
  });
}
