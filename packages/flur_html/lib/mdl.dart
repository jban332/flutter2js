library flur_html.mdl;

import 'dart:html' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'flur.dart';

class MdlUIPlugin extends HtmlUIPlugin {
  @override
  Widget buildSnackBar(BuildContext context, SnackBar widget) {
    final children = [
      new DomElementWidget.withTag("div",
          className: "mdl-snackbar__text", children: [widget.content])
    ];
    if (widget.action != null) {
      children.add(new DomElementWidget.withTag("button",
          className: "mdl-snackbar__action",
          attributes: const {"type": "button"}));
    }
    return new DomElementWidget.withTag("div",
        creator: widget, className: "mdl-snackbar", children: children);
  }

  @override
  Widget buildChip(BuildContext context, Chip widget) {
    final node = new html.DivElement();
    debugDomElement(context, node, widget);

    final children = [];
    children.add(new DomElementWidget.withTag("span", children: [
      textFromWidget(widget.label),
    ]));
    if (widget.onDeleted != null) {
      final actionButton = new html.AnchorElement()
        ..className = "mdl-chip__action"
        ..onClick.listen((_) {
          widget.onDeleted();
        });
      children.add(
          new DomElementWidget(actionButton, child: new Icon(Icons.cancel)));
    }
    return new DomElementWidget(node);
  }

  @override
  Widget buildListTile(BuildContext context, ListTile widget) {
    //
    final primaryChildren = <Widget>[];
    final leading = widget.leading;
    if (leading != null) {
      primaryChildren
          .add(elementWithClassName("i", "mdl-list__item-avatar", leading));
    }
    final title = widget.title;
    if (title != null) {
      primaryChildren.add(title);
    }
    final subtitle = widget.subtitle;
    if (subtitle != null) {
      primaryChildren.add(
          elementWithClassName("span", "mdl-list__item-sub-title", subtitle));
    }
    final secondaryChildren = <Widget>[];
    final trailing = widget.trailing;
    if (trailing != null) {
      secondaryChildren.add(trailing);
    }

    final itemNode = new html.Element.li();
    itemNode.className = "mdl-list__item mdl-list__item--two-line";
    final item = new DomElementWidget(itemNode, children: [
      new DomElementWidget.withTag("span",
          className: "mdl-list__item-primary-content",
          children: primaryChildren),
      new DomElementWidget.withTag("span",
          className: "mdl-list__item-secondary-content",
          children: secondaryChildren),
    ]);

    final onTap = widget.onTap;
    if (onTap != null) {
      itemNode.style.cursor = "pointer";
      itemNode.style.touchAction = "manipulation";
      itemNode.onClick.listen((domEvent) {
        onTap();
      });
    }
    final onLongPress = widget.onLongPress;
    if (onLongPress != null) {
      return new ErrorWidget(
          "Long presses are not supported by ${this.runtimeType}.");
    }

    final node = new html.Element.ul();
    debugDomElement(context, node, widget);
    node.className = "mdl-list";
    return new DomElementWidget(node, child: item);
  }

  @override
  Widget buildTooltip(BuildContext context, Tooltip widget) {
    final node = new html.DivElement();
    debugDomElement(context, node, widget);

    final id = generateHtmlElementId();
    final tooltipDom = new html.DivElement()
      ..className = "mdl-tooltip"
      ..setAttribute("data-mdl-for", id);
    final tooltip =
        new DomElementWidget(tooltipDom, children: [widget.message]);

    final children = [
      new DomElementWidget.withTag("div",
          attributes: {"id": id}, children: [widget.child]),
      tooltip,
    ];
    return new DomElementWidget.withTag("div",
        creator: widget, children: children);
  }

  @override
  Widget buildFlatButton(BuildContext context, FlatButton widget) {
    final built = super.buildFlatButton(context, widget);
    return _styled(built, "mdl-button mdl-js-button mdl-js-ripple-effect");
  }

  @override
  Widget buildMaterialButton(BuildContext context, MaterialButton widget) {
    final built = super.buildMaterialButton(context, widget);
    return _styled(built, "mdl-button mdl-js-button mdl-button--raised");
  }

  @override
  Widget buildRaisedButton(BuildContext context, RaisedButton widget) {
    final built = super.buildRaisedButton(context, widget);
    return _styled(built, "mdl-button mdl-js-button mdl-button--raised");
  }

  @override
  Widget buildSwitch(BuildContext context, Switch widget) {
    final built = super.buildSwitch(context, widget);
    return _styled(built, "mdl-switch__input");
  }

  @override
  Widget buildCheckbox(BuildContext context, Checkbox widget) {
    var built = super.buildCheckbox(context, widget);
    built = _styled(built, "mdl-checkbox__input");
    return _wrapper(
        "div", "mdl-switch mdl-js-switch mdl-js-ripple-effect", built);
  }

  @override
  Widget buildIconButton(BuildContext context, IconButton widget) {
    final built = super.buildIconButton(context, widget);
    return _styled(
        built, "mdl-button mdl-js-button mdl-button--icon mdl-button--colored");
  }

  @override
  Widget buildFloatingActionButton(
      BuildContext context, FloatingActionButton widget) {
    final built = super.buildFloatingActionButton(context, widget);
    return _styled(
        built, "mdl-button mdl-js-button mdl-button--fab mdl-button--colored");
  }

  Widget _styled(Widget widget, String className) {
    final domElement = widget as DomElementWidget;
    domElement.node.className = className;
    return domElement;
  }

  Widget _wrapper(String tagName, String className, Widget child) {
    return new DomElementWidget.withTag(tagName,
        className: className, children: [child]);
  }
}
