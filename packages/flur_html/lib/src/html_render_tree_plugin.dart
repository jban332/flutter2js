import 'dart:html' as dom;

import 'package:flur/flur.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

/// Implements rendering using our own virtual DOM, which reuses Flutter
/// rendering tree implementation.
class HtmlRenderTreePlugin extends RenderTreePlugin {
  final String _selector;

  HtmlRenderTreePlugin({String selector: "#flur"}) : this._selector = selector;

  dom.Element getRootElement() {
    final rootDomElement = dom.querySelector(_selector);
    if (rootDomElement == null) {
      throw new StateError(
          "Can't find HTML element '${_selector}' in the document.");
    }
    return rootDomElement;
  }

  @override
  void runApp(Widget widget) {
    final rootDomElement = this.getRootElement();

    // Initialize root widget
    final rootWidget = new _RootWidget(this, rootDomElement);

    // Initialize root element
    final rootElement = rootWidget.createElement();

    // Initialize BuildOwner
    BuildOwner buildOwner;
    buildOwner = new BuildOwner(onBuildScheduled: () {
      // TODO: This was a quick hack. Should we use Flutter pipelining instead?
      scheduleMicrotask(() {
        buildOwner.buildScope(rootElement);
        buildOwner.finalizeTree();
      });
    });
    buildOwner.lockState(() {
      rootElement.assignOwner(buildOwner);
      rootElement.mount(null, null);
    });
    buildOwner.buildScope(rootElement, () {
      // Initialize child element
      // ignore: INVALID_USE_OF_PROTECTED_MEMBER
      final element = widget.createElement();

      // Mount child element
      element.mount(rootElement, null);
    });

    // Build the render tree
    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();
  }

  @override
  Widget buildHtmlElementWidget(
      BuildContext context, HtmlElementWidget widget) {
    return new _HtmlElementWidget(widget);
  }

  @override
  Widget buildErrorWidget(BuildContext context, ErrorWidget widget) {
    return new _HtmlTextWidget(widget.message);
  }
}

class _RootWidget extends RenderObjectWidget {
  final RenderTreePlugin renderTreePlugin;
  final dom.Element domElement;

  _RootWidget(this.renderTreePlugin, this.domElement) {
    assert(renderTreePlugin != null);
    assert(domElement != null);
  }

  @override
  _RootElement createElement() => new _RootElement(this);

  @override
  _HtmlRenderObject createRenderObject(BuildContext context) {
    assert(domElement != null);
    return new _HtmlRenderObject.fromDom(domElement);
  }
}

class _RootElement extends RootRenderObjectElement {
  @override
  _RootWidget get widget => super.widget;
  _RootElement(_RootWidget widget) : super(widget);

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
    if (child is _HtmlRenderObject) {
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

class _HtmlElementWidget extends MultiChildRenderObjectWidget {
  final HtmlElementWidget widget;

  _HtmlElementWidget(HtmlElementWidget widget)
      : this.widget = widget,
        super(children: _getChildWidgets(widget.children)) {
    assert(widget != null);
  }

  static List<Widget> _getChildWidgets(Iterable children,
      [List<Widget> result]) {
    if (children == null) return const <Widget>[];
    if (result == null) result = <Widget>[];
    for (var item in children) {
      if (item == null) {
        // Do nothing
      } else if (item is String) {
        result.add(new _HtmlTextWidget(item));
      } else if (item is Widget) {
        result.add(item);
      } else if (item is Iterable) {
        _getChildWidgets(item, result);
      } else {
        result.add(new _HtmlTextWidget(item.toString()));
      }
    }
    return result;
  }

  @override
  _HtmlElement createElement() => new _HtmlElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return new _HtmlRenderObject.fromHtmlElementWidget(this);
  }

  @override
  void updateRenderObject(
      BuildContext context, _HtmlRenderObject renderObject) {
    renderObject.replaceWithHtmlElementWidget(this);
  }
}

class _HtmlElement extends MultiChildRenderObjectElement {
  @override
  _HtmlRenderObject get renderObject => super.renderObject;

  @override
  _HtmlElementWidget get widget => super.widget;

  _HtmlElement(_HtmlElementWidget widget) : super(widget);

  @override
  void forgetChild(Element child) {
    (child.renderObject as _HtmlRenderObject)?.domNode?.remove();
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    if (child is _HtmlRenderObject) {
      child.domNode.remove();
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void moveChildRenderObject(RenderObject child, Element slot) {
    if (child is _HtmlRenderObject) {
      final parentDom = this.renderObject.domNode;
      final childDom = child.domNode;
      childDom.remove();
      if (slot==null) {
        parentDom.insertBefore(childDom, null);
      } else {
        final afterDom = (slot.renderObject as _HtmlRenderObject)?.domNode;
        parentDom.insertBefore(childDom, afterDom?.nextNode);
      }
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void insertChildRenderObject(RenderObject child, Element slot) {
    if (child is _HtmlRenderObject) {
      final parentDom = this.renderObject.domNode;
      final childDom = child.domNode;
      if (slot==null) {
        parentDom.insertBefore(childDom, null);
      } else {
        final afterDom = (slot.renderObject as _HtmlRenderObject)?.domNode;
        parentDom.insertBefore(childDom, afterDom?.nextNode);
      }
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    // Invoke super method
    super.mount(parent, newSlot);

    // Callback
    final onDomElement = widget.widget.onDomElement;
    if (onDomElement != null) {
      final domNode = renderObject.domNode;
      scheduleMicrotask(() {
        onDomElement(domNode);
      });
    }
  }

  @override
  void unmount() {
    // Invoke super method
    super.unmount();

    // Callback
    final onDomElement = widget.widget.onDomElement;
    if (onDomElement != null) {
      scheduleMicrotask(() {
        onDomElement(null);
      });
    }
  }
}

class _HtmlTextWidget extends LeafRenderObjectWidget {
  final String value;
  _HtmlTextWidget(this.value);

  @override
  _HtmlRenderObject createRenderObject(BuildContext context) {
    return new _HtmlRenderObject.fromText(value);
  }

  @override
  void updateRenderObject(
      BuildContext context, _HtmlRenderObject renderObject) {
    (renderObject.domNode as dom.Text).text = value;
  }
}

class _HtmlRenderObject extends RenderObject {
  dom.Node domNode;

  _HtmlRenderObject.fromDom(this.domNode) {
    assert(domNode!=null);
  }

  _HtmlRenderObject.fromText(String value) {
    assert(value!=null);
    this.domNode = new dom.Text(value);
  }

  _HtmlRenderObject.fromHtmlElementWidget(_HtmlElementWidget widget) {
    replaceWithHtmlElementWidget(widget);
  }

  void replaceWithHtmlElementWidget(_HtmlElementWidget internalWidget) {
    final widget = internalWidget.widget;

    // Create DOM element
    assert(widget!=null);
    assert(widget.type!=null);
    final domElement = new dom.Element.tag(widget.type);

    // Props
    final domAttributes = domElement.attributes;
    widget.forEachAttribute((k, v) {
      assert(k is String);
      assert(v is String);
      domAttributes[k] = v.toString();
    });

    widget.forEachEventHandler((k, v) {
      assert(k is String);
      assert(v is Function);
      domElement.addEventListener(k, v);
    });

    // Style
    final domStyle = domElement.style;
    widget.forEachStyleProperty((k, v) {
      assert(k is String);
      assert(v is String);
      try {
        domStyle.setProperty(k, v);
      } catch (e) {
        //print("Error building '${widget.type}' ('${widget.debugCreator.toString()}') CSS '${k}': '${v}' (${v.runtimeType})");
        rethrow;
      }
    });

    // If old DOM node exists
    final oldDomNode = this.domNode;
    if (oldDomNode != null) {
      // Move children from old DOM node to the new one
      var next = oldDomNode.firstChild;
      while (next != null) {
        final current = next;
        next = current.nextNode;
        current.remove();
        domElement.insertBefore(current, null);
      }

      // Replace DOM node
      oldDomNode.replaceWith(domElement);
    }

    // Assign
    this.domNode = domElement;
  }

  @override
  String toStringShort() {
    final domNode = this.domNode;
    if (domNode is dom.Element)
      return "[HtmlRenderObject:element:${domNode.tagName}]";
    return "[HtmlRenderObject:${domNode.runtimeType.toString()}]";
  }
}
