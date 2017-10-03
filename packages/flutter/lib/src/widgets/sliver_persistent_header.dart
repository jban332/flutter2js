// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'framework.dart';

/// Delegate for configuring a [SliverPersistentHeader].
abstract class SliverPersistentHeaderDelegate {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SliverPersistentHeaderDelegate();

  /// The widget to place inside the [SliverPersistentHeader].
  ///
  /// The `context` is the [BuildContext] of the sliver.
  ///
  /// The `shrinkOffset` is a distance from [maxExtent] towards [minExtent]
  /// representing the current amount by which the sliver has been shrunk. When
  /// the `shrinkOffset` is zero, the contents will be rendered with a dimension
  /// of [maxExtent] in the main axis. When `shrinkOffset` equals the difference
  /// between [maxExtent] and [minExtent] (a positive number), the contents will
  /// be rendered with a dimension of [minExtent] in the main axis. The
  /// `shrinkOffset` will always be a positive number in that range.
  ///
  /// The `overlapsContent` argument is true if subsequent slivers (if any) will
  /// be rendered beneath this one, and false if the sliver will not have any
  /// contents below it. Typically this is used to decide whether to draw a
  /// shadow to simulate the sliver being above the contents below it. Typically
  /// this is true when `shrinkOffset` is at its greatest value and false
  /// otherwise, but that is not guaranteed. See [NestedScrollView] for an
  /// example of a case where `overlapsContent`'s value can be unrelated to
  /// `shrinkOffset`.
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent);

  /// The smallest size to allow the header to reach, when it shrinks at the
  /// start of the viewport.
  ///
  /// This must return a value equal to or less than [maxExtent].
  ///
  /// This value should not change over the lifetime of the delegate. It should
  /// be based entirely on the constructor arguments passed to the delegate. See
  /// [shouldRebuild], which must return true if a new delegate would return a
  /// different value.
  double get minExtent;

  /// The size of the header when it is not shrinking at the top of the
  /// viewport.
  ///
  /// This must return a value equal to or greater than [minExtent].
  ///
  /// This value should not change over the lifetime of the delegate. It should
  /// be based entirely on the constructor arguments passed to the delegate. See
  /// [shouldRebuild], which must return true if a new delegate would return a
  /// different value.
  double get maxExtent;

  /// Specifies how floating headers should animate in and out of view.
  ///
  /// If the value of this property is null, then floating headers will
  /// not animate into place.
  ///
  /// This is only used for floating headers (those with
  /// [SliverPersistentHeader.floating] set to true).
  ///
  /// Defaults to null.
  FloatingHeaderSnapConfiguration get snapConfiguration => null;

  /// Whether this delegate is meaningfully different from the old delegate.
  ///
  /// If this returns false, then the header might not be rebuilt, even though
  /// the instance of the delegate changed.
  ///
  /// This must return true if `oldDelegate` and this object would return
  /// different values for [minExtent], [maxExtent], [snapConfiguration], or
  /// would return a meaningfully different widget tree from [build] for the
  /// same arguments.
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate);
}

/// A sliver whose size varies when the sliver is scrolled to the leading edge
/// of the viewport.
///
/// This is the layout primitive that [SliverAppBar] uses for its
/// shrinking/growing effect.
class SliverPersistentHeader extends StatelessWidget {
  /// Creates a sliver that varies its size when it is scrolled to the start of
  /// a viewport.
  ///
  /// The [delegate], [pinned], and [floating] arguments must not be null.
  const SliverPersistentHeader({
    Key key,
    @required this.delegate,
    this.pinned: false,
    this.floating: false,
  })
      : super(key: key);

  /// Configuration for the sliver's layout.
  ///
  /// The delegate provides the following information:
  ///
  ///  * The minimum and maximum dimensions of the sliver.
  ///
  ///  * The builder for generating the widgets of the sliver.
  ///
  ///  * The instructions for snapping the scroll offset, if [floating] is true.
  final SliverPersistentHeaderDelegate delegate;

  /// Whether to stick the header to the start of the viewport once it has
  /// reached its minimum size.
  ///
  /// If this is false, the header will continue scrolling off the screen after
  /// it has shrunk to its minimum extent.
  final bool pinned;

  /// Whether the header should immediately grow again if the user reverses
  /// scroll direction.
  ///
  /// If this is false, the header only grows again once the user reaches the
  /// part of the viewport that contains the sliver.
  ///
  /// The [delegate]'s [SliverPersistentHeaderDelegate.snapConfiguration] is
  /// ignored unless [floating] is true.
  final bool floating;

  @override
  Widget build(BuildContext context) {
    return delegate.build(context, 0.0, false);
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new DiagnosticsProperty<SliverPersistentHeaderDelegate>(
        'delegate', delegate));
    final List<String> flags = <String>[];
    if (pinned) flags.add('pinned');
    if (floating) flags.add('floating');
    if (flags.isEmpty) flags.add('normal');
    description.add(new IterableProperty<String>('mode', flags));
  }
}
