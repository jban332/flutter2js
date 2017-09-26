// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Defines the layout and behavior of a [BottomNavigationBar].
///
/// See also:
///
///  * [BottomNavigationBar]
///  * [BottomNavigationBarItem]
///  * <https://material.google.com/components/bottom-navigation.html#bottom-navigation-specs>
enum BottomNavigationBarType {
  /// The [BottomNavigationBar]'s [BottomNavigationBarItem]s have fixed width.
  fixed,

  /// The location and size of the [BottomNavigationBar] [BottomNavigationBarItem]s
  /// animate larger when they are tapped.
  shifting,
}

/// A material widget displayed at the bottom of an app for selecting among a
/// small number of views.
///
/// The bottom navigation bar consists of multiple items in the form of
/// labels, icons, or both, laid out on top of a piece of material. It provides
/// quick navigation between the top-level views of an app. For larger screens,
/// side navigation may be a better fit.
///
/// A bottom navigation bar is usually used in conjunction with [Scaffold] where
/// it is provided as the [Scaffold.bottomNavigationBar] argument.
///
/// See also:
///
///  * [BottomNavigationBarItem]
///  * [Scaffold]
///  * <https://material.google.com/components/bottom-navigation.html>
class BottomNavigationBar extends flur.StatelessUIPluginWidget {
  /// Creates a bottom navigation bar, typically used in a [Scaffold] where it
  /// is provided as the [Scaffold.bottomNavigationBar] argument.
  ///
  /// The arguments [items] and [type] should not be null.
  ///
  /// The number of items passed should be equal or greater than 2.
  ///
  /// Passing a null [fixedColor] will cause a fallback to the theme's primary
  /// color.
  BottomNavigationBar({
    Key key,
    @required this.items,
    this.onTap,
    this.currentIndex: 0,
    this.type: BottomNavigationBarType.fixed,
    this.fixedColor,
    this.iconSize: 24.0,
  })
      : super(key: key);

  /// The interactive items laid out within the bottom navigation bar.
  final List<BottomNavigationBarItem> items;

  /// The callback that is called when a item is tapped.
  ///
  /// The widget creating the bottom navigation bar needs to keep track of the
  /// current index and call `setState` to rebuild it with the newly provided
  /// index.
  final ValueChanged<int> onTap;

  /// The index into [items] of the current active item.
  final int currentIndex;

  /// Defines the layout and behavior of a [BottomNavigationBar].
  final BottomNavigationBarType type;

  /// The color of the selected item when bottom navigation bar is
  /// [BottomNavigationBarType.fixed].
  final Color fixedColor;

  /// The size of all of the [BottomNavigationBarItem] icons.
  ///
  /// This value is used to to configure the [IconTheme] for the navigation
  /// bar. When a [BottomNavigationBarItem.icon] widget is not an [Icon] the widget
  /// should configure itself to match the icon theme's size and color.
  final double iconSize;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildBottomNavigationBar(context, this);
  }
}
