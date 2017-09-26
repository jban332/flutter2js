// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'colors.dart';

/// Standard iOS nav bar height without the status bar.
const double _kNavBarPersistentHeight = 44.0;

/// Size increase from expanding the nav bar into an iOS 11 style large title
/// form in a [CustomScrollView].
const double _kNavBarLargeTitleHeightExtension = 56.0;

/// Number of logical pixels scrolled down before the title text is transferred
/// from the normal nav bar to a big title below the nav bar.
const double _kNavBarShowLargeTitleThreshold = 10.0;

const double _kNavBarEdgePadding = 16.0;

/// Title text transfer fade.
const Duration _kNavBarTitleFadeDuration = const Duration(milliseconds: 150);

const Color _kDefaultNavBarBackgroundColor = const Color(0xCCF8F8F8);
const Color _kDefaultNavBarBorderColor = const Color(0x4C000000);

const TextStyle _kLargeTitleTextStyle = const TextStyle(
  fontSize: 34.0,
  fontWeight: FontWeight.bold,
  letterSpacing: 0.41,
  color: CupertinoColors.black,
);

/// An iOS-styled navigation bar.
///
/// The navigation bar is a toolbar that minimally consists of a widget, normally
/// a page title, in the [middle] of the toolbar.
///
/// It also supports a [leading] and [trailing] widget before and after the
/// [middle] widget while keeping the [middle] widget centered.
///
/// It should be placed at top of the screen and automatically accounts for
/// the OS's status bar.
///
/// If the given [backgroundColor]'s opacity is not 1.0 (which is the case by
/// default), it will produce a blurring effect to the content behind it.
///
/// Enabling [largeTitle] will create a scrollable second row showing the title
/// in a larger font introduced in iOS 11. The [middle] widget must be a text
/// and the [CupertinoNavigationBar] must be placed in a sliver group in this case.
//
// TODO(xster): document automatic addition of a CupertinoBackButton.
// TODO(xster): add sample code using icons.
// TODO(xster): document integration into a CupertinoScaffold.
class CupertinoNavigationBar extends flur.StatelessUIPluginWidget
    implements PreferredSizeWidget {
  /// Creates a navigation bar in the iOS style.
  const CupertinoNavigationBar({
    Key key,
    this.leading,
    @required this.middle,
    this.trailing,
    this.backgroundColor: _kDefaultNavBarBackgroundColor,
    this.actionsForegroundColor: CupertinoColors.activeBlue,
    this.largeTitle: false,
  })
      : super(key: key);

  /// Widget to place at the start of the nav bar. Normally a back button
  /// for a normal page or a cancel button for full page dialogs.
  final Widget leading;

  /// Widget to place in the middle of the nav bar. Normally a title or
  /// a segmented control.
  final Widget middle;

  /// Widget to place at the end of the nav bar. Normally additional actions
  /// taken on the page such as a search or edit function.
  final Widget trailing;

  // TODO(xster): implement support for double row nav bars.

  /// The background color of the nav bar. If it contains transparency, the
  /// tab bar will automatically produce a blurring effect to the content
  /// behind it.
  final Color backgroundColor;

  /// Default color used for text and icons of the [leading] and [trailing]
  /// widgets in the nav bar.
  ///
  /// The default color for text in the [middle] slot is always black, as per
  /// iOS standard design.
  final Color actionsForegroundColor;

  /// True if the nav bar's background color has no transparency.
  bool get opaque => backgroundColor.alpha == 0xFF;

  /// Use iOS 11 style large title navigation bars.
  ///
  /// When true, the navigation bar will split into 2 sections. The static
  /// top 44px section will be wrapped in a SliverPersistentHeader and a
  /// second scrollable section behind it will show and replace the `middle`
  /// text in a larger font when scrolled down.
  ///
  /// Navigation bars with large titles must be used in a sliver group such
  /// as [CustomScrollView].
  final bool largeTitle;

  @override
  Size get preferredSize => const Size.fromHeight(_kNavBarPersistentHeight);

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildCupertinoNavigationBar(context, this);
  }
}
