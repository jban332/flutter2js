import 'dart:html' as html;

import 'package:flur_html/flur.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../helpers.dart';

Widget build(BuildContext context, CustomMultiChildLayout widget) {
  final node = new html.DivElement();
  debugDomElement(context, node, widget);

  // Wrap each child in a 'div'
  final wrappedChildren = <Widget>[];
  final Map<Object, html.Element> idToNode = <Object, html.Element>{};
  for (var child in widget.children) {
    if (child is LayoutId) {
      final childWrapperNode = new html.DivElement();
      childWrapperNode.style
        ..position = "absolute"
        ..left = "0"
        ..top = "0";
      idToNode[child.id] = childWrapperNode;
      wrappedChildren
          .add(new DomElementWidget(childWrapperNode, child: child.child));
    } else {
      throw new ArgumentError.value(child);
    }
  }

  // Wait until we have size information available
  measureNodeSize(node, (Size parentSize) {
    final parent = getElementSize(node.parent);
    if (node.offsetWidth == 0) {
      node.style.width = cssFromLogicalPixels(parent.width);
    }
    if (node.offsetHeight == 0) {
      node.style.height = cssFromLogicalPixels(parent.height);
    }

    final helper = new MultiChildLayoutDelegateHelperImpl(widget.delegate);
    idToNode.forEach((id, node) {
      helper.children[id] = node;
    });
    helper.performLayout(parentSize);
  });

  return new DomElementWidget(node, children: wrappedChildren);
}

Size getElementSize(html.Element element) {
  final width = element.offsetWidth.toDouble();
  var height = element.offsetHeight.toDouble();
  while (width == 0.0) {
    element = element.parent;
    if (element == null) {
      break;
    }
    height = element.offsetWidth.toDouble();
  }
  while (height == 0.0) {
    element = element.parent;
    if (element == null) {
      break;
    }
    height = element.offsetHeight.toDouble();
  }
  return new Size(width, height);
}

class MultiChildLayoutDelegateHelperImpl
    extends MultiChildLayoutDelegateHelper {
  final Map<Object, html.Element> children = <Object, html.Element>{};

  MultiChildLayoutDelegateHelperImpl(MultiChildLayoutDelegate delegate)
      : super(delegate);

  @override
  bool hasChild(Object childId) {
    return children.containsKey(childId);
  }

  @override
  void positionChild(Object childId, Offset offset) {
    final element = children[childId];
    final parentSize = getElementSize(element.parent);
    final style = element.style;
    style.position = "absolute";
    style.left = cssFromLogicalPixels(offset.dx * parentSize.width);
    style.top = cssFromLogicalPixels(offset.dy * parentSize.height);
  }

  @override
  Size layoutChild(Object childId, BoxConstraints constraints) {
    final element = children[childId];
    final style = element.style;
    {
      var width = constraints.minWidth;
      if (width != 0.0) {
        style.minWidth = cssFromLogicalPixels(width);
      }
    }

    {
      var height = constraints.minHeight;
      if (height != 0.0) {
        style.minHeight = cssFromLogicalPixels(height);
      }
    }
    {
      var width = constraints.maxWidth;
      if (width != double.INFINITY) {
        style.maxWidth = cssFromLogicalPixels(width);
      }
    }
    {
      var height = constraints.maxHeight;
      if (height != double.INFINITY) {
        style.maxHeight = cssFromLogicalPixels(height);
      }
    }
    final parentSize = getElementSize(element.parent);
    constraints =
        constraints.tighten(width: parentSize.width, height: parentSize.height);

    final size = delegate.getSize(constraints);
    style.width = cssFromLogicalPixels(size.width);
    style.height = cssFromLogicalPixels(size.height);
    return size;
  }
}
