import 'dart:io';

File _sourceFile(String relativePath) {
  final candidates = [
    File(relativePath),
    File('flutter_inappwebview_forge_macos/$relativePath'),
  ];
  return candidates.firstWhere((file) => file.existsSync());
}

void main() {
  final settings = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/WebAuthenticationSession/'
    'WebAuthenticationSessionSettings.swift',
  ).readAsStringSync();
  final session = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/WebAuthenticationSession/'
    'WebAuthenticationSession.swift',
  ).readAsStringSync();

  if (!settings.contains('additionalHeaderFields')) {
    throw StateError(
      'macOS authentication settings do not expose additional headers',
    );
  }
  if (!session.contains('session.additionalHeaderFields')) {
    throw StateError(
      'macOS authentication session does not apply additional headers',
    );
  }
  if (!session.contains('NSApp.keyWindow')) {
    throw StateError(
      'macOS authentication session does not prefer the active key window',
    );
  }

  final printScript = _sourceFile(
    'macos/flutter_inappwebview_forge_macos/Sources/'
    'flutter_inappwebview_forge_macos/PluginScriptsJS/PrintJS.swift',
  ).readAsStringSync();
  if (!printScript.contains('window.location.href);\n        };')) {
    throw StateError(
      'macOS print override is missing its terminating semicolon',
    );
  }
}
