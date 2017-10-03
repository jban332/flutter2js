// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'icon_button.dart';
import 'icons.dart';

/// A widget representing a rotating expand/collapse button. The icon rotates
/// 180 deg when pressed, then reverts the animation on a second press.
/// The underlying icon is [Icons.expand_more].
///
/// See [IconButton] for a more general implementation of a pressable button
/// with an icon.
class ExpandIcon extends flur.StatelessUIPluginWidget {
  /// Creates an [ExpandIcon] with the given padding, and a callback that is
  /// triggered when the icon is pressed.
  const ExpandIcon(
      {Key key,
      this.isExpanded: false,
      this.size: 24.0,
      @required this.onPressed,
      this.padding: const EdgeInsets.all(8.0)})
      : super(key: key);

  /// Whether the icon is in an expanded state.
  ///
  /// Rebuilding the widget with a different [isExpanded] value will trigger
  /// the animation, but will not trigger the [onPressed] callback.
  final bool isExpanded;

  /// The size of the icon.
  ///
  /// This property must not be null. It defaults to 24.0.
  final double size;

  /// The callback triggered when the icon is pressed and the state changes
  /// between expanded and collapsed. The value passed to the current state.
  ///
  /// If this is set to null, the button will be disabled.
  final ValueChanged<bool> onPressed;

  /// The padding around the icon. The entire padded icon will reactb to input
  /// gestures.
  ///
  /// This property must not be null. It defaults to 8.0 padding on all sides.
  final EdgeInsetsGeometry padding;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildExpandIcon(context, this);
  }
}
