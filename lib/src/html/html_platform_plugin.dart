import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';
import 'package:flutter2js/core.dart';
import 'package:flutter/services.dart';

import 'html_routing_plugins.dart';
import 'logging.dart';
import 'ui/html_image.dart';
import 'ui/html_paragraph_builder.dart';
import 'ui/html_path.dart';
import 'ui/html_picture.dart';
import 'ui/html_picture_recording_canvas.dart';
import 'ui/html_scene_builder.dart';
import 'ui/html_semantics_update_builder.dart';

/// Implements [Image] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// For examples, "Stocks" examples app uses the widget.
class BrowserPlatformPlugin implements HasDebugName, PlatformPlugin {
  final String debugName = "PlatformPlugin";

  @override
  final RoutingPlugin routingPlugin;

  html.Element rootHtmlElement = html.document.body;

  final Stopwatch _stopwatch = new Stopwatch();

  BrowserPlatformPlugin({RoutingPlugin routingPlugin})
      : this.routingPlugin = routingPlugin ?? new UrlFragmentRoutingPlugin();

  @override
  Size get physicalSize {
    final width = html.window.innerWidth;
    final height = html.window.innerHeight;
    final size = new Size(width.toDouble(), height.toDouble());
    return size;
  }

  @override
  Future<ui.Image> decodeImageFromList(
      Uint8List list, void complete(ui.Image image)) async {
    logStaticMethod("decodeImageFromList", arg0:"${list.length} bytes");
    // Create a data URL
    final blob = new html.Blob([list]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create "img" element
    final element = new html.ImageElement(src: url);
    element.style.display = "none";

    // Wait until "img" is loaded
    final completer = new Completer<HtmlEngineImage>();
    element.onError.listen((error) {
      completer.completeError(error);
    });
    element.onLoad.listen((_) {
      // Get width and height
      final width = element.width ?? 300;
      final height = element.height ?? 150;

      // Remove 'img' element from the document
      element.remove();

      // Create 'dart:ui' Image
      final image = new HtmlEngineImage(url, width: width, height: height);

      // Complete future
      completer.complete(image);

      // Invoke callback
      if (complete != null) {
        complete(image);
      }
    });

    // Start loading
    html.document.body.insertBefore(element, null);
    return completer.future;
  }

  @override
  Future<UriHandler> getUriHandler(Uri uri) async {
    return const _UriHandler();
  }

  @override
  ui.Canvas newCanvas(ui.PictureRecorder recorder, Rect cullRect) {
    return new HtmlPictureRecordingCanvas(recorder as HtmlPictureRecorder);
  }

  @override
  ui.ParagraphBuilder newParagraphBuilder(ui.ParagraphStyle style) {
    return new HtmlParagraphBuilder(style);
  }

  @override
  ui.Path newPath() {
    return new HtmlPath();
  }

  @override
  ui.PictureRecorder newPictureRecorder() {
    return new HtmlPictureRecorder();
  }

  @override
  ui.SceneBuilder newSceneBuilder() {
    return new HtmlSceneBuilder();
  }

  @override
  ui.SemanticsUpdateBuilder newSemanticsUpdateBuilder() {
    return new HtmlSemanticsUpdateBuilder();
  }

  @override
  WidgetsFlutterBinding newWidgetsFlutterBinding() {
    return widgetsFlutterBinding;
  }

  @override
  void renderScene(ui.Scene scene) {
    if (scene is HtmlScene) {
      logStaticMethod("renderScene", arg0:scene);
      final newChild = scene.htmlElement;
      final parent = this.rootHtmlElement;
      while (parent.firstChild != null) {
        parent.firstChild.remove();
      }
      parent.insertBefore(newChild, null);
    } else {
      throw new ArgumentError.value(scene);
    }
  }

  @override
  void scheduleFrame() {
    logStaticMethod("scheduleFrame");
    new Timer(const Duration(milliseconds: 10), () {
      if (!_stopwatch.isRunning) {
        _stopwatch.start();
      }
      var microseconds = _stopwatch.elapsedMicroseconds;
      final duration = new Duration(microseconds: microseconds);
      window.onBeginFrame(duration);
      window.onDrawFrame();
    });
  }

  @override
  ui.Locale get locale {
    var language = html.window.navigator.language;
    if (language == null || language.isEmpty) {
      language = "en-US";
    }
    final i = language.indexOf("-");
    if (i<0) {
      return new ui.Locale(language);
    }
    return new ui.Locale(language.substring(0,i), language.substring(i+1));
  }

  @override
  Future<ClipboardData> clipboardGetData(String format) async {
    logMethod(this, "clipboardGetData", arg0:format);
    return null;
  }

  @override
  Future<Null> clipboardSetData(ClipboardData data) {
    logMethod(this, "clipboardSetData", arg0:data);
  }

  @override
  MethodChannelHandler getMethodChannelHandler(String name, dynamic argument) {
    logMethod(this, "getMethodChannelHandler", arg0:name, arg1:argument);
    return null;
  }

  @override
  Future<ui.Codec> instantiateImageCodec(Uint8List list) async {
    logMethod(this, "instantiateImageCode", arg0:"${list.length} bytes");
    throw new UnimplementedError();
  }

  @override
  ui.SceneHost newSceneHost(dynamic exportTokenHandle) {
    logMethod(this, "newScenehost", arg0:exportTokenHandle);
    throw new UnimplementedError();
  }

  @override
  void playSystemSound(SystemSoundType sound) {
    logMethod(this, "playSystemSound", arg0:sound);
  }

  @override
  Stream<dynamic> receiveEventChannelStream(EventChannel eventChannel,
      [dynamic arguments]) async* {

  }

  @override
  void semanticsUpdate(SemanticsOwner owner) {

  }

  @override
  void sendEventChannelMessage(String name, dynamic event) {
    logMethod(this, "sendEventChannelMessgage", arg0:name, arg1:event);
  }

  @override
  Future<dynamic> sendMethodChannelMessage(String name, dynamic argument) async {
    logMethod(this, "sendMethodChannelMessgage", arg0:name, arg1:argument);
  }

  @override
  void sendPlatformMessage(String name, ByteData data,
      ui.PlatformMessageResponseCallback callback) {
    logMethod(this, "sendPlatformMessage", arg0:name, arg1:"${data.lengthInBytes} bytes");
  }

  @override
  void setMethodChannelHandler(String name, MethodChannelHandler handler) {
    logMethod(this, "setMethodChannelHandler", arg0:name);
  }

  @override
  void updateSemantics(ui.SemanticsUpdate update) {

  }

  @override
  Future<Null> vibrate() async {
    logMethod(this, "vibrate");
  }
}

class _UriHandler implements UriHandler {
  const _UriHandler();

  @override
  Future handleUri(Uri uri, {BuildContext buildContext}) async {
    html.window.location.assign(uri.toString());
    return null;
  }
}
