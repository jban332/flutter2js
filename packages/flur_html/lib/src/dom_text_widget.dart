import 'dart:html' as dom;

import 'package:flutter/widgets.dart';

import 'dom_render_objects.dart';

/// Inserts text into the DOM tree.
class DomTextWidget extends LeafRenderObjectWidget {
  final String value;

  const DomTextWidget(this.value);

  @override
  DomLeafRenderObject createRenderObject(BuildContext context) {
    return new DomLeafRenderObject(new dom.Text(value));
  }

  @override
  void updateRenderObject(
      BuildContext context, DomLeafRenderObject renderObject) {
    renderObject.domNode.text = value;
  }
}
