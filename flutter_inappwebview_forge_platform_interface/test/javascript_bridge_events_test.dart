import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';

class _FakeController extends PlatformInAppWebViewController {
  _FakeController()
    : super.implementation(
        const PlatformInAppWebViewControllerCreationParams(id: 1),
      );

  final Map<String, Function> handlers = {};
  final List<String> evaluatedScripts = [];

  @override
  void addJavaScriptHandler({
    required String handlerName,
    required Function callback,
  }) {
    handlers[handlerName] = callback;
  }

  @override
  Function? removeJavaScriptHandler({required String handlerName}) =>
      handlers.remove(handlerName);

  @override
  bool hasJavaScriptHandler({required String handlerName}) =>
      handlers.containsKey(handlerName);

  @override
  Future<String> getJavaScriptBridgeName() async =>
      'flutter_inappwebview_forge';

  @override
  Future<dynamic> evaluateJavascript({
    required String source,
    ContentWorld? contentWorld,
  }) async {
    evaluatedScripts.add(source);
    return true;
  }

  @override
  void dispose({bool isKeepAlive = false}) {}
}

void main() {
  test('bridge events install once and dispatch JavaScript events', () async {
    final controller = _FakeController();
    final events = JavaScriptBridgeEvents(controller: controller);
    final received = <Object?>[];

    await events.on('cart.updated', received.add);
    await events.on('cart.updated', received.add);
    expect(controller.handlers, hasLength(1));
    expect(controller.evaluatedScripts, hasLength(1));

    final handler = controller.handlers.values.single as Function;
    await handler([
      {
        'eventName': 'cart.updated',
        'data': {'count': 2},
      },
    ]);
    expect(
      received,
      equals([
        {'count': 2},
      ]),
    );
    expect(events.hasListener('cart.updated'), isTrue);

    await events.off('cart.updated', received.add);
    expect(events.hasListener('cart.updated'), isFalse);

    await events.emit('cart.updated', {'count': 3});
    expect(controller.evaluatedScripts, hasLength(2));
    expect(controller.evaluatedScripts.last, contains('__dispatch'));
  });

  test('typed JSON handler decodes and encodes values', () async {
    final controller = _FakeController();
    final events = JavaScriptBridgeEvents(controller: controller);

    events.addJsonJavaScriptHandler<int, String>(
      handlerName: 'double',
      decodeRequest: (value) => (value as Map)['value'] as int,
      callback: (request) => 'value=${request * 2}',
      encodeResponse: (response) => {'message': response},
    );

    final callback = controller.handlers['double']! as Function;
    final result = await callback([
      {'value': 4},
    ]);
    expect(result, equals({'message': 'value=8'}));
  });
}
