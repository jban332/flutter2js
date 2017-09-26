import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'internal/dialog.dart' as internal;

abstract class UIPlugin {
  static UIPlugin current;

  Widget buildAlign(BuildContext context, Align widget) {
    return widget.child;
  }

  Widget buildAppBar(BuildContext context, AppBar widget) {
    throw new UnimplementedError();
  }

  Widget buildAspectRatio(BuildContext context, AspectRatio widget) {
    throw new UnimplementedError();
  }

  Widget buildBackdropFilter(BuildContext context, BackdropFilter widget) {
    throw new UnimplementedError();
  }

  Widget buildBanner(BuildContext context, Banner widget) {
    return widget.child;
  }

  Widget buildBaseline(BuildContext context, Baseline widget) {
    throw new UnimplementedError();
  }

  Widget buildBottomNavigationBar(
      BuildContext context, BottomNavigationBar widget);

  Widget buildCard(BuildContext context, Card widget);

  Widget buildCheckbox(BuildContext context, Checkbox widget);

  Widget buildChip(BuildContext context, Chip widget);

  Widget buildCircularProgressIndicator(
      BuildContext context, CircularProgressIndicator widget) {
    return buildProgressIndicator(context, widget);
  }

  Widget buildClipOval(BuildContext context, ClipOval widget) {
    return widget.child;
  }

  Widget buildClipPath(BuildContext context, ClipPath widget) {
    throw new UnimplementedError();
  }

  Widget buildClipRect(BuildContext context, ClipRect widget) {
    return widget.child;
  }

  Widget buildClipRRect(BuildContext context, ClipRRect widget) {
    return widget.child;
  }

  Widget buildConstrainedBox(BuildContext context, ConstrainedBox widget) {
    return widget.child;
  }

  Widget buildCupertinoButton(BuildContext context, CupertinoButton widget) {
    return new FlatButton(child: widget.child, onPressed: widget.onPressed);
  }

  Widget buildCupertinoNavigationBar(
      BuildContext context, CupertinoNavigationBar widget);

  Widget buildCupertinoScaffold(BuildContext context, CupertinoScaffold widget);

  Widget buildCupertinoSlider(BuildContext context, CupertinoSlider widget) {
    return new Slider(
        value: widget.value,
        min: widget.min,
        max: widget.max,
        onChanged: widget.onChanged);
  }

  Widget buildCupertinoSwitch(BuildContext context, CupertinoSwitch widget) {
    return new Switch(value: widget.value, onChanged: widget.onChanged);
  }

  Widget buildCupertinoTabBar(BuildContext context, CupertinoTabBar widget) {
    return new BottomNavigationBar(items: widget.items);
  }

  Widget buildCustomPaint(BuildContext context, CustomPaint widget);

  Widget buildDayPicker(BuildContext context, DayPicker widget);

  Widget buildDraggable(BuildContext context, Draggable widget) {
    return widget.child;
  }

  Widget buildDragTarget(BuildContext context, DragTarget widget) {
    return widget.builder(context, const [], const []);
  }

  Widget buildDrawer(BuildContext context, Drawer widget) {
    throw new UnimplementedError();
  }

  Widget buildDropdownButton(BuildContext context, DropdownButton widget);

  Widget buildDropdownMenuItem(BuildContext context, DropdownMenuItem widget) {
    return widget.child;
  }

  Widget buildEditableText(BuildContext context, EditableText widget);

  Widget buildErrorWidget(BuildContext context, ErrorWidget widget) {
    throw new UnimplementedError();
  }

  Widget buildFittedBox(BuildContext context, FittedBox widget) {
    throw new UnimplementedError();
  }

  Widget buildFlatButton(BuildContext context, FlatButton widget);

  Widget buildFlex(BuildContext context, Flex widget);

  Widget buildFlexible(BuildContext context, Flexible widget) {
    throw new UnimplementedError();
  }

  Widget buildFloatingActionButton(
      BuildContext context, FloatingActionButton widget);

  Widget buildFlow(BuildContext context, Flow widget) {
    throw new UnimplementedError();
  }

  Widget buildFractionallySizedBox(
      BuildContext context, FractionallySizedBox widget) {
    return widget.child;
  }

  Widget buildFractionalTranslation(
      BuildContext context, FractionalTranslation widget) {
    throw new UnimplementedError();
  }

  Widget buildGestureDetector(BuildContext context, GestureDetector widget) {
    return widget.child;
  }

  Widget buildGridView(BuildContext context, GridView widget);

  Widget buildHero(BuildContext context, Hero widget) => widget.child;

  Widget buildIcon(BuildContext context, Icon widget) {
    final icon = widget.icon;
    final textString = new String.fromCharCode(icon.codePoint);
    final style = new TextStyle(fontFamily: icon.fontFamily);
    return new RichText(text: new TextSpan(text: textString, style: style));
  }

  Widget buildIconButton(BuildContext context, IconButton widget);

  Widget buildImage(BuildContext context, Image widget);

  Widget buildInputDecorator(BuildContext context, InputDecorator widget) =>
      widget.child;

  Widget buildIntrinsicHeight(BuildContext context, IntrinsicHeight widget) {
    throw new UnimplementedError();
  }

  Widget buildIntrinsicWidth(BuildContext context, IntrinsicWidth widget) {
    throw new UnimplementedError();
  }

  Widget buildKeepAlive(BuildContext context, KeepAlive widget) {
    return widget.child;
  }

  Widget buildLayoutId(BuildContext context, LayoutId widget) {
    return widget.child;
  }

  Widget buildLimitedBox(BuildContext context, LimitedBox widget) {
    throw new UnimplementedError();
  }

  Widget buildLinearProgressIndicator(
      BuildContext context, LinearProgressIndicator widget) {
    return buildProgressIndicator(context, widget);
  }

  Widget buildListBody(BuildContext context, ListBody widget) {
    throw new UnimplementedError();
  }

  Widget buildListView(BuildContext context, ListView widget);

  Widget buildMaterialApp(BuildContext context, MaterialApp widget) {
    return new WidgetsApp(
        key: new GlobalObjectKey(this),
        title: widget.title,
        onGenerateTitle: widget.onGenerateTitle,
        textStyle: const TextStyle(),
        // blue is the primary color of the default theme
        color: widget.color ?? widget.theme?.primaryColor ?? Colors.blue,
        navigatorObservers:
            new List<NavigatorObserver>.from(widget.navigatorObservers),
        initialRoute: widget.initialRoute,
        onGenerateRoute: widget.onGenerateRoute ??
            (route) {
              print("Generating route: ${route.name}");
            },
        onUnknownRoute: widget.onUnknownRoute ??
            (route) {
              print("Unknown route: ${route.name}");
            },
        locale: widget.locale ?? new Locale("en", "US"),
        localizationsDelegates: widget.localizationsDelegates,
        localeResolutionCallback: widget.localeResolutionCallback,
        supportedLocales: widget.supportedLocales,
        showPerformanceOverlay: widget.showPerformanceOverlay,
        checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
        checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
        showSemanticsDebugger: widget.showSemanticsDebugger,
        debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner);
  }

  Widget buildMaterialButton(BuildContext context, MaterialButton widget);

  Widget buildMergeableMaterial(
      BuildContext context, MergeableMaterial widget) {
    final children = widget.children
        .map((item) {
          if (item is MaterialSlice) {
            throw new UnimplementedError();
          }
          if (item is MaterialGap) {
            throw new UnimplementedError();
          }
          throw new UnimplementedError();
        })
        .where((item) => item != null)
        .toList();
    return new Flex(direction: widget.mainAxis, children: children);
  }

  Widget buildMonthPicker(BuildContext context, MonthPicker widget);

  Widget buildNavigationToolbar(BuildContext context, NavigationToolbar widget);

  Widget buildNestedScrollView(BuildContext context, NestedScrollView widget) {
    throw new UnimplementedError();
  }

  Widget buildOffstage(BuildContext context, Offstage widget);

  Widget buildOpacity(BuildContext context, Opacity widget) {
    throw new UnimplementedError();
  }

  Widget buildOverflowBox(BuildContext context, OverflowBox widget) {
    throw new UnimplementedError();
  }

  Widget buildOverlay(BuildContext context, Overlay widget) {
    return widget.initialEntries.first.builder(context);
  }

  Widget buildPadding(BuildContext context, Padding widget) {
    return widget.child;
  }

  Widget buildPhysicalModel(BuildContext context, PhysicalModel widget) {
    throw new UnimplementedError();
  }

  Widget buildPopupMenuButton(BuildContext context, PopupMenuButton widget);

  Widget buildPositioned(BuildContext context, Positioned widget);

  Widget buildPreferredSize(BuildContext context, PreferredSize widget) {
    return widget.child;
  }

  Widget buildProgressIndicator(BuildContext context, ProgressIndicator widget);

  Widget buildRadio(BuildContext context, Radio widget);

  Widget buildRaisedButton(BuildContext context, RaisedButton widget);

  Widget buildRawImage(BuildContext context, RawImage widget) {
    throw new UnimplementedError();
  }

  Widget buildRefreshProgressIndicator(
      BuildContext context, RefreshProgressIndicator widget) {
    return buildProgressIndicator(context, widget);
  }

  Widget buildRichText(BuildContext context, RichText widget);

  Widget buildRotatedBox(BuildContext context, RotatedBox widget) {
    throw new UnimplementedError();
  }

  Widget buildScaffold(BuildContext context, Scaffold widget);

  Widget buildScrollView(BuildContext context, ScrollView widget);

  Widget buildShaderMask(BuildContext context, ShaderMask widget) {
    throw new UnimplementedError();
  }

  Widget buildShrinkWrappingViewport(
      BuildContext context, ShrinkWrappingViewport widget) {
    throw new UnimplementedError();
  }

  Widget buildSingleChildScrollView(
          BuildContext context, SingleChildScrollView widget) =>
      widget.child;

  Widget buildSizedBox(BuildContext context, SizedBox widget) {
    return widget.child;
  }

  Widget buildSizedOverflowBox(BuildContext context, SizedOverflowBox widget) {
    throw new UnimplementedError();
  }

  Widget buildSlider(BuildContext context, Slider widget);

  Widget buildSliverAppBar(BuildContext context, SliverAppBar widget) {
    throw new UnimplementedError();
  }

  Widget buildSnackBar(BuildContext context, SnackBar widget);

  Widget buildStack(BuildContext context, Stack widget);

  Widget buildStatefulWidget(BuildContext context, StatefulWidget widget);

  Widget buildStepper(BuildContext context, Stepper widget);

  Widget buildSwitch(BuildContext context, Switch widget);

  Widget buildTab(BuildContext context, Tab widget);

  Widget buildTabBar(BuildContext context, TabBar widget);

  Widget buildTabBarView(BuildContext context, TabBarView widget);

  Widget buildTable(BuildContext context, Table widget);

  Widget buildTableCell(BuildContext context, TableCell widget) {
    return widget.child;
  }

  Widget buildText(BuildContext context, Text widget);

  Widget buildTextField(BuildContext context, TextField widget);

  Widget buildTitle(BuildContext context, Title widget) {
    return widget.child;
  }

  Widget buildTooltip(BuildContext context, Tooltip widget);

  Widget buildTransform(BuildContext context, Transform widget) {
    throw new UnimplementedError();
  }

  Widget buildViewport(BuildContext context, Viewport widget) {
    throw new UnimplementedError();
  }

  Widget builWidgetsApp(BuildContext context, WidgetsApp widget) {
    final navigatorKey = new GlobalObjectKey<NavigatorState>(this);
    return new Navigator(
      key: navigatorKey,
      initialRoute: widget.initialRoute ?? ui.window.defaultRouteName,
      onGenerateRoute: widget.onGenerateRoute ?? new MaterialPageRoute<Null>(builder:(c)=>new Text("No routes defines")),
      onUnknownRoute: widget.onUnknownRoute ?? new MaterialPageRoute<Null>(builder:(c)=>new Text("Unknown route")),
      observers: widget.navigatorObservers,
    );
  }

  Widget buildWrap(BuildContext context, Wrap widget);

  Widget buildYearPicker(BuildContext context, YearPicker widget);

  OverlayState createOverlayState(Overlay overlay);

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
    return internal.showDialog(
        context: context, barrierDismissible: barrierDismissible, child: child);
  }

  Future<T> showMenu<T>(
      {@required BuildContext context,
      RelativeRect position,
      @required List<PopupMenuEntry<T>> items,
      T initialValue,
      double elevation: 8.0});

  Future<TimeOfDay> showTimePicker(
      {@required BuildContext context, @required TimeOfDay initialTime}) {
    throw new UnimplementedError();
  }
}
