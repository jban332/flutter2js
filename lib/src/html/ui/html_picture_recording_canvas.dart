import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../logging.dart';
import 'html_canvas.dart';
import 'html_picture.dart';

class HtmlPictureRecordingCanvas extends Object
    with HasDebugName
    implements Canvas {
  final String debugName;
  List<Command> commands = <Command>[];
  int _saveCount;

  HtmlPictureRecordingCanvas(HtmlPictureRecorder recorder)
      : this.commands = recorder.commands,
        this.debugName = allocateDebugName("[PictureRecording]Canvas") {
    logConstructor(this);
  }

  @override
  void clipPath(Path path) {
    _add((Canvas canvas) {
      canvas.clipPath(path);
    });
  }

  @override
  void clipRect(Rect rect, {ClipOp clipOp}) {
    _add((Canvas canvas) {
      canvas.clipRect(rect);
    });
  }

  @override
  void clipRRect(RRect rrect) {
    _add((Canvas canvas) {
      canvas.clipRRect(rrect);
    });
  }

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter,
      Paint paint) {
    _add((Canvas canvas) {
      canvas.drawArc(rect, startAngle, sweepAngle, useCenter, paint);
    });
  }

  @override
  void drawAtlas(Image atlas, List<RSTransform> transforms, List<Rect> rects,
      List<Color> colors, BlendMode blendMode, Rect cullRect, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawAtlas(
          atlas, transforms, rects, colors, blendMode, cullRect, paint);
    });
  }

  @override
  void drawCircle(Offset c, double radius, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawCircle(c, radius, paint);
    });
  }

  @override
  void drawColor(Color color, BlendMode blendMode) {
    _add((Canvas canvas) {
      canvas.drawColor(color, blendMode);
    });
  }

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawDRRect(outer, inner, paint);
    });
  }

  @override
  void drawImage(Image image, Offset p, Paint paint) {
    logMethod(this, "drawImage", arg0: image, arg1: p, arg2: paint);
    _add((Canvas canvas) {
      canvas.drawImage(image, p, paint);
    });
  }

  @override
  void drawImageNine(Image image, Rect center, Rect dst, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawImageNine(image, center, dst, paint);
    });
  }

  @override
  void drawImageRect(Image image, Rect src, Rect dst, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawImageRect(image, src, dst, paint);
    });
  }

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawLine(p1, p2, paint);
    });
  }

  @override
  void drawOval(Rect rect, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawOval(rect, paint);
    });
  }

  @override
  void drawPaint(Paint paint) {
    _add((Canvas canvas) {
      canvas.drawPaint(paint);
    });
  }

  @override
  void drawParagraph(Paragraph paragraph, Offset offset) {
    logMethod(this, "drawParagraph", arg0: paragraph, arg1: offset);
    _add((Canvas canvas) {
      canvas.drawParagraph(paragraph, offset);
    });
  }

  @override
  void drawPath(Path path, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawPath(path, paint);
    });
  }

  @override
  void drawPicture(Picture picture) {
    _add((Canvas canvas) {
      canvas.drawPicture(picture);
    });
  }

  @override
  void drawPoints(PointMode pointMode, List<Offset> points, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawPoints(pointMode, points, paint);
    });
  }

  @override
  void drawRawAtlas(Image atlas, Float32List rstTransforms, Float32List rects,
      Int32List colors, BlendMode blendMode, Rect cullRect, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawRawAtlas(
          atlas, rstTransforms, rects, colors, blendMode, cullRect, paint);
    });
  }

  @override
  void drawRawPoints(PointMode pointMode, Float32List points, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawRawPoints(pointMode, points, paint);
    });
  }

  @override
  void drawRect(Rect rect, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawRect(rect, paint);
    });
  }

  @override
  void drawRRect(RRect rrect, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawRRect(rrect, paint);
    });
  }

  @override
  void drawShadow(
      Path path, Color color, double elevation, bool transparentOccluder) {
    _add((HtmlCanvas canvas) {
      canvas.drawShadow(path, color, elevation, transparentOccluder);
    });
  }

  @override
  void drawVertices(Vertices vertices, BlendMode blendMode, Paint paint) {
    _add((Canvas canvas) {
      canvas.drawVertices(vertices, blendMode, paint);
    });
  }

  @override
  int getSaveCount() {
    return _saveCount;
  }

  @override
  void restore() {
    _saveCount--;
    _add((Canvas canvas) {
      canvas.restore();
    });
  }

  @override
  void rotate(double radians) {
    _add((Canvas canvas) {
      canvas.rotate(radians);
    });
  }

  @override
  void save() {
    _add((Canvas canvas) {
      canvas.save();
    });
  }

  @override
  void saveLayer(Rect bounds, Paint paint) {
    _saveCount++;
    _add((Canvas canvas) {
      canvas.saveLayer(bounds, paint);
    });
  }

  @override
  void scale(double sx, double sy) {
    _add((Canvas canvas) {
      canvas.scale(sx, sy);
    });
  }

  @override
  void skew(double sx, double sy) {
    _add((Canvas canvas) {
      canvas.skew(sx, sy);
    });
  }

  @override
  void transform(Float64List matrix4) {
    _add((Canvas canvas) {
      canvas.transform(matrix4);
    });
  }

  @override
  void translate(double dx, double dy) {
    _add((Canvas canvas) {
      canvas.translate(dx, dy);
    });
  }

  void _add(Command command) {
    commands.add(command);
  }
}
