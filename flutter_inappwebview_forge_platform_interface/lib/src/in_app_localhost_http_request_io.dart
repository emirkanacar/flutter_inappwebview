import 'dart:io' show HttpRequest;

/// HTTP request received by [DefaultInAppLocalhostServer].
///
/// On VM platforms this is [HttpRequest] from `dart:io`.
typedef InAppLocalhostHttpRequest = HttpRequest;
