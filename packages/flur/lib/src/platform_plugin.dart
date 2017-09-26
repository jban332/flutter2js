import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'uri_handler.dart';

final _flutterEventChannelControllers = <String, StreamController<String>>{};

final _flutterMethodChannelHandlers = <String, MethodChannelHandler>{};
typedef Future MethodChannelHandler(String name, List args);

/// Contains various non-visual methods that are rarely customized by
/// developers.
abstract class PlatformPlugin {
  static PlatformPlugin current;

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
  /// This API is not available in Flurre core API.
  /// It requires (url_launcher)[https://github.com/flutter/plugins/tree/master/packages/url_launcher] plugin.
  Future<UriHandler> getUriHandler(Uri uri) {
    throw new UnimplementedError();
  }

  /// Invoked by implementation of Flutter's [ui.Canvas].
  ///
  /// Many type of widgets need to draw to Canvas (e.g. chart widgets) so
  /// this is important!
  ui.Canvas newCanvas(ui.PictureRecorder recorder, Rect cullRect) {
    throw new UnimplementedError();
  }

  /// Invoked by implementation of Flutter's [ui.ParagraphBuilder].
  ui.ParagraphBuilder newParagraphBuilder(ui.ParagraphStyle style) {
    throw new UnimplementedError();
  }

  /// Invoked by implementation of Flutter's [ui.Path].
  ui.Path newPath() {
    throw new UnimplementedError();
  }

  /// Invoked by implementation of Flutter's [ui.PictureRecorder].
  ui.PictureRecorder newPictureRecorder() {
    throw new UnimplementedError();
  }

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
      String name, ui.PlatformMessageResponseCallback callback, ByteData data) {
    throw new UnimplementedError();
  }

  @protected
  void setMethodChannelHandler(String name, MethodChannelHandler handler) {
    _flutterMethodChannelHandlers[name] = handler;
  }

  /// Invoked by implementation of Flutter's [SystemSound.play].
  Future<Null> vibrate() async {
    // Do nothing
    return null;
  }
}
