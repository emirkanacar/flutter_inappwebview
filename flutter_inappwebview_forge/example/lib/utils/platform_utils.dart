import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview_forge_example/utils/support_checker.dart';

/// Utility class for platform detection and information.
class PlatformUtils {
  /// Gets the name of the current platform.
  static String getPlatformName() {
    if (kIsWeb) {
      return 'Web';
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'Android';
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.macOS:
        return 'macOS';
      case TargetPlatform.windows:
        return 'Windows';
      case TargetPlatform.linux:
        return 'Linux';
      default:
        return 'Unknown';
    }
  }

  /// Gets the current platform as a [SupportedPlatform] enum value.
  /// Returns null if the current platform is not recognized.
  static SupportedPlatform? getCurrentPlatform() {
    if (kIsWeb) {
      return SupportedPlatform.web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return SupportedPlatform.android;
      case TargetPlatform.iOS:
        return SupportedPlatform.ios;
      case TargetPlatform.macOS:
        return SupportedPlatform.macos;
      case TargetPlatform.windows:
        return SupportedPlatform.windows;
      case TargetPlatform.linux:
        return SupportedPlatform.linux;
      default:
        return null;
    }
  }

  /// Gets the Flutter SDK version.
  /// Note: This is a placeholder. In production, you might use
  /// package_info_plus or similar to get actual version info.
  static String getFlutterVersion() {
    return FlutterVersion.version != null
        ? FlutterVersion.version! + ' (' + (FlutterVersion.channel ?? '') + ')'
        : 'Flutter SDK';
  }

  /// Gets the Dart SDK version.
  static String getDartVersion() {
    return FlutterVersion.dartVersion ?? 'Dart SDK';
  }

  /// Returns true if running on web platform.
  static bool isWebPlatform() {
    return kIsWeb;
  }

  /// Returns true if running on mobile platform (Android or iOS).
  static bool isMobilePlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Returns true if running on desktop platform (Windows, macOS, or Linux).
  static bool isDesktopPlatform() {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Gets an appropriate icon for the current platform.
  static IconData getPlatformIcon() {
    if (kIsWeb) {
      return Icons.language;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return Icons.android;
      case TargetPlatform.iOS:
        return Icons.phone_iphone;
      case TargetPlatform.macOS:
        return Icons.laptop_mac;
      case TargetPlatform.windows:
        return Icons.desktop_windows;
      case TargetPlatform.linux:
        return Icons.computer;
      default:
        return Icons.devices;
    }
  }

  /// Gets a short platform identifier (lowercase).
  static String getPlatformIdentifier() {
    return getPlatformName().toLowerCase();
  }
}
