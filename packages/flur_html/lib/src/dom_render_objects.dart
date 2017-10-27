import 'dart:async';
import 'dart:html' as dom;

import 'package:flutter/widgets.dart';
import 'package:flutter/rendering.dart';

/// Abstract superclass of all render objects in 'flur_html'.
abstract class DomRenderObject extends RenderObject {
  /// Underlying DOM node or null.
  dom.Node get domNode;

  /// Attaches DOM node into the parent DOM node.
  void attachDomNodeAfter(dom.Node parent, dom.Node before);

  /// Detaches DOM node from the parent DOM node.
  void detachDomNode();
}

class DomLeafRenderObject extends DomRenderObject {
  @override
  final dom.Node domNode;

  DomLeafRenderObject(this.domNode);

  @override
  void attachDomNodeAfter(dom.Node parentDomNode, dom.Node afterDomNode) {
    assert(parentDomNode != null);
    final beforeDomNode =
        afterDomNode == null ? parentDomNode.firstChild : afterDomNode.nextNode;
    parentDomNode.insertBefore(domNode, beforeDomNode);
  }

  @override
  void detachDomNode() {
    domNode.remove();
  }
}

/// Wraps a DOM node.
class DomElementRenderObject extends DomRenderObject {
  dom.Node _domNode;

  @override
  dom.Node get domNode => _domNode;

  /// Current event listeners. Optional.
  Map<String, ValueChanged<dom.Event>> eventListeners;
  Timer timer;

  @override
  void attachDomNodeAfter(dom.Node parentDomNode, dom.Node afterDomNode) {
    assert(parentDomNode != null);
    assert(_domNode != null);
    final beforeDomNode =
        afterDomNode == null ? parentDomNode.firstChild : afterDomNode.nextNode;
    parentDomNode.insertBefore(_domNode, beforeDomNode);
  }

  @override
  void detachDomNode() {
    _domNode.remove();
  }

  void setDomNode(dom.Node node,
      {Map<String, ValueChanged<dom.Event>> eventListeners,
      ValueChanged<dom.Node> onLayout}) {
    // Cancel possible existing timer
    this.timer?.cancel();

    // Patch node
    RenderObject ancestor = this.parent;
    while (true) {
      final current = ancestor;
      if (current is DomModificationRenderObject) {
        final onCreated = current.onBuild;
        if (onCreated != null) {
          onCreated(node);
        }
        ancestor = current.parent;
      } else {
        break;
      }
    }

    // Set node
    _domNode = node;

    // Set new event listeners
    this.eventListeners = eventListeners;

    // Set new timer
    if (onLayout == null) {
      this.timer = null;
    } else {}
  }

  DomElementRenderObject(dom.Node node,
      {Map<String, ValueChanged<dom.Event>> eventListeners,
      ValueChanged<dom.Node> onLayout}) {
    setDomNode(node, eventListeners: eventListeners, onLayout: onLayout);
  }
}

class DomModificationRenderObject extends RenderObjectWithChildMixin
    implements DomRenderObject {
  dom.Node parentDomNode, beforeDomNode;

  @override
  void adoptChild(RenderObject child) {
    if (child is DomRenderObject) {
      super.adoptChild(child);
      final parentDomNode = this.parentDomNode;
      if (parentDomNode != null) {
        child.attachDomNodeAfter(parentDomNode, beforeDomNode);
      }
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void dropChild(RenderObject child) {
    if (child is DomRenderObject) {
      super.dropChild(child);
      if (parentDomNode != null) {
        child.detachDomNode();
      }
    } else {
      throw new ArgumentError.value(child);
    }
  }

  @override
  void attachDomNodeAfter(dom.Node parentDomNode, dom.Node afterDomNode) {
    assert(parentDomNode != null);

    // Store parent node
    // If we later adopt a child, we will use this to attach the child tree.
    this.parentDomNode = parentDomNode;
    this.beforeDomNode = afterDomNode;

    // Apply to children, if any
    final child = this.child;
    if (child != null) {
      (child as DomRenderObject)
          .attachDomNodeAfter(parentDomNode, afterDomNode);
    }
  }

  @override
  void detachDomNode() {
    // Clear parent node
    this.parentDomNode = null;
    this.beforeDomNode = null;

    // Apply to children, if any
    final child = this.child;
    if (child != null) {
      (this.child as DomRenderObject).detachDomNode();
    }
  }

  @override
  dom.Node get domNode {
    dom.Node result;
    visitChildren((child) {
      result = (child as DomRenderObject).domNode;
    });
    return result;
  }

  ValueChanged<dom.Element> onBuild;

  DomModificationRenderObject({this.onBuild});
}
