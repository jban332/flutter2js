import 'dart:async';
import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flur/js.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:flur_html/flur.dart';

import 'helpers.dart';
import 'html_ui_style.dart';
import 'internal/custom_paint.dart';
import 'internal/overlay_state.dart';

abstract class HtmlUIPlugin extends UIPlugin {
  int _gid = 0;

  final HtmlUIStyle style = new HtmlUIStyle();

  @override
  Widget buildAlign(BuildContext context, Align widget) {
    final style = <String, String>{
      "border": "0",
      "padding": "0",
      "margin": "0",
    };
    final offset = widget.alignment.resolve(TextDirection.ltr);
    {
      final v = offset.x;
      if (v == 0.0) {
        style["width"] = "100%";
        style["text-align"] = "right";
      } else if (v == 0.5) {
        style["width"] = "100%";
        style["text-align"] = "center";
      } else if (v == 1.0) {
        style["width"] = "100%";
        style["text-align"] = "right";
      } else {
        // This is a more complicated case
      }
    }
    {
      final v = offset.y;
      if (v == 0.0) {
        style["height"] = "100%";
        style["vertical-align"] = "top";
      } else if (v == 0.5) {
        style["height"] = "100%";
        style["vertical-align"] = "middle";
      } else if (v == 1.0) {
        style["height"] = "100%";
        style["vertical-align"] = "bottom";
      } else {
        // This is a more complicated case
      }
    }
    return _styled(debugCreator: widget, style: style, child: widget.child);
  }

  @override
  Widget buildBanner(BuildContext context, Banner widget) {
    return widget.child;
  }

  @override
  Widget buildBottomNavigationBar(
      BuildContext context, BottomNavigationBar widget) {
    final className = this.style.buildBottomNavigationBar(context, widget);
    final children = widget.items.map((item) {
      return new HtmlElementWidget("div", children: [
        item.icon,
        item.title,
      ]);
    }).toList();
    return new HtmlElementWidget("div",
        debugCreator: widget, className: className, children: children);
  }

  @override
  Widget buildCard(BuildContext context, Card widget) {
    final className = this.style.buildCard(context, widget);
    return new HtmlElementWidget("div",
        debugCreator: widget, className: className, children: [widget.child]);
  }

  @override
  Widget buildCheckbox(BuildContext context, Checkbox widget) {
    final props = {"type": "checkbox", "checked": widget.value};
    if (widget.onChanged == null) {
      props["disabled"] = true;
    } else {
      props["onChange"] = _checkedValueChanged(widget.onChanged);
    }
    return new HtmlElementWidget("input",
        debugCreator: widget, attributes: props);
  }

  @override
  Widget buildChip(BuildContext context, Chip widget) {
    final className = this.style.buildChip(context, widget);
    final children = [];
    children.add(new HtmlElementWidget("span", debugCreator: null, children: [
      textFromWidget(widget.label),
    ]));
    if (widget.onDeleted != null) {
      children.add(new HtmlElementWidget("a", debugCreator: null, attributes: {
        "classNames": "mdl-chip__action",
      }, eventHandlers: {
        "click": (node) {
          widget.onDeleted();
        },
      }, children: [
        new Icon(Icons.cancel),
      ]));
    }
    return new HtmlElementWidget("div",
        debugCreator: widget, className: className, children: children);
  }

  @override
  Widget buildConstrainedBox(BuildContext context, ConstrainedBox widget) {
    return new HtmlElementWidget("div",
        debugCreator: widget, children: [widget.child]);
  }

  Widget buildFractionallySizedBox(
      BuildContext context, FractionallySizedBox widget) {
    return new HtmlElementWidget("div",
        debugCreator: widget, children: [widget.child]);
  }

  Widget buildFractionalTranslation(
      BuildContext context, FractionalTranslation widget) {
    return new HtmlElementWidget("div",
        debugCreator: widget, children: [widget.child]);
  }

  @override
  Widget buildCupertinoNavigationBar(
      BuildContext context, CupertinoNavigationBar widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildCupertinoScaffold(
      BuildContext context, CupertinoScaffold widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildCustomPaint(BuildContext context, CustomPaint widget) {
    return new HtmlCustomPaint(widget);
  }

  @override
  Widget buildDayPicker(BuildContext context, DayPicker widget) {
    final className = this.style.buildDayPicker(context, widget);
    return new HtmlElementWidget("input",
        debugCreator: widget,
        className: className,
        attributes: const {"type": "date"});
  }

  @override
  Widget buildDropdownButton(BuildContext context, DropdownButton widget) {
    final children = widget.items.map((item) {
      var props;
      if (item.value == widget.value) {
        props = {"selected": true};
      }
      return new HtmlElementWidget("option",
          debugCreator: null, attributes: props, children: [item.child]);
    }).toList();
    return new HtmlElementWidget("select",
        debugCreator: widget,
        className: this.style.buildDropdownButton(context, widget),
        children: children);
  }

  @override
  Widget buildEditableText(BuildContext context, EditableText widget) {
    final props = <String, Object>{
      "type": "text",
    };
    if (widget.onChanged != null) {
      props["onChange"] = (JsValue event) {
        final target =
            (event.unsafeValue as html.Event).target as html.TextAreaElement;
        widget.onChanged(target.value);
      };
    }
    final textArea = new HtmlElementWidget("textarea",
        debugCreator: widget,
        className: this.style.buildEditableText_textArea(context, widget),
        attributes: props);
    return new HtmlElementWidget("div",
        debugCreator: widget,
        className: this.style.buildEditableText_wrapper(context, widget),
        children: [textArea]);
  }

  @override
  Widget buildFlatButton(BuildContext context, FlatButton widget) {
    final className = style.buildFlatButton(context, widget);
    final props = {};
    final onClick = _onClick(widget.onPressed);
    if (onClick == null) {
      props["disabled"] = "";
    } else {
      props["onClick"] = onClick;
    }
    return new HtmlElementWidget("button",
        debugCreator: widget, className: className, children: [widget.child]);
  }

  @override
  Widget buildFlex(BuildContext context, Flex widget) {
    final style = <String, String>{};
    style["display"] = "flex";
    style["border"] = "1px solid blue";

    // Direction
    {
      String cssValue;
      switch (widget.direction) {
        case Axis.vertical:
          cssValue = "column";
          break;
        case Axis.horizontal:
          cssValue = "row";
          break;
      }
      style["flex-direction"] = cssValue;
    }

    // Main axis alignment
    {
      String cssValue;
      switch (widget.mainAxisAlignment) {
        case MainAxisAlignment.start:
          cssValue = "start";
          break;
        case MainAxisAlignment.end:
          cssValue = "end";
          break;
        case MainAxisAlignment.center:
          cssValue = "center";
          break;
          break;
        case MainAxisAlignment.spaceAround:
          break;
        case MainAxisAlignment.spaceBetween:
          break;
        case MainAxisAlignment.spaceEvenly:
          break;
      }
      style["justifyContent"] = cssValue;
    }

    // Cross axis alignment
    {
      String cssValue;
      switch (widget.crossAxisAlignment) {
        case CrossAxisAlignment.start:
          cssValue = "start";
          break;
        case CrossAxisAlignment.end:
          cssValue = "end";
          break;
        case CrossAxisAlignment.center:
          cssValue = "center";
          break;
        case CrossAxisAlignment.stretch:
          cssValue = "stretch";
          break;
        case CrossAxisAlignment.baseline:
          break;
      }
      style["align-items"] = cssValue;
    }
    return new HtmlElementWidget("div",
        debugCreator: widget, style: style, children: widget.children);
  }

  @override
  Widget buildFloatingActionButton(
      BuildContext context, FloatingActionButton widget) {
    final className = this.style.buildFloatingActionButton(context, widget);
    final props = <String, String>{};
    final eventHandlers = <String, ValueChanged>{
      "click": (event) {
        widget.onPressed();
      },
    };
    return new HtmlElementWidget("button",
        debugCreator: widget,
        className: className,
        attributes: props,
        eventHandlers: eventHandlers,
        children: [widget.child]);
  }

  @override
  Widget buildGridView(BuildContext context, GridView widget) {
    final rows = [];
    final tbody =
        new HtmlElementWidget("tbody", debugCreator: null, children: rows);
    return new HtmlElementWidget("table",
        debugCreator: widget, children: [tbody]);
  }

  @override
  Widget buildIcon(BuildContext context, Icon widget) {
    final iconData = widget.icon;
    return new HtmlElementWidget("span",
        debugCreator: widget,
        className: "material-icons",
        children: [new String.fromCharCode(iconData.codePoint)]);
  }

  @override
  Widget buildIconButton(BuildContext context, IconButton widget) {
    final className = this.style.buildIconButton(context, widget);
    final attributes = <String, String>{};
    final eventHandlers = <String, ValueChanged>{};
    final onPressed = widget.onPressed;
    if (onPressed == null) {
      attributes["disabled"] = "";
    } else {
      eventHandlers["click"] = (event) {
        onPressed();
      };
    }
    final style = <String, String>{};
    final color = widget.color;
    if (color != null) {
      style["color"] = colorToCss(color);
    }
    final icon = (widget.icon as Icon);
    final iconWidget = new HtmlElementWidget("i",
        debugCreator: widget,
        className: "material-icons",
        children: [new String.fromCharCode(icon.icon.codePoint)]);
    return new HtmlElementWidget("button",
        debugCreator: widget,
        className: className,
        attributes: attributes,
        style: style,
        eventHandlers: eventHandlers,
        children: [iconWidget]);
  }

  @override
  Widget buildImage(BuildContext context, Image widget) {
    final attributes = {
      "src": (widget.image as NetworkImage).url,
    };
    return new HtmlElementWidget("img",
        debugCreator: widget, attributes: attributes);
  }

  @override
  Widget buildLimitedBox(BuildContext context, LimitedBox widget) {
    final style = <String, String>{
      "padding": "0",
      "margin": "0",
      "max-height": "${widget.maxHeight}",
      "min-width": "${widget.maxWidth}",
    };
    return new HtmlElementWidget("div",
        debugCreator: widget, style: style, children: [widget.child]);
  }

  @override
  Widget buildListView(BuildContext context, ListView widget) {
    final itemClassName = this.style.buildListView_item(context, widget);
    final items = widget.buildSlivers(context).map((item) {
      return new HtmlElementWidget("div",
          debugCreator: null, className: itemClassName);
    }).toList();
    return new HtmlElementWidget("div",
        debugCreator: widget,
        className: this.style.buildListView(context, widget),
        children: items);
  }

  @override
  Widget buildMaterialButton(BuildContext context, MaterialButton widget) {
    final className = this.style.buildMaterialButton(context, widget);
    final props = {};
    final children = [];
    return new HtmlElementWidget("button",
        debugCreator: widget,
        className: className,
        attributes: props,
        children: children);
  }

  @override
  Widget buildMonthPicker(BuildContext context, MonthPicker widget) {
    final className = this.style.buildMonthPicker(context, widget);
    final attributes = {"type": "month"};
    return new HtmlElementWidget("input",
        debugCreator: widget, className: className, attributes: attributes);
  }

  @override
  Widget buildNavigationToolbar(
      BuildContext context, NavigationToolbar widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildOffstage(BuildContext context, Offstage widget) {
    List<Widget> children;
    assert(() {
      children = [widget.child];
      return true;
    }());
    return new HtmlElementWidget("div", debugCreator: widget, children: children);
  }

  @override
  Widget buildPadding(BuildContext context, Padding widget) {
    final padding = widget.padding;
    final horizontal = padding.horizontal ?? 0;
    final vertical = padding.vertical ?? 0;
    final style = <String, String>{
      "margin": "0",
      "padding-left": "${horizontal}",
      "padding-right": "${horizontal}",
      "padding-top": "${vertical}",
      "padding-bottom": "${vertical}",
    };
    return _styled(debugCreator: widget, style: style, child: widget.child);
  }

  @override
  Widget buildPopupMenuButton(BuildContext context, PopupMenuButton widget) {
    return widget.child;
  }

  @override
  Widget buildPositioned(BuildContext context, Positioned widget) {
    return widget.child;
  }

  @override
  Widget buildProgressIndicator(
      BuildContext context, ProgressIndicator widget) {
    return null;
  }

  @override
  Widget buildRadio(BuildContext context, Radio widget) {
    final className = this.style.buildRadio(context, widget);
    final attributes = {
      "type": "radio",
    };
    return new HtmlElementWidget("input",
        debugCreator: widget, className: className, attributes: attributes);
  }

  @override
  Widget buildRaisedButton(BuildContext context, RaisedButton widget) {
    final b = new HtmlElementWidgetBuilder(widget, "button");
    b.className = style.buildRaisedButton(context, widget);
    b.setVoidCallback("click", widget.onPressed);
    b.addWidget(widget.child);
    return b.build();
  }

  @override
  Widget buildRichText(BuildContext context, RichText widget) {
    return new Text(widget.text.toPlainText());
  }


  @override
  Widget buildSliverList(BuildContext context, SliverList widget) {
    final children = <Widget>[];
    final delegate = widget.delegate;
    final count = delegate.estimatedChildCount;
    for (var i=0;i<count;i++) {
      final child = delegate.build(context, i);
      if (child==null) {
        break;
      }
      children.add(child);
    }
    return new HtmlElementWidget("div", debugCreator: widget, children:children);
  }

  @override
  Widget buildSliverAppBar(BuildContext context, SliverAppBar widget) {
    final children = <Widget>[];
    final actions = widget.actions;
    if (actions!=null) {
      for (var action in actions) {
        children.add(action);
      }
    }
    return new HtmlElementWidget("div", debugCreator: widget, children:children);
  }

  @override
  Widget buildScaffold(BuildContext context, Scaffold widget) {
    final className = this.style.buildScaffold(context, widget);

    final children = <Widget>[];
    {
      final child = widget.floatingActionButton;
      if (child != null) {
        children.add(child);
      }
    }
    {
      final child = widget.appBar;
      if (child != null) {
        children.add(child);
      }
    }
    {
      final child = widget.drawer;
      if (child != null) {
        children.add(child);
      }
    }
    {
      final child = widget.persistentFooterButtons;
      if (child != null) {
        children.add(new HtmlElementWidget("div",
            debugCreator: widget, children: child));
      }
    }
    {
      final child = widget.bottomNavigationBar;
      if (child != null) {
        children.add(child);
      }
    }
    {
      final child = widget.body;
      if (child != null) {
        children.add(child);
      }
    }
    final style = <String, String>{};
    {
      final backgroundColor = widget.backgroundColor;
      if (backgroundColor != null) {
        style["background"] = colorToCss(backgroundColor);
      }
    }
    return new HtmlElementWidget("div",
        debugCreator: widget,
        className: className,
        style: style,
        children: children);
  }

  @override
  Widget buildScrollView(BuildContext context, ScrollView widget) {
    // ignore: INVALID_USE_OF_PROTECTED_MEMBER
    final children = widget.buildSlivers(context);
    return new HtmlElementWidget("div",
        debugCreator: widget, children: children);
  }

  @override
  Widget buildSizedBox(BuildContext context, SizedBox widget) {
    final style = <String, String>{
      "padding": "0",
      "margin": "0",
      "height": "${widget.height}",
      "width": "${widget.width}",
    };
    return new HtmlElementWidget("div",
        debugCreator: widget, style: style, children: [widget]);
  }

  @override
  Widget buildSlider(BuildContext context, Slider widget) {
    final className = style.buildSlider(context, widget);
    final props = <String, Object>{"style": "slider"};
    if (widget.onChanged == null) {
      props["disabled"] = "";
    } else {
      props["onChange"] = (JsValue $this, JsValue event) {
        final input = event.get("target").unsafeValue as html.InputElement;
        widget.onChanged(input.valueAsNumber);
      };
    }
    return new HtmlElementWidget("input",
        debugCreator: widget, className: className, attributes: props);
  }

  @override
  Widget buildSnackBar(BuildContext context, SnackBar widget) {
    return null;
  }

  @override
  Widget buildStack(BuildContext context, Stack widget) {
    final style = <String, String>{
      "position": "absolute",
    };
    final children = widget.children.map((item) {
      // TODO: Positioning
      return item;
    }).toList();
    return new HtmlElementWidget("div",
        debugCreator: widget, style: style, children: children);
  }

  @override
  Widget buildStatefulWidget(BuildContext context, StatefulWidget widget) {
    return widget;
  }

  @override
  Widget buildStepper(BuildContext context, Stepper widget) {
    final className = style.buildStepper(context, widget);
    final props = <String, Object>{"style": "slider"};
    if (widget.onStepTapped == null) {
      props["disabled"] = "";
    } else {
      props["onChange"] = ($this, html.Event event) {
        widget
            .onStepTapped(int.parse((event.target as html.InputElement).value));
      };
    }
    return new HtmlElementWidget("input",
        debugCreator: widget, className: className, attributes: props);
  }

  @override
  Widget buildSwitch(BuildContext context, Switch widget) {
    final className = style.buildSwitch(context, widget);
    final props = <String, Object>{"style": "checkbox"};
    if (widget.onChanged == null) {
      props["disabled"] = "";
    } else {
      props["onChange"] = ($this, JsValue event) {};
    }
    return new HtmlElementWidget("input",
        debugCreator: widget, className: className, attributes: props);
  }

  @override
  Widget buildTab(BuildContext context, Tab widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildTabBar(BuildContext context, TabBar widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildTabBarView(BuildContext context, TabBarView widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildTable(BuildContext context, Table widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildText(BuildContext context, Text widget) {
    return new HtmlElementWidget("div",
        debugCreator: widget, children: [widget.data]);
  }

  @override
  Widget buildTextField(BuildContext context, TextField widget) {
    return new HtmlElementWidget("type",
        debugCreator: widget, attributes: const {"type": "text"});
  }

  @override
  Widget buildTooltip(BuildContext context, Tooltip widget) {
    return widget.child;
  }

  @override
  Widget buildWrap(BuildContext context, Wrap widget) {
    return new HtmlElementWidget("div",
        debugCreator: widget, children: widget.children);
  }

  @override
  Widget buildYearPicker(BuildContext context, YearPicker widget) {
    final className = this.style.buildYearPicker(context, widget);
    final props = <String, Object>{"type": "number"};
    final min = widget?.firstDate?.year;
    if (min != null) {
      props["min"] = min;
    }
    final max = widget?.lastDate?.year;
    if (max != null) {
      props["max"] = max;
    }
    return new HtmlElementWidget("input",
        debugCreator: widget, className: className, attributes: props);
  }

  @override
  OverlayState createOverlayState(Overlay widget) {
    return new HtmlOverlayState();
  }

  /// Generates unique ID for an HTML element
  String generateHtmlElementId({Widget widget}) => "gid${_gid++}";

  @override
  Future<T> showMenu<T>(
      {@required BuildContext context,
      RelativeRect position,
      @required List<PopupMenuEntry<T>> items,
      T initialValue,
      double elevation: 8.0}) async {
    throw new UnimplementedError();
  }

  String textFromWidget(Widget widget) {
    if (widget is Text)
      return widget.data;
    else if (widget is RichText)
      return widget.text.toPlainText();
    else
      return "";
  }

  Function _checkedValueChanged(ValueChanged<bool> f) {
    if (f == null) {
      return null;
    }
    return (JsValue event) {
      final target =
          (event.unsafeValue as html.Event).target as html.InputElement;
      f(target.checked);
    };
  }

  Function _onClick(VoidCallback callback) {
    if (callback == null) {
      return null;
    }
    return ($this, event) {
      callback();
    };
  }

  Widget _styled(
      {@required Widget debugCreator,
      @required Map<String, String> style,
      @required Widget child}) {
    return new HtmlElementWidget("div",
        debugCreator: debugCreator, style: style, children: [child]);
  }
}
