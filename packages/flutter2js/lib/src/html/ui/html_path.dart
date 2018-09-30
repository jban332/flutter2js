import 'dart:html' as html;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../logging.dart';

abstract class HtmlPath implements Path {
  factory HtmlPath() {
    return new InternalHtmlPath();
  }
  void stroke(html.CanvasRenderingContext2D context);
  void fill(html.CanvasRenderingContext2D context);
  void clip(html.CanvasRenderingContext2D context);
}

typedef void InternalHtmlPathCommand(html.CanvasRenderingContext2D context);

final html.CanvasElement _testCanvas = new html.CanvasElement(width:1000, height:1000);

class InternalHtmlPath extends Object with HasDebugName implements HtmlPath {
  final String debugName;
  final List<InternalHtmlPathCommand> _commands = <InternalHtmlPathCommand>[];

  void _add(InternalHtmlPathCommand command) {
    _commands.add(command);
  }

  @override
  void stroke(html.CanvasRenderingContext2D context) {
    for (var command in _commands) {
      command(context);
    }
    context.stroke();
  }

  @override
  void fill(html.CanvasRenderingContext2D context) {
    context.save();
    context.beginPath();
    for (var command in _commands) {
      command(context);
    }
    context.clip();
    context.fill();
    context.restore();
  }

  @override
  void clip(html.CanvasRenderingContext2D context) {
    context.beginPath();
    for (var command in _commands) {
      command(context);
    }
    context.clip();
  }

  double _x = 0.0;
  double _y = 0.0;

  @override
  PathFillType get fillType => _fillType;

  @override
  set fillType(PathFillType newValue) {
    _fillType = newValue;
  }

  PathFillType _fillType = PathFillType.nonZero;

  InternalHtmlPath() :this.debugName = allocateDebugName("Path") {
    logConstructor(this);
  }

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    _add((context) {
      context.arc(oval.left, oval.top, oval.width / 2, startAngle,
          startAngle + sweepAngle, false);
    });
  }

  @override
  void addOval(Rect oval) {
    _add((context) {
      context.ellipse(
          oval.left,
          oval.top,
          oval.width / 2,
          oval.height / 2,
          0,
          0,
          2 * math.pi,
          false);
    });
  }

  @override
  void addPath(Path path, Offset offset) {
    if (path is InternalHtmlPath) {
      _commands.addAll(path._commands);
    } else {
      throw new ArgumentError.value(path);
    }
  }

  @override
  void addPolygon(List<Offset> points, bool close) {
    Offset previous;
    for (var point in points) {
      if (previous != null) {
        lineTo(point.dx, point.dy);
      }
      moveTo(point.dx, point.dy);
    }
    if (close) {
      final first = points.first;
      lineTo(first.dx, first.dy);
    }
  }

  @override
  void addRect(Rect rect) {
    _add((context) {
      context.rect(rect.left, rect.top, rect.width, rect.height);
    });
  }

  @override
  void addRRect(RRect rrect) {
    _add((context) {
      context.rect(rrect.left, rrect.top, rrect.width, rrect.height);
    });
  }

  @override
  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    // TODO: implementation
  }

  @override
  void arcToPoint(Offset arcEnd,
      {Radius radius: Radius.zero,
        double rotation: 0.0,
        bool largeArc: false,
        bool clockwise: true}) {
    // TODO: implementation
  }

  @override
  void close() {
    _add((context) {
      context.closePath();
    });
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    _add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  bool contains(Offset point) {
    logMethod(this, "contains");
    final context = _testCanvas.context2D;
    context.save();
    fill(context);
    final result = context.isPointInPath(point.dx, point.dy);
    context.restore();
    return result;
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    _add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  void extendWithPath(Path path, Offset offset) {
    this.addPath(path, offset);
  }

  @override
  void lineTo(double x, double y) {
    _add((context) {
      context.lineTo(x, y);
    });
  }

  @override
  void moveTo(double x, double y) {
    _add((context) {
      context.moveTo(x, y);
    });
    _x = x;
    _y = y;
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    _add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  void relativeArcToPoint(Offset arcEndDelta,
      {Radius radius: Radius.zero,
        double rotation: 0.0,
        bool largeArc: false,
        bool clockwise: true}) {
    arcToPoint(arcEndDelta, radius:radius, rotation:rotation, largeArc: largeArc, clockwise: clockwise);
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    conicTo(this._x + x1, this._y + y1, this._x + x2, this._y + y2, w);
  }

  @override
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    cubicTo(this._x + x1, this._y + y1, this._x + x2, this._y + y2, this._x + x3, this._y + y3);
  }

  @override
  void relativeLineTo(double dx, double dy) {
    lineTo(this._x + dx, this._y + dy);
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    moveTo(this._x + dx, this._y + dy);
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    quadraticBezierTo(this._x + x1, this._y + y1, this._x + x2, this._y + y2);
  }

  @override
  void reset() {
    _commands.clear();
  }

  @override
  Path shift(Offset offset) {
    final result = new HtmlPath();
    result.addPath(this, Offset.zero);
    return result;
  }

  @override
  Path transform(Float64List matrix4) {
    final result = new HtmlPath();
    result.addPath(this, Offset.zero);
    return result;
  }
}

class NativeHtmlPath extends Object with HasDebugName implements HtmlPath {
  final String debugName;

  @override
  void stroke(html.CanvasRenderingContext2D context) {
    context.stroke(htmlPath);
  }

  @override
  void fill(html.CanvasRenderingContext2D context) {
    context.save();
    context.clip(htmlPath);
    context.fill();
    context.restore();
  }

  @override
  void clip(html.CanvasRenderingContext2D context) {
    context.clip(htmlPath);
  }

  html.Path2D get htmlPath => _htmlPath;
  html.Path2D _htmlPath = new html.Path2D();

  double _x = 0.0;
  double _y = 0.0;

  @override
  PathFillType get fillType => _fillType;

  @override
  set fillType(PathFillType newValue) {
    _fillType = newValue;
  }

  PathFillType _fillType = PathFillType.nonZero;

  NativeHtmlPath() :
        this.debugName = allocateDebugName("Path") {
    logConstructor(this);
  }

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    htmlPath.arc(oval.left, oval.top, oval.width / 2, startAngle,
        startAngle + sweepAngle, false);
  }

  @override
  void addOval(Rect oval) {
    htmlPath.ellipse(oval.left, oval.top, oval.width / 2, oval.height / 2, 0,
        0, 2 * math.pi, false);
  }

  @override
  void addPath(Path path, Offset offset) {
    if (path is NativeHtmlPath) {
      htmlPath.addPath(path.htmlPath);
    } else {
      throw new ArgumentError.value(path);
    }
  }

  @override
  void addPolygon(List<Offset> points, bool close) {
    Offset previous;
    for (var point in points) {
      if (previous != null) {
        htmlPath.lineTo(point.dx, point.dy);
      }
      htmlPath.moveTo(point.dx, point.dy);
    }
    if (close) {
      final first = points.first;
      htmlPath.lineTo(first.dx, first.dy);
    }
  }

  @override
  void addRect(Rect rect) {
    htmlPath.rect(rect.left, rect.top, rect.width, rect.height);
  }

  @override
  void addRRect(RRect rrect) {
    htmlPath.rect(rrect.left, rrect.top, rrect.width, rrect.height);
  }

  @override
  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    // TODO: implementation
  }

  @override
  void arcToPoint(Offset arcEnd,
      {Radius radius: Radius.zero,
      double rotation: 0.0,
      bool largeArc: false,
      bool clockwise: true}) {
    // TODO: implementation
  }

  @override
  void close() {
    htmlPath.closePath();
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    htmlPath.quadraticCurveTo(x1, y1, x2, y2);
  }

  @override
  bool contains(Offset point) {
    logMethod(this, "contains");
    final context = _testCanvas.context2D;
    return context.isPointInPath(htmlPath, point.dx, point.dy);
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    htmlPath.quadraticCurveTo(x1, y1, x2, y2);
  }

  @override
  void extendWithPath(Path path, Offset offset) {
    this.addPath(path, offset);
  }

  @override
  void lineTo(double x, double y) {
    // Store command
    htmlPath.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    htmlPath.moveTo(x, y);
    _x = x;
    _y = y;
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    htmlPath.quadraticCurveTo(x1, y1, x2, y2);
  }

  @override
  void relativeArcToPoint(Offset arcEndDelta,
      {Radius radius: Radius.zero,
      double rotation: 0.0,
      bool largeArc: false,
      bool clockwise: true}) {
    arcToPoint(arcEndDelta, radius:radius, rotation:rotation, largeArc: largeArc, clockwise: clockwise);
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    conicTo(this._x + x1, this._y + y1, this._x + x2, this._y + y2, w);
  }

  @override
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    cubicTo(this._x + x1, this._y + y1, this._x + x2, this._y + y2, this._x + x3, this._y + y3);
  }

  @override
  void relativeLineTo(double dx, double dy) {
    lineTo(this._x + dx, this._y + dy);
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    moveTo(this._x + dx, this._y + dy);
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    quadraticBezierTo(this._x + x1, this._y + y1, this._x + x2, this._y + y2);
  }

  @override
  void reset() {
    _htmlPath = new html.Path2D();
  }

  @override
  Path shift(Offset offset) {
    final result = new HtmlPath();
    result.addPath(this, Offset.zero);
    return result;
  }

  @override
  Path transform(Float64List matrix4) {
    final result = new HtmlPath();
    result.addPath(this, Offset.zero);
    return result;
  }
}
