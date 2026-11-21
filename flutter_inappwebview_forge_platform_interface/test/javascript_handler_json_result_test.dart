import 'dart:convert';

import 'package:flutter_inappwebview_forge_platform_interface/flutter_inappwebview_forge_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Upstream PR #2948.
  test('encode passes pre-encoded JSON through unchanged', () {
    const json = '{"a":[1,{"b":"\\"x\\""}]}';

    final encoded = JavaScriptHandlerJsonResult.encode(
      const JavaScriptHandlerJsonResult(json),
    );

    expect(identical(encoded, json), isTrue);
  });

  test('encode keeps jsonEncode for other results', () {
    expect(JavaScriptHandlerJsonResult.encode({'a': 1}), '{"a":1}');
    expect(JavaScriptHandlerJsonResult.encode(null), 'null');
    expect(JavaScriptHandlerJsonResult.encode('x'), '"x"');
  });

  test('jsonEncode embeds the value when nested or used directly', () {
    const result = JavaScriptHandlerJsonResult('{"a":[1,2]}');

    expect(jsonEncode(result), '{"a":[1,2]}');
    expect(jsonEncode({'data': result}), '{"data":{"a":[1,2]}}');
  });
}
