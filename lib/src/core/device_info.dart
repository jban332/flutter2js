import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' as flutter;

enum PlatformType {
  flutter,
  browser,
  other,
}

enum OperatingSystemType {
  ios,
  android,
  osx,
  windows,
  fuchsia,
  other,
}

const bool isRunningInFlutter = const bool.fromEnvironment("dart.ui");
const bool isRunningInFlutter2js = !isRunningInFlutter;

class DeviceInfo {
  /// By default, obtains device information from Flutter APIs.
  static DeviceInfo current = new DeviceInfo.fromSystem();

  /// Platform (stocks_for_browser, React Native, etc.).
  /// Usually known at compile time.
  /// Must be non-null.
  final PlatformType platformType;

  /// Operating system of the device.
  /// May be null.
  final OperatingSystemType operatingSystemType;

  /// Browser user agent.
  /// May be null.
  final String userAgent;

  DeviceInfo({this.platformType, this.userAgent, this.operatingSystemType});

  factory DeviceInfo.fromSystem() {
    if (isRunningInFlutter2js) {
      return new DeviceInfo(
        platformType: PlatformType.browser,
        operatingSystemType: OperatingSystemType.android,
      );
    }
    return new DeviceInfo(
        platformType: PlatformType.flutter,
        operatingSystemType: _getOperatingSystemTypeFromFlutter());
  }

  factory DeviceInfo.fromBrowser(
      {@required String userAgent, OperatingSystemType osType}) {
    return new DeviceInfo(
        platformType: PlatformType.browser,
        userAgent: userAgent,
        operatingSystemType:
            osType ?? getOperatingSystemTypeFromUserAgent(userAgent));
  }

  bool get isMobile {
    if (platformType == PlatformType.flutter) return true;
    switch (operatingSystemType) {
      case OperatingSystemType.android:
        return true;
      case OperatingSystemType.ios:
        return true;
      default:
        switch (platformType) {
          case PlatformType.flutter:
            return true;
          case PlatformType.browser:
            var ua = this.userAgent;
            if (ua != null) {
              ua = ua.toLowerCase();
              if (ua.contains(" mobile safari")) return true;
              if (ua.contains("; mobile;")) return true;
              if (ua.contains(" iphone ")) return true;
            }
            return false;
          default:
            return false;
        }
    }
  }

  /// Obtains operating system type from Flutter.
  static OperatingSystemType _getOperatingSystemTypeFromFlutter() {
    switch (defaultTargetPlatform) {
      case flutter.TargetPlatform.android:
        return OperatingSystemType.android;
      case flutter.TargetPlatform.iOS:
        return OperatingSystemType.ios;
      case flutter.TargetPlatform.fuchsia:
        return OperatingSystemType.fuchsia;
      default:
        return OperatingSystemType.other;
    }
  }

  /// Attempts to determine operating system type by parsing user agent string.
  static OperatingSystemType getOperatingSystemTypeFromUserAgent(String ua) {
    if (ua == null) {
      return null;
    }
    ua = ua.toLowerCase();
    if (ua.contains("android")) {
      return OperatingSystemType.android;
    }
    if (ua.contains(" iphone ")) {
      return OperatingSystemType.ios;
    }
    return OperatingSystemType.other;
  }
}
