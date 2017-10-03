// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/ui.dart' show lerpDouble, hashValues;

import 'box.dart';
import 'object.dart';

/// An immutable 2D, axis-aligned, floating-point rectangle whose coordinates
/// are given relative to another rectangle's edges, known as the container.
/// Since the dimensions of the rectangle are relative to those of the
/// container, this class has no width and height members. To determine the
/// width or height of the rectangle, convert it to a [Rect] using [toRect()]
/// (passing the container's own Rect), and then examine that object.
///
/// If you create the RelativeRect with null values, the methods on
/// RelativeRect will not work usefully (or at all).
@immutable
class RelativeRect {
  /// Creates a RelativeRect with the given values.
  const RelativeRect.fromLTRB(this.left, this.top, this.right, this.bottom);

  /// Creates a RelativeRect from a Rect and a Size. The Rect (first argument)
  /// and the RelativeRect (the output) are in the coordinate space of the
  /// rectangle described by the Size, with 0,0 being at the top left.
  factory RelativeRect.fromSize(Rect rect, Size container) {
    return new RelativeRect.fromLTRB(rect.left, rect.top,
        container.width - rect.right, container.height - rect.bottom);
  }

  /// Creates a RelativeRect from two Rects. The second Rect provides the
  /// container, the first provides the rectangle, in the same coordinate space,
  /// that is to be converted to a RelativeRect. The output will be in the
  /// container's coordinate space.
  ///
  /// For example, if the top left of the rect is at 0,0, and the top left of
  /// the container is at 100,100, then the top left of the output will be at
  /// -100,-100.
  ///
  /// If the first rect is actually in the container's coordinate space, then
  /// use [RelativeRect.fromSize] and pass the container's size as the second
  /// argument instead.
  factory RelativeRect.fromRect(Rect rect, Rect container) {
    return new RelativeRect.fromLTRB(
        rect.left - container.left,
        rect.top - container.top,
        container.right - rect.right,
        container.bottom - rect.bottom);
  }

  /// A rect that covers the entire container.
  static final RelativeRect fill =
      const RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0);

  /// Distance from the left side of the container to the left side of this rectangle.
  final double left;

  /// Distance from the top side of the container to the top side of this rectangle.
  final double top;

  /// Distance from the right side of the container to the right side of this rectangle.
  final double right;

  /// Distance from the bottom side of the container to the bottom side of this rectangle.
  final double bottom;

  /// Returns a new rectangle object translated by the given offset.
  RelativeRect shift(Offset offset) {
    return new RelativeRect.fromLTRB(left + offset.dx, top + offset.dy,
        right - offset.dx, bottom - offset.dy);
  }

  /// Returns a new rectangle with edges moved outwards by the given delta.
  RelativeRect inflate(double delta) {
    return new RelativeRect.fromLTRB(
        left - delta, top - delta, right - delta, bottom - delta);
  }

  /// Returns a new rectangle with edges moved inwards by the given delta.
  RelativeRect deflate(double delta) {
    return inflate(-delta);
  }

  /// Returns a new rectangle that is the intersection of the given rectangle and this rectangle.
  RelativeRect intersect(RelativeRect other) {
    return new RelativeRect.fromLTRB(
        math.max(left, other.left),
        math.max(top, other.top),
        math.max(right, other.right),
        math.max(bottom, other.bottom));
  }

  /// Convert this [RelativeRect] to a [Rect], in the coordinate space of the container.
  Rect toRect(Rect container) {
    return new Rect.fromLTRB(
        left, top, container.width - right, container.height - bottom);
  }

  /// Linearly interpolate between two RelativeRects.
  ///
  /// If either rect is null, this function interpolates from [RelativeRect.fill].
  static RelativeRect lerp(RelativeRect a, RelativeRect b, double t) {
    if (a == null && b == null) return null;
    if (a == null)
      return new RelativeRect.fromLTRB(
          b.left * t, b.top * t, b.right * t, b.bottom * t);
    if (b == null) {
      final double k = 1.0 - t;
      return new RelativeRect.fromLTRB(
          b.left * k, b.top * k, b.right * k, b.bottom * k);
    }
    return new RelativeRect.fromLTRB(
        lerpDouble(a.left, b.left, t),
        lerpDouble(a.top, b.top, t),
        lerpDouble(a.right, b.right, t),
        lerpDouble(a.bottom, b.bottom, t));
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! RelativeRect) return false;
    final RelativeRect typedOther = other;
    return left == typedOther.left &&
        top == typedOther.top &&
        right == typedOther.right &&
        bottom == typedOther.bottom;
  }

  @override
  int get hashCode => hashValues(left, top, right, bottom);

  @override
  String toString() => "RelativeRect.fromLTRB(${left?.toStringAsFixed(1)}, ${top
          ?.toStringAsFixed(1)}, ${right?.toStringAsFixed(1)}, ${bottom
          ?.toStringAsFixed(1)})";
}

/// How to size the non-positioned children of a [Stack].
///
/// This enum is used with [Stack.fit] and [RenderStack.fit] to control
/// how the [BoxConstraints] passed from the stack's parent to the stack's child
/// are adjusted.
///
/// See also:
///
///  * [Stack], the widget that uses this.
///  * [RenderStack], the render object that implements the stack algorithm.
enum StackFit {
  /// The constraints passed to the stack from its parent are loosened.
  ///
  /// For example, if the stack has constraints that force it to 350x600, then
  /// this would allow the non-positioned children of the stack to have any
  /// width from zero to 350 and any height from zero to 600.
  ///
  /// See also:
  ///
  ///  * [Center], which loosens the constraints passed to its child and then
  ///    centers the child in itself.
  ///  * [BoxConstraints.loosen], which implements the loosening of box
  ///    constraints.
  loose,

  /// The constraints passed to the stack from its parent are tightened to the
  /// biggest size allowed.
  ///
  /// For example, if the stack has loose constraints with a width in the range
  /// 10 to 100 and a height in the range 0 to 600, then the non-positioned
  /// children of the stack would all be sized as 100 pixels wide and 600 high.
  expand,

  /// The constraints passed to the stack from its parent are passed unmodified
  /// to the non-positioned children.
  ///
  /// For example, if a [Stack] is an [Expanded] child of a [Row], the
  /// horizontal constraints will be tight and the vertical constraints will be
  /// loose.
  passthrough,
}

/// Whether overflowing children should be clipped, or their overflow be
/// visible.
enum Overflow {
  /// Overflowing children will be visible.
  visible,

  /// Overflowing children will be clipped to the bounds of their parent.
  clip,
}
