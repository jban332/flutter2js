import 'package:test/test.dart';
import 'package:flur/flur.dart';

void main() {
  group("DeviceInfo: ", () {
    test("Default", () {
      final info = DeviceInfo.current;
      expect(info.platformType, PlatformType.flutter);
      expect(info.isMobile, true);
      expect(info.userAgent, null);
      expect(info.operatingSystemType, OperatingSystemType.android);
    });
    group("Browser: ", () {
      test("Default", () {
        final info = new DeviceInfo.withBrowser();
        expect(info.platformType, PlatformType.browser);
        expect(info.isMobile, false);
        expect(info.userAgent, null);
        expect(info.operatingSystemType, null);
      });
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
            expect(
                new DeviceInfo.withBrowser(userAgent: item).operatingSystemType,
                operatingSystemType);
          }
        });
      });
    });
    group("React Native: ", () {
      test("Default", () {
        final info = new DeviceInfo.withReactNative();
        expect(info.platformType, PlatformType.reactNative);
        expect(info.isMobile, true);
        expect(info.userAgent, null);
        expect(info.operatingSystemType, null);
      });
    });
  });
}
