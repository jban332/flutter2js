import 'dart:typed_data';

import 'package:flutter2js/src/core/platform_plugin.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';

final ui.Window window = new _Window();

/// Singleton class that delegates implementation to [PlatformPlugin].
class _Window extends ui.Window {
  _Window();

  @override
  String get defaultRouteName => PlatformPlugin.current.routingPlugin.current;

  @override
  void sendPlatformMessage(
      String name, ByteData data, ui.PlatformMessageResponseCallback callback) {
    PlatformPlugin.current.sendPlatformMessage(name, data, callback);
  }

  @override
  void updateSemantics(ui.SemanticsUpdate update) {
    PlatformPlugin.current.updateSemantics(update);
  }

  @override
  void render(ui.Scene scene) {
    PlatformPlugin.current.renderScene(scene);
  }

  @override
  void scheduleFrame() {
    PlatformPlugin.current.scheduleFrame();
  }

  @override
  Size get physicalSize => PlatformPlugin.current.physicalSize;

  @override
  Locale get locale => PlatformPlugin.current.locale;

  @override
  set onDrawFrame(ui.VoidCallback callback) {
    super.onDrawFrame = callback;
  }

  @override
  set onBeginFrame(ui.FrameCallback callback) {
    super.onBeginFrame = callback;
  }

  @override
  set onPlatformMessage(ui.PlatformMessageCallback callback) {
    super.onPlatformMessage = callback;
  }
}
