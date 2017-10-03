// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'box.dart';
import 'object.dart';

/// A delegate that controls the layout of multiple children.
///
/// Delegates must be idempotent. Specifically, if two delegates are equal, then
/// they must produce the same layout. To change the layout, replace the
/// delegate with a different instance whose [shouldRelayout] returns true when
/// given the previous instance.
///
/// Override [getSize] to control the overall size of the layout. The size of
/// the layout cannot depend on layout properties of the children.
///
/// Override [performLayout] to size and position the children. An
/// implementation of [performLayout] must call [layoutChild] exactly once for
/// each child, but it may call [layoutChild] on children in an arbitrary order.
/// Typically a delegate will use the size returned from [layoutChild] on one
/// child to determine the constraints for [performLayout] on another child or
/// to determine the offset for [positionChild] for that child or another child.
///
/// Override [shouldRelayout] to determine when the layout of the children needs
/// to be recomputed when the delegate changes.
///
/// Used with [CustomMultiChildLayout], the widget for the
/// [RenderCustomMultiChildLayoutBox] render object.
///
/// ## Example
///
/// Below is an example implementation of [performLayout] that causes one widget
/// to be the same size as another:
///
/// ```dart
/// @override
/// void performLayout(Size size) {
///   Size followerSize = Size.zero;
///
///   if (hasChild(_Slots.leader) {
///     followerSize = layoutChild(_Slots.leader, new BoxConstraints.loose(size));
///     positionChild(_Slots.leader, Offset.zero);
///   }
///
///   if (hasChild(_Slots.follower)) {
///     layoutChild(_Slots.follower, new BoxConstraints.tight(followerSize));
///     positionChild(_Slots.follower, new Offset(size.width - followerSize.width,
///                                               size.height - followerSize.height));
///   }
/// }
/// ```
///
/// The delegate gives the leader widget loose constraints, which means the
/// child determines what size to be (subject to fitting within the given size).
/// The delegate then remembers the size of that child and places it in the
/// upper left corner.
///
/// The delegate then gives the follower widget tight constraints, forcing it to
/// match the size of the leader widget. The delegate then places the follower
/// widget in the bottom right corner.
///
/// The leader and follower widget will paint in the order they appear in the
/// child list, regardless of the order in which [layoutChild] is called on
/// them.
abstract class MultiChildLayoutDelegate {
  Map<Object, RenderBox> _idToChild;
  Set<RenderBox> _debugChildrenNeedingLayout;

  /// True if a non-null LayoutChild was provided for the specified id.
  ///
  /// Call this from the [performLayout] or [getSize] methods to
  /// determine which children are available, if the child list might
  /// vary.
  bool hasChild(Object childId) => _idToChild[childId] != null;

  /// Ask the child to update its layout within the limits specified by
  /// the constraints parameter. The child's size is returned.
  ///
  /// Call this from your [performLayout] function to lay out each
  /// child. Every child must be laid out using this function exactly
  /// once each time the [performLayout] function is called.
  Size layoutChild(Object childId, BoxConstraints constraints) {
    final RenderBox child = _idToChild[childId];
    assert(() {
      if (child == null) {
        throw new FlutterError(
            'The $this custom multichild layout delegate tried to lay out a non-existent child.\n'
            'There is no child with the id "$childId".');
      }
      if (!_debugChildrenNeedingLayout.remove(child)) {
        throw new FlutterError(
            'The $this custom multichild layout delegate tried to lay out the child with id "$childId" more than once.\n'
            'Each child must be laid out exactly once.');
      }
      try {
        assert(constraints.debugAssertIsValid(isAppliedConstraint: true));
      } on AssertionError catch (exception) {
        throw new FlutterError(
            'The $this custom multichild layout delegate provided invalid box constraints for the child with id "$childId".\n'
            '$exception\n'
            'The minimum width and height must be greater than or equal to zero.\n'
            'The maximum width must be greater than or equal to the minimum width.\n'
            'The maximum height must be greater than or equal to the minimum height.');
      }
      return true;
    });
    ;
    return null;
  }

  /// Specify the child's origin relative to this origin.
  ///
  /// Call this from your [performLayout] function to position each
  /// child. If you do not call this for a child, its position will
  /// remain unchanged. Children initially have their position set to
  /// (0,0), i.e. the top left of the [RenderCustomMultiChildLayoutBox].
  void positionChild(Object childId, Offset offset) {
    final RenderBox child = _idToChild[childId];
    assert(() {
      if (child == null) {
        throw new FlutterError(
            'The $this custom multichild layout delegate tried to position out a non-existent child:\n'
            'There is no child with the id "$childId".');
      }
      if (offset == null) {
        throw new FlutterError(
            'The $this custom multichild layout delegate provided a null position for the child with id "$childId".');
      }
      return true;
    });
  }

  /// Override this method to return the size of this object given the
  /// incoming constraints.
  ///
  /// The size cannot reflect the sizes of the children. If this layout has a
  /// fixed width or height the returned size can reflect that; the size will be
  /// constrained to the given constraints.
  ///
  /// By default, attempts to size the box to the biggest size
  /// possible given the constraints.
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  /// Override this method to lay out and position all children given this
  /// widget's size.
  ///
  /// This method must call [layoutChild] for each child. It should also specify
  /// the final position of each child with [positionChild].
  void performLayout(Size size);

  /// Override this method to return true when the children need to be
  /// laid out.
  ///
  /// This should compare the fields of the current delegate and the given
  /// `oldDelegate` and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate);

  /// Override this method to include additional information in the
  /// debugging data printed by [debugDumpRenderTree] and friends.
  ///
  /// By default, returns the [runtimeType] of the class.
  @override
  String toString() => '$runtimeType';
}
