// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';

import 'basic.dart';
import 'framework.dart';

const Duration _kDismissDuration = const Duration(milliseconds: 200);
const Curve _kResizeTimeCurve = const Interval(0.4, 1.0, curve: Curves.ease);
const double _kMinFlingVelocity = 700.0;
const double _kMinFlingVelocityDelta = 400.0;
const double _kFlingVelocityScale = 1.0 / 300.0;
const double _kDismissThreshold = 0.4;

/// Signature used by [Dismissible] to indicate that it has been dismissed in
/// the given `direction`.
///
/// Used by [Dismissible.onDismissed].
typedef void DismissDirectionCallback(DismissDirection direction);

/// The direction in which a [Dismissible] can be dismissed.
enum DismissDirection {
  /// The [Dismissible] can be dismissed by dragging either up or down.
  vertical,

  /// The [Dismissible] can be dismissed by dragging either left or right.
  horizontal,

  /// The [Dismissible] can be dismissed by dragging in the reverse of the
  /// reading direction (e.g., from right to left in left-to-right languages).
  endToStart,

  /// The [Dismissible] can be dismissed by dragging in the reading direction
  /// (e.g., from left to right in left-to-right languages).
  startToEnd,

  /// The [Dismissible] can be dismissed by dragging up only.
  up,

  /// The [Dismissible] can be dismissed by dragging down only.
  down
}

/// A widget that can be dismissed by dragging in the indicated [direction].
///
/// Dragging or flinging this widget in the [DismissDirection] causes the child
/// to slide out of view. Following the slide animation, if [resizeDuration] is
/// non-null, the Dismissible widget animates its height (or width, whichever is
/// perpendicular to the dismiss direction) to zero over the [resizeDuration].
///
/// Backgrounds can be used to implement the "leave-behind" idiom. If a background
/// is specified it is stacked behind the Dismissible's child and is exposed when
/// the child moves.
///
/// The widget calls the [onDismissed] callback either after its size has
/// collapsed to zero (if [resizeDuration] is non-null) or immediately after
/// the slide animation (if [resizeDuration] is null). If the Dismissible is a
/// list item, it must have a key that distinguishes it from the other items and
/// its [onDismissed] callback must remove the item from the list.
class Dismissible extends flur.SingleChildUIPluginWidget {
  /// Creates a widget that can be dismissed.
  ///
  /// The [key] argument must not be null because [Dismissible]s are commonly
  /// used in lists and removed from the list when dismissed. Without keys, the
  /// default behavior is to sync widgets based on their index in the list,
  /// which means the item after the dismissed item would be synced with the
  /// state of the dismissed item. Using keys causes the widgets to sync
  /// according to their keys and avoids this pitfall.
  const Dismissible({
    @required Key key,
    @required this.child,
    this.background,
    this.secondaryBackground,
    this.onResize,
    this.onDismissed,
    this.direction: DismissDirection.horizontal,
    this.resizeDuration: const Duration(milliseconds: 300),
    this.dismissThresholds: const <DismissDirection, double>{},
  })
      : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// A widget that is stacked behind the child. If secondaryBackground is also
  /// specified then this widget only appears when the child has been dragged
  /// down or to the right.
  final Widget background;

  /// A widget that is stacked behind the child and is exposed when the child
  /// has been dragged up or to the left. It may only be specified when background
  /// has also been specified.
  final Widget secondaryBackground;

  /// Called when the widget changes size (i.e., when contracting before being dismissed).
  final VoidCallback onResize;

  /// Called when the widget has been dismissed, after finishing resizing.
  final DismissDirectionCallback onDismissed;

  /// The direction in which the widget can be dismissed.
  final DismissDirection direction;

  /// The amount of time the widget will spend contracting before [onDismissed] is called.
  ///
  /// If null, the widget will not contract and [onDismissed] will be called
  /// immediately after the the widget is dismissed.
  final Duration resizeDuration;

  /// The offset threshold the item has to be dragged in order to be considered dismissed.
  ///
  /// Represented as a fraction, e.g. if it is 0.4, then the item has to be dragged at least
  /// 40% towards one direction to be considered dismissed. Clients can define different
  /// thresholds for each dismiss direction. This allows for use cases where item can be
  /// dismissed to end but not to start.
  final Map<DismissDirection, double> dismissThresholds;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildDismissible(context, this);
  }
}
