import 'dart:async';
import 'dart:html' as dom;

import 'package:flur/flur.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'dom_element_widget.dart';
import 'dom_render_objects.dart';
import 'dom_text_widget.dart';

/// Implements rendering using our own virtual DOM, which reuses Flutter
/// rendering tree implementation.
class HtmlRenderTreePlugin extends RenderTreePlugin {
  final String _selector;

  HtmlRenderTreePlugin({String selector: "#flutter"})
      : this._selector = selector;

  dom.Element getRootElement() {
    final rootDomElement = dom.querySelector(_selector);
    if (rootDomElement == null) {
      throw new StateError(
          "Can't find HTML element '${_selector}' in the document.");
    }
    return rootDomElement;
  }

  final BuildOwner buildOwner = new BuildOwner();

  @override
  void runApp(Widget widget) {
    final rootDomNode = this.getRootElement();

    // Initialize root widget
    final rootWidget = new DomRootRenderObjectWidget(this, rootDomNode);

    // Initialize root element
    final rootElement = rootWidget.createElement();

    // Initialize BuildOwner
    WidgetsFlutterBinding.ensureInitialized();

    // Build the render tree
    buildOwner.buildScope(rootElement, () {
      rootElement.assignOwner(buildOwner);
      rootElement.mount(null, null);
    });

    buildOwner.onBuildScheduled = () {
      new Timer(const Duration(milliseconds: 1), () {
        buildOwner.buildScope(rootElement);
        buildOwner.finalizeTree();
      });
    };

    buildOwner.buildScope(rootElement, () {
      // Initialize child element
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      final element = widget.createElement();

      // Mount child element
      element.mount(rootElement, null);
      element.markNeedsBuild();
    });

    buildOwner.finalizeTree();
  }

  @override
  Widget buildTheatre({Stack onstage, List<Widget> offstage}) {
    final children = <Widget>[onstage];
    if (offstage != null) {
      for (var item in offstage) {
        children.add(new DomElementWidget.withTag("div",
            className: "flutter-offstage", children: [item]));
      }
    }
    return new DomElementWidget.withTag("div", children: children);
  }

  @override
  Widget buildHtmlElementWidget(
      BuildContext context, HtmlElementWidget widget) {
    assert(widget != null);

    // Create DOM element
    assert(widget != null);
    assert(widget.type != null);
    final domElement = new dom.Element.tag(widget.type);

    // HTML attributes
    widget.forEachAttribute((String name, String value) {
      domElement.setAttribute(name, value);
    });

    // HTML event handlers
    widget.forEachEventHandler((k, v) {
      assert(k is String);
      assert(v is Function);
      domElement.addEventListener(k, v);
    });

    // CSS style
    final domStyle = domElement.style;
    widget.forEachStyleProperty((k, v) {
      // Null value means no value.
      if (v == null) {
        return;
      }

      // Assert key and value are valid
      assert(k is String, "Style property is not string: ${k}");
      assert(v is String,
          "Style property '${k}' has a value of type ${v.runtimeType}");

      // Set property
      domStyle.setProperty(k, v);
    });
    final onDomElement = widget.onDomElement;
    if (onDomElement != null) {
      scheduleMicrotask(() {
        onDomElement(domElement);
      });
    }

    return new DomElementWidget(domElement, children: widget.children);
  }

  @override
  Widget buildErrorWidget(BuildContext context, ErrorWidget widget) {
    return new DomTextWidget(widget.message);
  }
}

class DomRootRenderObjectWidget extends RenderObjectWidget {
  final RenderTreePlugin renderTreePlugin;
  final dom.Element domElement;

  DomRootRenderObjectWidget(this.renderTreePlugin, this.domElement, {Key key})
      : super(key: key) {
    if (renderTreePlugin == null || domElement == null)
      throw new ArgumentError();
  }

  @override
  DomRootRenderObjectElement createElement() =>
      new DomRootRenderObjectElement(this);

  @override
  DomElementRenderObject createRenderObject(BuildContext context) {
    return new DomElementRenderObject(domElement);
  }
}

class DomRootRenderObjectElement extends RootRenderObjectElement {
  @override
  DomRootRenderObjectWidget get widget => super.widget;

  DomRootRenderObjectElement(DomRootRenderObjectWidget widget) : super(widget);

  @override
  void removeChildRenderObject(RenderObject child) {
    widget.domElement.children.clear();
  }

  @override
  void forgetChild(Element child) {
    widget.domElement.children.clear();
  }

  @override
  void moveChildRenderObject(RenderObject child, dynamic slot) {}

  @override
  void insertChildRenderObject(RenderObject child, dynamic slot) {
    if (child is DomElementRenderObject) {
      final domParent = widget.domElement;
      final domChild = child.domNode;
      while (domParent.firstChild != null) {
        domParent.firstChild.remove();
      }
      domParent.insertBefore(domChild, null);
    } else {
      throw new ArgumentError.value(child);
    }
  }
}
