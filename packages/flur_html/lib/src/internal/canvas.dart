import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/ui.dart';

import 'image.dart';

/// Implements [Canvas] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// TODO: Implement methods.
class HtmlFlutterCanvas implements Canvas {
  html.CanvasRenderingContext2D context;

  HtmlFlutterCanvas(this.context);

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {
    throw new UnimplementedError();
  }

  @override
  void drawRawAtlas(Image atlas, Float32List rstTransforms, Float32List rects,
      Int32List colors, BlendMode blendMode, Rect cullRect, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color> colors, BlendMode blendMode, Rect cullRect, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    throw new UnimplementedError();
  }

  @override
  void drawPicture(Picture picture) {
    throw new UnimplementedError();
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawImage(Image image, Offset p, Paint paint) {
    context.drawImage(getCanvasImageSource(image), p.dx, p.dy);
  }

  html.CanvasImageSource getCanvasImageSource(Image image) {
    return new html.ImageElement(src: (image as HtmlFlutterImage).uri);
  }

  @override
  void drawPath(Path path, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    context.rect(rect.left, rect.top, rect.width, rect.height);
  }

  @override
  void drawPaint(Paint paint) {
    final color = paint.color;
    context.setFillColorRgb(color.red, color.green, color.blue);
    context.fill();
  }

  void setFillColor(Color color) {
    context.setFillColorRgb(color.red, color.green, color.blue);
  }

  void setStrokeColor(Color color) {
    context.setStrokeColorRgb(color.red, color.green, color.blue);
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    context.lineTo(p2.dx, p2.dy);
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    setFillColor(color);
    context.fill();
  }

  @override
  void clipPath(Path path) {
    throw new UnimplementedError();
  }

  @override
  void clipRRect(RRect rrect) {
    throw new UnimplementedError();
  }

  @override
  void clipRect(Rect rect) {
    throw new UnimplementedError();
  }

  @override
  void transform(Float64List matrix4) {
    throw new UnimplementedError();
  }

  @override
  void skew(double sx, double sy) {
    throw new UnimplementedError();
  }

  @override
  void rotate(double radians) {
    context.rotate(radians);
  }

  @override
  void scale(double sx, double sy) {
    context.scale(sx, sy);
  }

  @override
  void translate(double dx, double dy) {
    context.translate(dx, dy);
  }

  @override
  int getSaveCount() {
    throw new UnimplementedError();
  }

  @override
  void restore() {
    throw new UnimplementedError();
  }

  @override
  void saveLayer(Rect bounds, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void save() {}
}
