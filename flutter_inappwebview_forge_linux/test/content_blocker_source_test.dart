import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

String _read(String relativePath) {
  final candidates = [
    File('linux/$relativePath'),
    File('flutter_inappwebview_forge_linux/linux/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync()).readAsStringSync();
}

void main() {
  // Upstream PR #2928: content blockers fail closed and swap without a gap.
  test('content blocker filters are swapped add-first per rule set', () {
    final handler = _read('content_blocker/content_blocker_handler.cc');
    final set = handler.substring(
      handler.indexOf('void ContentBlockerHandler::setContentBlockers('),
      handler.indexOf(
        'std::string ContentBlockerHandler::serializeContentBlockers(',
      ),
    );
    // The old filter is only removed for an empty rule set.
    expect('removeAllFilters();'.allMatches(set), hasLength(1));
    expect(set, contains('std::hash<std::string>{}(jsonSource)'));
    final ready = handler.substring(
      handler.indexOf('void ContentBlockerHandler::filterReady('),
    );
    expect(
      ready.indexOf('webkit_user_content_manager_add_filter('),
      lessThan(
        ready.indexOf('webkit_user_content_manager_remove_filter_by_id('),
      ),
    );
    expect(handler, contains('context->alive.expired()'));
  });

  test('loads and navigations do not run without the requested rules', () {
    final webView = _read('in_app_webview/in_app_webview.cc');
    expect(
      webView,
      contains(
        'errorLog("InAppWebView: Content blockers failed to apply, not loading content");\n'
        '            return;',
      ),
    );
    expect(webView, contains('blockers->rulesMissing()'));
    expect(webView, contains('blockers->whenSettled('));
  });
}
