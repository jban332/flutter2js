import 'package:flur/flur.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;

/// Implements [Image] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// For examples, "Stocks" examples app uses the widget.
class BrowserPlatformPlugin extends PlatformPlugin {

  @override
  ui.ParagraphBuilder newParagraphBuilder(ui.ParagraphStyle style) {
    return new HtmlParagraphBuilder(new html.CanvasElement(), style);
  }
}

class HtmlParagraphBuilder implements ui.ParagraphBuilder {
  final html.CanvasElement _canvas;
  final html.CanvasRenderingContext2D _context;
  final ui.ParagraphStyle style;
  final List<ui.TextStyle> _styles = <ui.TextStyle>[];

  HtmlParagraphBuilder(html.CanvasElement canvas, this.style) : this._canvas = canvas, this._context = canvas.context2D;

  @override
  void pushStyle(ui.TextStyle style) {
    _styles.add(style);
  }

  @override
  HtmlParagraph build() {
    return new HtmlParagraph(_canvas);
  }

  @override
  void addText(String text) {
    _context.strokeText(text, 0, 0);
  }

  @override
  void pop() {
    _styles.removeLast();
  }
}

class HtmlParagraph implements ui.Paragraph {
  final html.CanvasElement canvas;
  HtmlParagraph(this.canvas);

  @override
  double get width {
    return canvas.width.toDouble();
  }

  @override
  List<int> getWordBoundary(int offset) {
    throw new UnimplementedError();
  }

  @override
  List<ui.TextBox> getBoxesForRange(int start, int end) {
    throw new UnimplementedError();
  }

  @override
  void layout(ui.ParagraphConstraints constraints) {

  }

  @override
  bool get didExceedMaxLines {
    throw new UnimplementedError();
  }

  @override
  double get ideographicBaseline {
    throw new UnimplementedError();
  }

  @override
  double get alphabeticBaseline {
    throw new UnimplementedError();
  }

  @override
  double get maxIntrinsicWidth {
    throw new UnimplementedError();
  }

  @override
  double get minIntrinsicWidth {
    throw new UnimplementedError();
  }

  @override
  double get height {
    return canvas.height.toDouble();
  }

  @override
  ui.TextPosition getPositionForOffset(Offset offset) {
    throw new UnimplementedError();
  }
}