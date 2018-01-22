import 'dart:typed_data';

import 'package:flutter/ui.dart';
import 'dart:html' as html;
import 'html_picture.dart';
import '../css_helpers.dart';

typedef void SceneCommand(html.Element element);

class HtmlSceneBuilder implements SceneBuilder {
  HtmlScene _scene = new HtmlScene();
  List<SceneCommand> _commands = [];

  void _push(SceneCommand command) {
    _commands.add(command);
  }

  void _unsupported(String name) {
    _commands.add((element) {});
  }

  @override
  void pushTransform(Float64List matrix4) {
    _unsupported("pushTransform");
  }

  @override
  Scene build() {
    final scene = new HtmlScene();
    _scene = null;
    return scene;
  }

  @override
  void setCheckerboardOffscreenLayers(bool checkerboard) {
    _unsupported("setCheckerboardOffscreenLayers");
  }

  @override
  void setCheckerboardRasterCacheImages(bool checkerboard) {
    _unsupported("setCheckerboardCacheImages");
  }

  @override
  void setRasterizerTracingThreshold(int frameInterval) {
    _unsupported("setRasterizerTracingThreshold");
  }

  // Fuchsia-only feature
  @override
  void addChildScene(
      {Offset offset: Offset.zero,
      double width: 0.0,
      double height: 0.0,
      SceneHost sceneHost,
      bool hitTestable: true}) {
    _unsupported("addChildScene");
  }

  @override
  void addTexture(int textureId,
      {Offset offset: Offset.zero, double width: 0.0, double height: 0.0}) {
    final element = html.querySelector("#flutter-texture-${textureId}");
    _scene.addChild(offset, element, width: width, height: height);
  }

  @override
  void addPicture(Offset offset, Picture picture,
      {bool isComplexHint: false, bool willChangeHint: false}) {
    _scene.addChild(offset, (picture as HtmlPicture).toHtmlElement());
  }

  @override
  void addPerformanceOverlay(int enabledOptions, Rect bounds) {
    _unsupported("addPerformanceOverlay");
  }

  @override
  void pop() {
    _commands.removeLast();
  }

  @override
  void pushPhysicalShape({Path path, double elevation, Color color}) {
    _unsupported("pushPhysicalShape");
  }

  @override
  void pushShaderMask(Shader shader, Rect maskRect, BlendMode blendMode) {
    _unsupported("pushShaderMask");
  }

  @override
  void pushBackdropFilter(ImageFilter filter) {
    _unsupported("pushBackdropFilter");
  }

  @override
  void pushColorFilter(Color color, BlendMode blendMode) {
    _push((element) {
      element.style.backgroundColor = cssFromColor(color);
      element.style.mixBlendMode = cssFromBlendMode(blendMode);
    });
  }

  @override
  void pushOpacity(int alpha) {
    _push((element) {
      element.style.opacity = "${alpha/255}";
    });
  }

  @override
  void pushClipPath(Path path) {
    _unsupported("pushClipPath");
  }

  @override
  void pushClipRRect(RRect rrect) {
    _unsupported("pushClipRRect");
  }

  @override
  void pushClipRect(Rect rect) {
    _unsupported("pushClipRect");
  }
}

class HtmlScene extends Scene {
  static int _nextId = 0;
  final int id = _nextId++;
  final html.Element htmlElement = new html.DivElement()
    ..setAttribute("data-kind", "Scene");

  HtmlScene() {
    final style = htmlElement.style;
    style.position = "fixed";
    style.width = "auto";
    style.height = "auto";
    style.left = "0px";
    style.right = "0px";
    style.top = "0px";
    style.bottom = "0px";
  }

  void addChild(Offset offset, html.Element element,
      {double width, double height}) {
    if (element == null) {
      throw new ArgumentError.notNull("element");
    }
    if (element.parent != null) {
      throw new ArgumentError.value(
          element, "element", "Element should not have parent");
    }
    final style = element.style;
    if (width != null) {
      style.width = "${width}px";
    }
    if (height != null) {
      style.height = "${height}px";
    }
    this.htmlElement.insertBefore(element, null);
  }

  @override
  void dispose() {}

  String toString() {
    return "Scene #${id} (${htmlElement.children.length} children)";
  }
}
