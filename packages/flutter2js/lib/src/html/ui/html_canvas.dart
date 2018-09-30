import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../logging.dart';
import '../css_helpers.dart';
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

  HtmlCanvas(html.CanvasElement element)
      : _context = element.context2D,
        this.debugName = allocateDebugName("Canvas") {
    logConstructor(this);
  }

  html.CanvasRenderingContext2D get context => _context;

  @override
  void clipPath(Path path) {
    if (path is HtmlPath) {
      path.clip(context);
    } else {
      throw new ArgumentError.value(path);
    }
  }

  @override
  void clipRect(Rect rect, {ClipOp clipOp}) {
    context.beginPath();
    context.rect(rect.left, rect.top, rect.width, rect.height);
    context.clip();
  }

  @override
  void clipRRect(RRect rrect) {
    context.beginPath();
    _rrect(rrect);
    context.clip();
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    beginStrokeOrFill(paint);
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
    endStrokeOrFill(paint);
  }

  @override
  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color> colors, BlendMode blendMode, Rect cullRect, Paint paint) {
    throw new UnimplementedError();
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    assert(radius > 0, "Invalid radius ${radius}");
    beginStrokeOrFill(paint);
    context.arc(c.dx, c.dy, radius, 0.0, 2 * math.pi);
    endStrokeOrFill(paint);
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
    beginStrokeOrFill(paint);
    _rrect(outer);
    endStrokeOrFill(paint);
    beginStrokeOrFill(paint);
    _rrect(inner);
    endStrokeOrFill(paint);
  }

  @override
  void drawImage(Image image, Offset p, Paint paint) {
    context.drawImage(getCanvasImageSource(image), p.dx, p.dy);
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {

  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {}

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    beginStrokeOrFill(paint, style:PaintingStyle.stroke);
    context.moveTo(p1.dx, p1.dy);
    context.lineTo(p2.dx, p2.dy);
    endStrokeOrFill(paint, style:PaintingStyle.stroke);
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    beginStrokeOrFill(paint);
    final center = rect.center;
    final rx = rect.width / 2;
    final ry = rect.height / 2;
    context.ellipse(center.dx, center.dy, rx, ry, 0, 0, 2 * math.pi, false);
    endStrokeOrFill(paint);
  }

  @override
  void drawPaint(Paint paint) {
    setPaint(paint);
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    (paragraph as HtmlParagraph).draw(context, offset);
  }

  @override
  void drawPath(Path path, Paint paint) {
    if (path is HtmlPath) {
      endStrokeOrFill(paint, path: path);
    } else {
      throw new ArgumentError.value(path);
    }
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
    throw new UnimplementedError();
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    setPaint(paint);
    final context = this.context;
    for (var i = 0; i < points.length; i += 2) {
      final x = points[i];
      final y = points[i + 1];
      context.moveTo(x, y);
      context.lineTo(x, y);
      context.stroke();
    }
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    beginStrokeOrFill(paint);
    context.rect(rect.left, rect.top, rect.width, rect.height);
    endStrokeOrFill(paint);
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    beginStrokeOrFill(paint);
    _rrect(rrect);
    endStrokeOrFill(paint);
  }

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {
    if (path is HtmlPath) {
      context.setStrokeColorRgb(color.red, color.green, color.blue);
      context.beginPath();
      context.lineWidth = 1;
      path.stroke(context);
    } else {
      throw new ArgumentError.value(path);
    }
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

    // Color
    final color = paint.color ?? const Color.fromARGB(255, 0, 0, 0);
    context.globalAlpha = color.alpha;
    context.fillStyle = cssFromColor(color);
    context.setFillColorRgb(color.red, color.green, color.blue);
    context.setStrokeColorRgb(color.red, color.green, color.blue);
    final shader = paint.shader;
    if (shader!=null) {
      if (shader is LinearGradient) {
        final from = shader.from;
        final to = shader.to;
        final result = context.createLinearGradient(from.dx, from.dy, to.dx, to.dy);
        final stops = shader.colorStops;
        final colors = shader.colors;
        for (var i=0;i<stops.length;i++) {
          result.addColorStop(stops[i], cssFromColor(colors[i]));
        }
        context.fillStyle = result;
      } else if (shader is RadialGradient) {
        final center = shader.center;
        final radius = shader.radius;
        final result = context.createRadialGradient(center.dx, center.dy, center.dx-radius, center.dy-radius, radius*2, radius*2);
        final stops = shader.colorStops;
        final colors = shader.colors;
        for (var i=0;i<stops.length;i++) {
          result.addColorStop(stops[i], cssFromColor(colors[i]));
        }
        context.fillStyle = result;
      }
    }

    // Blend
    final blendMode =
        globalCompositeOperationFrom(paint.blendMode) ?? "srcOver";
    context.globalCompositeOperation = blendMode;

    final style = paint.style ?? PaintingStyle.fill;
    if (style == PaintingStyle.stroke) {
      context.lineCap = lineCapFrom(paint.strokeCap) ?? "butt";
      context.lineWidth = paint.strokeWidth ?? 0.0;
    } else if (style == PaintingStyle.fill) {
      context.fillStyle = "color";
    }
  }

  @override
  void skew(double sx, double sy) {
    context.transform(0.0, 0.0, sx, sy, 0.0, 0.0);
  }


  void beginStrokeOrFill(Paint paint, {PaintingStyle style}) {
    if (style == null) {
      style = paint.style ?? PaintingStyle.stroke;
    }
    if (style == PaintingStyle.fill) {
      context.save();
      context.beginPath();
    }
  }

  void endStrokeOrFill(Paint paint, {PaintingStyle style, HtmlPath path}) {
    setPaint(paint);
    if (style == null) {
      style = paint.style ?? PaintingStyle.stroke;
    }
    if (style == PaintingStyle.stroke) {
      if (path == null) {
        context.stroke();
      } else {
        path.stroke(context);
      }
    } else if (style == PaintingStyle.fill) {
      if (path == null) {
        context.fill();
        context.restore();
      } else {
        path.fill(context);
      }
    } else {
      throw new ArgumentError.value(style);
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
          left + dx, top + dy, dx, dy, 0.0, 0.5 * math.pi, math.pi, true);
    }
    // Top-right
    {
      final r = rrect.trRadius;
      final dx = r.x;
      final dy = r.y;
      final right = rrect.right;
      final top = rrect.top;
      context.ellipse(
          right - dx, top + dy, dx, dy, 0.0, 0.0, 0.5 * math.pi, true);
    }

    // Bottom-left
    {
      final r = rrect.blRadius;
      final dx = r.x;
      final dy = r.y;
      final left = rrect.left;
      final bottom = rrect.bottom;
      context.ellipse(
          left + dx, bottom - dy, dx, dy, 0.0, math.pi, 1.5 * math.pi, true);
    }

    // Bottom-right
    {
      final r = rrect.brRadius;
      final dx = r.x;
      final dy = r.y;
      final right = rrect.right;
      final bottom = rrect.bottom;
      context.ellipse(right - dx, bottom - dy, dx, dy, 1.5 * math.pi,
          2 * math.pi, math.pi, true);
    }
    context.closePath();
  }
}
