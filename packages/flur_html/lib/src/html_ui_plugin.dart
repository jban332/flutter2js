import 'dart:async';
import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flur_html/flur.dart';
import 'package:flur_html/src/controllable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'dom_element_widget.dart';
import 'dom_modification_widget.dart';
import 'dom_sliver_widget.dart';
import 'dom_text_widget.dart';
import 'internal/canvas.dart';
import 'internal/custom_layout.dart' as custom_layout;
import 'internal/drag_target.dart';
import 'internal/drawer.dart';
import 'internal/scaffold.dart';

class CssNames {
  const CssNames();

  String get nameForAlign => "fl-Align";

  String get nameForCheckbox => "fl-Checkbox";

  String get nameForColumn => "fl-Column";

  String get nameForDropdownButton => "fl-DropdownButton";

  String get nameForEditableText => "fl-EditableText";

  String get nameForFloatingActionButton => "fl-FloatingActionButton";

  String get nameForIcon => "fl-Icon";

  String get nameForIconButton => "fl-IconButton";

  String get nameForMaterialButton => "fl-MaterialButton";

  String get nameForRadio => "fl-Radio";

  String get nameForRichText => "fl-RichText";

  String get nameForRow => "fl-Row";

  String get nameForSlider => "fl-Slider";

  String get nameForStack => "fl-Stack";

  String get nameForSwitch => "fl-Switch";

  String get nameForTab => "fl-Tab";

  String get nameForTabBar => "fl-TabBar";

  String get nameForText => "fl-Text";

  String get nameForTextField => "fl-TextField";
}

abstract class HtmlUIPlugin extends UIPlugin {
  /// Used by [generateHtmlElementId].
  int _gid = 0;

  CssNames get cssNames => const CssNames();

  @override
  Widget buildAbsorbPointer(BuildContext context, AbsorbPointer widget) {
    return withStyle(context, widget, widget.child, (style) {
      style.pointerEvents ??= "";
    });
  }

  @override
  Widget buildAlign(BuildContext context, Align widget) {
    final node = new html.DivElement();
    node.className = cssNames.nameForAlign;
    final style = node.style;
    if (widget.alignment != Alignment.center) {
      // Resolve offset
      final alignment = widget.alignment;
      final offset = alignment == null
          ? null
          : alignment.resolve(Directionality.of(context) ?? TextDirection.ltr);
      final x = offset.x;
      if (x != 0.0) {
        if (x < 0.0) {
          style.textAlign = "left";
          final m = 0.5 * (x + 1.0);
          if (m != 0.0) {
            style.marginLeft = cssFromFactional(m);
          }
        } else {
          style.textAlign = "right";
          final m = 0.5 * (x - 1.0);
          if (m != 0.0) {
            style.marginRight = cssFromFactional(m);
          }
        }
      }
    }
    final w = widget.widthFactor;
    if (w != 1.0) {
      style.width = cssFromFactional(w);
    }
    final h = widget.heightFactor;
    if (h != 1.0) {
      style.width = cssFromFactional(h);
    }
    return new DomElementWidget(node, child: widget.child);
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
    final node = _newDiv(context, widget);

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
    node.className = cssNames.nameForCheckbox;

    // Attributes
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
    final clip = widget.clipper.getClip(const Size(100.0, 100.0));
    final center = clip.center;
    return withStyle(context, widget, widget.child, (style) {
      style.clipPath =
          "ellipse(${clip.width}% ${clip.height}% at ${center.dx}% ${center.dy}%)";
    });
  }

  @override
  Widget buildClipRect(BuildContext context, ClipRect widget) {
    final clip = widget.clipper.getClip(const Size(100.0, 100.0));
    return withStyle(context, widget, widget.child, (style) {
      style.clipPath =
          "inset(${clip.left}% ${clip.right}% ${clip.height}% ${clip.bottomRight}%)";
    });
  }

  @override
  Widget buildClipRRect(BuildContext context, ClipRRect widget) {
    final clip = widget.clipper.getClip(const Size(100.0, 100.0));
    return withStyle(context, widget, widget.child, (style) {
      style.clipPath = "inset(${clip.left}% ${clip.right}% ${clip.top}% ${clip
          .bottom}%) radius ${clip.blRadius}";
    });
  }

  @override
  Widget buildConstrainedBox(BuildContext context, ConstrainedBox widget) {
    final constraints = widget.constraints;
    final minWidth = cssFromLogicalPixels(constraints.minWidth);
    final maxWidth = cssFromLogicalPixels(constraints.maxWidth);
    final minHeight = cssFromLogicalPixels(constraints.minHeight);
    final maxHeight = cssFromLogicalPixels(constraints.maxHeight);
    return withStyle(context, widget, widget.child, (style) {
      style.minWidth = minWidth;
      style.maxWidth = maxWidth;
      style.minHeight = minHeight;
      style.maxHeight = maxHeight;
    });
  }

  @override
  Widget buildCustomMultiChildLayout(
      BuildContext context, CustomMultiChildLayout widget) {
    return custom_layout.build(context, widget);
  }

  @override
  Widget buildCustomPaint(BuildContext context, CustomPaint widget) {
    var size = widget.size;
    if (size == null || size == Size.zero) {
      size = const Size(100.0, 100.0);
    }
    final children = <Widget>[];

    // Paint background
    final painter = widget.painter;
    if (painter != null) {
      final node = new html.CanvasElement(
          width: size.width.toInt(), height: size.height.toInt());
      painter.paint(new HtmlCanvas(node), size);
      children.add(new DomElementWidget(node));
    }

    // Paint child
    var child = widget.child;
    if (child != null) {
      final node = new html.DivElement();
      children.add(new DomElementWidget(node, child: child));
    }

    // Paint foreground
    final foregroundPainter = widget.foregroundPainter;
    if (foregroundPainter != null) {
      final node = new html.CanvasElement(
          width: size.width.toInt(), height: size.height.toInt());
      foregroundPainter.paint(new HtmlCanvas(node), size);
      children.add(new DomElementWidget(node));
    }

    return new Stack(children: children);
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
    final decoration = widget.decoration;
    if (decoration is BoxDecoration) {
      return new DomModificationWidget(
          child: widget.child,
          onBuild: (html.Element node) {
            final style = node.style;
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
              style.borderBottomLeftRadius =
                  cssFromRadius(borderRadius.bottomLeft);
              style.borderBottomRightRadius =
                  cssFromRadius(borderRadius.bottomRight);
            }
          });
    } else {
      print("Unsupported box decoration: '${decoration.runtimeType}'");
      return widget.child;
    }
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
    node.className = cssNames.nameForDropdownButton;

    //
    // Events
    //
    final items = widget.items;
    final onChanged = widget.onChanged;
    if (onChanged == null) {
      node.disabled = true;
    } else {
      node.onChange.listen((event) {
        onChanged(items[node.selectedIndex].value);
      });
    }

    //
    // Children
    //
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
      node.className = cssNames.nameForEditableText;

      //
      // Events
      //
      final onChanged = widget.onChanged;
      if (onChanged == null) {
        node.disabled = true;
      } else {
        node.onChange.listen((event) {
          onChanged(node.value);
        });
      }
      final onSelectionChanged = widget.onSelectionChanged;
      if (onSelectionChanged != null) {
        node.onSelect.listen((event) {
          final textSelection = new TextSelection(
              baseOffset: node.selectionStart, extentOffset: node.selectionEnd);
          onSelectionChanged(textSelection, false);
        });
      }
      return new DomElementWidget(node);
    });
  }

  @override
  Widget buildExcludeSemantics(BuildContext context, ExcludeSemantics widget) {
    return widget.child;
  }

  @override
  Widget buildFlex(BuildContext context, Flex widget) {
    final node = new html.DivElement();

    // Set CSS class name
    {
      switch (widget.direction) {
        case Axis.vertical:
          node.className = cssNames.nameForColumn;
          break;
        case Axis.horizontal:
          node.className = cssNames.nameForRow;
          break;
      }
    }

    // Get style
    final style = node.style;

    // Main axis alignment
    {
      String cssValue;
      switch (widget.mainAxisAlignment) {
        case MainAxisAlignment.start:
          // Default value
          break;
        case MainAxisAlignment.end:
          cssValue = "end";
          break;
        case MainAxisAlignment.center:
          cssValue = "center";
          break;
        case MainAxisAlignment.spaceAround:
          cssValue = "space-around";
          break;
        case MainAxisAlignment.spaceBetween:
          cssValue = "space-between";
          break;
        case MainAxisAlignment.spaceEvenly:
          cssValue = "space-evenly";
          break;
      }
      if (cssValue != null) {
        style.justifyContent = cssValue;
      }
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
          // Default!
          break;
        case CrossAxisAlignment.stretch:
          cssValue = "stretch";
          break;
        case CrossAxisAlignment.baseline:
          cssValue = "baseline";
          break;
      }
      if (cssValue != null) {
        style.alignItems = cssValue;
      }
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
      style.position = "relative";
      final translation = widget.translation;
      style.left = cssFromFactional(translation.dx);
      style.top = cssFromFactional(translation.dy);
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

    // Get delegate
    final delegate = widget.childrenDelegate;

    // TODO: Real slivers
    var count = delegate.estimatedChildCount;
    if (count > 10) {
      count = 10;
    }

    // Build rows
    final rows = <Widget>[];
    for (var i = 0; i < count; i++) {
      final item = delegate.build(context, i);
      rows.add(new DomElementWidget.withTag("tr",
          child: new DomElementWidget.withTag("td", child: item)));
    }

    // Build tbody
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
    node.className = cssNames.nameForIcon;
    node.text = new String.fromCharCode(widget.icon.codePoint);
    return new DomElementWidget(node);
  }

  @override
  Widget buildIconButton(BuildContext context, IconButton widget) {
    final node = new html.ButtonElement();
    node.className = cssNames.nameForIconButton;

    final onPressed = widget.onPressed;
    if (onPressed == null) {
      node.disabled = true;
      final disabledColor = widget.disabledColor;
      if (disabledColor != null) {
        node.style.backgroundColor = cssFromColor(disabledColor);
      }
    } else {
      final color = widget.color;
      if (color != null) {
        node.style.backgroundColor = cssFromColor(color);
      }
      node.onClick.listen((event) {
        onPressed();
      });
    }
    return new DomElementWidget(node, child: widget.icon);
  }

  @override
  Widget buildIgnorePointer(BuildContext context, IgnorePointer widget) {
    return withStyle(context, widget, widget.child, (style) {
      style.pointerEvents ??= widget.ignoring ? "none" : "auto";
    });
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
      final onPointerDown = widget.onPointerDown;
      if (onPointerDown != null) {
        node.onMouseDown.listen((html.MouseEvent event) {
          final point = event.page;
          onPointerDown(new PointerDownEvent(
            kind: PointerDeviceKind.mouse,
            position: new Offset(point.x.toDouble(), point.y.toDouble()),
          ));
        });
        node.onTouchStart.listen((html.TouchEvent event) {
          for (var touch in event.targetTouches) {
            final point = touch.page;
            onPointerDown(new PointerDownEvent(
              kind: PointerDeviceKind.touch,
              position: new Offset(point.x.toDouble(), point.y.toDouble()),
              pressure: touch.force,
            ));
          }
        });
      }
    }
    {
      final onPointerCancel = widget.onPointerCancel;
      if (onPointerCancel != null) {
        node.onTouchCancel.listen((html.TouchEvent event) {
          previousPositions.clear();
          for (var touch in event.targetTouches) {
            onPointerCancel(new PointerCancelEvent(
              kind: PointerDeviceKind.touch,
              pointer: touch.identifier,
            ));
          }
        });
      }
    }
    {
      final onPointerNew = widget.onPointerMove;
      if (onPointerNew != null) {
        node.onMouseMove.listen((html.MouseEvent event) {
          final point = event.page;
          final movement = event.movement;
          onPointerNew(new PointerMoveEvent(
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
            onPointerNew(new PointerMoveEvent(
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
      final onPointerUp = widget.onPointerUp;
      if (onPointerUp != null) {
        node.onMouseUp.listen((html.MouseEvent event) {
          final point = event.page;
          onPointerUp(new PointerUpEvent(
            kind: PointerDeviceKind.mouse,
            position: new Offset(point.x.toDouble(), point.y.toDouble()),
          ));
        });
        node.onTouchEnd.listen((html.TouchEvent event) {
          previousPositions.clear();
          for (var touch in event.targetTouches) {
            final point = touch.page;
            onPointerUp(new PointerUpEvent(
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
    node.className = cssNames.nameForMaterialButton;

    //
    // Style
    //
    final style = node.style;
    final textColor = widget.textColor;
    if (textColor != null) {
      style.color = cssFromColor(textColor);
    }
    final color = widget.color;
    if (color != null) {
      style.backgroundColor = cssFromColor(widget.color);
    }
    final padding = widget.padding;
    if (padding!=null) {
      style.paddingLeft = cssFromLogicalPixels(padding.left);
      style.paddingRight = cssFromLogicalPixels(padding.right);
      style.paddingTop = cssFromLogicalPixels(padding.top);
      style.paddingBottom = cssFromLogicalPixels(padding.bottom);
    }
    style.minWidth = cssFromLogicalPixels(widget.minWidth);
    final elevation = widget.elevation;
    if (elevation==0) {

    } else {
      style.boxShadow = "";
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
    return new DomModificationWidget(
        child: widget.child,
        onBuild: (node) {
          addClassName(node, "fl-Offstage");
        });
  }

  @override
  Widget buildPadding(BuildContext context, Padding widget) {
    final padding =
        widget.padding.resolve(Directionality.of(context) ?? TextDirection.ltr);
    final left = cssFromLogicalPixels(padding.left);
    final right = cssFromLogicalPixels(padding.right);
    final top = cssFromLogicalPixels(padding.top);
    final bottom = cssFromLogicalPixels(padding.bottom);
    return withStyle(context, widget, widget.child, (style) {
      style.paddingLeft = left;
      style.paddingRight = right;
      style.paddingTop = top;
      style.paddingBottom = bottom;
    });
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

    final node = _newDiv(context, widget);
    return new DomElementWidget(node, children: [menu, button]);
  }

  @override
  Widget buildPositioned(BuildContext context, Positioned widget) {
    return withStyle(context, widget, widget.child, (style) {
      style.position = "relative";
      style.left = cssFromPositionValue(widget.left) ?? "auto";
      style.right = cssFromPositionValue(widget.right) ?? "auto";
      style.top = cssFromPositionValue(widget.top) ?? "auto";
      style.bottom = cssFromPositionValue(widget.bottom) ?? "auto";
    });
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
  Widget buildRawImage(BuildContext context, RawImage widget) {
    final node = new html.ImageElement();
    debugDomElement(context, node, widget);

    // TODO: Use 'img' element when repeating, etc. is not used?
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
    final node = new html.DivElement();
    node.className = cssNames.nameForRichText;

    //
    // Set CSS properties
    //
    // Text overflow
    final style = node.style;
    final overflow = widget.overflow;
    if (overflow != null) {
      style.textOverflow = cssFromTextOverflow(overflow);
    }

    // Text alignment
    final align = widget.textAlign;
    if (align != null) {
      style.textAlign = cssFromTextAlign(align);
    }

    // Text scale
    final textScaleFactor =
        (widget.textScaleFactor ?? MediaQuery.of(context)?.textScaleFactor);
    if (textScaleFactor != null && textScaleFactor != 1.0) {
      style.fontSize = "${textScaleFactor * 100}%";
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
    node.className = cssNames.nameForSlider;

    // Attributes
    node.valueAsNumber = widget.value;
    node.min = "${widget.min}";
    node.max = "${widget.max}";
    final onChanged = widget.onChanged;
    if (onChanged == null) {
      node.disabled = true;
    } else {
      node.onChange.listen((event) {
        onChanged(node.valueAsNumber);
      });
    }

    return new DomElementWidget(node);
  }

  @override
  Widget buildSliverAppBar(BuildContext context, SliverAppBar widget) {
    // We just build a regular AppBAr
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
      // We just build a regular SliverList
      BuildContext context,
      SliverFixedExtentList widget) {
    return new DomSliverWidget(widget.delegate);
  }

  @override
  Widget buildSliverList(BuildContext context, SliverList widget) {
    return new DomSliverWidget(widget.delegate);
  }

  @override
  Widget buildSnackBar(BuildContext context, SnackBar widget) {
    return unimplementedWidget(context, widget);
  }

  @override
  Widget buildStack(BuildContext context, Stack widget) {
    final node = _newDiv(context, widget);
    debugDomElement(context, node, widget);
    node.className = cssNames.nameForStack;
    measureNodeSize(node, (size) {
      // Calculate max height of child
      var maxBottom = 0;
      for (var child in node.children) {
        final bottom = child.client.bottom;
        if (bottom > maxBottom) {
          maxBottom = bottom;
        }
      }
      node.style.minHeight = cssFromLogicalPixels(maxBottom.toDouble());
      node.style.width = "100%";
    });
    return new DomElementWidget(node, children: widget.children);
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
    node.className = cssNames.nameForSwitch;

    // value
    node.checked = widget.value;

    // onChanged
    final onChanged = widget.onChanged;
    if (onChanged == null) {
      node.disabled = true;
    } else {
      node.onChange.listen((event) {
        onChanged(node.checked);
      });
    }

    // OK
    return new DomElementWidget(node);
  }

  @override
  Widget buildTab(BuildContext context, Tab widget) {
    final node = _newDiv(context, widget);
    node.className = cssNames.nameForTab;
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
      node.className = cssNames.nameForTabBar;

      // Build tabs
      var tabIndex = -1;
      final currentTabIndex = controller.index;
      final children = widget.tabs.map((item) {
        // Increment tab index
        tabIndex++;

        // Build wrapper widget
        final node = new html.DivElement();
        node.className = "fl-TabBar-item";
        if (tabIndex == currentTabIndex) {
          node.className += " fl-TabBar-current";
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
    // Build rows
    final htmlRows = <Widget>[];
    if (widget.children != null) {
      for (var row in widget.children) {
        // Build cells
        final htmlCells = <Widget>[];
        for (var cell in row.children) {
          htmlCells.add(new HtmlElementWidget("td", children: [cell]));
        }
        htmlRows.add(new HtmlElementWidget("tr", children: htmlCells));
      }
    }

    // OK
    return new HtmlElementWidget("table", debugCreator: widget, children: [
      new HtmlElementWidget("tbody", children: htmlRows),
    ]);
  }

  @override
  Widget buildText(BuildContext context, Text widget) {
    final textStyle = widget.style;
    final textScaleFactor =
        (widget.textScaleFactor ?? MediaQuery.of(context)?.textScaleFactor) ??
            1.0;
    final overflow = widget.overflow;
    final textAlign = widget.textAlign;
    if (textStyle == null &&
        textScaleFactor == 1.0 &&
        overflow == null &&
        textAlign == null) {
      return new DomTextWidget(widget.data);
    }

    final node = new html.SpanElement();
    node.className = cssNames.nameForText;

    final style = node.style;

    // Text style
    if (textStyle != null) {
      cssFromTextStyle(textStyle, style);
    }

    // Text scale
    if (textScaleFactor != null && textScaleFactor != 1.0) {
      style.fontSize = "${textScaleFactor * 100}%";
    }

    // Text overflow
    if (overflow != null) {
      style.textOverflow = cssFromTextOverflow(overflow);
    }

    // Text alignment
    if (textAlign != null) {
      style.textAlign = cssFromTextAlign(textAlign);
    }
    return new DomElementWidget(node, child: new DomTextWidget(widget.data));
  }

  @override
  Widget buildTextField(BuildContext context, TextField widget) {
    final html.InputElement node = new html.TextInputElement();
    node.className = cssNames.nameForTextField;

    // Attributes
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
    return withStyle(context, widget, widget.child, (style) {
      style.transform = cssFromTransformMatrix(widget.transform);
    });
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
    // Create HTML span
    final node = new html.SpanElement();

    // Set span style
    final style = widget.style;
    if (style != null) {
      cssFromTextStyle(style, node.style);
    }

    // Set span text
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

    // OK
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

  static DomModificationWidget withStyle(BuildContext context, Widget widget,
      Widget child, void f(html.CssStyleDeclaration style)) {
    return new DomModificationWidget(
        child: child,
        onBuild: (node) {
          f(node.style);
        });
  }

  static html.DivElement _newDiv(BuildContext context, Widget widget) {
    final node = new html.DivElement();
    debugDomElement(context, node, widget);
    return node;
  }
}
