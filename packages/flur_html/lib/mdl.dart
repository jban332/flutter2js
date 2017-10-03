library flur_html.mdl;

import 'package:flur/flur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'flur.dart';

class MdlUIPlugin extends HtmlUIPlugin {
  MdlUIStyle get style => const MdlUIStyle();

  @override
  Widget buildDrawer(BuildContext context, Drawer widget) {
    return new HtmlElementWidget("div",
        debugCreator: widget, children: [widget.child]);
  }
  @override
  Widget buildSnackBar(BuildContext context, SnackBar widget) {
    final children = [
      new HtmlElementWidget("div",
          className: "mdl-snackbar__text", children: [widget.content])
    ];
    if (widget.action != null) {
      children.add(new HtmlElementWidget("button",
          className: "mdl-snackbar__action",
          attributes: const {"type": "button"}));
    }
    return new HtmlElementWidget("div",
        debugCreator: widget,
        className: "mdl-snackbar", children: children);
  }

  @override
  Widget buildTabBar(BuildContext context, TabBar widget) {
    final buttons = <Widget>[];
    final tabs = <Widget>[];

    var i = -1;
    for (var item in widget.tabs) {
      i++;
      final tab = item as Tab;
      buttons.add(new HtmlElementWidget("a",
          className: "mdl-layout__tab",
          attributes: {"href": "#tab-${i}"},
          children: [
            tab.text,
          ]));
      tabs.add(new HtmlElementWidget("section",
          className: "mdl-layout__tab-panel",
          attributes: {"id": "#tab-${i}"},
          children: [
            tab.build(context),
          ]));
    }

    final header = new HtmlElementWidget("header", children: [
      new HtmlElementWidget("div",
          className: "mdl-layout__tab-bar mdl-js-ripple-effect",
          children: buttons)
    ]);

    final main = new HtmlElementWidget("main", children: tabs);
    return new HtmlElementWidget(
      "div",
      debugCreator: widget,
      className: "mdl-layout mdl-js-layout mdl-layout--fixed-header",
      children: [
        header,
        main,
      ],
    );
  }

  @override
  Widget buildTooltip(BuildContext context, Tooltip widget) {
    final id = generateHtmlElementId();
    final children = [
      new HtmlElementWidget("div",
          attributes: {"id": id}, children: [widget.child]),
      new HtmlElementWidget(
        "div",
        attributes: {
          "classNames": "mdl-tooltip",
          "data-mdl-for": id,
        },
        children: [widget.message],
      )
    ];
    return new HtmlElementWidget("div",
        debugCreator: widget, children: children);
  }
}

class MdlUIStyle extends HtmlUIStyle {
  const MdlUIStyle();

  @override
  String buildCard(BuildContext context, Card widget) {
    return "demo-card-wide mdl-card mdl-shadow--2dp";
  }

  @override
  String buildCheckbox(BuildContext context, Checkbox widget) {
    return "mdl-checkbox__input";
  }

  @override
  String buildChip(BuildContext context, Chip widget) {
    return "mdl-chip__text";
  }

  @override
  String buildDrawer(BuildContext context, Drawer widget) {
    return "mdl-layout__drawer";
  }

  @override
  String buildEditableText_textArea(BuildContext context, EditableText widget) {
    return "mdl-textfield__input";
  }

  @override
  String buildEditableText_wrapper(BuildContext context, EditableText widget) {
    return "mdl-textfield mdl-js-textfield";
  }

  @override
  String buildFlatButton(BuildContext context, FlatButton widget) {
    return "mdl-button mdl-js-button mdl-js-ripple-effect";
  }

  @override
  String buildListView(BuildContext context, ListView widget) {
    return "mdl-list";
  }

  @override
  String buildListView_item(BuildContext context, ListView widget) {
    return "mdl-list__item";
  }

  @override
  String buildCheckbox_wrapper(BuildContext context, Checkbox widget) {
    return "mdl-button mdl-js-button mdl-js-ripple-effect";
  }

  @override
  String buildFloatingActionButton(
      BuildContext context, FloatingActionButton widget) {
    return "mdl-button mdl-js-button mdl-button--fab mdl-button--colored";
  }

  @override
  String buildIconButton(BuildContext context, IconButton widget) {
    return "mdl-button mdl-js-button mdl-button--icon mdl-button--colored";
  }

  @override
  String buildMaterialButton(BuildContext context, MaterialButton widget) {
    return "mdl-button mdl-js-button mdl-button--raised";
  }

  @override
  String buildRadio(BuildContext context, Radio widget) {
    return "mdl-radio__button";
  }

  @override
  String buildRaisedButton(BuildContext context, RaisedButton widget) {
    return "mdl-button mdl-js-button mdl-button--raised";
  }

  @override
  String buildScaffold(BuildContext context, Scaffold widget) {
    return "mdl-layout mdl-js-layout";
  }

  @override
  String buildSwitch(BuildContext context, Switch widget) {
    return "mdl-switch__input";
  }

  @override
  String buildSwitch_wrapper(BuildContext context, Switch widget) {
    return "mdl-switch mdl-js-switch mdl-js-ripple-effect";
  }

  @override
  String buildTooltip(BuildContext context, Tooltip widget) {
    return "mdl-tooltip";
  }
}
