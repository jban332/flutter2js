// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'bottom_tab_bar.dart';
import 'nav_bar.dart';

/// Implements a basic iOS application's layout and behavior structure.
///
/// The scaffold lays out the navigation bar on top, the tab bar at the bottom
/// and tabbed or untabbed content between or behind the bars.
///
/// For tabbed scaffolds, the tab's active item and the actively showing tab
/// in the content area are automatically connected.
// TODO(xster): describe navigator handlings.
// TODO(xster): add an example.
class CupertinoScaffold extends flur.StatelessUIPluginWidget {
  /// Construct a [CupertinoScaffold] without tabs.
  ///
  /// The [tabBar] and [rootTabPageBuilder] fields are not used in a [CupertinoScaffold]
  /// without tabs.
  // TODO(xster): document that page transitions will happen behind the navigation
  // bar.
  const CupertinoScaffold({
    Key key,
    this.navigationBar,
    @required this.child,
  })
      : tabBar = null,
        rootTabPageBuilder = null,
        super(key: key);

  /// Construct a [CupertinoScaffold] with tabs.
  ///
  /// A [tabBar] and a [rootTabPageBuilder] are required. The [CupertinoScaffold]
  /// will automatically listen to the provided [CupertinoTabBar]'s tap callbacks
  /// to change the active tab.
  ///
  /// Tabs' contents are built with the provided [rootTabPageBuilder] at the active
  /// tab index. [rootTabPageBuilder] must be able to build the same number of
  /// pages as the [tabBar.items.length]. Inactive tabs will be moved [Offstage]
  /// and its animations disabled.
  ///
  /// The [child] field is not used in a [CupertinoScaffold] with tabs.
  const CupertinoScaffold.tabbed({
    Key key,
    this.navigationBar,
    @required this.tabBar,
    @required this.rootTabPageBuilder,
  })
      : child = null,
        super(key: key);

  /// The [navigationBar], typically a [CupertinoNavigationBar], is drawn at the
  /// top of the screen.
  ///
  /// If translucent, the main content may slide behind it.
  /// Otherwise, the main content's top margin will be offset by its height.
  // TODO(xster): document its page transition animation when ready
  final PreferredSizeWidget navigationBar;

  /// The [tabBar] is a [CupertinoTabBar] drawn at the bottom of the screen
  /// that lets the user switch between different tabs in the main content area
  /// when present.
  ///
  /// This parameter is required and must be non-null when the [new CupertinoScaffold.tabbed]
  /// constructor is used.
  ///
  /// When provided, [CupertinoTabBar.currentIndex] will be ignored and will
  /// be managed by the [CupertinoScaffold] to show the currently selected page
  /// as the active item index. If [CupertinoTabBar.onTap] is provided, it will
  /// still be called. [CupertinoScaffold] automatically also listen to the
  /// [CupertinoTabBar]'s `onTap` to change the [CupertinoTabBar]'s `currentIndex`
  /// and change the actively displayed tab in [CupertinoScaffold]'s own
  /// main content area.
  ///
  /// If translucent, the main content may slide behind it.
  /// Otherwise, the main content's bottom margin will be offset by its height.
  final CupertinoTabBar tabBar;

  /// An [IndexedWidgetBuilder] that's called when tabs become active.
  ///
  /// Used when a tabbed scaffold is constructed via the [new CupertinoScaffold.tabbed]
  /// constructor and must be non-null.
  ///
  /// When the tab becomes inactive, its content is still cached in the widget
  /// tree [Offstage] and its animations disabled.
  ///
  /// Content can slide under the [navigationBar] or the [tabBar] when they're
  /// translucent.
  final IndexedWidgetBuilder rootTabPageBuilder;

  /// Widget to show in the main content area when the scaffold is used without
  /// tabs.
  ///
  /// Used when the default [new CupertinoScaffold] constructor is used and must
  /// be non-null.
  ///
  /// Content can slide under the [navigationBar] or the [tabBar] when they're
  /// translucent.
  final Widget child;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildCupertinoScaffold(context, this);
  }
}
