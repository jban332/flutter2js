// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/widgets.dart';

// TODO(eseidel): Draw width should vary based on device size:
// http://material.google.com/layout/structure.html#structure-side-nav

// Mobile:
// Width = Screen width − 56 dp
// Maximum width: 320dp
// Maximum width applies only when using a left nav. When using a right nav,
// the panel can cover the full width of the screen.

// Desktop/Tablet:
// Maximum width for a left nav is 400dp.
// The right nav can vary depending on content.

const double _kWidth = 304.0;
const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;
const Duration _kBaseSettleDuration = const Duration(milliseconds: 246);

/// A material design panel that slides in horizontally from the edge of a
/// [Scaffold] to show navigation links in an application.
///
/// Drawers are typically used with the [Scaffold.drawer] property. The child of
/// the drawer is usually a [ListView] whose first child is a [DrawerHeader]
/// that displays status information about the current user. The remaining
/// drawer children are often constructed with [ListTile]s, often concluding
/// with an [AboutListTile].
///
/// An open drawer can be closed by calling [Navigator.pop]. For example
/// a drawer item might close the drawer when tapped:
///
/// ```dart
/// new ListTile(
///   leading: new Icon(Icons.change_history),
///   title: new Text('Change history'),
///   onTap: () {
///     // change app state...
///     Navigator.pop(context); // close the drawer
///   },
/// );
/// ```
///
/// The [AppBar] automatically displays an appropriate [IconButton] to show the
/// [Drawer] when a [Drawer] is available in the [Scaffold]. The [Scaffold]
/// automatically handles the edge-swipe gesture to show the drawer.
///
/// See also:
///
///  * [Scaffold.drawer], where one specifies a [Drawer] so that it can be
///    shown.
///  * [Scaffold.of], to obtain the current [ScaffoldState], which manages the
///    display and animation of the drawer.
///  * [ScaffoldState.openDrawer], which displays its [Drawer], if any.
///  * <https://material.google.com/patterns/navigation-drawer.html>
class Drawer extends flur.StatelessUIPluginWidget {
  /// Creates a material design drawer.
  ///
  /// Typically used in the [Scaffold.drawer] property.
  const Drawer({
    Key key,
    this.elevation: 16.0,
    this.child,
  })
      : super(key: key);

  /// The z-coordinate at which to place this drawer. This controls the size of
  /// the shadow below the drawer.
  ///
  /// Defaults to 16, the appropriate elevation for drawers.
  final double elevation;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [SliverList].
  final Widget child;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildDrawer(context, this);
  }
}
