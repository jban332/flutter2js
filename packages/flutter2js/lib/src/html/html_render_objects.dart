import 'dart:html' as html;

import 'package:flutter/rendering.dart';
import 'package:flutter2js/core.dart';
import 'package:flutter2js/html.dart';

class HtmlRenderNode extends RenderObject {
  final html.Element htmlElement;

  HtmlRenderNode(this.htmlElement);

  @override
  Rect get paintBounds {
    return flutterRectFromHtmlRect(htmlElement.getBoundingClientRect());
  }

  @override
  Rect get semanticBounds {
    return flutterRectFromHtmlRect(htmlElement.getBoundingClientRect());
  }

  @override
  void debugAssertDoesMeetConstraints() {}

  @override
  void paint(PaintingContext context, Offset offset) {
    final platform = PlatformPlugin.current as BrowserPlatformPlugin;
    final root = platform.rootHtmlElement;
    final element = this.htmlElement;
    final style = element.style;
    style.position = "absolute";
    style.left = "${offset.dx}px";
    style.top = "${offset.dy}px";
    if (!identical(element, root)) {
      element.remove();
      root.insertBefore(element, null);
    }
  }

  @override
  void performLayout() {}

  @override
  void performResize() {}
}
