import 'dart:html' as html;

import 'package:flur_html/flur.dart';
import 'package:flutter/widgets.dart';

class HtmlDragTarget extends StatefulWidget {
  final DragTarget definition;

  HtmlDragTarget(this.definition);

  createState() => new HtmlDragTargetState();
}

class HtmlDragTargetState extends State<HtmlDragTarget> {
  List accepted = [];
  List rejected = [];

  void readDataTransfer(html.DataTransfer value) {
    List items = [];
    // TODO: Correct implementation
    for (var dataTransferItem in value.items ?? const []) {
      items.add(dataTransferItem);
    }
    setState(() {
      final onWillAccept = this.widget.definition.onWillAccept;
      for (var item in items) {
        if (onWillAccept == null) {
          accepted.add(item);
        } else {
          if (onWillAccept(items)) {
            accepted.add(item);
          } else {
            rejected.add(item);
          }
        }
      }
    });
  }

  Widget build(BuildContext context) {
    final definition = widget.definition;
    final node = new html.DivElement();
    debugDomElement(context, node, definition);

    node.dropzone = "auto";
    final onAccept = definition.onAccept;
    final onWillAccept = definition.onWillAccept;
    if (onAccept != null || onWillAccept != null) {
      node.onDragOver.listen((html.MouseEvent event) {
        readDataTransfer(event.dataTransfer);
      });
      node.onDrop.listen((html.MouseEvent event) {
        readDataTransfer(event.dataTransfer);
        if (onAccept != null) {
          return onAccept(accepted);
        }
      });
    }
    final child = definition.builder(context, accepted, rejected);
    return new DomElementWidget(node, child: child);
  }
}
