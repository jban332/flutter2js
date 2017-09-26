// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A material design tooltip.
///
/// Tooltips provide text labels that help explain the function of a button or
/// other user interface action. Wrap the button in a [Tooltip] widget to
/// show a label when the widget long pressed (or when the user takes some
/// other appropriate action).
///
/// Many widgets, such as [IconButton], [FloatingActionButton], and
/// [PopupMenuButton] have a `tooltip` property that, when non-null, causes the
/// widget to include a [Tooltip] in its build.
///
/// Tooltips improve the accessibility of visual widgets by proving a textual
/// representation of the widget, which, for example, can be vocalized by a
/// screen reader.
///
/// See also:
///
///  * <https://material.google.com/components/tooltips.html>
class Tooltip extends flur.StatelessUIPluginWidget {
  /// Creates a tooltip.
  ///
  /// By default, tooltips prefer to appear below the [child] widget when the
  /// user long presses on the widget.
  ///
  /// The [message] argument cannot be null.
  const Tooltip({
    Key key,
    @required this.message,
    this.height: 32.0,
    this.padding: const EdgeInsets.symmetric(horizontal: 16.0),
    this.verticalOffset: 24.0,
    this.preferBelow: true,
    @required this.child,
  })
      : super(key: key);

  /// The text to display in the tooltip.
  final String message;

  /// The amount of vertical space the tooltip should occupy (inside its padding).
  final double height;

  /// The amount of space by which to inset the child.
  ///
  /// Defaults to 16.0 logical pixels in each direction.
  final EdgeInsets padding;

  /// The amount of vertical distance between the widget and the displayed tooltip.
  final double verticalOffset;

  /// Whether the tooltip defaults to being displayed below the widget.
  ///
  /// Defaults to true. If there is insufficient space to display the tooltip in
  /// the preferred direction, the tooltip will be displayed in the opposite
  /// direction.
  final bool preferBelow;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  void debugFillProperties(description) {
    super.debugFillProperties(description);
    description.add(new StringProperty('message', message, showName: false));
    description.add(new DoubleProperty('vertical offset', verticalOffset));
    description.add(new FlagProperty('position',
        value: preferBelow, ifTrue: 'below', ifFalse: 'above', showName: true));
  }

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildTooltip(context, this);
  }
}
