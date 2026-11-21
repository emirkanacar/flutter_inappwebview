// Device check for InAppWebViewSettings.shouldInterceptRequestUrlFilter. Run on
// a physical device:
//
//   fvm flutter test integration_test/intercept_url_filter_test.dart -d <device>
//
// The page requests _imageCount images on a reserved .invalid host plus one
// API URL. shouldInterceptRequest is called before any network access, so DNS
// failures do not matter. Only the API URL matches the filter.
//
// Without a filter, the native cap on concurrent synchronous interception
// lets most requests bypass Dart, which can include the API request itself.

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview_forge_android/flutter_inappwebview_forge_android.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

const _imageCount = 200;
const _apiUrl = 'https://api.forge.invalid/data.json';
const _filter = [r'^https://api\.forge\.invalid/'];

String _html(String tag) {
  final images = List.generate(
    _imageCount,
    (i) => '<img src="https://img.forge.invalid/$tag/$i.png">',
  ).join();
  return '''
<!DOCTYPE html><html><body>$images
<script>
window.apiResult = 'pending';
fetch('$_apiUrl?$tag').then(function(r) { return r.text(); })
  .then(function(t) { window.apiResult = t; })
  .catch(function(e) { window.apiResult = 'error'; });
</script></body></html>
''';
}

void _log(String line) {
  // ignore: avoid_print
  print('[intercept_filter] $line');
}

class _Probe {
  AndroidInAppWebViewController? controller;
  final loaded = Completer<void>();
  final urls = <String>[];
}

Future<void> _pumpFor(WidgetTester tester, Duration duration) async {
  final end = DateTime.now().add(duration);
  while (DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Future<T> _await<T>(WidgetTester tester, Future<T> future) async {
  T? result;
  var done = false;
  future.then((value) {
    result = value;
    done = true;
  });
  final end = DateTime.now().add(const Duration(seconds: 30));
  while (!done && DateTime.now().isBefore(end)) {
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(done, isTrue, reason: 'timed out');
  return result as T;
}

Future<String> _apiResult(WidgetTester tester, _Probe probe) async {
  final end = DateTime.now().add(const Duration(seconds: 20));
  while (DateTime.now().isBefore(end)) {
    final value = await _await(
      tester,
      probe.controller!.evaluateJavascript(source: 'window.apiResult;'),
    );
    if (value != 'pending') return '$value';
    await _pumpFor(tester, const Duration(milliseconds: 200));
  }
  return 'pending';
}

Future<_Probe> _open(
  WidgetTester tester,
  String tag, {
  required List<String> filter,
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
                  useShouldInterceptRequest: true,
                  shouldInterceptRequestUrlFilter: filter,
                ),
                initialData: InAppWebViewInitialData(
                  data: _html(tag),
                  baseUrl: WebUri('https://page.forge.invalid/'),
                ),
                onWebViewCreated: (c) =>
                    probe.controller = c as AndroidInAppWebViewController,
                onLoadStop: (c, url) {
                  if (!probe.loaded.isCompleted) probe.loaded.complete();
                },
                shouldInterceptRequest: (controller, request) async {
                  final url = request.url.toString();
                  probe.urls.add(url);
                  if (url.startsWith(_apiUrl)) {
                    return WebResourceResponse(
                      contentType: 'application/json',
                      contentEncoding: 'utf-8',
                      statusCode: 200,
                      reasonPhrase: 'OK',
                      headers: {'Access-Control-Allow-Origin': '*'},
                      data: Uint8List.fromList(utf8.encode('from-dart')),
                    );
                  }
                  return null;
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

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('filter limits shouldInterceptRequest calls', (tester) async {
    final wallAll = Stopwatch()..start();
    final all = await _open(tester, 'all', filter: const []);
    final allResult = await _apiResult(tester, all);
    wallAll.stop();
    final allCalls = all.urls.length;

    final wallFiltered = Stopwatch()..start();
    final filtered = await _open(tester, 'filtered', filter: _filter);
    final filteredResult = await _apiResult(tester, filtered);
    wallFiltered.stop();
    final filteredCalls = List.of(filtered.urls);

    _log(
      'RESULT no-filter: calls=$allCalls api=$allResult '
      'wallMs=${wallAll.elapsedMilliseconds}',
    );
    _log(
      'RESULT filter: calls=${filteredCalls.length} api=$filteredResult '
      'wallMs=${wallFiltered.elapsedMilliseconds} urls=$filteredCalls',
    );

    // Without a filter, requests beyond the native concurrency cap for
    // synchronous interception bypass Dart, so allCalls is usually far below
    // _imageCount and the API response may never come from Dart. It is logged,
    // not asserted.
    expect(allCalls, greaterThan(filteredCalls.length));
    expect(filteredResult, 'from-dart');
    expect(filteredCalls, hasLength(1));
    expect(filteredCalls.single, startsWith(_apiUrl));

    // Clearing the filter at runtime sends every request to Dart again.
    await _await(
      tester,
      filtered.controller!.setSettings(
        settings: InAppWebViewSettings(
          useShouldInterceptRequest: true,
          shouldInterceptRequestUrlFilter: const [],
        ),
      ),
    );
    filtered.urls.clear();
    await _await(
      tester,
      filtered.controller!.evaluateJavascript(
        source:
            "var i = new Image(); i.src = 'https://img.forge.invalid/late.png'; 1;",
      ),
    );
    await _pumpFor(tester, const Duration(seconds: 2));
    _log('RESULT after clearing filter: ${filtered.urls}');
    expect(filtered.urls, contains('https://img.forge.invalid/late.png'));

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
  });
}
