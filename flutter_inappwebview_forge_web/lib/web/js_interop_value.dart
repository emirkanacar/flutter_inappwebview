import 'dart:js_interop';

import 'js_value.dart';

Object jsAnyToDartViewId(JSAny viewId) {
  return jsViewIdToDart(viewId.dartify());
}

List<Object?>? jsArrayToDartArgs(JSArray? args) {
  if (args == null) {
    return null;
  }
  return jsArgsToDart(
    args.toDart.map<Object?>((JSAny? item) => item?.dartify()).toList(),
  );
}
