import 'dart:html' as html;

import 'package:flutter/ui.dart';

import 'canvas.dart';

typedef void HtmlPathCommand(html.CanvasRenderingContext2D context);

class HtmlPath extends Path {
  final List<HtmlPathCommand> commands = <HtmlPathCommand>[];
  Paint paint = new Paint();
  Offset startOffset = new Offset(0.0, 0.0);
  Offset offset = new Offset(0.0, 0.0);

  HtmlPath() : super.constructor();

  @override
  PathFillType fillType;

  @override
  void reset() {
    commands.clear();
  }

  @override
  void close() {
    offset = startOffset;
    commands.add((context) {
      context.closePath();
    });
  }

  void draw(HtmlCanvas canvas) {
    final context = canvas.context;
    context.beginPath();
    for (var command in commands) {
      command(context);
    }
    context.stroke();
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
  void conicTo(double x1, double y1, double x2, double y2, double w) {
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
  void cubicTo(
      double x1, double y1, double x2, double y2, double x3, double y3) {
    offset = new Offset(x3, y3);
    commands.add((context) {
      context.quadraticCurveTo(x1, y1, x2, y2);
    });
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
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    offset = new Offset(x2, y2);
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
  void relativeMoveTo(double dx, double dy) {
    final offset = this.offset.translate(dx, dy);
    this.offset = offset;
    this.startOffset = offset;
  }

  @override
  void moveTo(double x, double y) {
    final offset = new Offset(x, y);
    this.offset = offset;
    this.startOffset = offset;
  }
}
