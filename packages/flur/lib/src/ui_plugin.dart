import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'internal/card.dart' as card;
import 'internal/chip.dart' as chip;
import 'internal/gesture_detector.dart' as gestureDetector;

abstract class UIPlugin {
  static UIPlugin current;

  Widget buildAbsorbPointer(BuildContext context, AbsorbPointer widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildAlign(BuildContext context, Align widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildAnimatedSize(BuildContext context, AnimatedSize widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildAppBar(BuildContext context, AppBar widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildAspectRatio(BuildContext context, AspectRatio widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildBackdropFilter(BuildContext context, BackdropFilter widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildBanner(BuildContext context, Banner widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildBaseline(BuildContext context, Baseline widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildBlockSemantics(BuildContext context, BlockSemantics widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildBottomNavigationBar(
      BuildContext context, BottomNavigationBar widget);

  Widget buildBottomSheet(BuildContext context, BottomSheet widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCard(BuildContext context, Card widget) {
    return card.buildCard(context, widget);
  }

  Widget buildCheckbox(BuildContext context, Checkbox widget);

  Widget buildCheckedPopupMenuItem(
      BuildContext context, CheckedPopupMenuItem widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildChip(BuildContext context, Chip widget) {
    return chip.buildChip(context, widget);
  }

  Widget buildCircularProgressIndicator(
      BuildContext context, CircularProgressIndicator widget) {
    return buildProgressIndicator(context, widget);
  }

  Widget buildClipOval(BuildContext context, ClipOval widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildClipPath(BuildContext context, ClipPath widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildClipRect(BuildContext context, ClipRect widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildClipRRect(BuildContext context, ClipRRect widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildConstrainedBox(BuildContext context, ConstrainedBox widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildCupertinoButton(BuildContext context, CupertinoButton widget) {
    return new FlatButton(
        child: widget.child, onPressed: widget.onPressed, color: widget.color);
  }

  Widget buildCupertinoNavigationBar(
      BuildContext context, CupertinoNavigationBar widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCupertinoPageScaffold(
      BuildContext context, CupertinoPageScaffold widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCupertinoSlider(BuildContext context, CupertinoSlider widget) {
    return new Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        onChanged: widget.onChanged,
        activeColor: widget.activeColor);
  }

  Widget buildCupertinoSwitch(BuildContext context, CupertinoSwitch widget) {
    return new Switch(
        value: widget.value,
        onChanged: widget.onChanged,
        activeColor: widget.activeColor);
  }

  Widget buildCupertinoTabBar(BuildContext context, CupertinoTabBar widget) {
    return new BottomNavigationBar(items: widget.items, onTap: widget.onTap);
  }

  Widget buildCupertinoTabScaffold(
      BuildContext context, CupertinoTabScaffold widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCupertinoTabView(BuildContext context, CupertinoTabView widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCustomMultiChildLayout(
      BuildContext context, CustomMultiChildLayout widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCustomPaint(BuildContext context, CustomPaint widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildCustomSingleChildLayout(
      BuildContext context, CustomSingleChildLayout widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildDayPicker(BuildContext context, DayPicker widget);

  Widget buildDecoratedBox(BuildContext context, DecoratedBox widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildDismissible(BuildContext context, Dismissible widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildDraggable(BuildContext context, Draggable widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildDragTarget(BuildContext context, DragTarget widget) {
    return widget.builder(context, const [], const []);
  }

  Widget buildDropdownButton(BuildContext context, DropdownButton widget);

  Widget buildDropdownMenuItem(BuildContext context, DropdownMenuItem widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildEditableText(BuildContext context, EditableText widget);

  Widget buildErrorWidget(BuildContext context, ErrorWidget widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildExcludeSemantics(BuildContext context, ExcludeSemantics widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildExpandIcon(BuildContext context, ExpandIcon widget) {
    bool value = widget.isExpanded;
    return new IconButton(
        icon: const Icon(Icons.expand_more),
        onPressed: () {
          value = !value;
          final f = widget.onPressed;
          if (f != null) {
            f(value);
          }
        });
  }

  Widget buildFittedBox(BuildContext context, FittedBox widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildFlex(BuildContext context, Flex widget);

  Widget buildFlexible(BuildContext context, Flexible widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildFloatingActionButton(
      BuildContext context, FloatingActionButton widget);

  Widget buildFlow(BuildContext context, Flow widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildFractionallySizedBox(
      BuildContext context, FractionallySizedBox widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildFractionalTranslation(
      BuildContext context, FractionalTranslation widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildGestureDetector(BuildContext context, GestureDetector widget) {
    return gestureDetector.buildGestureDetector(context, widget);
  }

  Widget buildGridTile(BuildContext context, GridTile widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildGridView(BuildContext context, GridView widget);

  Widget buildHero(BuildContext context, Hero widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildIcon(BuildContext context, Icon widget) {
    final iconData = widget.icon;
    final content = new String.fromCharCode(iconData.codePoint);
    final style = new TextStyle(fontFamily: iconData.fontFamily);
    return new Text(content, style: style);
  }

  Widget buildIconButton(BuildContext context, IconButton widget);

  Widget buildIgnorePointer(BuildContext context, IgnorePointer widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildImage(BuildContext context, Image widget);

  Widget buildInputDecorator(BuildContext context, InputDecorator widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildIntrinsicHeight(BuildContext context, IntrinsicHeight widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildIntrinsicWidth(BuildContext context, IntrinsicWidth widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildKeepAlive(BuildContext context, KeepAlive widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildLayoutId(BuildContext context, LayoutId widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildLimitedBox(BuildContext context, LimitedBox widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildLinearProgressIndicator(
      BuildContext context, LinearProgressIndicator widget) {
    return buildProgressIndicator(context, widget);
  }

  Widget buildListBody(BuildContext context, ListBody widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildListener(BuildContext context, Listener widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildListTile(BuildContext context, ListTile widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildListView(BuildContext context, ListView widget);

  Widget buildMaterialButton(BuildContext context, MaterialButton widget);

  Widget buildMergeableMaterial(
      BuildContext context, MergeableMaterial widget) {
    final children = widget.children
        .map((item) {
          if (item is MaterialSlice) {
            return unimplementedWidget(context, widget);
          }
          if (item is MaterialGap) {
            return unimplementedWidget(context, widget);
          }
          return unimplementedWidget(context, widget);
        })
        .where((item) => item != null)
        .toList();
    return new Flex(direction: widget.mainAxis, children: children);
  }

  Widget buildMergeSemantics(BuildContext context, MergeSemantics widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildMetaData(BuildContext context, MetaData widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildMonthPicker(BuildContext context, MonthPicker widget) {
    return new EditableText(
        controller: null, focusNode: null, style: null, cursorColor: null);
  }

  Widget buildNavigationToolbar(BuildContext context, NavigationToolbar widget);

  Widget buildNestedScrollView(BuildContext context, NestedScrollView widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildOffstage(BuildContext context, Offstage widget);

  Widget buildOpacity(BuildContext context, Opacity widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildOverflowBox(BuildContext context, OverflowBox widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildPadding(BuildContext context, Padding widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildPhysicalModel(BuildContext context, PhysicalModel widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildPopupMenuButton(BuildContext context, PopupMenuButton widget);

  Widget buildPopupMenuDivider(BuildContext context, PopupMenuDivider widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildPopupMenuItem(BuildContext context, PopupMenuItem widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildPositioned(BuildContext context, Positioned widget);

  Widget buildPreferredSize(BuildContext context, PreferredSize widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildProgressIndicator(BuildContext context, ProgressIndicator widget);

  Widget buildRadio(BuildContext context, Radio widget);

  Widget buildRawImage(BuildContext context, RawImage widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildRefreshProgressIndicator(
      BuildContext context, RefreshProgressIndicator widget) {
    return buildProgressIndicator(context, widget);
  }

  Widget buildRepaintBoundary(BuildContext context, RepaintBoundary widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildRichText(BuildContext context, RichText widget);

  Widget buildRotatedBox(BuildContext context, RotatedBox widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildScrollView(BuildContext context, ScrollView widget);

  Widget buildSemantics(BuildContext context, Semantics widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildShaderMask(BuildContext context, ShaderMask widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildShrinkWrappingViewport(
      BuildContext context, ShrinkWrappingViewport widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSingleChildScrollView(
      BuildContext context, SingleChildScrollView widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildSizedBox(BuildContext context, SizedBox widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildSizedOverflowBox(BuildContext context, SizedOverflowBox widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSlider(BuildContext context, Slider widget);

  Widget buildSliverAppBar(BuildContext context, SliverAppBar widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverFillRemaining(
      BuildContext context, SliverFillRemaining widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverFillViewport(
      BuildContext context, SliverFillViewport widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverFixedExtentList(
      BuildContext context, SliverFixedExtentList widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverGrid(BuildContext context, SliverGrid widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverList(BuildContext context, SliverList widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverPadding(BuildContext context, SliverPadding widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSliverToBoxAdapter(
      BuildContext context, SliverToBoxAdapter widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildSnackBar(BuildContext context, SnackBar widget);

  Widget buildStack(BuildContext context, Stack widget);

  Widget buildStepper(BuildContext context, Stepper widget);

  Widget buildSwitch(BuildContext context, Switch widget);

  Widget buildTab(BuildContext context, Tab widget);

  Widget buildTabBar(BuildContext context, TabBar widget);

  Widget buildTabBarView(BuildContext context, TabBarView widget);

  Widget buildTable(BuildContext context, Table widget);

  Widget buildTableCell(BuildContext context, TableCell widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildText(BuildContext context, Text widget);

  Widget buildTextField(BuildContext context, TextField widget);

  Widget buildTitle(BuildContext context, Title widget) {
    return unimplementedSingleChildWidget(context, widget);
  }

  Widget buildTooltip(BuildContext context, Tooltip widget);

  Widget buildTransform(BuildContext context, Transform widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildViewport(BuildContext context, Viewport widget) {
    return unimplementedWidget(context, widget);
  }

  Widget buildWrap(BuildContext context, Wrap widget);

  Widget buildYearPicker(BuildContext context, YearPicker widget) {
    return new EditableText(
        controller: null, focusNode: null, style: null, cursorColor: null);
  }

  DrawerControllerState createDrawerControllerState();

  OverlayState createOverlayState() {
    throw new UnimplementedError();
  }

  ScaffoldState createScaffoldState();

  Future<DateTime> showDatePicker({
    @required BuildContext context,
    @required DateTime initialDate,
    @required DateTime firstDate,
    @required DateTime lastDate,
    SelectableDayPredicate selectableDayPredicate,
  }) {
    throw new UnimplementedError();
  }

  Future<T> showDialog<T>({
    @required BuildContext context,
    bool barrierDismissible: true,
    @required Widget child,
  }) {
    throw new UnimplementedError();
  }

  Future<T> showMenu<T>(
      {@required BuildContext context,
      RelativeRect position,
      @required List<PopupMenuEntry<T>> items,
      T initialValue,
      double elevation: 8.0});

  Future<T> showModalBottomSheet<T>({
    @required BuildContext context,
    @required WidgetBuilder builder,
  }) {
    throw new UnimplementedError();
  }

  Future<TimeOfDay> showTimePicker(
      {@required BuildContext context, @required TimeOfDay initialTime}) {
    throw new UnimplementedError();
  }

  Widget unimplementedSingleChildWidget(
      BuildContext context, SingleChildUIPluginWidget widget) {
    assert(() {
      print("Ignoring unsupported widget '${widget
          .runtimeType}' with child '${widget.child.runtimeType}'");
      return true;
    }());
    return widget.child;
  }

  Widget unimplementedWidget(BuildContext context, Widget widget) {
    assert(() {
      print("Encounted unsupported widget '${widget.runtimeType}': ${context
          .toString()}");
      return true;
    }());
    return new ErrorWidget(
        "Widget '${widget.runtimeType}' is not implemented by '${this
            .runtimeType}'.");
  }
}
