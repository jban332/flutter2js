import 'package:flutter2js/core.dart';
import 'package:test/test.dart';

void main() {
  group("DeviceInfo: ", () {
    test("Default", () {
      final info = DeviceInfo.current;
      expect(info.platformType, PlatformType.browser);
      expect(info.isMobile, true);
      expect(info.userAgent, null);
      expect(info.operatingSystemType, OperatingSystemType.android);
    });
    group("Browser: ", () {
      test("'user-agent' parsing", () {
        final userAgents = <OperatingSystemType, List<String>>{
          OperatingSystemType.android: [
            "Mozilla/5.0 (Linux; Android 4.0.4; Galaxy Nexus Build/IMM76B) AppleWebKit/535.19 (KHTML, like Gecko) Chrome/18.0.1025.133 Mobile Safari/535.19",
          ],
          OperatingSystemType.ios: [
            "Mozilla/5.0 (iPhone; CPU iPhone OS 10_3 like Mac OS X) AppleWebKit/602.1.50 (KHTML, like Gecko) CriOS/56.0.2924.75 Mobile/14E5239e Safari/602.1",
          ],
        };
        userAgents.forEach((operatingSystemType, list) {
          for (var item in list) {
            final deviceInfo = new DeviceInfo.fromBrowser(userAgent: item);
            expect(deviceInfo.operatingSystemType, operatingSystemType);
          }
        });
      });
    });
  });
}
