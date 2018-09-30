import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart' show SemanticsOwner;
import 'package:flutter/services.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter2js/core.dart';
import 'package:flutter2js/html.dart' show BrowserPlatformPlugin;
import 'package:meta/meta.dart';

final _flutterEventChannelControllers = <String, StreamController<String>>{};

final _flutterMethodChannelHandlers = <String, MethodChannelHandler>{};

typedef Future MethodChannelHandler(String name, List args);

/// Contains various non-visual methods that are rarely customized by
/// developers.
abstract class PlatformPlugin {
  static final PlatformPlugin current = new BrowserPlatformPlugin();

  ui.Locale get locale;

  Size get physicalSize;

  RoutingPlugin get routingPlugin;

  /// Invoked by implementation of Flutter's [Clipboard].
  Future<ClipboardData> clipboardGetData(String format) {
    throw new UnimplementedError();
  }

  /// Invoked by implementation of Flutter's [Clipboard].
  Future<Null> clipboardSetData(ClipboardData data) {
    throw new UnimplementedError();
  }

  /// Invoked by implementation of 'dart:ui' method 'decodeImageFromList'.
  ///
  /// In practice, this should never happen because we attempt to capture
  /// image loading at higher level (e.g. URL, asset path, etc.).
  Future<ui.Image> decodeImageFromList(
      Uint8List list, void complete(ui.Image image)) {
    throw new UnimplementedError();
  }

  @protected
  MethodChannelHandler getMethodChannelHandler(String name, dynamic argument) {
    return _flutterMethodChannelHandlers[name];
  }

  /// Returns a handler that can launch the URI.
  ///
  /// This API is not available in Flutter2jsre core API.
  /// It requires (url_launcher)[https://github.com/flutter/plugins/tree/master/packages/url_launcher] plugin.
  Future<UriHandler> getUriHandler(Uri uri) {
    throw new UnimplementedError();
  }

  Future<ui.Codec> instantiateImageCodec(Uint8List list) =>
      throw new UnimplementedError();

  /// Invoked by implementation of Flutter's [ui.Canvas].
  ///
  /// Many type of widgets need to draw to Canvas (e.g. chart widgets) so
  /// this is important!
  ui.Canvas newCanvas(ui.PictureRecorder recorder, Rect cullRect);

  /// Invoked by implementation of Flutter's [ui.ParagraphBuilder].
  ui.ParagraphBuilder newParagraphBuilder(ui.ParagraphStyle style);

  /// Invoked by implementation of Flutter's [ui.Path].
  ui.Path newPath();

  /// Invoked by implementation of Flutter's [ui.PictureRecorder].
  ui.PictureRecorder newPictureRecorder();

  ui.SceneBuilder newSceneBuilder();

  ui.SceneHost newSceneHost(dynamic exportTokenHandle) =>
      throw new UnimplementedError();

  ui.SemanticsUpdateBuilder newSemanticsUpdateBuilder();

  WidgetsFlutterBinding newWidgetsFlutterBinding();

  /// Invoked by implementation of Flutter's [SystemSound.play].
  void playSystemSound(SystemSoundType sound) {
    // Do nothing
  }

  /// Invoked by implementation of Flutter's [EventChannel].
  Stream<dynamic> receiveEventChannelStream(EventChannel eventChannel,
      [dynamic arguments]) {
    var controller = _flutterEventChannelControllers[eventChannel.name];
    if (controller == null) {
      controller = new StreamController.broadcast();
      _flutterEventChannelControllers[eventChannel.name] = controller;
    }
    return controller.stream.map((raw) => new JsonDecoder().convert(raw));
  }

  void renderScene(ui.Scene scene);

  void scheduleFrame();

  void semanticsUpdate(SemanticsOwner owner) {}

  /// Sends the event to everyone who is listening to the plugin with the name.
  void sendEventChannelMessage(String name, dynamic event) {
    var controller = _flutterEventChannelControllers[name];
    if (controller != null) {
      // We only need to create controller if someone is listening the events
      controller.add(new JsonEncoder().convert(event));
    }
  }

  /// Invoked by implementation of Flutter's [MethodChannel].
  Future<dynamic> sendMethodChannelMessage(String name, dynamic argument) {
    final handler = getMethodChannelHandler(name, argument);
    if (handler == null) {
      throw new UnimplementedError(
          "Received MethodChannel '${name}' invocation, but it has no handler.");
    }

    return handler(name, argument);
  }

  /// Invoked by implementation of Flutter's [ui.Window].
  ///
  /// In practice, this should never happen because we capture [MethodChannel]
  /// and [EventChannel] usage before messages are encoded/decoded.
  void sendPlatformMessage(
      String name, ByteData data, ui.PlatformMessageResponseCallback callback) {
    print("Sent platform message '${name}'.");
  }

  @protected
  void setMethodChannelHandler(String name, MethodChannelHandler handler) {
    _flutterMethodChannelHandlers[name] = handler;
  }

  void updateSemantics(ui.SemanticsUpdate update) {
    print("Updating semantics");
    return null;
  }

  /// Invoked by implementation of Flutter's [SystemSound.play].
  Future<Null> vibrate() async {
    // Do nothing
    return null;
  }
}
