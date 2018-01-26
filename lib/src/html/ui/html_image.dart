import 'dart:html' as html;

import 'package:flutter/ui.dart';

import '../logging.dart';

/// Implements [Image] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// For examples, "Stocks" examples app uses the widget.
class HtmlEngineImage extends Object with HasDebugName implements Image {
  @override
  final String debugName;
  final String uri;

  @override
  final int width;

  @override
  final int height;

  HtmlEngineImage(this.uri, {this.width: 300, this.height: 150}) : this.debugName = allocateDebugName( "Image") {
    logConstructor(this, arg0:uri, arg1:width, arg2:height);
    assert(uri != null);
  }

  @override
  void dispose() {
    html.Url.revokeObjectUrl(uri);
  }
}
