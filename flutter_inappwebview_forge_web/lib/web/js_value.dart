/// Converts a JS-origin view identity into the Dart map key used by
/// `InAppWebViewManager.webViews`.
///
/// Platform views register [int] IDs. Headless views register [String] IDs.
/// dart2wasm represents JS numbers as [double], so whole numbers become [int].
/// String identities are left unchanged so numeric-looking headless IDs still
/// match the original map key.
Object jsViewIdToDart(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return value;
  }
  return value ?? '';
}

/// Copies a JS argument list into Dart values, converting nested lists.
List<Object?>? jsArgsToDart(List<Object?>? args) {
  if (args == null) {
    return null;
  }
  return args.map(jsArgValueToDart).toList(growable: false);
}

/// Identity conversion for a single JS argument after `dartify`.
Object? jsArgValueToDart(Object? value) {
  if (value is List) {
    return value.map(jsArgValueToDart).toList(growable: false);
  }
  return value;
}

String? jsArgAsString(Object? value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

double jsArgAsDouble(Object? value) {
  if (value is double) {
    return value;
  }
  if (value is int) {
    return value.toDouble();
  }
  if (value is num) {
    return value.toDouble();
  }
  throw ArgumentError.value(value, 'value', 'Expected a number');
}

int jsArgAsInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is double) {
    return value.toInt();
  }
  if (value is num) {
    return value.toInt();
  }
  throw ArgumentError.value(value, 'value', 'Expected a number');
}
