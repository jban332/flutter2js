// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

import 'box.dart';
import 'object.dart';

/// A context in which a [FlowDelegate] paints.
///
/// Provides information about the current size of the container and the
/// children and a mechanism for painting children.
///
/// See also:
///
///  * [FlowDelegate]
///  * [Flow]
///  * [RenderFlow]
abstract class FlowPaintingContext {
  /// The size of the container in which the children can be painted.
  Size get size;

  /// The number of children available to paint.
  int get childCount;

  /// The size of the [i]th child.
  ///
  /// If [i] is negative or exceeds [childCount], returns null.
  Size getChildSize(int i);

  /// Paint the [i]th child using the given transform.
  ///
  /// The child will be painted in a coordinate system that concatenates the
  /// container's coordinate system with the given transform. The origin of the
  /// parent's coordinate system is the upper left corner of the parent, with
  /// x increasing rightward and y increasing downward.
  ///
  /// The container will clip the children to its bounds.
  void paintChild(int i, {Matrix4 transform, double opacity: 1.0});
}

/// A delegate that controls the appearance of a flow layout.
///
/// Flow layouts are optimized for moving children around the screen using
/// transformation matrices. For optimal performance, construct the
/// [FlowDelegate] with an [Animation] that ticks whenever the delegate wishes
/// to change the transformation matrices for the children and avoid rebuilding
/// the [Flow] widget itself every animation frame.
///
/// See also:
///
///  * [Flow]
///  * [RenderFlow]
abstract class FlowDelegate {
  /// The flow will repaint whenever [repaint] notifies its listeners.
  const FlowDelegate({Listenable repaint});

  /// Override to control the size of the container for the children.
  ///
  /// By default, the flow will be as large as possible. If this function
  /// returns a size that does not respect the given constraints, the size will
  /// be adjusted to be as close to the returned size as possible while still
  /// respecting the constraints.
  ///
  /// If this function depends on information other than the given constraints,
  /// override [shouldRelayout] to indicate when when the container should
  /// relayout.
  Size getSize(BoxConstraints constraints) => constraints.biggest;

  /// Override to control the layout constraints given to each child.
  ///
  /// By default, the children will receive the given constraints, which are the
  /// constrains the constraints used to size the container. The children need
  /// not respect the given constraints, but they are required to respect the
  /// returned constraints. For example, the incoming constraints might require
  /// the container to have a width of exactly 100.0 and a height of exactly
  /// 100.0, but this function might give the children looser constraints that
  /// let them be larger or smaller than 100.0 by 100.0.
  ///
  /// If this function depends on information other than the given constraints,
  /// override [shouldRelayout] to indicate when when the container should
  /// relayout.
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) =>
      constraints;

  /// Override to paint the children of the flow.
  ///
  /// Children can be painted in any order, but each child can be painted at
  /// most once. Although the container clips the children to its own bounds, it
  /// is more efficient to skip painting a child altogether rather than having
  /// it paint entirely outside the container's clip.
  ///
  /// To paint a child, call [FlowPaintingContext.paintChild] on the given
  /// [FlowPaintingContext] (the `context` argument). The given context is valid
  /// only within the scope of this function call and contains information (such
  /// as the size of the container) that is useful for picking transformation
  /// matrices for the children.
  ///
  /// If this function depends on information other than the given context,
  /// override [shouldRepaint] to indicate when when the container should
  /// relayout.
  void paintChildren(FlowPaintingContext context);

  /// Override this method to return true when the children need to be laid out.
  /// This should compare the fields of the current delegate and the given
  /// oldDelegate and return true if the fields are such that the layout would
  /// be different.
  bool shouldRelayout(covariant FlowDelegate oldDelegate) => false;

  /// Override this method to return true when the children need to be
  /// repainted. This should compare the fields of the current delegate and the
  /// given oldDelegate and return true if the fields are such that
  /// paintChildren would act differently.
  ///
  /// The delegate can also trigger a repaint if the delegate provides the
  /// repaint animation argument to this object's constructor and that animation
  /// ticks. Triggering a repaint using this animation-based mechanism is more
  /// efficient than rebuilding the [Flow] widget to change its delegate.
  ///
  /// The flow container might repaint even if this function returns false, for
  /// example if layout triggers painting (e.g., if [shouldRelayout] returns
  /// true).
  bool shouldRepaint(covariant FlowDelegate oldDelegate);

  /// Override this method to include additional information in the
  /// debugging data printed by [debugDumpRenderTree] and friends.
  ///
  /// By default, returns the [runtimeType] of the class.
  @override
  String toString() => '$runtimeType';
}
