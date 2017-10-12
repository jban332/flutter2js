import 'dart:html' as html;

import 'package:flur_html/flur.dart';
import 'package:flutter/material.dart';

class DrawerControllerStateImpl extends DrawerControllerState {
  DrawerControllerStateImpl() : super.constructor();

  @override
  Widget build(BuildContext context) {
    final node = new html.DivElement();
    node.className = "mdl-layout__drawer";
    node.style.border = "1px solid black";
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  void close() {}

  @override
  void open() {}
}
