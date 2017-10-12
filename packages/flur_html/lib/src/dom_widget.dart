import 'dart:html' as dom;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Delivers a HTML text node to the rendering tree.
class DomTextWidget extends LeafRenderObjectWidget {
  final String value;

  const DomTextWidget(this.value);

  @override
  DomRenderObject createRenderObject(BuildContext context) {
    return new DomRenderObject(new dom.Text(value));
  }

  @override
  void updateRenderObject(BuildContext context, DomRenderObject renderObject) {
    (renderObject.domNode as dom.Text).text = value;
  }
}

/// Delivers a HTML DOM node to the rendering tree.
class DomElementWidget extends MultiChildRenderObjectWidget {
  final dom.Element node;

  factory DomElementWidget.withTag(String name,
      {Key key,
      String className,
      Object creator,
      Map<String, String> attributes,
      Widget child,
      Iterable children}) {
    // Handle 'child' helper.
    if (children == null && child != null) {
      children = [child];
    }

    // Create DOM element
    final node = new dom.Element.tag(name);

    // Set debugging properties
    assert(() {
      if (creator != null) {
        node.setAttribute("data-flutter-name", creator.runtimeType.toString());
      }
      return true;
    });

    // Set className
    if (className != null) {
      node.className = className;
    }

    // Set other attributes
    if (attributes != null) {
      attributes.forEach((String name, String value) {
        node.setAttribute(name, value);
      });
    }

    // Return
    return new DomElementWidget(node, key: key, children: children);
  }

  DomElementWidget(this.node, {Key key, Widget child, Iterable children})
      : super(key: key, children: _iterableToWidgetList(children ?? [child])) {
    assert(node != null);
  }

  static List<Widget> _iterableToWidgetList(Iterable children,
      [List<Widget> result]) {
    // Handle empty input
    if (children == null) return const <Widget>[];

    // Create result list if not given
    if (result == null) result = <Widget>[];

    // Add all children
    for (var item in children) {
      if (item == null) {
        // Do nothing
      } else if (item is String) {
        result.add(new DomTextWidget(item));
      } else if (item is Widget) {
        result.add(item);
      } else if (item is Iterable) {
        _iterableToWidgetList(item, result);
      } else {
        result.add(new DomTextWidget(item.toString()));
      }
    }
    return result;
  }

  @override
  DomRenderObjectElement createElement() => new DomRenderObjectElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return new DomRenderObject(node);
  }

  @override
  void updateRenderObject(BuildContext context, DomRenderObject renderObject) {
    // Move children from old DOM node to the new one
    final newDomNode = this.node;
    final oldDomNode = renderObject.domNode;
    if (newDomNode is dom.Element && oldDomNode is dom.Element) {
      var next = oldDomNode.firstChild;
      while (next != null) {
        final current = next;
        next = current.nextNode;
        current.remove();
        newDomNode.insertBefore(current, null);
      }
    }

    // Replace DOM node
    oldDomNode.replaceWith(newDomNode);
    renderObject.domNode = newDomNode;
  }
}

class DomRenderObjectElement extends MultiChildRenderObjectElement {
  @override
  DomRenderObject get renderObject => super.renderObject;

  DomRenderObjectElement(DomElementWidget widget) : super(widget);

  @override
  DomElementWidget get widget => super.widget;

  @override
  void forgetChild(Element child) {
    super.forgetChild(child);

    // Modify DOM
    final childRenderObject = child.renderObject as DomRenderObject;
    if (childRenderObject != null) {
      childRenderObject.domNode.remove();
    }
  }

  @override
  void removeChildRenderObject(RenderObject child) {
    if (child is DomRenderObject) {
      // We shouldn't invoke super method because our RenderObject
      // assumption is different from superclass.
      //
      // Modify DOM
      child.domNode.remove();
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void moveChildRenderObject(RenderObject child, Element slot) {
    if (child is DomRenderObject) {
      // We shouldn't invoke super method because our RenderObject
      // assumption is different from superclass.
      //
      // Modify DOM
      final parentNode = this.renderObject.domNode;
      final childNode = child.domNode;
      childNode.remove();
      if (slot == null) {
        parentNode.insertBefore(childNode, null);
      } else {
        final afterDom = (slot.renderObject as DomRenderObject)?.domNode;
        parentNode.insertBefore(childNode, afterDom?.nextNode);
      }
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void insertChildRenderObject(RenderObject child, Element slot) {
    if (child is DomRenderObject) {
      // We shouldn't invoke super method because our RenderObject
      // assumption is different from superclass.
      //
      // Modify DOM
      final parentNode = this.renderObject.domNode;
      final childNode = child.domNode;
      if (slot == null) {
        parentNode.insertBefore(childNode, null);
      } else {
        final afterNode = (slot.renderObject as DomRenderObject)?.domNode;
        parentNode.insertBefore(childNode, afterNode?.nextNode);
      }
    } else {
      throw new ArgumentError.value(child);
    }
  }
}

class DomRenderObject extends RenderObject {
  dom.Node domNode;

  DomRenderObject(this.domNode) {
    assert(domNode != null);
  }

  @override
  String toStringShort() {
    final domNode = this.domNode;
    if (domNode is dom.Element)
      return "[HtmlRenderObject:element:${domNode.tagName}]";
    return "[HtmlRenderObject:${domNode.runtimeType.toString()}]";
  }
}
