import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_web/web/web_view_lifecycle_coordinator.dart';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_web/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void _assert(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
}

void main() {
  test('Web source contracts remain guarded', _runSourceContractAssertions);
  test('Web lifecycle coordinator is idempotent', () {
    final lifecycle = WebViewLifecycleCoordinator();

    expect(lifecycle.state, WebViewLifecycleState.creating);
    expect(lifecycle.beginPreparing(), isTrue);
    lifecycle.markAttached();
    lifecycle.markReady();
    expect(lifecycle.state, WebViewLifecycleState.ready);
    expect(lifecycle.beginPreparing(), isFalse);

    lifecycle.markDetachedRetained();
    lifecycle.markReattached();
    expect(lifecycle.state, WebViewLifecycleState.reattached);
    expect(lifecycle.acceptsCallbacks, isTrue);
    final operationId = lifecycle.beginAsyncOperation();
    expect(operationId, isNotNull);
    expect(lifecycle.pendingAsyncOperations, 1);
    final operation = operationId!;
    expect(lifecycle.completeAsyncOperation(operation), isTrue);
    expect(lifecycle.completeAsyncOperation(operation), isFalse);
    expect(lifecycle.pendingAsyncOperations, 0);
    expect(lifecycle.callbackCompletionCount, 1);
    lifecycle.markRendererLost();
    lifecycle.markAttached();
    lifecycle.markReady();
    expect(lifecycle.state, WebViewLifecycleState.ready);
    expect(lifecycle.beginDisposal(), isTrue);
    expect(lifecycle.beginDisposal(), isFalse);
    expect(lifecycle.acceptsCallbacks, isFalse);
    lifecycle.finishDisposal();
    expect(lifecycle.state, WebViewLifecycleState.disposed);
    expect(lifecycle.beginDisposal(), isFalse);
  });
}

void _runSourceContractAssertions() {
  final supportSource = _sourceFile(
    'lib/assets/web/web_support.js',
  ).readAsStringSync();
  final elementSource = _sourceFile(
    'lib/web/in_app_web_view_web_element.dart',
  ).readAsStringSync();
  final platformSource = _sourceFile(
    'lib/web/web_platform.dart',
  ).readAsStringSync();
  final headlessElementSource = _sourceFile(
    'lib/web/headless_in_app_web_view_web_element.dart',
  ).readAsStringSync();
  final headlessManagerSource = _sourceFile(
    'lib/web/headless_inappwebview_manager.dart',
  ).readAsStringSync();
  final managerSource = _sourceFile(
    'lib/web/in_app_webview_manager.dart',
  ).readAsStringSync();
  final bridgeSource = _sourceFile('lib/web/js_bridge.dart').readAsStringSync();
  final lifecycleSource = _sourceFile(
    'lib/web/web_view_lifecycle_coordinator.dart',
  ).readAsStringSync();
  final webSupportSource = _sourceFile(
    'lib/assets/web/web_support.js',
  ).readAsStringSync();

  _assert(
    supportSource.contains('const getIFrameUrl = function(iframeElement)'),
    'iframe URL helper is missing',
  );
  _assert(
    supportSource.contains('return null;'),
    'cross-origin iframe URL fallback is missing',
  );
  _assert(
    supportSource.contains(
      '_nativeCommunication("onLoadStart", viewId, [url])',
    ),
    'load-start URL event is missing',
  );
  _assert(
    supportSource.contains('_nativeCommunication("onLoadStop", viewId, [url])'),
    'load-stop URL event is missing',
  );
  _assert(
    supportSource.contains('return getIFrameUrl(iframe2);'),
    'getUrl does not read the current iframe location',
  );
  _assert(
    elementSource.contains('void onLoadStart(String? url)'),
    'load-start callback is not nullable',
  );
  _assert(
    elementSource.contains('void onLoadStop(String? url)'),
    'load-stop callback is not nullable',
  );
  _assert(
    elementSource.contains('bool _hasLoadedDocument = false;'),
    'document-load state is missing',
  );
  _assert(
    elementSource.contains('if (!_hasLoadedDocument &&'),
    'getUrl still falls back to a stale source after a document loads',
  );
  _assert(
    platformSource.contains('jsArgAsString(args?[0])') &&
        platformSource.contains('jsAnyToDartViewId(viewId)') &&
        platformSource.contains('jsArrayToDartArgs(args)'),
    'native URL event decoding is not WASM-safe',
  );
  _assert(
    supportSource.contains('return null;') &&
        supportSource.contains('getIFrameUrl'),
    'cross-origin URL reads must not reuse the iframe source',
  );
  _assert(
    elementSource.contains('disableAutocorrection') &&
        elementSource.contains('autocorrect') &&
        elementSource.contains('spellcheck') &&
        elementSource.contains('MutationObserver'),
    'Web autocorrection script wiring is missing',
  );
  _assert(
    supportSource.contains('evaluateJavascript: function(source)') &&
        supportSource.contains('contentWindow?.eval(source)') &&
        RegExp(r'\beval\s*\(').allMatches(supportSource).length == 1,
    'web dynamic JavaScript evaluation must remain limited to the explicit API',
  );
  _assert(
    headlessElementSource.contains('disposeAndGetFlutterWebView') &&
        headlessElementSource.contains('disposeWebView: false') &&
        headlessElementSource.contains('WebViewLifecycleCoordinator'),
    'headless-to-regular transfer must retain the underlying iframe and be idempotent',
  );
  _assert(
    lifecycleSource.contains('beginDisposal') &&
        lifecycleSource.contains('acceptsCallbacks') &&
        lifecycleSource.contains('detachedRetained') &&
        lifecycleSource.contains('finishDisposal'),
    'Web lifecycle ownership and callback admission must use one internal state machine',
  );
  _assert(
    elementSource.contains('lifecycle.beginPreparing()') &&
        elementSource.contains('lifecycle.markReattached()') &&
        elementSource.contains('lifecycle.finishDisposal()') &&
        elementSource.contains('_settingsSnapshot') &&
        elementSource.contains('_deepEquals'),
    'Web platform elements must guard prepare, transfer, and disposal with the lifecycle coordinator',
  );
  _assert(
    elementSource.contains(
          'if (!lifecycle.acceptsCallbacks) {\n      return;\n    }',
        ) &&
        elementSource.contains(
          'if (!lifecycle.acceptsCallbacks) {\n      return false;\n    }',
        ) &&
        elementSource.contains(
          'InAppWebViewManager.windowActions.remove(windowId);',
        ),
    'Web outgoing events and popup/bridge callbacks must stop after disposal',
  );
  _assert(
    headlessManagerSource.contains(
          'Map<String, HeadlessInAppWebViewWebElement>',
        ) &&
        headlessManagerSource.contains('final previousHeadlessWebView =') &&
        headlessManagerSource.contains('webViews[id] = headlessWebView;'),
    'Web headless ownership must not use nullable placeholders or silently overwrite an existing view',
  );
  _assert(
    managerSource.contains('Map<dynamic, InAppWebViewWebElement>') &&
        managerSource.contains('static void registerWebView') &&
        managerSource.contains('previousWebView.dispose();'),
    'Web manager ownership must be explicit and duplicate IDs must dispose the previous owner',
  );
  _assert(
    elementSource.contains('_reattachToView') &&
        elementSource.contains('_configureChannel();') &&
        elementSource.contains(
          'identical(InAppWebViewManager.webViews[_viewId], this)',
        ) &&
        elementSource.contains('continue using the transferred element'),
    'transferred WebViews must move their channel and manager ownership atomically',
  );
  _assert(
    bridgeSource.contains('external void reattach(') &&
        webSupportSource.contains('reattach: function(viewId2'),
    'Web bridge must update the JavaScript view identity during headless transfer',
  );
  _assert(
    webSupportSource.contains('scheduleScrollChanged: function()') &&
        webSupportSource.contains('requestAnimationFrame') &&
        webSupportSource.contains('scrollEventFramePending'),
    'Web scroll callbacks must be coalesced to animation frames',
  );
  _assert(
    !platformSource.contains("import 'dart:html'") &&
        !platformSource.contains("import 'dart:js'") &&
        !platformSource.contains("import 'package:js/") &&
        !elementSource.contains("import 'dart:html'") &&
        !bridgeSource.contains("import 'dart:html'"),
    'Web implementation must not import dart:html, dart:js, or package:js',
  );
}
