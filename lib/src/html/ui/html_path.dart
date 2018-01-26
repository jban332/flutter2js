import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../logging.dart';
import 'html_canvas.dart';

typedef void HtmlPathCommand(html.CanvasRenderingContext2D context);

class HtmlPath extends Object with HasDebugName implements Path {
  // TODO: Use HTML Path
  final List<HtmlPathCommand> commands = <HtmlPathCommand>[];
  final String debugName;
  Paint paint = new Paint();
  Offset startOffset = new Offset(0.0, 0.0);
  Offset offset = new Offset(0.0, 0.0);

  @override
  PathFillType fillType;

  HtmlPath() : this.debugName = allocateDebugName("Path") {
    logConstructor(this);
  }

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    throw new UnimplementedError();
  }

  @override
  void addOval(Rect oval) {
    throw new UnimplementedError();
  }

  @override
  void addPath(Path path, Offset offset) {
    throw new UnimplementedError();
  }

  @override
  void addPolygon(List<Offset> points, bool close) {
    throw new UnimplementedError();
  }

  @override
  void addRect(Rect rect) {
    throw new UnimplementedError();
  }

  @override
  void addRRect(RRect rrect) {
    throw new UnimplementedError();
  }

  @override
  void arcTo(
      Rect rect, double startAngle, double sweepAngle, bool forceMoveTo) {
    throw new UnimplementedError();
  }

  @override
  void arcToPoint(Offset arcEnd,
      {Radius radius: Radius.zero,
      double rotation: 0.0,
      bool largeArc: false,
      bool clockwise: true}) {
    throw new UnimplementedError();
  }

  @override
  void close() {
    offset = startOffset;
    commands.add((context) {
      context.closePath();
    });
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    offset = new Offset(x2, y2);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  bool contains(Offset point) {
    logMethod(this, "contains");
    return false;
  }

  @override
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    offset = new Offset(x3, y3);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  void draw(HtmlCanvas canvas) {
    logMethod(this, "draw", arg0:canvas);
    final context = canvas.context;
    context.beginPath();
    for (var command in commands) {
      command(context);
    }
    context.stroke();
  }

  @override
  void extendWithPath(Path path, Offset offset) {
    throw new UnimplementedError();
  }

  @override
  void lineTo(double x, double y) {
    // Update offset
    final newOffset = new Offset(x, y);
    this.offset = newOffset;

    // Store command
    commands.add((context) {
      context.lineTo(newOffset.dx, newOffset.dy);
    });
  }

  @override
  void moveTo(double x, double y) {
    final offset = new Offset(x, y);
    this.offset = offset;
    this.startOffset = offset;
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    offset = new Offset(x2, y2);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  void relativeArcToPoint(Offset arcEndDelta,
      {Radius radius: Radius.zero,
      double rotation: 0.0,
      bool largeArc: false,
      bool clockwise: true}) {
    throw new UnimplementedError();
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    final dx = offset.dx;
    final dy = offset.dy;
    x1 += dx;
    x2 += dx;
    y1 += dy;
    y2 += dy;
    offset = new Offset(x2, y2);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  void relativeCubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    final dx = offset.dx;
    final dy = offset.dy;
    x1 += dx;
    x2 += dx;
    x3 += dx;
    y1 += dy;
    y2 += dy;
    y3 += dy;
    offset = new Offset(x3, y3);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  void relativeLineTo(double dx, double dy) {
    // Update offset
    final newOffset = this.offset.translate(dx, dy);
    this.offset = newOffset;

    // Store command
    commands.add((context) {
      context.lineTo(newOffset.dx, newOffset.dy);
    });
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    final offset = this.offset.translate(dx, dy);
    this.offset = offset;
    this.startOffset = offset;
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    final dx = offset.dx;
    final dy = offset.dy;
    x1 += dx;
    x2 += dx;
    y1 += dy;
    y2 += dy;
    offset = new Offset(x2, y2);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
  }

  @override
  void reset() {
    logMethod(this, "reset");
    commands.clear();
  }

  @override
  Path shift(Offset offset) {
    throw new UnimplementedError();
  }

  @override
  Path transform(Float64List matrix4) {
    throw new UnimplementedError();
  }
}
