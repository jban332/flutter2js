import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flur/flur.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';

import 'internal/image.dart';
import 'internal/paragraph.dart';
import 'internal/path.dart';
import 'internal/picture.dart';
import 'route_adapter.dart';

/// Implements [Image] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// For examples, "Stocks" examples app uses the widget.
class BrowserPlatformPlugin extends PlatformPlugin {
  @override
  final RouteAdapter routeAdapter;

  BrowserPlatformPlugin({RouteAdapter routeAdapter})
      : this.routeAdapter = routeAdapter ?? new UrlFragmentRouteAdapter();

  @override
  Future<ui.Image> decodeImageFromList(
      Uint8List list, void complete(ui.Image image)) async {
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
}

class _UriHandler implements UriHandler {
  const _UriHandler();

  @override
  Future handleUri(Uri uri, {BuildContext buildContext}) async {
    html.window.location.assign(uri.toString());
    return null;
  }
}
