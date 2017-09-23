import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import 'device_info.dart';
import 'platform_plugin.dart';
import 'render_tree_plugin.dart';
import 'ui_plugin.dart';

class FlurConfig {
  static FlurConfig _current;

  static FlurConfig get current => _current;

  static set current(FlurConfig value) {
    if (_current != null) {
      throw new StateError("Flur is already configured.");
    }
    _current = value;
    DeviceInfo.current = value.deviceInfo;
  }

  final DeviceInfo deviceInfo;
  final PlatformPlugin platformPlugin;
  final UIPlugin uiPlugin;
  final RenderTreePlugin renderTreePlugin;

  FlurConfig(
      {@required PlatformPlugin platformPlugin,
      @required UIPlugin uiPlugin,
      @required RenderTreePlugin renderTreePlugin,
      @required DeviceInfo deviceInfo})
      : this.platformPlugin = platformPlugin,
        this.uiPlugin = uiPlugin,
        this.renderTreePlugin = renderTreePlugin,
        this.deviceInfo = deviceInfo;
}
