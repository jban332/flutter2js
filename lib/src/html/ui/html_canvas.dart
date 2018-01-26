import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../logging.dart';
import 'html_image.dart';
import 'html_paragraph_builder.dart';
import 'html_path.dart';
import 'html_picture.dart';

/// Implements [Canvas] ('dart:ui') that may be used by [CustomPaint] widget ('package:flutter/widgets.dart').
/// TODO: Implement methods.
class HtmlCanvas extends Object with HasDebugName implements Canvas {
  final String debugName;
  final html.CanvasRenderingContext2D _context;

  int _saveCount = 0;

  HtmlCanvas(html.CanvasElement element) : _context = element.context2D, this.debugName = allocateDebugName( "Canvas") {
    logConstructor(this);
  }

  html.CanvasRenderingContext2D get context => _context;

  @override
  void clipPath(Path path) {
    (path as HtmlPath).draw(this);
    context.clip();
  }

  @override
  void clipRect(Rect rect, {ClipOp clipOp}) {
    context.rect(rect.left, rect.top, rect.width, rect.height);
    context.clip();
  }

  @override
  void clipRRect(RRect rrect) {
    _rrect(rrect);
    context.clip();
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    // TODO: Support ellipses
    final center = rect.center;
    final radius = (center - rect.topLeft).distance.abs();
    assert(radius > 0, "Invalid radius ${radius}");
    if (useCenter) {
      _drawArcPointLine(center, radius, startAngle);
    }
    context.arc(center.dx, center.dy, radius, startAngle, sweepAngle);
    if (useCenter) {
      _drawArcPointLine(center, radius, startAngle + sweepAngle);
    }
    strokeOrFill(paint);
  }

  @override
  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color> colors, BlendMode blendMode, Rect cullRect, Paint paint) {

  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    assert(radius > 0, "Invalid radius ${radius}");
    context.arc(c.dx, c.dy, radius, 0.0, 2 * math.PI);
    strokeOrFill(paint);
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    context.setStrokeColorRgb(color.red, color.green, color.blue);
    context.setFillColorRgb(color.red, color.green, color.blue);
    context.globalCompositeOperation = globalCompositeOperationFrom(blendMode);
    context.fill();
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    _rrect(outer);
    strokeOrFill(paint);
    _rrect(inner);
    strokeOrFill(paint);
  }

  @override
  void drawImage(Image image, Offset p, Paint paint) {
    context.drawImage(getCanvasImageSource(image), p.dx, p.dy);
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {

  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {

  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    context.moveTo(p1.dx, p1.dy);
    context.lineTo(p2.dx, p2.dy);
    strokeOrFill(paint);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    final center = rect.center;
    final rx = rect.width / 2;
    final ry = rect.height / 2;
    context.ellipse(center.dx, center.dy, rx, ry, 0, 0, 2 * math.PI, false);
    strokeOrFill(paint);
  }

  @override
  void drawPaint(Paint paint) {
    setPaint(paint);
    context.fill();
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    (paragraph as HtmlParagraph).draw(context, offset);
  }

  @override
  void drawPath(Path path, Paint paint) {
    (path as HtmlPath).draw(this);
    strokeOrFill(paint);
  }

  @override
  void drawPicture(Picture picture) {
    if (picture is HtmlPicture) {
      picture.draw(this);
    } else {
      throw new ArgumentError.value(picture);
    }
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    final context = this.context;
    setPaint(paint);
    for (var point in points) {
      context.moveTo(point.dx, point.dy);
      context.lineTo(0, 0);
      context.stroke();
    }
  }

  @override
  void drawRawAtlas(Image atlas, Float32List rstTransforms, Float32List rects,
      Int32List colors, BlendMode blendMode, Rect cullRect, Paint paint) {

  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    setPaint(paint);
    final context = this.context;
    for (var i = 0; i < points.length; i += 2) {
      final x = points[i];
      final y = points[i + 1];
      context.moveTo(x, y);
      context.lineTo(x + 1, y + 1);
      context.stroke();
    }
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    context.rect(rect.left, rect.top, rect.width, rect.height);
    strokeOrFill(paint);
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    _rrect(rrect);
    strokeOrFill(paint);
  }

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {

  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    final context = this.context;
    setPaint(paint);
    context.globalCompositeOperation = globalCompositeOperationFrom(blendMode);
    final colors = vertices.colors;
    final positions = vertices.positions;
    final length = positions.length;
    for (var i = 0; i < length; i += 3) {
      if (colors != null) {
        final color = colors[i];
        context.setFillColorRgb(color.red, color.green, color.blue);
      }
      final v0 = positions[i];
      final v1 = positions[i + 1];
      final v2 = positions[i + 2];
      context.beginPath();
      context.moveTo(v0.dx, v0.dy);
      context.lineTo(v1.dx, v1.dy);
      context.lineTo(v2.dx, v2.dy);
      context.closePath();
      context.fill();
      context.stroke();
    }
  }

  html.CanvasImageSource getCanvasImageSource(Image image) {
    return new html.ImageElement(src: (image as HtmlEngineImage).uri);
  }

  @override
  int getSaveCount() {
    return _saveCount;
  }

  String globalCompositeOperationFrom(BlendMode value) {
    if (value == null) {
      return null;
    }
    switch (value) {
      case BlendMode.color:
        return "color";
      case BlendMode.colorBurn:
        return "color-burn";
      case BlendMode.colorDodge:
        return "color-dodge";
      case BlendMode.darken:
        return "darken";
      case BlendMode.dstATop:
        return "destination-atop";
      case BlendMode.dstIn:
        return "destination-in";
      case BlendMode.dstOut:
        return "destination-out";
      case BlendMode.dstOver:
        return "destination-over";
      case BlendMode.difference:
        return "difference";
      case BlendMode.exclusion:
        return "exclusion";
      case BlendMode.hardLight:
        return "hard-light";
      case BlendMode.hue:
        return "hue";
      case BlendMode.lighten:
        return "lighten";
      case BlendMode.luminosity:
        return "luminosity";
      case BlendMode.multiply:
        return "multiply";
      case BlendMode.overlay:
        return "overlay";
      case BlendMode.screen:
        return "screen";
      case BlendMode.softLight:
        return "soft-light";
      case BlendMode.srcATop:
        return "source-atop";
      case BlendMode.srcIn:
        return "source-in";
      case BlendMode.srcOut:
        return "source-out";
      case BlendMode.srcOver:
        return "source-over";
      case BlendMode.xor:
        return "xor";
      default:
        return "normal";
    }
  }

  String lineCapFrom(StrokeCap strokeCap) {
    if (strokeCap == null) {
      return null;
    }
    switch (strokeCap) {
      case StrokeCap.butt:
        return "butt";
      case StrokeCap.square:
        return "square";
      default:
        return "round";
    }
  }

  @override
  void restore() {
    context.restore();
    _saveCount--;
  }

  @override
  void rotate(double radians) {
    context.rotate(radians);
  }

  @override
  void save() {
    context.save();
    _saveCount++;
  }

  @override
  void saveLayer(Rect bounds, Paint paint) {
    // TODO: Bounds and paint
    context.save();
    _saveCount++;
  }

  @override
  void scale(double sx, double sy) {
    context.transform(sx, sy, 0.0, 0.0, 0.0, 0.0);
  }

  void setPaint(Paint paint) {
    final context = this.context;
    final style = paint.style;
    if (style == PaintingStyle.stroke) {
      final color = paint.color;
      context.setStrokeColorRgb(color.red, color.green, color.blue);
      context.globalCompositeOperation =
          globalCompositeOperationFrom(paint.blendMode);
      context.lineCap = lineCapFrom(paint.strokeCap);
      context.lineWidth = paint.strokeWidth ?? 1.0;
    }
    if (style == PaintingStyle.fill) {
      final color = paint.color;
      context.setStrokeColorRgb(color.red, color.green, color.blue);
      context.globalCompositeOperation =
          globalCompositeOperationFrom(paint.blendMode);
    }
  }

  @override
  void skew(double sx, double sy) {
    context.transform(0.0, 0.0, sx, sy, 0.0, 0.0);
  }

  void strokeOrFill(Paint paint) {
    setPaint(paint);
    final style = paint.style;
    if (style == PaintingStyle.stroke) {
      context.stroke();
    } else if (style == PaintingStyle.fill) {
      context.fill();
    }
  }

  @override
  void transform(Float64List matrix4) {
    context.transform(matrix4[0], matrix4[1], matrix4[2], matrix4[3], 0.0, 0.0);
  }

  @override
  void translate(double dx, double dy) {
    context.translate(dx, dy);
  }

  void _drawArcPointLine(Offset center, double radius, double angle) {
    context.lineTo(center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius);
  }

  void _rrect(RRect rrect) {
    context.beginPath();
    // Top-left
    {
      final r = rrect.tlRadius;
      final dx = r.x;
      final dy = r.y;
      final left = rrect.left;
      final top = rrect.top;
      context.ellipse(
          left + dx, top + dy, dx, dy, 0.0, 0.5 * math.PI, math.PI, true);
    }
    // Top-right
    {
      final r = rrect.trRadius;
      final dx = r.x;
      final dy = r.y;
      final right = rrect.right;
      final top = rrect.top;
      context.ellipse(
          right - dx, top + dy, dx, dy, 0.0, 0.0, 0.5 * math.PI, true);
    }

    // Bottom-left
    {
      final r = rrect.blRadius;
      final dx = r.x;
      final dy = r.y;
      final left = rrect.left;
      final bottom = rrect.bottom;
      context.ellipse(
          left + dx, bottom - dy, dx, dy, 0.0, math.PI, 1.5 * math.PI, true);
    }

    // Bottom-right
    {
      final r = rrect.brRadius;
      final dx = r.x;
      final dy = r.y;
      final right = rrect.right;
      final bottom = rrect.bottom;
      context.ellipse(right - dx, bottom - dy, dx, dy, 1.5 * math.PI,
          2 * math.PI, math.PI, true);
    }
    context.closePath();
  }
}
