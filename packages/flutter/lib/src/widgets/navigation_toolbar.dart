// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;

import 'framework.dart';

/// [NavigationToolbar] is a layout helper to position 3 widgets or groups of
/// widgets along a horizontal axis that's sensible for an application's
/// navigation bar such as in Material Design and in iOS.
///
/// The [leading] and [trailing] widgets occupy the edges of the widget with
/// reasonable size constraints while the [middle] widget occupies the remaining
/// space in either a center aligned or start aligned fashion.
///
/// Either directly use the themed app bars such as the Material [AppBar] or
/// the iOS [CupertinoNavigationBar] or wrap this widget with more theming
/// specifications for your own custom app bar.
class NavigationToolbar extends flur.StatelessUIPluginWidget {
  /// Creates a widget that lays out its children in a manner suitable for a
  /// toolbar.
  const NavigationToolbar({
    Key key,
    this.leading,
    this.middle,
    this.trailing,
    this.centerMiddle: true,
    this.middleSpacing: kMiddleSpacing,
  })
      : super(key: key);

  /// The default spacing around the [middle] widget in dp.
  static const double kMiddleSpacing = 16.0;

  /// Widget to place at the start of the horizontal toolbar.
  final Widget leading;

  /// Widget to place in the middle of the horizontal toolbar, occupying
  /// as much remaining space as possible.
  final Widget middle;

  /// Widget to place at the end of the horizontal toolbar.
  final Widget trailing;

  /// Whether to align the [middle] widget to the center of this widget or
  /// next to the [leading] widget when false.
  final bool centerMiddle;

  /// The spacing around the [middle] widget on horizontal axis.
  ///
  /// Defaults to [kMiddleSpacing].
  final double middleSpacing;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildNavigationToolbar(context, this);
  }
}
