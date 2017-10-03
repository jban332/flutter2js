import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flur/js.dart';
import 'package:flutter/widgets.dart';

import 'canvas.dart';

class HtmlCustomPaint extends StatelessWidget {
  final CustomPaint paint;

  HtmlCustomPaint(this.paint) {
    assert(paint != null);
  }

  @override
  Widget build(BuildContext context) {
    final painter = paint.painter;
    final foregroundPainter = paint.foregroundPainter;
    void onDomElement(html.CanvasElement element) {
      final size =
          new Size(element.width.toDouble(), element.height.toDouble());
      if (foregroundPainter != null) {
        foregroundPainter.paint(new HtmlFlutterCanvas(element.context2D), size);
      }
    }
    final canvasDom =
        new HtmlElementWidget("canvas", onDomElement: onDomElement);
    return new HtmlElementWidget("div", debugCreator: paint, children: [
      canvasDom,
      paint.child,
    ]);
  }
}
