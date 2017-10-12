import 'dart:html' as html;

import 'package:flutter/ui.dart';

/// Implements [Image] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// For examples, "Stocks" examples app uses the widget.
class HtmlEngineImage implements Image {
  final String uri;

  @override
  final int width;

  @override
  final int height;

  HtmlEngineImage(this.uri, {this.width: 300, this.height: 150}) {
    assert(uri != null);
  }

  @override
  void dispose() {
    html.Url.revokeObjectUrl(uri);
  }
}
