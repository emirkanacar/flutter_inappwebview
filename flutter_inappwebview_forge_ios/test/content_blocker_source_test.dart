import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _sources =
    'ios/flutter_inappwebview_forge_ios/Sources/flutter_inappwebview_forge_ios/';

String _read(String relativePath) {
  final candidates = [
    File('$_sources$relativePath'),
    File('flutter_inappwebview_forge_ios/$_sources$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync()).readAsStringSync();
}

void main() {
  // Upstream PR #2928: content blockers fail closed and swap without a gap.
  test('content blockers are compiled per rule set and swapped add-first', () {
    final webView = _read('InAppWebView/InAppWebView.swift');
    expect(webView, isNot(contains('forIdentifier: "ContentBlockingRules"')));
    expect(
      webView,
      contains(
        'InAppWebView.contentRuleListPrefix + Util.sha256Hex(encodedRules)',
      ),
    );
    final enforce = webView.indexOf('private func enforceContentRuleList(');
    expect(enforce, greaterThan(0));
    final body = webView.substring(enforce, enforce + 700);
    expect(
      body.indexOf('userContentController.add(contentRuleList)'),
      lessThan(body.indexOf('userContentController.remove(previous)')),
    );
    final setSettings = webView.substring(webView.indexOf('func setSettings('));
    expect(
      setSettings,
      contains('applyContentBlockers(newSettings.contentBlockers)'),
    );
  });

  test('navigation waits for requested rules and is refused if they fail', () {
    final webView = _read('InAppWebView/InAppWebView.swift');
    expect(
      webView,
      contains(
        'if requestedContentRuleListIdentifier != "", appliedContentRuleList == nil {',
      ),
    );
    expect(webView, contains('guard contentRuleListPending else {'));
    // Dispose answers waiting navigations exactly once.
    final dispose = webView.indexOf('public func dispose() {');
    expect(
      webView.substring(dispose, dispose + 600),
      contains('finishContentRuleListRequest(false)'),
    );
  });

  test('initial loads do not start without the requested rules', () {
    for (final path in [
      'InAppWebView/FlutterWebViewController.swift',
      'InAppBrowser/InAppBrowserWebViewController.swift',
    ]) {
      final source = _read(path);
      expect(source, contains('applyContentBlockers(contentBlockers)'));
      expect(source, isNot(contains('compileContentRuleList(')));
    }
  });
}
