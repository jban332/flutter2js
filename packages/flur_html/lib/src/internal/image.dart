import 'package:flutter/ui.dart';

/// Implements [Image] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// For examples, "Stocks" examples app uses the widget.
class HtmlFlutterImage implements Image {
  final String uri;

  const HtmlFlutterImage(this.uri);

  @override
  int get width {
    throw new UnimplementedError();
  }

  @override
  void dispose() {}

  @override
  int get height {
    throw new UnimplementedError();
  }
}
