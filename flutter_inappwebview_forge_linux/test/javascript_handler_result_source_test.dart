import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_linux/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  test('JavaScript handler results are parsed, never run as code', () {
    // Upstream PR #2948: a handler can return pre-encoded JSON text
    // (JavaScriptHandlerJsonResult). The result must not be spliced into
    // JavaScript source, or invalid or untrusted text would run in the page.
    final source = _sourceFile(
      'linux/in_app_webview/in_app_webview.cc',
    ).readAsStringSync();

    final start = source.indexOf(
      'void InAppWebView::ResolveInternalHandlerWithReply(',
    );
    final body = source.substring(start, source.indexOf('\n}\n', start));
    expect(body, isNot(contains('jsc_context_evaluate')));
    expect(
      body,
      contains('jsc_value_new_from_json(context, jsonResult.c_str())'),
    );
    expect(body, contains('webkit_script_message_reply_return_error_message'));
  });
}
