import 'dart:html' as html;

import 'package:flutter/rendering.dart';

Rect flutterRectFromHtmlRect(html.Rectangle rect) {
  return new Rect.fromLTWH(rect.left, rect.top, rect.width, rect.height);
}

Size flutterSizeFromHtmlRect(html.Rectangle rect) {
  return new Size(rect.width, rect.height);
}
