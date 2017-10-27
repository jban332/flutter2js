import 'dart:html' as dom;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'dom_render_objects.dart';

/// Mutates DOM element built by the child.
class DomModificationWidget extends SingleChildRenderObjectWidget {
  final ValueChanged<dom.Element> onBuild;

  DomModificationWidget({Key key, @required Widget child, this.onBuild})
      : super(key: key, child: child);

  @override
  RenderObjectWithChildMixin createRenderObject(BuildContext context) {
    return new DomModificationRenderObject(onBuild: onBuild);
  }

  @override
  void updateRenderObject(BuildContext context,
      DomModificationRenderObject renderObject) {
    super.updateRenderObject(context, renderObject);
    renderObject.onBuild = onBuild;
  }
}