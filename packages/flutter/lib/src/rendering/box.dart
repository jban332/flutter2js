// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/ui.dart' as ui show lerpDouble;

import 'object.dart';

// This class should only be used in debug builds.
class _DebugSize extends Size {
  _DebugSize(Size source, this._owner, this._canBeUsedByParent)
      : super.copy(source);
  final RenderBox _owner;
  final bool _canBeUsedByParent;
}

/// Immutable layout constraints for [RenderBox] layout.
///
/// A [Size] respects a [BoxConstraints] if, and only if, all of the following
/// relations hold:
///
/// * [minWidth] <= [Size.width] <= [maxWidth]
/// * [minHeight] <= [Size.height] <= [maxHeight]
///
/// The constraints themselves must satisfy these relations:
///
/// * 0.0 <= [minWidth] <= [maxWidth] <= [double.INFINITY]
/// * 0.0 <= [minHeight] <= [maxHeight] <= [double.INFINITY]
///
/// [double.INFINITY] is a legal value for each constraint.
///
/// ## The box layout model
///
/// Render objects in the Flutter framework are laid out by a one-pass layout
/// model which walks down the render tree passing constraints, then walks back
/// up the render tree passing concrete geometry.
///
/// For boxes, the constraints are [BoxConstraints], which, as described herein,
/// consist of four numbers: a minimum width [minWidth], a maximum width
/// [maxWidth], a minimum height [minHeight], and a maximum height [maxHeight].
///
/// The geometry for boxes consists of a [Size], which must satisfy the
/// constraints described above.
///
/// Each [RenderBox] (the objects that provide the layout models for box
/// widgets) receives [BoxConstraints] from its parent, then lays out each of
/// its children, then picks a [Size] that satisfies the [BoxConstraints].
///
/// Render objects position their children independently of laying them out.
/// Frequently, the parent will use the children's sizes to determine their
/// position. A child does not know its position and will not necessarily be
/// laid out again, or repainted, if its position changes.
///
/// ## Terminology
///
/// When the minimum constraints and the maximum constraint in an axis are the
/// same, that axis is _tightly_ constrained. See: [new
/// BoxConstraints.tightFor], [new BoxConstraints.tightForFinite], [tighten],
/// [hasTightWidth], [hasTightHeight], [isTight].
///
/// An axis with a minimum constraint of 0.0 is _loose_ (regardless of the
/// maximum constraint; if it is also 0.0, then the axis is simultaneously tight
/// and loose!). See: [new BoxConstraints.loose], [loosen].
///
/// An axis whose maximum constraint is not infinite is _bounded_. See:
/// [hasBoundedWidth], [hasBoundedHeight].
///
/// An axis whose maximum constraint is infinite is _unbounded_. An axis is
/// _expanding_ if it is tightly infinite (its minimum and maximum constraints
/// are both infinite). See: [new BoxConstraints.expand].
///
/// A size is _constrained_ when it satisfies a [BoxConstraints] description.
/// See: [constrain], [constrainWidth], [constrainHeight],
/// [constrainDimensions], [constrainSizeAndAttemptToPreserveAspectRatio],
/// [isSatisfiedBy].
class BoxConstraints extends Constraints {
  /// Creates box constraints with the given constraints.
  const BoxConstraints(
      {this.minWidth: 0.0,
      this.maxWidth: double.INFINITY,
      this.minHeight: 0.0,
      this.maxHeight: double.INFINITY});

  /// The minimum width that satisfies the constraints.
  final double minWidth;

  /// The maximum width that satisfies the constraints.
  ///
  /// Might be [double.INFINITY].
  final double maxWidth;

  /// The minimum height that satisfies the constraints.
  final double minHeight;

  /// The maximum height that satisfies the constraints.
  ///
  /// Might be [double.INFINITY].
  final double maxHeight;

  /// Creates box constraints that is respected only by the given size.
  BoxConstraints.tight(Size size)
      : minWidth = size.width,
        maxWidth = size.width,
        minHeight = size.height,
        maxHeight = size.height;

  /// Creates box constraints that require the given width or height.
  ///
  /// See also:
  ///
  ///  * [new BoxConstraints.tightForFinite], which is similar but instead of
  ///    being tight if the value is non-null, is tight if the value is not
  ///    infinite.
  const BoxConstraints.tightFor({double width, double height})
      : minWidth = width != null ? width : 0.0,
        maxWidth = width != null ? width : double.INFINITY,
        minHeight = height != null ? height : 0.0,
        maxHeight = height != null ? height : double.INFINITY;

  /// Creates box constraints that require the given width or height, except if
  /// they are infinite.
  ///
  /// See also:
  ///
  ///  * [new BoxConstraints.tightFor], which is similar but instead of being
  ///    tight if the value is not infinite, is tight if the value is non-null.
  const BoxConstraints.tightForFinite(
      {double width: double.INFINITY, double height: double.INFINITY})
      : minWidth = width != double.INFINITY ? width : 0.0,
        maxWidth = width != double.INFINITY ? width : double.INFINITY,
        minHeight = height != double.INFINITY ? height : 0.0,
        maxHeight = height != double.INFINITY ? height : double.INFINITY;

  /// Creates box constraints that forbid sizes larger than the given size.
  BoxConstraints.loose(Size size)
      : minWidth = 0.0,
        maxWidth = size.width,
        minHeight = 0.0,
        maxHeight = size.height;

  /// Creates box constraints that expand to fill another box constraints.
  ///
  /// If width or height is given, the constraints will require exactly the
  /// given value in the given dimension.
  const BoxConstraints.expand({double width, double height})
      : minWidth = width != null ? width : double.INFINITY,
        maxWidth = width != null ? width : double.INFINITY,
        minHeight = height != null ? height : double.INFINITY,
        maxHeight = height != null ? height : double.INFINITY;

  /// Creates a copy of this box constraints but with the given fields replaced with the new values.
  BoxConstraints copyWith(
      {double minWidth, double maxWidth, double minHeight, double maxHeight}) {
    return new BoxConstraints(
        minWidth: minWidth ?? this.minWidth,
        maxWidth: maxWidth ?? this.maxWidth,
        minHeight: minHeight ?? this.minHeight,
        maxHeight: maxHeight ?? this.maxHeight);
  }

  /// Returns new box constraints that are smaller by the given edge dimensions.
  BoxConstraints deflate(EdgeInsets edges) {
    assert(edges != null);
    assert(debugAssertIsValid());
    final double horizontal = edges.horizontal;
    final double vertical = edges.vertical;
    final double deflatedMinWidth = math.max(0.0, minWidth - horizontal);
    final double deflatedMinHeight = math.max(0.0, minHeight - vertical);
    return new BoxConstraints(
        minWidth: deflatedMinWidth,
        maxWidth: math.max(deflatedMinWidth, maxWidth - horizontal),
        minHeight: deflatedMinHeight,
        maxHeight: math.max(deflatedMinHeight, maxHeight - vertical));
  }

  /// Returns new box constraints that remove the minimum width and height requirements.
  BoxConstraints loosen() {
    assert(debugAssertIsValid());
    return new BoxConstraints(
        minWidth: 0.0,
        maxWidth: maxWidth,
        minHeight: 0.0,
        maxHeight: maxHeight);
  }

  /// Returns new box constraints that respect the given constraints while being
  /// as close as possible to the original constraints.
  BoxConstraints enforce(BoxConstraints constraints) {
    return new BoxConstraints(
        minWidth: minWidth.clamp(constraints.minWidth, constraints.maxWidth),
        maxWidth: maxWidth.clamp(constraints.minWidth, constraints.maxWidth),
        minHeight:
            minHeight.clamp(constraints.minHeight, constraints.maxHeight),
        maxHeight:
            maxHeight.clamp(constraints.minHeight, constraints.maxHeight));
  }

  /// Returns new box constraints with a tight width and/or height as close to
  /// the given width and height as possible while still respecting the original
  /// box constraints.
  BoxConstraints tighten({double width, double height}) {
    return new BoxConstraints(
        minWidth: width == null ? minWidth : width.clamp(minWidth, maxWidth),
        maxWidth: width == null ? maxWidth : width.clamp(minWidth, maxWidth),
        minHeight:
            height == null ? minHeight : height.clamp(minHeight, maxHeight),
        maxHeight:
            height == null ? maxHeight : height.clamp(minHeight, maxHeight));
  }

  /// A box constraints with the width and height constraints flipped.
  BoxConstraints get flipped {
    return new BoxConstraints(
        minWidth: minHeight,
        maxWidth: maxHeight,
        minHeight: minWidth,
        maxHeight: maxWidth);
  }

  /// Returns box constraints with the same width constraints but with
  /// unconstrained height.
  BoxConstraints widthConstraints() =>
      new BoxConstraints(minWidth: minWidth, maxWidth: maxWidth);

  /// Returns box constraints with the same height constraints but with
  /// unconstrained width
  BoxConstraints heightConstraints() =>
      new BoxConstraints(minHeight: minHeight, maxHeight: maxHeight);

  /// Returns the width that both satisfies the constraints and is as close as
  /// possible to the given width.
  double constrainWidth([double width = double.INFINITY]) {
    assert(debugAssertIsValid());
    return width.clamp(minWidth, maxWidth);
  }

  /// Returns the height that both satisfies the constraints and is as close as
  /// possible to the given height.
  double constrainHeight([double height = double.INFINITY]) {
    assert(debugAssertIsValid());
    return height.clamp(minHeight, maxHeight);
  }

  Size _debugPropagateDebugSize(Size size, Size result) {
    assert(() {
      if (size is _DebugSize)
        result = new _DebugSize(result, size._owner, size._canBeUsedByParent);
      return true;
    });
    return result;
  }

  /// Returns the size that both satisfies the constraints and is as close as
  /// possible to the given size.
  ///
  /// See also [constrainDimensions], which applies the same algorithm to
  /// separately provided widths and heights.
  Size constrain(Size size) {
    Size result =
        new Size(constrainWidth(size.width), constrainHeight(size.height));
    assert(() {
      result = _debugPropagateDebugSize(size, result);
      return true;
    });
    return result;
  }

  /// Returns the size that both satisfies the constraints and is as close as
  /// possible to the given width and height.
  ///
  /// When you already have a [Size], prefer [constrain], which applies the same
  /// algorithm to a [Size] directly.
  Size constrainDimensions(double width, double height) {
    return new Size(constrainWidth(width), constrainHeight(height));
  }

  /// Returns a size that attempts to meet the following conditions, in order:
  ///
  ///  * The size must satisfy these constraints.
  ///  * The aspect ratio of the returned size matches the aspect ratio of the
  ///    given size.
  ///  * The returned size as big as possible while still being equal to or
  ///    smaller than the given size.
  Size constrainSizeAndAttemptToPreserveAspectRatio(Size size) {
    if (isTight) {
      Size result = smallest;
      assert(() {
        result = _debugPropagateDebugSize(size, result);
        return true;
      });
      return result;
    }

    double width = size.width;
    double height = size.height;
    assert(width > 0.0);
    assert(height > 0.0);
    final double aspectRatio = width / height;

    if (width > maxWidth) {
      width = maxWidth;
      height = width / aspectRatio;
    }

    if (height > maxHeight) {
      height = maxHeight;
      width = height * aspectRatio;
    }

    if (width < minWidth) {
      width = minWidth;
      height = width / aspectRatio;
    }

    if (height < minHeight) {
      height = minHeight;
      width = height * aspectRatio;
    }

    Size result = new Size(constrainWidth(width), constrainHeight(height));
    assert(() {
      result = _debugPropagateDebugSize(size, result);
      return true;
    });
    return result;
  }

  /// The biggest size that satisifes the constraints.
  Size get biggest => new Size(constrainWidth(), constrainHeight());

  /// The smallest size that satisfies the constraints.
  Size get smallest => new Size(constrainWidth(0.0), constrainHeight(0.0));

  /// Whether there is exactly one width value that satisfies the constraints.
  bool get hasTightWidth => minWidth >= maxWidth;

  /// Whether there is exactly one height value that satisfies the constraints.
  bool get hasTightHeight => minHeight >= maxHeight;

  /// Whether there is exactly one size that satifies the constraints.
  @override
  bool get isTight => hasTightWidth && hasTightHeight;

  /// Whether there is an upper bound on the maximum width.
  bool get hasBoundedWidth => maxWidth < double.INFINITY;

  /// Whether there is an upper bound on the maximum height.
  bool get hasBoundedHeight => maxHeight < double.INFINITY;

  /// Whether the given size satisfies the constraints.
  bool isSatisfiedBy(Size size) {
    assert(debugAssertIsValid());
    return (minWidth <= size.width) &&
        (size.width <= maxWidth) &&
        (minHeight <= size.height) &&
        (size.height <= maxHeight);
  }

  /// Scales each constraint parameter by the given factor.
  BoxConstraints operator *(double factor) {
    return new BoxConstraints(
        minWidth: minWidth * factor,
        maxWidth: maxWidth * factor,
        minHeight: minHeight * factor,
        maxHeight: maxHeight * factor);
  }

  /// Scales each constraint parameter by the inverse of the given factor.
  BoxConstraints operator /(double factor) {
    return new BoxConstraints(
        minWidth: minWidth / factor,
        maxWidth: maxWidth / factor,
        minHeight: minHeight / factor,
        maxHeight: maxHeight / factor);
  }

  /// Scales each constraint parameter by the inverse of the given factor, rounded to the nearest integer.
  BoxConstraints operator ~/(double factor) {
    return new BoxConstraints(
        minWidth: (minWidth ~/ factor).toDouble(),
        maxWidth: (maxWidth ~/ factor).toDouble(),
        minHeight: (minHeight ~/ factor).toDouble(),
        maxHeight: (maxHeight ~/ factor).toDouble());
  }

  /// Computes the remainder of each constraint parameter by the given value.
  BoxConstraints operator %(double value) {
    return new BoxConstraints(
        minWidth: minWidth % value,
        maxWidth: maxWidth % value,
        minHeight: minHeight % value,
        maxHeight: maxHeight % value);
  }

  /// Linearly interpolate between two BoxConstraints.
  ///
  /// If either is null, this function interpolates from a [BoxConstraints]
  /// object whose fields are all set to 0.0.
  static BoxConstraints lerp(BoxConstraints a, BoxConstraints b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b * t;
    if (b == null) return a * (1.0 - t);
    assert(a.debugAssertIsValid());
    assert(b.debugAssertIsValid());
    return new BoxConstraints(
        minWidth: ui.lerpDouble(a.minWidth, b.minWidth, t),
        maxWidth: ui.lerpDouble(a.maxWidth, b.maxWidth, t),
        minHeight: ui.lerpDouble(a.minHeight, b.minHeight, t),
        maxHeight: ui.lerpDouble(a.maxHeight, b.maxHeight, t));
  }

  /// Returns whether the object's constraints are normalized.
  /// Constraints are normalized if the minimums are less than or
  /// equal to the corresponding maximums.
  ///
  /// For example, a BoxConstraints object with a minWidth of 100.0
  /// and a maxWidth of 90.0 is not normalized.
  ///
  /// Most of the APIs on BoxConstraints expect the constraints to be
  /// normalized and have undefined behavior when they are not. In
  /// checked mode, many of these APIs will assert if the constraints
  /// are not normalized.
  @override
  bool get isNormalized {
    return minWidth >= 0.0 &&
        minWidth <= maxWidth &&
        minHeight >= 0.0 &&
        minHeight <= maxHeight;
  }

  @override
  bool debugAssertIsValid({
    bool isAppliedConstraint: false,
    InformationCollector informationCollector,
  }) {
    assert(() {
      void throwError(String message) {
        final StringBuffer information = new StringBuffer();
        if (informationCollector != null) informationCollector(information);
        throw new FlutterError(
            '$message\n${information}The offending constraints were:\n  $this');
      }

      if (minWidth.isNaN ||
          maxWidth.isNaN ||
          minHeight.isNaN ||
          maxHeight.isNaN) {
        final List<String> affectedFieldsList = <String>[];
        if (minWidth.isNaN) affectedFieldsList.add('minWidth');
        if (maxWidth.isNaN) affectedFieldsList.add('maxWidth');
        if (minHeight.isNaN) affectedFieldsList.add('minHeight');
        if (maxHeight.isNaN) affectedFieldsList.add('maxHeight');
        assert(affectedFieldsList.isNotEmpty);
        if (affectedFieldsList.length > 1)
          affectedFieldsList.add('and ${affectedFieldsList.removeLast()}');
        String whichFields = '';
        if (affectedFieldsList.length > 2) {
          whichFields = affectedFieldsList.join(', ');
        } else if (affectedFieldsList.length == 2) {
          whichFields = affectedFieldsList.join(' ');
        } else {
          whichFields = affectedFieldsList.single;
        }
        throwError('BoxConstraints has ${affectedFieldsList.length == 1
            ? 'a NaN value'
            : 'NaN values' } in $whichFields.');
      }
      if (minWidth < 0.0 && minHeight < 0.0)
        throwError(
            'BoxConstraints has both a negative minimum width and a negative minimum height.');
      if (minWidth < 0.0)
        throwError('BoxConstraints has a negative minimum width.');
      if (minHeight < 0.0)
        throwError('BoxConstraints has a negative minimum height.');
      if (maxWidth < minWidth && maxHeight < minHeight)
        throwError(
            'BoxConstraints has both width and height constraints non-normalized.');
      if (maxWidth < minWidth)
        throwError('BoxConstraints has non-normalized width constraints.');
      if (maxHeight < minHeight)
        throwError('BoxConstraints has non-normalized height constraints.');
      if (isAppliedConstraint) {
        if (minWidth.isInfinite && minHeight.isInfinite)
          throwError(
              'BoxConstraints forces an infinite width and infinite height.');
        if (minWidth.isInfinite)
          throwError('BoxConstraints forces an infinite width.');
        if (minHeight.isInfinite)
          throwError('BoxConstraints forces an infinite height.');
      }
      assert(isNormalized);
      return true;
    });
    return isNormalized;
  }

  /// Returns a box constraints that [isNormalized].
  ///
  /// The returned [maxWidth] is at least as large as the [minWidth]. Similarly,
  /// the returned [maxHeight] is at least as large as the [minHeight].
  BoxConstraints normalize() {
    if (isNormalized) return this;
    final double minWidth = this.minWidth >= 0.0 ? this.minWidth : 0.0;
    final double minHeight = this.minHeight >= 0.0 ? this.minHeight : 0.0;
    return new BoxConstraints(
        minWidth: minWidth,
        maxWidth: minWidth > maxWidth ? minWidth : maxWidth,
        minHeight: minHeight,
        maxHeight: minHeight > maxHeight ? minHeight : maxHeight);
  }

  @override
  bool operator ==(dynamic other) {
    assert(debugAssertIsValid());
    if (identical(this, other)) return true;
    if (other is! BoxConstraints) return false;
    final BoxConstraints typedOther = other;
    assert(typedOther.debugAssertIsValid());
    return minWidth == typedOther.minWidth &&
        maxWidth == typedOther.maxWidth &&
        minHeight == typedOther.minHeight &&
        maxHeight == typedOther.maxHeight;
  }

  @override
  int get hashCode {
    assert(debugAssertIsValid());
    return hashValues(minWidth, maxWidth, minHeight, maxHeight);
  }

  @override
  String toString() {
    final String annotation = isNormalized ? '' : '; NOT NORMALIZED';
    if (minWidth == double.INFINITY && minHeight == double.INFINITY)
      return 'BoxConstraints(biggest$annotation)';
    if (minWidth == 0 &&
        maxWidth == double.INFINITY &&
        minHeight == 0 &&
        maxHeight == double.INFINITY)
      return 'BoxConstraints(unconstrained$annotation)';
    String describe(double min, double max, String dim) {
      if (min == max) return '$dim=${min.toStringAsFixed(1)}';
      return '${min.toStringAsFixed(1)}<=$dim<=${max.toStringAsFixed(1)}';
    }

    final String width = describe(minWidth, maxWidth, 'w');
    final String height = describe(minHeight, maxHeight, 'h');
    return 'BoxConstraints($width, $height$annotation)';
  }
}

/// Parent data used by [RenderBox] and its subclasses.
class BoxParentData extends ParentData {
  /// The offset at which to paint the child in the parent's coordinate system.
  Offset offset = Offset.zero;

  @override
  String toString() => 'offset=$offset';
}

/// A render object in a 2D cartesian coordinate system.
///
/// The [size] of each box is expressed as a width and a height. Each box has
/// its own coordinate system in which its upper left corner is placed at (0,
/// 0). The lower right corner of the box is therefore at (width, height). The
/// box contains all the points including the upper left corner and extending
/// to, but not including, the lower right corner.
///
/// Box layout is performed by passing a [BoxConstraints] object down the tree.
/// The box constraints establish a min and max value for the child's width and
/// height. In determining its size, the child must respect the constraints
/// given to it by its parent.
///
/// This protocol is sufficient for expressing a number of common box layout
/// data flows. For example, to implement a width-in-height-out data flow, call
/// your child's [layout] function with a set of box constraints with a tight
/// width value (and pass true for parentUsesSize). After the child determines
/// its height, use the child's height to determine your size.
///
/// ## Writing a RenderBox subclass
///
/// One would implement a new [RenderBox] subclass to describe a new layout
/// model, new paint model, new hit-testing model, or new semantics model, while
/// remaining in the cartesian space defined by the [RenderBox] protocol.
///
/// To create a new protocol, consider subclassing [RenderObject] instead.
///
/// ### Constructors and properties of a new RenderBox subclass
///
/// The constructor will typically take a named argument for each property of
/// the class. The value is then passed to a private field of the class and the
/// constructor asserts its correctness (e.g. if it should not be null, it
/// asserts it's not null).
///
/// Properties have the form of a getter/setter/field group like the following:
///
/// ```dart
/// AxisDirection get axis => _axis;
/// AxisDirection _axis;
/// set axis(AxisDirection value) {
///   assert(value != null); // same check as in the constructor
///   if (value == _axis)
///     return;
///   _axis = value;
///   markNeedsLayout();
/// }
/// ```
///
/// The setter will typically finish with either a call to [markNeedsLayout], if
/// the layout uses this property, or [markNeedsPaint], if only the painter
/// function does. (No need to call both, [markNeedsLayout] implies
/// [markNeedsPaint].)
///
/// Consider layout and paint to be expensive; be conservative about calling
/// [markNeedsLayout] or [markNeedsPaint]. They should only be called if the
/// layout (or paint, respectively) has actually changed.
///
/// ### Children
///
/// If a render object is a leaf, that is, it cannot have any children, then
/// ignore this section. (Examples of leaf render objects are [RenderImage] and
/// [RenderParagraph].)
///
/// For render objects with children, there are four possible scenarios:
///
/// * A single [RenderBox] child. In this scenario, consider inheriting from
///   [RenderProxyBox] (if the render object sizes itself to match the child) or
///   [RenderShiftedBox] (if the child will be smaller than the box and the box
///   will align the child inside itself).
///
/// * A single child, but it isn't a [RenderBox]. Use the
///   [RenderObjectWithChildMixin] mixin.
///
/// * A single list of children. Use the [ContainerRenderObjectMixin] mixin.
///
/// * A more complicated child model.
///
/// #### Using RenderProxyBox
///
/// By default, a [RenderProxyBox] render object sizes itself to fit its child, or
/// to be as small as possible if there is no child; it passes all hit testing
/// and painting on to the child, and intrinsic dimensions and baseline
/// measurements similarly are proxied to the child.
///
/// A subclass of [RenderProxyBox] just needs to override the parts of the
/// [RenderBox] protocol that matter. For example, [RenderOpacity] just
/// overrides the paint method (and [alwaysNeedsCompositing] to reflect what the
/// paint method does, and the [visitChildrenForSemantics] method so that the
/// child is hidden from accessibility tools when it's invisible), and adds an
/// [RenderOpacity.opacity] field.
///
/// [RenderProxyBox] assumes that the child is the size of the parent and
/// positioned at 0,0. If this is not true, then use [RenderShiftedBox] instead.
///
/// See
/// [proxy_box.dart](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/proxy_box.dart)
/// for examples of inheriting from [RenderProxyBox].
///
/// #### Using RenderShiftedBox
///
/// By default, a [RenderShiftedBox] acts much like a [RenderProxyBox] but
/// without assuming that the child is positioned at 0,0 (the actual position
/// recorded in the child's [parentData] field is used), and without providing a
/// default layout algorithm.
///
/// See
/// [shifted_box.dart](https://github.com/flutter/flutter/blob/master/packages/flutter/lib/src/rendering/shifted_box.dart)
/// for examples of inheriting from [RenderShiftedBox].
///
/// #### Kinds of children and child-specific data
///
/// A [RenderBox] doesn't have to have [RenderBox] children. One can use another
/// subclass of [RenderObject] for a [RenderBox]'s children. See the discussion
/// at [RenderObject].
///
/// Children can have additional data owned by the parent but stored on the
/// child using the [parentData] field. The class used for that data must
/// inherit from [ParentData]. The [setupParentData] method is used to
/// initialise the [parentData] field of a child when the child is attached.
///
/// By convention, [RenderBox] objects that have [RenderBox] children use the
/// [BoxParentData] class, which has a [BoxParentData.offset] field to store the
/// position of the child relative to the parent. ([RenderProxyBox] does not
/// need this offset and therefore is an exception to this rule.)
///
/// #### Using RenderObjectWithChildMixin
///
/// If a render object has a single child but it isn't a [RenderBox], then the
/// [RenderObjectWithChildMixin] class, which is a mixin that will handle the
/// boilerplate of managing a child, will be useful.
///
/// It's a generic class with one type argument, the type of the child. For
/// example, if you are building a `RenderFoo` class which takes a single
/// `RenderBar` child, you would use the mixin as follows:
///
/// ```dart
/// class RenderFoo extends RenderBox
///   with RenderObjectWithChildMixin<RenderBar> {
///   // ...
/// }
/// ```
///
/// Since the `RenderFoo` class itself is still a [RenderBox] in this case, you
/// still have to implement the [RenderBox] layout algorithm, as well as
/// features like intrinsics and baselines, painting, and hit testing.
///
/// #### Using ContainerRenderObjectMixin
///
/// If a render box can have multiple children, then the
/// [ContainerRenderObjectMixin] mixin can be used to handle the boilerplate. It
/// uses a linked list to model the children in a manner that is easy to mutate
/// dynamically and that can be walked efficiently. Random access is not
/// efficient in this model; if you need random access to the children consider
/// the next section on more complicated child models.
///
/// The [ContainerRenderObjectMixin] class has two type arguments. The first is
/// the type of the child objects. The second is the type for their
/// [parentData]. The class used for [parentData] must itself have the
/// [ContainerParentDataMixin] class mixed into it; this is where
/// [ContainerRenderObjectMixin] stores the linked list. A [ParentData] class
/// can extend [ContainerBoxParentData]; this is essentially
/// [BoxParentData] mixed with [ContainerParentDataMixin]. For example, if a
/// `RenderFoo` class wanted to have a linked list of [RenderBox] children, one
/// might create a `FooParentData` class as follows:
///
/// ```dart
/// class FooParentData extends ContainerBoxParentData<RenderBox> {
///   // (any fields you might need for these children)
/// }
/// ```
///
/// When using [ContainerRenderObjectMixin] in a [RenderBox], consider mixing in
/// [RenderBoxContainerDefaultsMixin], which provides a collection of utility
/// methods that implement common parts of the [RenderBox] protocol (such as
/// painting the children).
///
/// The declaration of the `RenderFoo` class itself would thus look like this:
///
/// ```dart
/// class RenderFlex extends RenderBox with
///   ContainerRenderObjectMixin<RenderBox, FooParentData>,
///   RenderBoxContainerDefaultsMixin<RenderBox, FooParentData> {
///   // ...
/// }
/// ```
///
/// When walking the children (e.g. during layout), the following pattern is
/// commonly used (in this case assuming that the children are all [RenderBox]
/// objects and that this render object uses `FooParentData` objects for its
/// children's [parentData] fields):
///
/// ```dart
/// RenderBox child = firstChild;
/// while (child != null) {
///   final FooParentData childParentData = child.parentData;
///   // ...operate on child and childParentData...
///   assert(child.parentData == childParentData);
///   child = childParentData.nextSibling;
/// }
/// ```
///
/// #### More complicated child models
///
/// Render objects can have more complicated models, for example a map of
/// children keyed on an enum, or a 2D grid of efficiently randomly-accessible
/// children, or multiple lists of children, etc. If a render object has a model
/// that can't be handled by the mixins above, it must implement the
/// [RenderObject] child protocol, as follows:
///
/// * Any time a child is removed, call [dropChild] with the child.
///
/// * Any time a child is added, call [adoptChild] with the child.
///
/// * Implement the [attach] method such that it calls [attach] on each child.
///
/// * Implement the [detach] method such that it calls [detach] on each child.
///
/// * Implement the [redepthChildren] method such that it calls [redepthChild]
///   on each child.
///
/// * Implement the [visitChildren] method such that it calls its argument for
///   each child, typically in paint order (back-most to front-most).
///
/// * Implement [debugDescribeChildren] such that it outputs a [DiagnosticsNode]
///   for each child.
///
/// Implementing these seven bullet points is essentially all that the two
/// aforementioned mixins do.
///
/// ### Layout
///
/// [RenderBox] classes implement a layout algorithm. They have a set of
/// constraints provided to them, and they size themselves based on those
/// constraints and whatever other inputs they may have (for example, their
/// children or properties).
///
/// When implementing a [RenderBox] subclass, one must make a choice. Does it
/// size itself exclusively based on the constraints, or does it use any other
/// information in sizing itself? An example of sizing purely based on the
/// constraints would be growing to fit the parent.
///
/// Sizing purely based on the constraints allows the system to make some
/// significant optimizations. Classes that use this approach should override
/// [sizedByParent] to return true, and then override [performResize] to set the
/// [size] using nothing but the constraints, e.g.:
///
/// ```dart
/// @override
/// bool get sizedByParent => true;
///
/// @override
/// void performResize() {
///   size = constraints.smallest;
/// }
/// ```
///
/// Otherwise, the size is set in the [performLayout] function.
///
/// The [performLayout] function is where render boxes decide, if they are not
/// [sizedByParent], what [size] they should be, and also where they decide
/// where their children should be.
///
/// #### Layout of RenderBox children
///
/// The [performLayout] function should call the [layout] function of each (box)
/// child, passing it a [BoxConstraints] object describing the constraints
/// within which the child can render. Passing tight constraints (see
/// [BoxConstraints.isTight]) to the child will allow the rendering library to
/// apply some optimizations, as it knows that if the constraints are tight, the
/// child's dimensions cannot change even if the layout of the child itself
/// changes.
///
/// If the [performLayout] function will use the child's size to affect other
/// aspects of the layout, for example if the render box sizes itself around the
/// child, or positions several children based on the size of those children,
/// then it must specify the `parentUsesSize` argument to the child's [layout]
/// function, setting it to true.
///
/// This flag turns off some optimizations; algorithms that do not rely on the
/// children's sizes will be more efficient. (In particular, relying on the
/// child's [size] means that if the child is marked dirty for layout, the
/// parent will probably also be marked dirty for layout, unless the
/// [constraints] given by the parent to the child were tight constraints.)
///
/// For [RenderBox] classes that do not inherit from [RenderProxyBox], once they
/// have laid out their children, should also position them, by setting the
/// [BoxParentData.offset] field of each child's [parentData] object.
///
/// #### Layout of non-RenderBox children
///
/// The children of a [RenderBox] do not have to be [RenderBox]es themselves. If
/// they use another protocol (as discussed at [RenderObject]), then instead of
/// [BoxConstraints], the parent would pass in the appropriate [Constraints]
/// subclass, and instead of reading the child's size, the parent would read
/// whatever the output of [layout] is for that layout protocol. The
/// `parentUsesSize` flag is still used to indicate whether the parent is going
/// to read that output, and optimizations still kick in if the child has tight
/// constraints (as defined by [Constraints.isTight]).
///
/// ### Painting
///
/// To describe how a render box paints, implement the [paint] method. It is
/// given a [PaintingContext] object and an [Offset]. The painting context
/// provides methods to affect the layer tree as well as a
/// [PaintingContext.canvas] which can be used to add drawing commands. The
/// canvas object should not be cached across calls to the [PaintingContext]'s
/// methods; every time a method on [PaintingContext] is called, there is a
/// chance that the canvas will change identity. The offset specifies the
/// position of the top left corner of the box in the coordinate system of the
/// [PaintingContext.canvas].
///
/// To draw text on a canvas, use a [TextPainter].
///
/// To draw an image to a canvas, use the [paintImage] method.
///
/// A [RenderBox] that uses methods on [PaintingContext] that introduce new
/// layers should override the [alwaysNeedsCompositing] getter and set it to
/// true. If the object sometimes does and sometimes does not, it can have that
/// getter return true in some cases and false in others. In that case, whenever
/// the return value would change, call [markNeedsCompositingBitsUpdate]. (This
/// is done automatically when a child is added or removed, so you don't have to
/// call it explicitly if the [alwaysNeedsCompositing] getter only changes value
/// based on the presence or absence of children.)
///
/// Anytime anything changes on the object that would cause the [paint] method
/// to paint something different (but would not cause the layout to change),
/// the object should call [markNeedsPaint].
///
/// #### Painting children
///
/// The [paint] method's `context` argument has a [PaintingContext.paintChild]
/// method, which should be called for each child that is to be painted. It
/// should be given a reference to the child, and an [Offset] giving the
/// position of the child relative to the parent.
///
/// If the [paint] method applies a transform to the painting context before
/// painting children (or generally applies an additional offset beyond the
/// offset it was itself given as an argument), then the [applyPaintTransform]
/// method should also be overridden. That method must adjust the matrix that it
/// is given in the same manner as it transformed the painting context and
/// offset before painting the given child. This is used by the [globalToLocal]
/// and [localToGlobal] methods.
///
/// #### Hit Tests
///
/// Hit testing for render boxes is implemented by the [hitTest] method. The
/// default implementation of this method defers to [hitTestSelf] and
/// [hitTestChildren]. When implementing hit testing, you can either override
/// these latter two methods, or ignore them and just override [hitTest].
///
/// The [hitTest] method itself is given an [Offset], and must return true if the
/// object or one of its children has absorbed the hit (preventing objects below
/// this one from being hit), or false if the hit can continue to other objects
/// below this one.
///
/// For each child [RenderBox], the [hitTest] method on the child should be
/// called with the same [HitTestResult] argument and with the point transformed
/// into the child's coordinate space (in the same manner that the
/// [applyPaintTransform] method would). The default implementation defers to
/// [hitTestChildren] to call the children. [RenderBoxContainerDefaultsMixin]
/// provides a [RenderBoxContainerDefaultsMixin.defaultHitTestChildren] method
/// that does this assuming that the children are axis-aligned, not transformed,
/// and positioned according to the [BoxParentData.offset] field of the
/// [parentData]; more elaborate boxes can override [hitTestChildren]
/// accordingly.
///
/// If the object is hit, then it should also add itself to the [HitTestResult]
/// object that is given as an argument to the [hitTest] method, using
/// [HitTestResult.add]. The default implementation defers to [hitTestSelf] to
/// determine if the box is hit. If the object adds itself before the children
/// can add themselves, then it will be as if the object was above the children.
/// If it adds itself after the children, then it will be as if it was below the
/// children. Entries added to the [HitTestResult] object should use the
/// [BoxHitTestEntry] class. The entries are subsequently walked by the system
/// in the order they were added, and for each entry, the target's [handleEvent]
/// method is called, passing in the [HitTestEntry] object.
///
/// Hit testing cannot rely on painting having happened.
///
/// ### Semantics
///
/// For a render box to be accessible, implement the
/// [describeApproximatePaintClip] and [visitChildrenForSemantics] methods, and
/// the [semanticsAnnotator] getter. The default implementations are sufficient
/// for objects that only affect layout, but nodes that represent interactive
/// components or information (diagrams, text, images, etc) should provide more
/// complete implementations. For more information, see the documentation for
/// these members.
///
/// ### Intrinsics and Baselines
///
/// The layout, painting, hit testing, and semantics protocols are common to all
/// render objects. [RenderBox] objects must implement two additional protocols:
/// intrinsic sizing and baseline measurements.
///
/// There are four methods to implement for intrinsic sizing, to compute the
/// minimum and maximum intrinsic width and height of the box. The documentation
/// for these methods discusses the protocol in detail:
/// [computeMinIntrinsicWidth], [computeMaxIntrinsicWidth],
/// [computeMinIntrinsicHeight], [computeMaxIntrinsicHeight].
///
/// In addition, if the box has any children, it must implement
/// [computeDistanceToActualBaseline]. [RenderProxyBox] provides a simple
/// implementation that forwards to the child; [RenderShiftedBox] provides an
/// implementation that offsets the child's baseline information by the position
/// of the child relative to the parent. If you do not inherited from either of
/// these classes, however, you must implement the algorithm yourself.
abstract class RenderBox extends RenderObject {}
