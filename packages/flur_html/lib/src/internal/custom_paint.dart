import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flur/js.dart';
import 'package:flutter/widgets.dart';

import 'canvas.dart';

class HtmlCustomPaint extends StatelessWidget {
  final CustomPaint paint;

  HtmlCustomPaint(this.paint);

  @override
  Widget build(BuildContext context) {
    final canvas = new HtmlReactWidget("canvas", onJsValue: (JsValue jsValue) {
      final element = jsValue.unsafeValue as html.CanvasElement;
      final size =
          new Size(element.width.toDouble(), element.height.toDouble());
      paint.painter.paint(new HtmlFlutterCanvas(element.context2D), size);
    });
    return canvas;
  }
}
