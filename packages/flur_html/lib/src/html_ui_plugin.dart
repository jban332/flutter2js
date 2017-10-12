import 'dart:async';
import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flur_html/flur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'controllable.dart';
import 'dom_widget.dart';
import 'internal/canvas.dart';
import 'internal/drag_target.dart';
import 'internal/drawer.dart';
import 'internal/scaffold.dart';

abstract class HtmlUIPlugin extends UIPlugin {
  /// Used by [generateHtmlElementId].
  int _gid = 0;

  @override
  Widget buildAbsorbPointer(BuildContext context, AbsorbPointer widget) {
    final node = _newDiv(context, widget);
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildAlign(BuildContext context, Align widget) {
    return withStyle(context, widget, widget.child, (style) {
      final alignment = widget.alignment;
      if (alignment != null) {
        final offset = widget.alignment
            .resolve(Directionality.of(context) ?? TextDirection.ltr);
        if (offset.x != 0.0 && offset.y != 0.0) {
          style.position = "relative";
          style.left = cssFromFactional(offset.x - 0.5);
          style.top = cssFromFactional(offset.y - 0.5);
          style.right = "auto";
          style.bottom = "auto";
        }
      }
      style.width = cssFromFactional(widget.widthFactor);
      style.height = cssFromFactional(widget.heightFactor);
    });
  }

  @override
  Widget buildAppBar(BuildContext context, AppBar widget) {
    final node = _newDiv(context, widget);
    final children = [];
    final leading = widget.leading;
    if (leading != null) {
      children.add(new DomElementWidget.withTag("div", child: leading));
    }
    final title = widget.title;
    if (title != null) {
      children.add(new DomElementWidget.withTag("div", child: title));
    }
    for (var child in (widget.actions ?? const [])) {
      children.add(new DomElementWidget.withTag("div", child: child));
    }
    final bottom = widget.bottom;
    if (bottom != null) {
      children.add(bottom);
    }
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildBlockSemantics(BuildContext context, BlockSemantics widget) {
    return widget.child;
  }

  @override
  Widget buildBottomNavigationBar(
      BuildContext context, BottomNavigationBar widget) {
    final node = new html.Element.div();
    debugDomElement(context, node, widget);

    final children = <Widget>[];
    for (var item in widget.items) {
      children.add(new DomElementWidget.withTag("div",
          children: <Widget>[item.icon, item.title]));
    }
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildCheckbox(BuildContext context, Checkbox widget) {
    final node = new html.CheckboxInputElement();
    debugDomElement(context, node, widget);

    node.checked = widget.value;
    {
      final value = widget.onChanged;
      if (value == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          value(node.checked);
        });
      }
    }
    return new DomElementWidget(node);
  }

  @override
  Widget buildClipOval(BuildContext context, ClipOval widget) {
    final node = _newDiv(context, widget);

    final clip = widget.clipper.getClip(const Size(100.0, 100.0));
    final center = clip.center;
    node.style.clipPath =
        "ellipse(${clip.width}% ${clip.height}% at ${center.dx}% ${center.dy}%)";
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildClipRect(BuildContext context, ClipRect widget) {
    final node = _newDiv(context, widget);

    final clip = widget.clipper.getClip(const Size(100.0, 100.0));
    node.style.clipPath =
        "inset(${clip.left}% ${clip.right}% ${clip.height}% ${clip.bottomRight}%)";
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildClipRRect(BuildContext context, ClipRRect widget) {
    final node = _newDiv(context, widget);

    final clip = widget.clipper.getClip(const Size(100.0, 100.0));
    node.style.clipPath =
        "inset(${clip.left}% ${clip.right}% ${clip.top}% ${clip
        .bottom}%) radius ${clip.blRadius}";
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildConstrainedBox(BuildContext context, ConstrainedBox widget) {
    final node = _newDiv(context, widget);

    return new DomElementWidget(node, children: [widget.child]);
  }

  @override
  Widget buildCustomMultiChildLayout(
      BuildContext context, CustomMultiChildLayout widget) {
    final node = _newDiv(context, widget);

    return new DomElementWidget(node, children: widget.children);
  }

  @override
  Widget buildCustomPaint(BuildContext context, CustomPaint widget) {
    final size = widget.size ?? const Size(100.0, 100.0);

    // Create HTML canvas
    final canvasElement = new html.CanvasElement(
        width: size.width.toInt(), height: size.height.toInt());
    final canvasWidget = new DomElementWidget(canvasElement);
    final canvas = new HtmlCanvas(canvasElement.context2D);

    // Paint background
    {
      final painter = widget.painter;
      if (painter != null) {
        painter.paint(canvas, size);
      }
    }

    // Paint foreground
    {
      final foregroundPainter = widget.foregroundPainter;
      if (foregroundPainter != null) {
        foregroundPainter.paint(canvas, size);
      }
    }

    // Wrap child
    final childWrapperNode = new html.DivElement();
    final childWrapperStyle = childWrapperNode.style;
    childWrapperStyle.position = "absolute";
    childWrapperStyle.left = "0px";
    childWrapperStyle.right = "0px";
    childWrapperStyle.top = "0px";
    childWrapperStyle.bottom = "0px";
    final childWrapperWidget =
        new DomElementWidget(childWrapperNode, child: widget.child);

    // Actual HTML element
    final node = _newDiv(context, widget);
    return new DomElementWidget(node, children: [
      canvasWidget,
      childWrapperWidget,
    ]);
  }

  @override
  Widget buildCustomSingleChildLayout(
      BuildContext context, CustomSingleChildLayout widget) {
    return widget.child;
  }

  @override
  Widget buildDayPicker(BuildContext context, DayPicker widget) {
    final node = new html.DateInputElement();
    debugDomElement(context, node, widget);

    {
      final firstDate = widget.firstDate;
      if (firstDate != null) {
        node.min = _dateTimeToString(firstDate);
      }
    }
    {
      final lastDate = widget.lastDate;
      if (lastDate != null) {
        node.max = _dateTimeToString(lastDate);
      }
    }
    {
      final onChanged = widget.onChanged;
      if (onChanged == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          onChanged(node.valueAsDate);
        });
      }
    }
    return new DomElementWidget(node);
  }

  @override
  Widget buildDecoratedBox(BuildContext context, DecoratedBox widget) {
    final node = _newDiv(context, widget);

    final style = node.style;
    final decoration = widget.decoration;
    if (decoration is BoxDecoration) {
      if (decoration.color != null) {
        style.backgroundColor = cssFromColor(decoration.color);
      }
      final border = decoration.border;
      if (border != null) {
        style.borderLeft = cssFromBorderSide(border.left);
        style.borderRight = cssFromBorderSide(border.right);
        style.borderTop = cssFromBorderSide(border.top);
        style.borderBottom = cssFromBorderSide(border.bottom);
      }
      final borderRadius = decoration.borderRadius;
      if (borderRadius != null) {
        style.borderTopLeftRadius = cssFromRadius(borderRadius.topLeft);
        style.borderTopRightRadius = cssFromRadius(borderRadius.topRight);
        style.borderBottomLeftRadius = cssFromRadius(borderRadius.bottomLeft);
        style.borderBottomRightRadius = cssFromRadius(borderRadius.bottomRight);
      }
    } else {
      print("Unsupported box decoration: '${decoration.runtimeType}'");
    }

    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildDraggable(BuildContext context, Draggable widget) {
    final node = _newDiv(context, widget);

    node.draggable = true;
    {
      final value = widget.onDragStarted;
      if (value != null) {
        node.onDragStart.listen((domEvent) {
          value();
        });
      }
    }
    {
      final value = widget.onDragCompleted;
      if (value != null) {
        node.onDragEnd.listen((domEvent) {
          value();
        });
      }
    }
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildDragTarget(BuildContext context, DragTarget widget) {
    return new HtmlDragTarget(widget);
  }

  @override
  Widget buildDropdownButton(BuildContext context, DropdownButton widget) {
    final node = new html.SelectElement();
    debugDomElement(context, node, widget);

    final items = widget.items;
    {
      final onChanged = widget.onChanged;
      if (onChanged == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          onChanged(items[node.selectedIndex].value);
        });
      }
    }
    final widgetValue = widget.value;
    final children = <Widget>[];
    var i = -1;
    for (var item in items) {
      i++;
      final itemNode = new html.OptionElement();
      if (item.value == widgetValue) {
        node.selectedIndex = i;
        itemNode.selected = true;
      }
      children.add(new DomElementWidget(itemNode, child: item.child));
    }
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildEditableText(BuildContext context, EditableText widget) {
    final controller = widget.controller;
    return new ValueControllable(controller, (context, value) {
      final node = new html.TextAreaElement();
      debugDomElement(context, node, widget);

      //
      // Attributes
      //

      //
      // Events
      //
      {
        final value = widget.onChanged;
        if (value == null) {
          node.disabled = true;
        } else {
          node.onChange.listen((event) {
            value(node.value);
          });
        }
      }
      {
        final value = widget.onSelectionChanged;
        if (value != null) {
          node.onSelect.listen((event) {
            final textSelection = new TextSelection(
                baseOffset: node.selectionStart,
                extentOffset: node.selectionEnd);
            value(textSelection, false);
          });
        }
      }
      return new DomElementWidget(node);
    });
  }

  @override
  Widget buildExcludeSemantics(BuildContext context, ExcludeSemantics widget) {
    return widget.child;
  }

  @override
  Widget buildFlatButton(BuildContext context, FlatButton widget) {
    final node = new html.TextAreaElement();
    debugDomElement(context, node, widget);

    //
    // Style
    //
    final style = node.style;
    {
      final textColor = widget.textColor;
      if (textColor != null) {
        style.color = cssFromColor(textColor);
      }
    }
    {
      final color = widget.color;
      if (color != null) {
        style.backgroundColor = cssFromColor(color);
      }
    }
    {
      final disabledColor = widget.disabledColor;
      if (disabledColor != null) {
        style.backgroundColor = cssFromColor(disabledColor);
      }
    }

    //
    // Events
    //
    final onPressed = widget.onPressed;
    if (onPressed == null) {
      node.disabled = true;
    } else {
      node.onClick.listen((event) {
        onPressed();
      });
    }

    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildFlex(BuildContext context, Flex widget) {
    final node = _newDiv(context, widget);

    //
    // Style
    //
    final style = node.style;
    style.display = "flex";

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
      style.flexDirection = cssValue;
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
        case MainAxisAlignment.spaceAround:
          break;
        case MainAxisAlignment.spaceBetween:
          break;
        case MainAxisAlignment.spaceEvenly:
          break;
      }
      style.justifyContent = cssValue;
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
      style.alignItems = cssValue;
    }
    return new DomElementWidget(node, children: widget.children);
  }

  @override
  Widget buildFlexible(BuildContext context, Flexible widget) {
    return widget.child;
  }

  @override
  Widget buildFloatingActionButton(
      BuildContext context, FloatingActionButton widget) {
    final node = new html.ButtonElement();
    debugDomElement(context, node, widget);

    node.style.backgroundColor = cssFromColor(widget.backgroundColor);
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildFractionallySizedBox(
      BuildContext context, FractionallySizedBox widget) {
    return withStyle(context, widget, widget.child, (style) {
      style.width = cssFromFactional(widget.widthFactor);
      style.height = cssFromFactional(widget.heightFactor);
    });
  }

  @override
  Widget buildFractionalTranslation(
      BuildContext context, FractionalTranslation widget) {
    return withStyle(context, widget, widget.child, (style) {
      final translation = widget.translation;
      style.left = cssFromFactional(translation.dx);
      style.top = cssFromFactional(translation.dy);
      style.right = "auto";
      style.bottom = "auto";
    });
  }

  @override
  Widget buildGridTile(BuildContext context, GridTile widget) {
    final node = _newDiv(context, widget);

    final children = <Widget>[
      widget.header,
      widget.child,
      widget.footer,
    ];
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildGridView(BuildContext context, GridView widget) {
    final node = new html.TableElement();
    debugDomElement(context, node, widget);

    final rows = [];
    final tbody = new html.Element.tag("tbody");
    new HtmlElementWidget("tbody", debugCreator: null, children: rows);
    return new DomElementWidget(node, child: new DomElementWidget(tbody));
  }

  @override
  Widget buildHero(BuildContext context, Hero widget) {
    return widget.child;
  }

  @override
  Widget buildIcon(BuildContext context, Icon widget) {
    final node = new html.SpanElement();
    debugDomElement(context, node, widget);

    node.className = "material-icons";
    node.text = new String.fromCharCode(widget.icon.codePoint);
    return new DomElementWidget(node);
  }

  @override
  Widget buildIconButton(BuildContext context, IconButton widget) {
    final node = new html.ButtonElement();
    debugDomElement(context, node, widget);

    final onPressed = widget.onPressed;
    if (onPressed == null) {
      node.disabled = true;
      {
        final value = widget.disabledColor;
        if (value != null) {
          node.style.backgroundColor = cssFromColor(value);
        }
      }
    } else {
      {
        final value = widget.color;
        if (value != null) {
          node.style.backgroundColor = cssFromColor(value);
        }
      }
      node.onClick.listen((event) {
        onPressed();
      });
    }
    return new DomElementWidget(node, child: widget.icon);
  }

  @override
  Widget buildIgnorePointer(BuildContext context, IgnorePointer widget) {
    final node = _newDiv(context, widget);

    node.style.pointerEvents = widget.ignoring ? "none" : "auto";
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildImage(BuildContext context, Image widget) {
    final node = new html.ImageElement();
    debugDomElement(context, node, widget);

    final style = node.style;
    final widthCss = cssFromLogicalPixels(widget.width);
    final heightCss = cssFromLogicalPixels(widget.height);
    if (widthCss != null) {
      if (heightCss != null) {
        style.backgroundSize = "${widthCss} ${heightCss}";
      } else {
        style.backgroundSize = widthCss;
      }
    } else if (heightCss != null) {
      style.backgroundSize = "100% ${heightCss}";
    }
    imageSrcFromImageProvider(widget.image, (uri) {
      style.backgroundImage = uri;
    });
    final direction = widget.matchTextDirection
        ? Directionality.of(context)
        : TextDirection.ltr;
    final alignment = widget.alignment.resolve(direction);
    style.backgroundRepeat = cssFromImageRepeat(widget.repeat);
    style.backgroundPositionX = cssFromLogicalPixels(alignment.x);
    style.backgroundPositionY = cssFromLogicalPixels(alignment.y);
    style.backgroundColor = cssFromColor(widget.color);
    style.backgroundBlendMode = cssFromBlendMode(widget.colorBlendMode);
    return new DomElementWidget(node);
  }

  @override
  Widget buildKeepAlive(BuildContext context, KeepAlive widget) {
    return widget.child;
  }

  @override
  Widget buildLayoutId(BuildContext context, LayoutId widget) {
    return widget.child;
  }

  @override
  Widget buildLimitedBox(BuildContext context, LimitedBox widget) {
    return withStyle(context, widget, widget.child, (style) {
      style.maxWidth = cssFromLogicalPixels(widget.maxWidth);
      style.maxHeight = cssFromLogicalPixels(widget.maxHeight);
    });
  }

  @override
  Widget buildListener(BuildContext context, Listener widget) {
    final node = _newDiv(context, widget);

    final previousPositions = <int, Offset>{};
    {
      final value = widget.onPointerDown;
      if (value != null) {
        node.onMouseDown.listen((html.MouseEvent event) {
          final point = event.page;
          value(new PointerDownEvent(
            kind: PointerDeviceKind.mouse,
            position: new Offset(point.x.toDouble(), point.y.toDouble()),
          ));
        });
        node.onTouchStart.listen((html.TouchEvent event) {
          for (var touch in event.targetTouches) {
            final point = touch.page;
            value(new PointerDownEvent(
              kind: PointerDeviceKind.touch,
              position: new Offset(point.x.toDouble(), point.y.toDouble()),
              pressure: touch.force,
            ));
          }
        });
      }
    }
    {
      final value = widget.onPointerCancel;
      if (value != null) {
        node.onTouchCancel.listen((html.TouchEvent event) {
          previousPositions.clear();
          for (var touch in event.targetTouches) {
            value(new PointerCancelEvent(
              kind: PointerDeviceKind.touch,
              pointer: touch.identifier,
            ));
          }
        });
      }
    }
    {
      final value = widget.onPointerMove;
      if (value != null) {
        node.onMouseMove.listen((html.MouseEvent event) {
          final point = event.page;
          final movement = event.movement;
          value(new PointerMoveEvent(
            kind: PointerDeviceKind.mouse,
            position: new Offset(point.x.toDouble(), point.y.toDouble()),
            delta: new Offset(movement.x, movement.y),
          ));
        });
        node.onTouchMove.listen((html.TouchEvent event) {
          for (var touch in event.touches) {
            final point = touch.page;
            final position = new Offset(point.x.toDouble(), point.y.toDouble());
            final Offset previousPosition =
                previousPositions[touch.identifier] ?? position;
            value(new PointerMoveEvent(
              kind: PointerDeviceKind.touch,
              pointer: touch.identifier,
              position: position,
              pressure: touch.force,
              delta: new Offset(position.dx - previousPosition.dx,
                  position.dy - previousPosition.dy),
            ));
          }
        });
      }
    }
    {
      final value = widget.onPointerUp;
      if (value != null) {
        node.onMouseUp.listen((html.MouseEvent event) {
          final point = event.page;
          value(new PointerUpEvent(
            kind: PointerDeviceKind.mouse,
            position: new Offset(point.x.toDouble(), point.y.toDouble()),
          ));
        });
        node.onTouchEnd.listen((html.TouchEvent event) {
          previousPositions.clear();
          for (var touch in event.targetTouches) {
            final point = touch.page;
            value(new PointerUpEvent(
              kind: PointerDeviceKind.touch,
              pointer: touch.identifier,
              position: new Offset(point.x.toDouble(), point.y.toDouble()),
            ));
          }
        });
      }
    }
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildListView(BuildContext context, ListView widget) {
    return this.buildScrollView(context, widget);
  }

  @override
  Widget buildMaterialButton(BuildContext context, MaterialButton widget) {
    final node = new html.ButtonElement();
    debugDomElement(context, node, widget);

    node.style.backgroundColor = cssFromColor(widget.color);
    {
      final value = widget.onPressed;
      if (value == null) {
        node.disabled = true;
      } else {
        node.onClick.listen((event) {
          value();
        });
      }
    }
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildMergeSemantics(BuildContext context, MergeSemantics widget) {
    return widget.child;
  }

  @override
  Widget buildNavigationToolbar(
      BuildContext context, NavigationToolbar widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildOffstage(BuildContext context, Offstage widget) {
    final node = _newDiv(context, widget);

    node.className = "flutter-Offstage";
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildPadding(BuildContext context, Padding widget) {
    final node = _newDiv(context, widget);

    final style = node.style;
    final padding = widget.padding.resolve(TextDirection.ltr);
    style.paddingLeft = cssFromLogicalPixels(padding.left);
    style.paddingRight = cssFromLogicalPixels(padding.right);
    style.paddingTop = cssFromLogicalPixels(padding.top);
    style.paddingBottom = cssFromLogicalPixels(padding.bottom);
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildPopupMenuButton(BuildContext context, PopupMenuButton widget) {
    final List<PopupMenuEntry> items = widget.itemBuilder(context);
    final onSelected = widget.onSelected;
    var divider = false;
    final menuChildren = items.map((PopupMenuEntry item) {
      if (item is PopupMenuDivider) {
        divider = true;
      } else if (item is PopupMenuItem) {
        var className = "mdl-menu__item";
        if (divider) {
          className += " mdl-menu__item--full-bleed-divider";
          divider = false;
        }
        return new HtmlElementWidget("li",
            debugCreator: item,
            className: className,
            eventHandlers: <String, ValueChanged>{
              "click": (domEvent) {
                onSelected(item.value);
              },
            },
            children: [
              textFromWidget(widget)
            ]);
      }
    }).toList();
    final buttonId = generateHtmlElementId();
    final menu = new HtmlElementWidget(
      "ul",
      attributes: <String, String>{
        "for": buttonId,
      },
      className:
          "mdl-menu mdl-menu--bottom-left mdl-js-menu mdl-js-ripple-effect",
      children: menuChildren,
    );
    final button = buildIconButton(
        context,
        new IconButton(
            icon: widget.icon,
            padding: widget.padding,
            tooltip: widget.tooltip,
            onPressed: onSelected == null
                ? null
                : () {
                    final menuDom = html.querySelector("#${buttonId}");
                    menuDom.style.display = "";
                  })) as DomElementWidget;
    button.node.id = buttonId;

    final node = _newDiv(context, widget);
    return new DomElementWidget(node, children: [menu, button]);
  }

  @override
  Widget buildPositioned(BuildContext context, Positioned widget) {
    final node = _newDiv(context, widget);

    final nodeStyle = node.style;
    nodeStyle.position = "relative";
    nodeStyle.left = cssFromPositionValue(widget.left) ?? "auto";
    nodeStyle.right = cssFromPositionValue(widget.right) ?? "auto";
    nodeStyle.top = cssFromPositionValue(widget.top) ?? "auto";
    nodeStyle.bottom = cssFromPositionValue(widget.bottom) ?? "auto";
    return new DomElementWidget(node, children: <Widget>[widget.child]);
  }

  @override
  Widget buildProgressIndicator(
      BuildContext context, ProgressIndicator widget) {
    // TODO: Implement correctly
    return new DecoratedBox(
        decoration: new BoxDecoration(color: widget.backgroundColor),
        child: new Text("${widget.value * 100}%"));
  }

  @override
  Widget buildRadio(BuildContext context, Radio widget) {
    final node = new html.RadioButtonInputElement();
    debugDomElement(context, node, widget);

    // TODO: improve appearance

    // checked
    node.checked = widget.value == widget.groupValue;

    // onChange
    {
      final onChange = widget.onChanged;
      if (onChange == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          onChange(node.checked);
        });
      }
    }

    return new DomElementWidget(node);
  }

  @override
  Widget buildRaisedButton(BuildContext context, RaisedButton widget) {
    final node = new html.ButtonElement();
    debugDomElement(context, node, widget);

    // TODO: improve appearance

    // onPressed
    {
      final onPressed = widget.onPressed;
      if (onPressed == null) {
        node.style.backgroundColor = cssFromColor(widget.disabledColor);
        node.disabled = true;
      } else {
        node.style.backgroundColor = cssFromColor(widget.color);
        node.onClick.listen((_) {
          onPressed();
        });
      }
    }

    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildRawImage(BuildContext context, RawImage widget) {
    final node = new html.ImageElement();
    debugDomElement(context, node, widget);

    final style = node.style;
    final widthCss = cssFromLogicalPixels(widget.width);
    final heightCss = cssFromLogicalPixels(widget.height);
    if (widthCss != null) {
      if (heightCss != null) {
        style.backgroundSize = "${widthCss} ${heightCss}";
      } else {
        style.backgroundSize = widthCss;
      }
    } else if (heightCss != null) {
      style.backgroundSize = "100% ${heightCss}";
    }
    imageSrcFromImage(widget.image, (uri) {
      style.backgroundImage = uri;
    });
    final direction = widget.matchTextDirection
        ? Directionality.of(context)
        : TextDirection.ltr;
    final alignment = widget.alignment.resolve(direction);
    style.backgroundRepeat = cssFromImageRepeat(widget.repeat);
    style.backgroundPositionX = cssFromLogicalPixels(alignment.x);
    style.backgroundPositionY = cssFromLogicalPixels(alignment.y);
    style.backgroundColor = cssFromColor(widget.color);
    style.backgroundBlendMode = cssFromBlendMode(widget.colorBlendMode);
    return new DomElementWidget(node);
  }

  @override
  Widget buildRepaintBoundary(BuildContext context, RepaintBoundary widget) {
    return widget.child;
  }

  @override
  Widget buildRichText(BuildContext context, RichText widget) {
    final node = new html.ParagraphElement();
    final style = node.style;
    {
      final value = widget.overflow;
      if (value != null) {
        style.textOverflow = cssFromTextOverflow(value);
      }
    }
    {
      final value = widget.textAlign;
      if (value != null) {
        style.textAlign = cssFromTextAlign(value);
      }
    }
    {
      final value =
          (widget.textScaleFactor ?? MediaQuery.of(context)?.textScaleFactor);
      if (value != null && value != 1.0) {
        style.fontSize = "${value * 100}%";
      }
    }
    node.insertBefore(htmlFromTextSpan(context, widget.text), null);
    return new DomElementWidget(node);
  }

  @override
  Widget buildScrollView(BuildContext context, ScrollView widget) {
    final node = _newDiv(context, widget);

    // ignore: INVALID_USE_OF_PROTECTED_MEMBER
    final children = widget.buildSlivers(context);
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildSemantics(BuildContext context, Semantics widget) {
    return widget.child;
  }

  @override
  Widget buildSizedBox(BuildContext context, SizedBox widget) {
    return withStyle(context, widget, widget.child, (style) {
      style.height = cssFromLogicalPixels(widget.height);
      style.width = cssFromLogicalPixels(widget.width);
    });
  }

  @override
  Widget buildSlider(BuildContext context, Slider widget) {
    final node = new html.RangeInputElement();
    debugDomElement(context, node, widget);

    node.valueAsNumber = widget.value;
    node.min = "${widget.min}";
    node.max = "${widget.max}";

    {
      final value = widget.onChanged;
      if (value == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          value(node.valueAsNumber);
        });
      }
    }

    return new DomElementWidget(node);
  }

  @override
  Widget buildSliverAppBar(BuildContext context, SliverAppBar widget) {
    return buildAppBar(
        context,
        new AppBar(
          title: widget.title,
          leading: widget.leading,
          actions: widget.actions,
          bottom: widget.bottom,
          backgroundColor: widget.backgroundColor,
        ));
  }

  @override
  Widget buildSliverFixedExtentList(
      BuildContext context, SliverFixedExtentList widget) {
    return this
        .buildSliverList(context, new SliverList(delegate: widget.delegate));
  }

  @override
  Widget buildSliverList(BuildContext context, SliverList widget) {
    final node = _newDiv(context, widget);

    final children = <Widget>[];
    final delegate = widget.delegate;
    var count = delegate.estimatedChildCount;
    if (count > 10) {
      count = 10;
    }
    for (var i = 0; i < count; i++) {
      final child = delegate.build(context, i);
      if (child == null) {
        break;
      }
      children.add(child);
    }
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildSnackBar(BuildContext context, SnackBar widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildStack(BuildContext context, Stack widget) {
    final node = _newDiv(context, widget);
    node.className = "flutter-Stack";
    return new DomElementWidget(node, children: widget.children?.map((item) {
      return new DomElementWidget.withTag("div", child: item);
    }));
  }

  @override
  Widget buildStepper(BuildContext context, Stepper widget) {
    final node = new html.RangeInputElement();
    debugDomElement(context, node, widget);
    return new DomElementWidget(node);
  }

  @override
  Widget buildSwitch(BuildContext context, Switch widget) {
    final node = new html.CheckboxInputElement();
    debugDomElement(context, node, widget);

    node.checked = widget.value;
    {
      final value = widget.onChanged;
      if (value == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          value(node.checked);
        });
      }
    }

    return new DomElementWidget(node);
  }

  @override
  Widget buildTab(BuildContext context, Tab widget) {
    final node = _newDiv(context, widget);
    final children = [
      widget.icon,
      widget.text,
    ];
    return new DomElementWidget(node, children: children);
  }

  @override
  Widget buildTabBar(BuildContext context, TabBar widget) {
    final TabController controller =
        widget.controller ?? DefaultTabController.of(context);
    return new Controllable(controller, (context) {
      final node = new html.Element.div();
      debugDomElement(context, node, widget);
      node.className = "flutter-TabBar";

      // Build tabs
      var tabIndex = -1;
      final currentTabIndex = controller.index;
      final children = widget.tabs.map((item) {
        // Increment tab index
        tabIndex++;

        // Build wrapper widget
        final node = new html.DivElement();
        node.className = "flutter-TabBar-tab";
        if (tabIndex == currentTabIndex) {
          node.className += " flutter-TabBar-tab-active";
        }
        node.onClick.listen((_) {
          controller.index = tabIndex;
        });
        return new DomElementWidget(
          node,
          child: item,
        );
      });
      return new DomElementWidget(node, children: children);
    });
  }

  @override
  Widget buildTabBarView(BuildContext context, TabBarView widget) {
    final TabController controller =
        widget.controller ?? DefaultTabController.of(context);
    return new Controllable(controller, (context) {
      final node = new html.Element.div();
      debugDomElement(context, node, widget);
      return new DomElementWidget(node,
          child: widget.children[controller.index]);
    });
  }

  @override
  Widget buildTable(BuildContext context, Table widget) {
    final htmlRows = <Widget>[];
    if (widget.children != null) {
      for (var row in widget.children) {
        final htmlCells = <Widget>[];
        for (var cell in row.children) {
          htmlCells.add(new HtmlElementWidget("td", children: [cell]));
        }
        htmlRows.add(new HtmlElementWidget("tr", children: htmlCells));
      }
    }
    return new HtmlElementWidget("table", debugCreator: widget, children: [
      new HtmlElementWidget("tbody", children: htmlRows),
    ]);
  }

  @override
  Widget buildText(BuildContext context, Text widget) {
    final node = new html.SpanElement();
    debugDomElement(context, node, widget);

    final style = node.style;
    {
      final textStyle = widget.style;
      if (textStyle != null) {
        cssFromTextStyle(textStyle, style);
      }
    }
    {
      final textScaleFactor =
          (widget.textScaleFactor ?? MediaQuery.of(context)?.textScaleFactor);
      if (textScaleFactor != null && textScaleFactor != 1.0) {
        style.fontSize = "${textScaleFactor * 100}%";
      }
    }
    {
      final overflow = widget.overflow;
      if (overflow != null) {
        style.textOverflow = cssFromTextOverflow(overflow);
      }
    }
    {
      final textAlign = widget.textAlign;
      if (textAlign != null) {
        style.textAlign = cssFromTextAlign(textAlign);
      }
    }
    return new DomElementWidget(node, child: new DomTextWidget(widget.data));
  }

  @override
  Widget buildTextField(BuildContext context, TextField widget) {
    final html.InputElement node = new html.TextInputElement();
    debugDomElement(context, node, widget);

    if (widget.obscureText) {
      node.type = "password";
    }

    final onSubmitted = widget.onSubmitted;
    if (onSubmitted != null) {
      node.onSubmit.listen((event) {
        onSubmitted(node.value);
      });
    }
    if (widget.autofocus) {
      node.autofocus = true;
    }
    if (widget.autocorrect) {
      node.autocomplete = "";
    }
    node.style.textAlign = cssFromTextAlign(widget.textAlign);

    // Controller
    final controller = widget.controller;
    final selection = controller.selection;
    node.value = controller.text;
    node.setSelectionRange(selection.start, selection.end);
    void updateController() {
      controller.value = new TextEditingValue(
          text: node.value,
          selection: new TextSelection(
              baseOffset: node.selectionStart,
              extentOffset: node.selectionEnd));
    }

    ;
    final onChanged = widget.onChanged;
    node.onChange.listen((item) {
      updateController();
      if (onChanged != null) {
        widget.onChanged(node.value);
      }
    });
    node.onSelect.listen((event) {
      updateController();
    });
    return new DomElementWidget(node);
  }

  @override
  Widget buildTitle(BuildContext context, Title widget) {
    html.document.head.title = widget.title;
    return widget.child;
  }

  @override
  Widget buildTooltip(BuildContext context, Tooltip widget) {
    final node = _newDiv(context, widget);
    node.title = widget.message;
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildTransform(BuildContext context, Transform widget) {
    final node = new html.Element.div();
    debugDomElement(context, node, widget);
    node.style.transform = cssFromTransformMatrix(widget.transform);
    debugDomElement(context, node, widget);
    return new DomElementWidget(node, child: widget.child);
  }

  @override
  Widget buildWrap(BuildContext context, Wrap widget) {
    final node = _newDiv(context, widget);
    final style = node.style;
    style.display = "flex";

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
      style.flexDirection = cssValue;
    }

    // Alignment
    {
      String cssValue;
      switch (widget.alignment) {
        case WrapAlignment.start:
          cssValue = "start";
          break;
        case WrapAlignment.center:
          cssValue = "center";
          break;
        case WrapAlignment.end:
          cssValue = "end";
          break;
        case WrapAlignment.spaceBetween:
          break;
        case WrapAlignment.spaceAround:
          break;
        case WrapAlignment.spaceEvenly:
          break;
      }
      style.justifyContent = cssValue;
    }

    // Cross axis alignment
    {
      String cssValue;
      switch (widget.crossAxisAlignment) {
        case WrapCrossAlignment.start:
          cssValue = "start";
          break;
        case WrapCrossAlignment.center:
          cssValue = "center";
          break;
        case WrapCrossAlignment.end:
          cssValue = "end";
          break;
      }
      style.alignItems = cssValue;
    }

    // Done
    return new DomElementWidget(node, children: widget.children);
  }

  @override
  DrawerControllerState createDrawerControllerState() {
    return new DrawerControllerStateImpl();
  }

  @override
  ScaffoldState createScaffoldState() {
    return new ScaffoldStateImpl();
  }

  Widget elementWithClassName(String type, String className, Widget widget) {
    return new HtmlElementWidget(type,
        className: className, children: [widget]);
  }

  /// Generates unique ID for an HTML element
  String generateHtmlElementId({Widget widget}) => "gid${_gid++}";

  html.SpanElement htmlFromTextSpan(BuildContext context, TextSpan widget) {
    // Build CSS style
    final node = new html.SpanElement();
    {
      final value = widget.style;
      if (value != null) {
        cssFromTextStyle(value, node.style);
      }
    }
    final text = widget.text;
    if (text == null) {
      node.insertBefore(new html.Text(text), null);
    } else {
      final children = widget.children;
      if (children != null) {
        for (var child in children) {
          node.insertBefore(htmlFromTextSpan(context, child), null);
        }
      }
    }
    return node;
  }

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

  String _dateTimeToString(DateTime value) {
    if (value == null) {
      return null;
    }
    return "${value.year.toString().padLeft(4, '0')}-${value.month.toString()
        .padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}";
  }

  static html.DivElement _newDiv(BuildContext context, Widget widget) {
    final node = new html.DivElement();
    debugDomElement(context, node, widget);
    return node;
  }

  static DomElementWidget withStyle(BuildContext context, Widget widget,
      Widget child, void f(html.CssStyleDeclaration style)) {
    final node = _newDiv(context, widget);
    f(node.style);
    return new DomElementWidget(node, child: child);
  }
}
