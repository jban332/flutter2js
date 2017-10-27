import 'dart:html' as dom;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'dom_render_objects.dart';
import 'dom_text_widget.dart';
import 'helpers.dart';

/// Inserts a HTML element to the DOM tree.
abstract class DomElementWidget extends MultiChildRenderObjectWidget {
  /// Constructs a widget that will replace any existing DOM element.
  ///
  /// See also:
  ///   * [DomElementWidget.withTag]
  factory DomElementWidget(dom.Element node,
      {Key key, Widget child, Iterable children}) = _DomElementWidget;

  /// Constructs a widget that will try to update any existing DOM element.
  ///
  /// See also:
  ///   * [DomElementWidget]
  factory DomElementWidget.withTag(String name,
      {Key key,
      String className,
      Widget creator,
      Map<String, String> attributes,
      Map<String, String> style,
      Map<String, ValueChanged<dom.Event>> eventListeners,
      ValueChanged<dom.Element> onLayout,
      Widget child,
      Iterable children}) {
    // Handle 'child' helper.
    if (children == null && child != null) {
      children = [child];
    }

    /// Return
    return new _DomElementBuilderWidget(name,
        creator: creator,
        attributes: attributes,
        style: style,
        eventListeners: eventListeners,
        key: key,
        children: children);
  }
}

/// Delivers a HTML DOM node to the rendering tree.
class _DomElementBuilderWidget extends MultiChildRenderObjectWidget implements DomElementWidget {
  final String tagName;
  final String className;
  final Widget creator;
  final Map<String, String> attributes;
  final Map<String, String> style;
  final Map<String, ValueChanged<dom.Event>> eventListeners;
  final ValueChanged<dom.Element> onLayout;

  _DomElementBuilderWidget(this.tagName,
      {Key key,
      List<Widget> children,
      this.className,
      this.creator,
      this.attributes,
      this.style,
      this.eventListeners,
      this.onLayout})
      : super(key: key, children: children);

  @override
  DomRenderObjectElement createElement() =>
      new DomRenderObjectElement(this, onLayout: onLayout);

  @override
  DomElementRenderObject createRenderObject(BuildContext context) {
    final node = new dom.Element.tag(tagName);

    // Update attributes
    final attributes = this.attributes;
    if (attributes != null) {
      attributes.forEach((k, v) {
        node.setAttribute(k, v);
      });
    }

    // Update className
    final className = this.className;
    if (className != null) {
      node.className = className;
    }

    // Update creator
    debugDomElement(context, node, creator);

    // Update style
    final style = this.style;
    if (style != null) {
      final nodeStyle = node.style;
      style.forEach((k, v) {
        nodeStyle.setProperty(k, v);
      });
    }

    // Update event handlers
    final eventListeners = this.eventListeners;
    if (eventListeners != null) {
      eventListeners.forEach((k, v) {
        node.addEventListener(k, v);
      });
    }
    return new DomElementRenderObject(node)..eventListeners = eventListeners;
  }

  /// Updates [DomElementRenderObject] by replacing the DOM node with a new one that has children of the old DOM node.
  /// This method will be invoked by [updateRenderObject] if the tag names are different.
  void updateRenderObjectWithCreated(
      BuildContext context, DomElementRenderObject renderObject) {
    // Move children from old DOM node to the new one
    final newDomNode = createRenderObject(context).domNode;
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
    renderObject.setDomNode(newDomNode);
  }

  /// Updates [DomElementRenderObject] by replacing all attributes, style properties, and event listeners.
  @override
  void updateRenderObject(
      BuildContext context, DomElementRenderObject renderObject) {
    var node = renderObject.domNode as dom.Element;

    // Ensure that the tag name is correct
    if (node.tagName != this.tagName) {
      updateRenderObjectWithCreated(context, renderObject);
      return;
    }

    // Update attributes
    final attributes = this.attributes;
    if (attributes == null || attributes.isEmpty) {
      // Remove all attributes
      node.attributes.forEach((k, v) {
        node.setAttribute(k, null);
      });
    } else {
      // Set all attributes
      attributes.forEach((k, v) {
        if (node.getAttribute(k) != v) {
          node.setAttribute(k, v);
        }
      });

      // Remove attributes that don't exist anymore
      node.attributes.forEach((k, v) {
        if (!attributes.containsKey(key)) {
          node.setAttribute(k, null);
        }
      });
    }

    // Update class name
    final className = this.className;
    if (className != null) {
      node.className = className;
    }

    // Update creator
    debugDomElement(context, node, creator);

    // Update style
    final style = this.style;
    final nodeStyle = node.style;
    if (style == null || style.isEmpty) {
      // Remove all style properties
      for (var i = 0; i < nodeStyle.length; i++) {
        nodeStyle.removeProperty(nodeStyle.item(i));
      }
    } else {
      // Set all style properties
      style.forEach((k, v) {
        if (nodeStyle.getPropertyValue(k) != v) {
          nodeStyle.setProperty(k, v);
        }
      });

      // Remove style properties that don't exist anymore
      final nodeStyleLength = nodeStyle.length;
      for (var i = 0; i < nodeStyleLength; i++) {
        final k = nodeStyle.item(i);
        if (!style.containsKey(k)) {
          nodeStyle.removeProperty(k);
        }
      }
    }

    // Update event handlers
    final eventListeners = this.eventListeners;
    final oldEventListeners =
        renderObject.eventListeners ?? const <String, ValueChanged>{};
    renderObject.eventListeners = null;
    if (eventListeners == null || eventListeners.isEmpty) {
      // Remove all event handlers
      oldEventListeners.forEach((k, v) {
        node.removeEventListener(k, v);
      });
    } else {
      // Set all event handlers
      eventListeners.forEach((k, v) {
        if (oldEventListeners[k] != v) {
          node.addEventListener(k, v);
        }
      });
      // Remove event handlers that dont' exist anymore
      oldEventListeners.forEach((k, v) {
        if (!eventListeners.containsKey(k)) {
          node.removeEventListener(k, v);
        }
      });
    }
  }
}

class _DomElementWidget extends MultiChildRenderObjectWidget
    implements DomElementWidget {
  final dom.Node node;
  final ValueChanged<dom.Node> onLayout;

  _DomElementWidget(this.node,
      {Key key, Widget child, Iterable children, this.onLayout})
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
  DomRenderObjectElement createElement() =>
      new DomRenderObjectElement(this, onLayout: onLayout);

  @override
  RenderObject createRenderObject(BuildContext context) {
    final renderObject =
        new DomElementRenderObject(this.node, onLayout: this.onLayout);
    return renderObject;
  }

  @override
  void updateRenderObject(
      BuildContext context, DomElementRenderObject renderObject) {
    // Move children from old DOM node to the new one
    final newDomNode = this.node;
    final oldDomNode = renderObject.domNode;

    // If identical, we don't need to do anything
    if (identical(newDomNode, oldDomNode)) {
      return;
    }

    // If both are elements
    if (newDomNode is dom.Element && oldDomNode is dom.Element) {
      // Move children from old element to new element
      var next = oldDomNode.firstChild;
      while (next != null) {
        final current = next;
        next = current.nextNode;
        current.remove();
        newDomNode.insertBefore(current, null);
      }
    }

    // Replace old node with new node
    oldDomNode.replaceWith(newDomNode);
    renderObject.setDomNode(newDomNode);
  }
}

class DomRenderObjectElement extends MultiChildRenderObjectElement {
  @override
  DomElementRenderObject get renderObject => super.renderObject;

  /// Invoked when DOM element is mounted.
  final ValueChanged<dom.Element> onLayout;

  DomRenderObjectElement(Widget widget, {this.onLayout}) : super(widget);

  @override
  void removeChildRenderObject(RenderObject child) {
    if (child is DomRenderObject) {
      // We shouldn't invoke super method because our RenderObject
      // assumption is different from superclass.
      //
      // Detach DOM tree
      child.detachDomNode();
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
      // Detach DOM tree
      child.detachDomNode();

      // Attach DOM tree
      final newParent = this.renderObject.domNode;
      final newBefore = slot == null ? null : (slot.renderObject as DomRenderObject).domNode;
      child.attachDomNodeAfter(newParent, newBefore);
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
      // Attach DOM tree
      final newParent = this.renderObject.domNode;
      final newBefore = slot == null ? null : (slot.renderObject as DomRenderObject).domNode;
      child.attachDomNodeAfter(newParent, newBefore);
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    // Super method
    super.mount(parent, newSlot);

    // onLayout
    final onLayout = this.onLayout;
    if (onLayout != null) {
//      new Timer(const Duration(milliseconds: 1), () {
//        onLayout(renderObject.domNode);
//      });
    }
  }

  @override
  void unmount() {
    // Super method
    super.unmount();
  }
}
