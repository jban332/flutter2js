import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../css_helpers.dart';
import '../logging.dart';
import 'html_picture.dart';

typedef void SceneCommand(html.Element element);

class HtmlScene extends Scene with HasDebugName {
  final String debugName;
  final html.Element htmlElement = new html.DivElement()
    ..setAttribute("data-kind", "Scene");

  HtmlScene() : this.debugName = allocateDebugName( "Scene") {
    logConstructor(this);
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

  @override
  String toString() => "${super.toString()}[children=${htmlElement.children.length}]";
}

class HtmlSceneBuilder extends Object with HasDebugName implements SceneBuilder {
  final String debugName;
  HtmlScene _scene = new HtmlScene();
  List<SceneCommand> _commands = [];

  HtmlSceneBuilder() : this.debugName = allocateDebugName( "SceneBuilder") {
    logConstructor(this);
  }

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
  void addPerformanceOverlay(int enabledOptions, Rect bounds) {
    _unsupported("addPerformanceOverlay");
  }

  @override
  void addPicture(Offset offset, Picture picture,
      {bool isComplexHint: false, bool willChangeHint: false}) {
    logMethod(this, "addPicture", arg0:offset, arg1:picture);
    final size = window.physicalSize;
    final element = (picture as HtmlPicture).toHtmlElement((size.width-offset.dx).clamp(0, size.width).toInt(), (size.height-offset.dy).clamp(0, size.height).toInt());
    _scene.addChild(offset, element);
  }

  @override
  void addTexture(int textureId,
      {Offset offset: Offset.zero, double width: 0.0, double height: 0.0}) {
    final element = html.querySelector("#flutter-texture-${textureId}");
    _scene.addChild(offset, element, width: width, height: height);
  }

  @override
  Scene build() {
    logMethod(this, "build");
    final scene = this._scene;
    _scene = null;
    return scene;
  }

  @override
  void pop() {
    _commands.removeLast();
  }

  @override
  void pushBackdropFilter(ImageFilter filter) {
    _unsupported("pushBackdropFilter");
  }

  // Fuchsia-only feature
  @override
  void pushClipPath(Path path) {
    _unsupported("pushClipPath");
  }

  @override
  void pushClipRect(Rect rect) {
    _unsupported("pushClipRect");
  }

  @override
  void pushClipRRect(RRect rrect) {
    _unsupported("pushClipRRect");
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
  void pushPhysicalShape({Path path, double elevation, Color color}) {
    _unsupported("pushPhysicalShape");
  }

  @override
  void pushShaderMask(Shader shader, Rect maskRect, BlendMode blendMode) {
    _unsupported("pushShaderMask");
  }

  @override
  void pushTransform(Float64List matrix4) {
    _unsupported("pushTransform");
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

  void _push(SceneCommand command) {
    _commands.add(command);
  }

  void _unsupported(String name) {
    _commands.add((element) {});
  }
}
