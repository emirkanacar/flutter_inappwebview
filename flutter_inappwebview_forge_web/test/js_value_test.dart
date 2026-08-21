import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_inappwebview_forge_web/web/js_value.dart';

void main() {
  test('jsViewIdToDart keeps platform-view ints and headless strings', () {
    expect(jsViewIdToDart(3), 3);
    expect(jsViewIdToDart(3.0), 3);
    expect(jsViewIdToDart(3.9), 3);
    expect(jsViewIdToDart('headless-id'), 'headless-id');
    expect(jsViewIdToDart('12'), '12');
    expect(jsViewIdToDart(null), '');
  });

  test('jsArgsToDart copies nested lists without changing primitives', () {
    expect(jsArgsToDart(null), isNull);
    expect(
      jsArgsToDart(<Object?>['https://example.com', 1.5, true, null]),
      <Object?>['https://example.com', 1.5, true, null],
    );
    expect(
      jsArgsToDart(<Object?>[
        <Object?>['nested', 2],
      ]),
      <Object?>[
        <Object?>['nested', 2],
      ],
    );
  });

  test('jsArg helpers accept int and double JS numbers', () {
    expect(jsArgAsString(null), isNull);
    expect(jsArgAsString('ready'), 'ready');
    expect(jsArgAsString(12), '12');
    expect(jsArgAsDouble(1.25), 1.25);
    expect(jsArgAsDouble(4), 4.0);
    expect(jsArgAsInt(8.0), 8);
    expect(jsArgAsInt(9), 9);
  });
}
