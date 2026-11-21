import 'package:flutter/services.dart';

///Aggregated statistics for one native-to-Dart method name.
///
///Keys are `<ControllerType>.<method>`, for example
///`AndroidInAppWebViewController.onScrollChanged`, so per-instance channel IDs
///are not part of the key.
class ChannelCallStat {
  ///The Dart controller type that received the call.
  final String controller;

  ///The platform channel method name.
  final String method;

  ///Number of calls received.
  int count = 0;

  ///Sum of the encoded payload sizes, in bytes.
  ///
  ///Only collected while [ChannelCallStats.measurePayloadSize] is `true`;
  ///otherwise it stays `0`.
  int totalPayloadBytes = 0;

  ///Total time spent in the Dart handler, until its future completed.
  Duration totalHandlerTime = Duration.zero;

  ///Longest single Dart handler time.
  Duration maxHandlerTime = Duration.zero;

  ChannelCallStat._(this.controller, this.method);

  ///Average Dart handler time per call.
  Duration get averageHandlerTime => count == 0
      ? Duration.zero
      : Duration(microseconds: totalHandlerTime.inMicroseconds ~/ count);

  ChannelCallStat _copy() => ChannelCallStat._(controller, method)
    ..count = count
    ..totalPayloadBytes = totalPayloadBytes
    ..totalHandlerTime = totalHandlerTime
    ..maxHandlerTime = maxHandlerTime;

  ///Converts the statistic to a JSON-compatible map.
  Map<String, dynamic> toMap() => {
    'controller': controller,
    'method': method,
    'count': count,
    'totalPayloadBytes': totalPayloadBytes,
    'totalHandlerTimeMicros': totalHandlerTime.inMicroseconds,
    'maxHandlerTimeMicros': maxHandlerTime.inMicroseconds,
  };

  @override
  String toString() =>
      'ChannelCallStat{controller: $controller, method: $method, '
      'count: $count, totalPayloadBytes: $totalPayloadBytes, '
      'averageHandlerTime: $averageHandlerTime, '
      'maxHandlerTime: $maxHandlerTime}';
}

///Opt-in counters for native-to-Dart platform channel traffic.
///
///Use it to measure channel pressure (for example scroll, progress, or console
///events) in a profile or release build before and after a change. Collection
///is disabled by default and costs a single boolean check per call when
///disabled.
///
///```dart
///ChannelCallStats.enabled = true;
///// ... exercise the WebView ...
///debugPrint(ChannelCallStats.report());
///ChannelCallStats.reset();
///```
///
///Only calls that reach a plugin controller's Dart handler are counted.
///Dart-to-native calls are not counted.
class ChannelCallStats {
  ChannelCallStats._();

  ///Enables collection. The default value is `false`.
  static bool enabled = false;

  ///Also re-encodes each call with [StandardMethodCodec] to record its payload
  ///size. This adds measurable cost, so it is disabled by default.
  static bool measurePayloadSize = false;

  static final Map<String, ChannelCallStat> _stats = {};
  static final Stopwatch _window = Stopwatch();

  ///Time elapsed since the first recorded call after the last [reset].
  static Duration get elapsed => _window.elapsed;

  ///A copy of the collected statistics, keyed by `<controller>.<method>`.
  static Map<String, ChannelCallStat> get snapshot => Map.unmodifiable(
    _stats.map((key, value) => MapEntry(key, value._copy())),
  );

  ///Total number of calls recorded since the last [reset].
  static int get totalCount =>
      _stats.values.fold(0, (sum, stat) => sum + stat.count);

  ///Clears all statistics and the elapsed-time window.
  static void reset() {
    _stats.clear();
    _window
      ..stop()
      ..reset();
  }

  ///Returns a plain-text table sorted by call count, highest first.
  static String report() {
    final stats = _stats.values.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    final seconds = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
    final buffer = StringBuffer(
      'ChannelCallStats: $totalCount calls in '
      '${seconds.toStringAsFixed(2)} s\n',
    );
    for (final stat in stats) {
      final rate = seconds > 0 ? stat.count / seconds : 0;
      buffer.writeln(
        '${stat.controller}.${stat.method}: count=${stat.count} '
        'rate=${rate.toStringAsFixed(1)}/s '
        'bytes=${stat.totalPayloadBytes} '
        'avg=${stat.averageHandlerTime.inMicroseconds}us '
        'max=${stat.maxHandlerTime.inMicroseconds}us',
      );
    }
    return buffer.toString();
  }

  static const StandardMethodCodec _codec = StandardMethodCodec();

  ///Runs [handler] for [call] and records it when [enabled].
  ///
  ///Used by the plugin controllers. Recording never changes the handler
  ///result or its errors.
  static Future<dynamic> track(
    Object controller,
    MethodCall call,
    Future<dynamic> Function(MethodCall call) handler,
  ) {
    if (!enabled) return handler(call);

    final controllerName = controller.runtimeType.toString();
    final stat = _stats.putIfAbsent(
      '$controllerName.${call.method}',
      () => ChannelCallStat._(controllerName, call.method),
    );
    stat.count++;
    if (!_window.isRunning) _window.start();
    if (measurePayloadSize) {
      try {
        stat.totalPayloadBytes += _codec.encodeMethodCall(call).lengthInBytes;
      } catch (_) {
        // Payloads decoded by the standard codec are re-encodable; ignore
        // anything else instead of affecting the call.
      }
    }

    final stopwatch = Stopwatch()..start();
    void record() {
      final time = stopwatch.elapsed;
      stat.totalHandlerTime += time;
      if (time > stat.maxHandlerTime) stat.maxHandlerTime = time;
    }

    final Future<dynamic> result;
    try {
      result = handler(call);
    } catch (_) {
      record();
      rethrow;
    }
    return result.whenComplete(record);
  }
}
