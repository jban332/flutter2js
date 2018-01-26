import 'dart:html' as html;

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';

import '../logging.dart';

class HtmlParagraph extends Object with HasDebugName implements ui.Paragraph {
  final ui.ParagraphStyle paragraphStyle;
  final List<HtmlParagraphBox> boxes;
  final List<HtmlParagraphLine> lines = [];
  final String debugName;
  double _canvasWidth;
  double _canvasHeight;

  HtmlParagraph(this.paragraphStyle, this.boxes) : this.debugName = allocateDebugName( "Paragraph") {
    logConstructor(this);
  }

  @override
  double get alphabeticBaseline {
    throw new UnimplementedError();
  }

  @override
  bool get didExceedMaxLines {
    final maxLines = paragraphStyle.maxLines;
    return maxLines != null && lines.length > maxLines;
  }

  @override
  double get height {
    return _canvasHeight;
  }

  @override
  double get ideographicBaseline {
    throw new UnimplementedError();
  }

  @override
  double get maxIntrinsicWidth {
    var maxWidth = 0.0;
    var width = 0.0;
    for (var box in boxes) {
      if (box.text == "\n") {
        width = 0.0;
      } else {
        width += box.width;
        if (width > maxWidth) {
          maxWidth = width;
        }
      }
    }
    return maxWidth;
  }

  @override
  double get minIntrinsicWidth {
    throw new UnimplementedError();
  }

  @override
  double get width {
    return _canvasWidth;
  }

  void draw(html.CanvasRenderingContext2D context, Offset offset) {
    logMethod(this, "draw", arg0:context, arg1:offset);
    _HtmlTextStyle previousStyle;
    for (var box in boxes) {
      final style = box.style;
      if (!identical(style, previousStyle)) {
        style.apply(context);
        previousStyle = style;
      }
      context.fillText(box.text, offset.dx + box.left, offset.dy + box.top);
    }
  }

  @override
  List<ui.TextBox> getBoxesForRange(int start, int end) {
    var i = 0;
    var startBox = 0;
    for (var box in boxes) {
      if (i >= start) {
        break;
      }
      i += box.text.length;
      startBox++;
    }
    i = 0;
    var endBox = 0;
    for (var box in boxes) {
      if (i >= end) {
        break;
      }
      i += box.text.length;
      endBox++;
    }
    return boxes.sublist(startBox, endBox);
  }

  @override
  ui.TextPosition getPositionForOffset(Offset offset) {
    final offsetX = offset.dx;
    final offsetY = offset.dy;
    var minDistance = null;
    var minIndex = null;
    var i = 0;
    for (var box in boxes) {
      final centerX = (box.left + box.width / 2);
      final centerY = (box.top + box.height / 2);
      final distance =
          new Offset(offsetX - centerX, offsetY - centerY).distanceSquared;
      if (minDistance == null || distance < minDistance) {
        minDistance = distance;
        minIndex = i;
      }
      i += box.text.length;
    }
    return new ui.TextPosition(offset: minIndex);
  }

  @override
  List<int> getWordBoundary(int offset) {
    throw new UnimplementedError();
  }

  @override
  void layout(ui.ParagraphConstraints constraints) {
    this.lines.clear();
    final lineWidthConstraint = constraints.width;
    final lineHeightMultiplier = paragraphStyle.lineHeight ?? 1.0;
    var currentLeft = 0.0;
    var currentTop = 0.0;
    var currentLineHeight = 0.0;
    var canvasWidth = 0.0;
    var canvasHeight = lineHeightMultiplier;
    var boxIndex = -1;
    var lineStartBoxIndex = 0;
    for (var box in boxes) {
      boxIndex++;

      // If the box can be added to the current line
      if (currentLeft < lineWidthConstraint && box.text != "\n") {
        // Set current box position
        box.left = currentLeft;
        box.top = currentTop;

        // Increment line width
        currentLeft += box.width;
        if (currentLeft > canvasWidth) {
          canvasWidth = currentLeft;
        }

        // Expand line height if needed
        final boxHeight = box.height;
        if (boxHeight > currentLineHeight) {
          currentLineHeight = boxHeight;
        }

        // Next box
        continue;
      }

      // Add previous line
      lines.add(new HtmlParagraphLine(lineStartBoxIndex, boxIndex,
          width: currentLeft));
      lineStartBoxIndex = boxIndex;

      // Go to the beginning of the new line
      currentLeft = 0.0;
      currentTop += lineHeightMultiplier * currentLineHeight;

      // Set current box position
      box.left = currentLeft;
      box.top = currentTop;

      // Increment line width
      currentLeft = box.width;
      currentLineHeight = box.height;
    }

    // Add last line
    lines.add(
        new HtmlParagraphLine(lineStartBoxIndex, boxIndex, width: currentLeft));
    canvasHeight += currentLineHeight;

    // Store size
    this._canvasWidth = canvasWidth;
    this._canvasHeight = canvasHeight;

    // Re-align if needed
    switch (paragraphStyle.textAlign ?? ui.TextAlign.left) {
      case ui.TextAlign.center:
        final boxes = this.boxes;
        for (var line in lines) {
          final start = line.startBox;
          final end = line.endBox;
          final diff = (canvasWidth - line.width) / 2;
          if (diff != 0.0) {
            for (var i = start; i < end; i++) {
              boxes[i].left += diff;
            }
          }
        }
        break;
      case ui.TextAlign.right:
        final boxes = this.boxes;
        for (var line in lines) {
          final start = line.startBox;
          final end = line.endBox;
          final diff = (canvasWidth - line.width);
          if (diff != 0.0) {
            for (var i = start; i < end; i++) {
              boxes[i].left += diff;
            }
          }
        }
        break;
      case ui.TextAlign.justify:
        final boxes = this.boxes;
        for (var line in lines) {
          final start = line.startBox;
          final end = line.endBox;
          final diff = (canvasWidth - line.width);
          if (diff != 0.0) {
            final multiplierStep = 1.0 / (end - start - 1);
            var multiplier = 0.0;
            for (var i = start; i < end; i++) {
              boxes[i].left += multiplier * diff;
              multiplier += multiplierStep;
            }
          }
        }
        break;
      default:
        break;
    }
  }
}

class HtmlParagraphBox implements ui.TextBox {
  final _HtmlTextStyle style;
  final String text;
  final double width;
  final double height;

  @override
  double left = 0.0;

  @override
  double top = 0.0;

  @override
  final TextDirection direction = TextDirection.ltr;

  HtmlParagraphBox(this.style, this.text, {this.width, this.height});

  @override
  double get bottom => top + height;

  @override
  double get end => right;

  @override
  double get right => left + width;

  @override
  double get start => left;

  @override
  Rect toRect() {
    return new ui.Rect.fromLTRB(left, top, right, bottom);
  }
}

class HtmlParagraphBuilder extends Object with HasDebugName implements ui.ParagraphBuilder {
  final String debugName;
  final ui.ParagraphStyle _paragraphStyle;
  final List<HtmlParagraphBox> _boxes = [];
  final html.CanvasRenderingContext2D _context =
      new html.CanvasElement().context2D;
  _HtmlTextStyle _textStyle;

  HtmlParagraphBuilder(ui.ParagraphStyle style) : this._paragraphStyle = style, this.debugName = allocateDebugName( "ParagraphBuilder") {
    logConstructor(this);
    this._textStyle = new _HtmlTextStyle(
        null,
        new ui.TextStyle(
            fontFamily: style.fontFamily,
            fontSize: style.fontSize,
            fontStyle: style.fontStyle,
            fontWeight: style.fontWeight));
  }

  void addText(String value) {
    logMethod(this, "addText", arg0:value);
    // For each rune
    for (var rune in value.runes) {
      final runeString = new String.fromCharCode(rune);

      // Calculate metrics
      final metrics = _context.measureText(runeString);

      // Calculate width
      final style = _textStyle;
      var width = metrics.width + (style.style.letterSpacing ?? 0.0);
      switch (runeString) {
        case "\t":
          width = 2 * width;
          break;
        case "\n":
          width = 0.0;
          break;
      }

      // Calculate height
      final height = (metrics.actualBoundingBoxAscent ?? 0.0) +
          (metrics.actualBoundingBoxDescent ?? 0.0);

      // Add box
      _boxes.add(new HtmlParagraphBox(style, runeString,
          width: width, height: height));
    }
  }

  @override
  HtmlParagraph build() {
    final result = new HtmlParagraph(_paragraphStyle, _boxes);
    logMethod(this, "build", result:result);
    return result;
  }

  @override
  void pop() {
    _textStyle = _textStyle.parent;
  }

  @override
  void pushStyle(ui.TextStyle style) {
    final newStyle = new _HtmlTextStyle(this._textStyle, style);
    newStyle.apply(_context);
    _textStyle = newStyle;
  }
}

class HtmlParagraphLine {
  final int startBox;
  final int endBox;
  final double width;

  HtmlParagraphLine(this.startBox, this.endBox, {this.width: 0.0});
}

class _HtmlTextStyle {
  final _HtmlTextStyle parent;
  final ui.TextStyle style;

  _HtmlTextStyle(this.parent, ui.TextStyle style)
      : this.style = _combineStyle(parent?.style, style);

  void apply(html.CanvasRenderingContext2D context) {
    final style = this.style;
    {
      final value = style.color ?? const Color.fromARGB(0, 0, 0, 0);
      if (value != null) {
        context.setFillColorRgb(value.red, value.green, value.blue);
      }
    }
    final fontSize = "${style.fontSize ?? 16}px";
    final fontFamily = style.fontFamily ?? "sans-serif";
    final font = "${fontSize} ${fontFamily}";
    context.font = font;
  }

  static ui.TextStyle _combineStyle(ui.TextStyle parent, ui.TextStyle child) {
    if (parent == null) return child;
    return new ui.TextStyle(
      color: child.color ?? parent.color,
      decoration: child.decoration ?? parent.decoration,
      decorationColor: child.decorationColor ?? parent.decorationColor,
      decorationStyle: child.decorationStyle ?? parent.decorationStyle,
      fontWeight: child.fontWeight ?? parent.fontWeight,
      fontStyle: child.fontStyle ?? parent.fontStyle,
      textBaseline: child.textBaseline ?? parent.textBaseline,
      fontFamily: child.fontFamily ?? parent.fontFamily,
      fontSize: child.fontSize ?? parent.fontSize,
      letterSpacing: child.letterSpacing ?? parent.letterSpacing,
      wordSpacing: child.wordSpacing ?? parent.letterSpacing,
      height: child.height ?? parent.height,
    );
  }
}
