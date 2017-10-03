// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:vector_math/vector_math_64.dart';

import 'box.dart';
import 'object.dart';
import 'viewport_offset.dart';

// CORE TYPES FOR SLIVERS
// The RenderSliver base class and its helper types.

/// The direction in which a sliver's contents are ordered, relative to the
/// scroll offset axis.
///
/// For example, a vertical alphabetical list that is going [AxisDirection.down]
/// with a [GrowthDirection.forward] would have the A at the top and the Z at
/// the bottom, with the A adjacent to the origin, as would such a list going
/// [AxisDirection.up] with a [GrowthDirection.reverse]. On the other hand, a
/// vertical alphabetical list that is going [AxisDirection.down] with a
/// [GrowthDirection.reverse] would have the Z at the top (at scroll offset
/// zero) and the A below it.
enum GrowthDirection {
  /// This sliver's contents are ordered so that the first item is at the lowest
  /// scroll offset, and later items are at greater scroll offsets. The
  /// direction in which the scroll offset increases is given by the
  /// [AxisDirection] of the sliver.
  forward,

  /// This sliver's contents are ordered so that the last item is at the lowest
  /// scroll offset, and earlier items are at greater scroll offsets. The
  /// direction in which the scroll offset increases is given by the
  /// [AxisDirection] of the sliver.
  reverse,
}

/// A direction along either the horizontal or vertical [Axis].
enum AxisDirection {
  /// Zero is at the bottom and positive values are above it: ⇈
  ///
  /// Alphabetical content with a [GrowthDirection.forward] would have the A at
  /// the bottom and the Z at the top. This is an unusual configuration.
  up,

  /// Zero is on the left and positive values are to the right of it: ⇉
  ///
  /// Alphabetical content with a [GrowthDirection.forward] would have the A on
  /// the left and the Z on the right. This is the ordinary reading order for a
  /// horizontal set of tabs in an English application, for example.
  right,

  /// Zero is at the top and positive values are below it: ⇊
  ///
  /// Alphabetical content with a [GrowthDirection.forward] would have the A at
  /// the top and the Z at the bottom. This is the ordinary reading order for a
  /// vertical list.
  down,

  /// Zero is to the right and positive values are to the left of it: ⇇
  ///
  /// Alphabetical content with a [GrowthDirection.forward] would have the A at
  /// the right and the Z at the left. This is the ordinary reading order for a
  /// horizontal set of tabs in a Hebrew application, for example.
  left,
}

/// Returns the [Axis] that contains the given [AxisDirection].
///
/// Specifically, returns [Axis.vertical] for [AxisDirection.up] and
/// [AxisDirection.down] and returns [Axis.horizontal] for [AxisDirection.left]
/// and [AxisDirection.right].
Axis axisDirectionToAxis(AxisDirection axisDirection) {
  assert(axisDirection != null);
  switch (axisDirection) {
    case AxisDirection.up:
    case AxisDirection.down:
      return Axis.vertical;
    case AxisDirection.left:
    case AxisDirection.right:
      return Axis.horizontal;
  }
  return null;
}

/// Returns the [AxisDirection] in which reading occurs in the given [TextDirection].
///
/// Specifically, returns [AxisDirection.left] for [TextDirection.rtl] and
/// [AxisDirection.right] for [TextDirection.ltr].
AxisDirection textDirectionToAxisDirection(TextDirection textDirection) {
  assert(textDirection != null);
  switch (textDirection) {
    case TextDirection.rtl:
      return AxisDirection.left;
    case TextDirection.ltr:
      return AxisDirection.right;
  }
  return null;
}

/// Returns the opposite of the given [AxisDirection].
///
/// Specifically, returns [AxisDirection.up] for [AxisDirection.down] (and
/// vice versa), as well as [AxisDirection.left] for [AxisDirection.right] (and
/// vice versa).
///
/// See also:
///
///  * [flipAxis], which does the same thing for [Axis] values.
AxisDirection flipAxisDirection(AxisDirection axisDirection) {
  assert(axisDirection != null);
  switch (axisDirection) {
    case AxisDirection.up:
      return AxisDirection.down;
    case AxisDirection.right:
      return AxisDirection.left;
    case AxisDirection.down:
      return AxisDirection.up;
    case AxisDirection.left:
      return AxisDirection.right;
  }
  return null;
}

/// Returns whether travelling along the given axis direction visits coordinates
/// along that axis in numerically decreasing order.
///
/// Specifically, returns true for [AxisDirection.up] and [AxisDirection.left]
/// and false for [AxisDirection.down] for [AxisDirection.right].
bool axisDirectionIsReversed(AxisDirection axisDirection) {
  assert(axisDirection != null);
  switch (axisDirection) {
    case AxisDirection.up:
    case AxisDirection.left:
      return true;
    case AxisDirection.down:
    case AxisDirection.right:
      return false;
  }
  return null;
}

/// Flips the [AxisDirection] if the [GrowthDirection] is [GrowthDirection.reverse].
///
/// Specifically, returns `axisDirection` if `growthDirection` is
/// [GrowthDirection.forward], otherwise returns [flipAxisDirection] applied to
/// `axisDirection`.
///
/// This function is useful in [RenderSliver] subclasses that are given both an
/// [AxisDirection] and a [GrowthDirection] and wish to compute the
/// [AxisDirection] in which growth will occur.
AxisDirection applyGrowthDirectionToAxisDirection(
    AxisDirection axisDirection, GrowthDirection growthDirection) {
  assert(axisDirection != null);
  assert(growthDirection != null);
  switch (growthDirection) {
    case GrowthDirection.forward:
      return axisDirection;
    case GrowthDirection.reverse:
      return flipAxisDirection(axisDirection);
  }
  return null;
}

/// Flips the [ScrollDirection] if the [GrowthDirection] is [GrowthDirection.reverse].
///
/// Specifically, returns `scrollDirection` if `scrollDirection` is
/// [GrowthDirection.forward], otherwise returns [flipScrollDirection] applied to
/// `scrollDirection`.
///
/// This function is useful in [RenderSliver] subclasses that are given both an
/// [ScrollDirection] and a [GrowthDirection] and wish to compute the
/// [ScrollDirection] in which growth will occur.
ScrollDirection applyGrowthDirecitonToScrollDirection(
    ScrollDirection scrollDirection, GrowthDirection growthDirection) {
  assert(scrollDirection != null);
  assert(growthDirection != null);
  switch (growthDirection) {
    case GrowthDirection.forward:
      return scrollDirection;
    case GrowthDirection.reverse:
      return flipScrollDirection(scrollDirection);
  }
  return null;
}

/// Immutable layout constraints for [RenderSliver] layout.
///
/// The [SliverConstraints] describe the current scroll state of the viewport
/// from the point of view of the sliver receiving the constraints. For example,
/// a [scrollOffset] of zero means that the leading edge of the sliver is
/// visible in the viewport, not that the viewport itself has a zero scroll
/// offset.
class SliverConstraints extends Constraints {
  /// Creates sliver constraints with the given information.
  ///
  /// All of the argument must not be null.
  const SliverConstraints({
    @required this.axisDirection,
    @required this.growthDirection,
    @required this.userScrollDirection,
    @required this.scrollOffset,
    @required this.overlap,
    @required this.remainingPaintExtent,
    @required this.crossAxisExtent,
    @required this.crossAxisDirection,
    @required this.viewportMainAxisExtent,
  });

  /// Creates a copy of this object but with the given fields replaced with the
  /// new values.
  SliverConstraints copyWith({
    AxisDirection axisDirection,
    GrowthDirection growthDirection,
    ScrollDirection userScrollDirection,
    double scrollOffset,
    double overlap,
    double remainingPaintExtent,
    double crossAxisExtent,
    AxisDirection crossAxisDirection,
    double viewportMainAxisExtent,
  }) {
    return new SliverConstraints(
      axisDirection: axisDirection ?? this.axisDirection,
      growthDirection: growthDirection ?? this.growthDirection,
      userScrollDirection: userScrollDirection ?? this.userScrollDirection,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      overlap: overlap ?? this.overlap,
      remainingPaintExtent: remainingPaintExtent ?? this.remainingPaintExtent,
      crossAxisExtent: crossAxisExtent ?? this.crossAxisExtent,
      crossAxisDirection: crossAxisDirection ?? this.crossAxisDirection,
      viewportMainAxisExtent:
          viewportMainAxisExtent ?? this.viewportMainAxisExtent,
    );
  }

  /// The direction in which the [scrollOffset] and [remainingPaintExtent]
  /// increase.
  final AxisDirection axisDirection;

  /// The direction in which the contents of slivers are ordered, relative to
  /// the [axisDirection].
  ///
  /// For example, if the [axisDirection] is [AxisDirection.up], and the
  /// [growthDirection] is [GrowthDirection.forward], then an alphabetical list
  /// will have A at the bottom, then B, then C, and so forth, with Z at the
  /// top, with the bottom of the A at scroll offset zero, and the top of the Z
  /// at the highest scroll offset.
  ///
  /// On the other hand, if the [axisDirection] is [AxisDirection.up] but the
  /// [growthDirection] is [GrowthDirection.reverse], then an alphabetical list
  /// will have A at the top, then B, then C, and so forth, with Z at the
  /// bottom, with the bottom of the Z at scroll offset zero, and the top of the
  /// A at the highest scroll offset.
  ///
  /// If a viewport has an overall [AxisDirection] of [AxisDirection.down], then
  /// slivers above the absolute zero offset will have an axis of
  /// [AxisDirection.up] and a growth direction of [GrowthDirection.reverse],
  /// while slivers below the absolute zero offset will have the same axis
  /// direction as the viewport and a growth direction of
  /// [GrowthDirection.forward]. (The slivers with a reverse growth direction
  /// still see only positive scroll offsets; the scroll offsets are reversed as
  /// well, with zero at the absolute zero point, and positive numbers going
  /// away from there.)
  ///
  /// In general, lists grow only in the positive scroll offset direction, so
  /// the only growth direction that is commonly seen is
  /// [GrowthDirection.forward].
  final GrowthDirection growthDirection;

  /// The direction in which the user is attempting to scroll, relative to the
  /// [axisDirection] and [growthDirection].
  ///
  /// For example, if [growthDirection] is [GrowthDirection.reverse] and
  /// [axisDirection] is [AxisDirection.down], then a
  /// [ScrollDirection.forward] means that the user is scrolling up, in the
  /// positive [scrollOffset] direction.
  ///
  /// If the _user_ is not scrolling, this will return [ScrollDirection.idle]
  /// even if there is (for example) a [ScrollActivity] currently animating the
  /// position.
  ///
  /// This is used by some slivers to determine how to react to a change in
  /// scroll offset. For example, [RenderSliverFloatingPersistentHeader] will
  /// only expand a floating app bar when the [userScrollDirection] is in the
  /// positive scroll offset direction.
  final ScrollDirection userScrollDirection;

  /// The scroll offset, in this sliver's coordinate system, that corresponds to
  /// the earliest visible part of this sliver in the [AxisDirection].
  ///
  /// For example, if [AxisDirection] is [AxisDirection.down], then this is the
  /// scroll offset at the top of the visible portion of the sliver.
  ///
  /// Whether this corresponds to the beginning or the end of the sliver's
  /// contents depends on the [growthDirection].
  final double scrollOffset;

  /// The number of pixels from where the pixels corresponding to the
  /// [scrollOffset] will be painted up to the first pixel that has not yet been
  /// painted on by an earlier sliver, in the [axisDirection].
  ///
  /// For example, if the previous sliver had a [SliverGeometry.paintExtent] of
  /// 100.0 pixels but a [SliverGeometry.layoutExtent] of only 50.0 pixels,
  /// then the [overlap] of this sliver will be 50.0.
  ///
  /// This is typically ignored unless the sliver is itself going to be pinned
  /// or floating and wants to avoid doing so under the previous sliver.
  final double overlap;

  /// The number of pixels of content that the sliver should consider providing.
  /// (Providing more pixels than this is inefficient.)
  ///
  /// The actual number of pixels provided should be specified in the
  /// [RenderSliver.geometry] as [SliverGeometry.paintExtent].
  ///
  /// This value may be infinite, for example if the viewport is an
  /// unconstrained [RenderShrinkWrappingViewport].
  ///
  /// This value may be 0.0, for example if the sliver is scrolled off the
  /// bottom of a downwards vertical viewport.
  final double remainingPaintExtent;

  /// The number of pixels in the cross-axis.
  ///
  /// For a vertical list, this is the width of the sliver.
  final double crossAxisExtent;

  /// The direction in which children should be placed in the cross axis.
  ///
  /// Typically used in vertical lists to describe whether the ambient
  /// [TextDirection] is [TextDirection.rtl] or [TextDirection.ltr].
  final AxisDirection crossAxisDirection;

  /// The number of pixels the viewport can display in the main axis.
  ///
  /// For a vertical list, this is the height of the viewport.
  final double viewportMainAxisExtent;

  /// The axis along which the [scrollOffset] and [remainingPaintExtent] are measured.
  Axis get axis => axisDirectionToAxis(axisDirection);

  /// Return what the [growthDirection] would be if the [axisDirection] was
  /// either [AxisDirection.down] or [AxisDirection.right].
  ///
  /// This is the same as [growthDirection] unless the [axisDirection] is either
  /// [AxisDirection.up] or [AxisDirection.left], in which case it is the
  /// opposite growth direction.
  ///
  /// This can be useful in combination with [axis] to view the [axisDirection]
  /// and [growthDirection] in different terms.
  GrowthDirection get normalizedGrowthDirection {
    assert(axisDirection != null);
    switch (axisDirection) {
      case AxisDirection.down:
      case AxisDirection.right:
        return growthDirection;
      case AxisDirection.up:
      case AxisDirection.left:
        switch (growthDirection) {
          case GrowthDirection.forward:
            return GrowthDirection.reverse;
          case GrowthDirection.reverse:
            return GrowthDirection.forward;
        }
        return null;
    }
    return null;
  }

  @override
  bool get isTight => false;

  @override
  bool get isNormalized {
    return scrollOffset >= 0.0 &&
        crossAxisExtent >= 0.0 &&
        axisDirectionToAxis(axisDirection) !=
            axisDirectionToAxis(crossAxisDirection) &&
        viewportMainAxisExtent >= 0.0 &&
        remainingPaintExtent >= 0.0;
  }

  /// Returns [BoxConstraints] that reflects the sliver constraints.
  ///
  /// The `minExtent` and `maxExtent` are used as the constraints in the main
  /// axis. If non-null, the given `crossAxisExtent` is used as a tight
  /// constraint in the cross axis. Otherwise, the [crossAxisExtent] from this
  /// object is used as a constraint in the cross axis.
  ///
  /// Useful for slivers that have [RenderBox] children.
  BoxConstraints asBoxConstraints({
    double minExtent: 0.0,
    double maxExtent: double.INFINITY,
    double crossAxisExtent,
  }) {
    crossAxisExtent ??= this.crossAxisExtent;
    switch (axis) {
      case Axis.horizontal:
        return new BoxConstraints(
          minHeight: crossAxisExtent,
          maxHeight: crossAxisExtent,
          minWidth: minExtent,
          maxWidth: maxExtent,
        );
      case Axis.vertical:
        return new BoxConstraints(
          minWidth: crossAxisExtent,
          maxWidth: crossAxisExtent,
          minHeight: minExtent,
          maxHeight: maxExtent,
        );
    }
    return null;
  }

  @override
  bool debugAssertIsValid({
    bool isAppliedConstraint: false,
    InformationCollector informationCollector,
  }) {
    assert(() {
      void verify(bool check, String message) {
        if (check) return;
        final StringBuffer information = new StringBuffer();
        if (informationCollector != null) informationCollector(information);
        throw new FlutterError(
            '$runtimeType is not valid: $message\n${information}The offending constraints were:\n  $this');
      }

      verify(axis != null, 'The "axis" is null.');
      verify(growthDirection != null, 'The "growthDirection" is null.');
      verify(scrollOffset != null, 'The "scrollOffset" is null.');
      verify(overlap != null, 'The "overlap" is null.');
      verify(
          remainingPaintExtent != null, 'The "remainingPaintExtent" is null.');
      verify(crossAxisExtent != null, 'The "crossAxisExtent" is null.');
      verify(viewportMainAxisExtent != null,
          'The "viewportMainAxisExtent" is null.');
      verify(scrollOffset >= 0.0, 'The "scrollOffset" is negative.');
      verify(crossAxisExtent >= 0.0, 'The "crossAxisExtent" is negative.');
      verify(crossAxisDirection != null, 'The "crossAxisDirection" is null.');
      verify(
          axisDirectionToAxis(axisDirection) !=
              axisDirectionToAxis(crossAxisDirection),
          'The "axisDirection" and the "crossAxisDirection" are along the same axis.');
      verify(viewportMainAxisExtent >= 0.0,
          'The "viewportMainAxisExtent" is negative.');
      verify(remainingPaintExtent >= 0.0,
          'The "remainingPaintExtent" is negative.');
      verify(isNormalized,
          'The constraints are not normalized.'); // should be redundant with earlier checks
      return true;
    });
    return true;
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other is! SliverConstraints) return false;
    final SliverConstraints typedOther = other;
    assert(typedOther.debugAssertIsValid());
    return typedOther.axisDirection == axisDirection &&
        typedOther.growthDirection == growthDirection &&
        typedOther.scrollOffset == scrollOffset &&
        typedOther.overlap == overlap &&
        typedOther.remainingPaintExtent == remainingPaintExtent &&
        typedOther.crossAxisExtent == crossAxisExtent &&
        typedOther.crossAxisDirection == crossAxisDirection &&
        typedOther.viewportMainAxisExtent == viewportMainAxisExtent;
  }

  @override
  int get hashCode {
    return hashValues(
      axisDirection,
      growthDirection,
      scrollOffset,
      overlap,
      remainingPaintExtent,
      crossAxisExtent,
      crossAxisDirection,
      viewportMainAxisExtent,
    );
  }

  @override
  String toString() {
    return 'SliverConstraints('
        '$axisDirection, '
        '$growthDirection, '
        '$userScrollDirection, '
        'scrollOffset: ${scrollOffset.toStringAsFixed(1)}, '
        'remainingPaintExtent: ${remainingPaintExtent.toStringAsFixed(1)}, ' +
        (overlap != 0.0 ? 'overlap: ${overlap.toStringAsFixed(1)}, ' : '') +
        'crossAxisExtent: ${crossAxisExtent.toStringAsFixed(1)}, ' +
        'crossAxisDirection: $crossAxisDirection, ' +
        'viewportMainAxisExtent: ${viewportMainAxisExtent.toStringAsFixed(1)}' +
        ')';
  }
}

/// Describes the amount of space occupied by a [RenderSliver].
///
/// A sliver can occupy space in several different ways, which is why this class
/// contains multiple values.
@immutable
class SliverGeometry extends Diagnosticable {
  /// Creates an object that describes the amount of space occupied by a sliver.
  ///
  /// If the [layoutExtent] argument is null, [layoutExtent] defaults to the
  /// [paintExtent]. If the [hitTestExtent] argument is null, [hitTestExtent]
  /// defaults to the [paintExtent]. If [visible] is null, [visible] defaults to
  /// whether [paintExtent] is greater than zero.
  ///
  /// The other arguments must not be null.
  const SliverGeometry({
    this.scrollExtent: 0.0,
    this.paintExtent: 0.0,
    this.paintOrigin: 0.0,
    double layoutExtent,
    this.maxPaintExtent: 0.0,
    this.maxScrollObstructionExtent: 0.0,
    double hitTestExtent,
    bool visible,
    this.hasVisualOverflow: false,
    this.scrollOffsetCorrection,
  })
      : layoutExtent = layoutExtent ?? paintExtent,
        hitTestExtent = hitTestExtent ?? paintExtent,
        visible = visible ?? paintExtent > 0.0;

  /// A sliver that occupies no space at all.
  static const SliverGeometry zero = const SliverGeometry();

  /// The (estimated) total scroll extent that this sliver has content for. In
  /// other words, the scroll offset of the end of the last bit of content of
  /// this sliver.
  ///
  /// This value must be accurate if the [paintExtent] is less than the
  /// [SliverConstraints.remainingPaintExtent] provided during layout.
  final double scrollExtent;

  /// The visual location of the first visible part of this sliver relative to
  /// its layout position.
  ///
  /// For example, if the sliver wishes to paint visually before its layout
  /// position, the [paintOrigin] is negative. The coordinate system this sliver
  /// uses for painting is relative to this [paintOrigin].
  ///
  /// This value does not affect the layout of subsequent slivers. The next
  /// sliver is still placed at [layoutExtent] after this sliver's layout
  /// position. This value does affect where the [paintExtent] extent is
  /// measured from when computing the [SliverConstraints.overlap] for the next
  /// sliver.
  ///
  /// Defaults to 0.0, which means slivers start painting at their layout
  /// position by default.
  final double paintOrigin;

  /// The amount of visual space that was taken by the sliver to render the
  /// subset of the sliver that covers all or part of the
  /// [SliverConstraints.remainingPaintExtent].
  ///
  /// This must be between zero and [SliverConstraints.remainingPaintExtent].
  ///
  /// This contributes to the calculation for the next sliver's
  /// [SliverConstraints.overlap].
  final double paintExtent;

  /// The distance from the first visible part of this sliver to the first
  /// visible part of the next sliver, assuming the next sliver's
  /// [SliverConstraints.scrollOffset] is zero.
  ///
  /// This must be between zero and [paintExtent]. It defaults to [paintExtent].
  final double layoutExtent;

  /// The (estimated) total paint extent that this sliver would be able to
  /// provide if the [SliverConstraints.remainingPaintExtent] was infinite.
  ///
  /// This is used by viewports that implement shrink-wrapping.
  ///
  /// By definition, this cannot be less than [paintExtent].
  final double maxPaintExtent;

  /// The maximum extent by which this sliver can reduce the area in which
  /// content can scroll if the sliver were pinned at the edge.
  ///
  /// Slivers that never get pinned at the edge, should return zero.
  ///
  /// A pinned app bar is an example for a sliver that would use this setting:
  /// When the app bar is pinned to the top, the area in which content can
  /// actually scroll is reduced by the height of the app bar.
  final double maxScrollObstructionExtent;

  /// The distance from where this sliver started painting to the bottom of
  /// where it should accept hits.
  ///
  /// This must be between zero and [paintExtent]. It defaults to [paintExtent].
  final double hitTestExtent;

  /// Whether this sliver should be painted.
  ///
  /// By default, this is true if [paintExtent] is greater than zero, and
  /// false if [paintExtent] is zero.
  final bool visible;

  /// Whether this sliver has visual overflow.
  ///
  /// By default, this is false, which means the viewport does not need to clip
  /// its children. If any slivers have visual overflow, the viewport will apply
  /// a clip to its children.
  final bool hasVisualOverflow;

  /// If this is non-zero after [RenderSliver.performLayout] returns, the scroll
  /// offset will be adjusted by the parent and then the entire layout of the
  /// parent will be rerun.
  final double scrollOffsetCorrection;

  /// Asserts that this geometry is internally consistent.
  ///
  /// Does nothing if asserts are disabled. Always returns true.
  bool debugAssertIsValid({
    InformationCollector informationCollector,
  }) {
    assert(() {
      void verify(bool check, String message) {
        if (check) return;
        final StringBuffer information = new StringBuffer();
        if (informationCollector != null) informationCollector(information);
        throw new FlutterError(
            '$runtimeType is not valid: $message\n$information');
      }

      verify(scrollExtent != null, 'The "scrollExtent" is null.');
      verify(scrollExtent >= 0.0, 'The "scrollExtent" is negative.');
      verify(paintExtent != null, 'The "paintExtent" is null.');
      verify(paintExtent >= 0.0, 'The "paintExtent" is negative.');
      verify(paintOrigin != null, 'The "paintOrigin" is null.');
      verify(layoutExtent != null, 'The "layoutExtent" is null.');
      verify(layoutExtent >= 0.0, 'The "layoutExtent" is negative.');
      if (layoutExtent > paintExtent) {
        verify(
          false,
          'The "layoutExtent" exceeds the "paintExtent".\n' +
              _debugCompareFloats(
                  'paintExtent', paintExtent, 'layoutExtent', layoutExtent),
        );
      }
      verify(maxPaintExtent != null, 'The "maxPaintExtent" is null.');
      if (maxPaintExtent < paintExtent) {
        verify(
            false,
            'The "maxPaintExtent" is less than the "paintExtent".\n' +
                _debugCompareFloats('maxPaintExtent', maxPaintExtent,
                    'paintExtent', paintExtent) +
                'By definition, a sliver can\'t paint more than the maximum that it can paint!');
      }
      verify(hitTestExtent != null, 'The "hitTestExtent" is null.');
      verify(hitTestExtent >= 0.0, 'The "hitTestExtent" is negative.');
      verify(visible != null, 'The "visible" property is null.');
      verify(hasVisualOverflow != null, 'The "hasVisualOverflow" is null.');
      verify(scrollOffsetCorrection != 0.0,
          'The "scrollOffsetCorrection" is zero.');
      return true;
    });
    return true;
  }

  @override
  String toStringShort() => '$runtimeType';

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new DoubleProperty('scrollExtent', scrollExtent));
    if (paintExtent > 0.0) {
      properties.add(new DoubleProperty('paintExtent', paintExtent,
          unit: visible ? null : ' but not painting'));
    } else if (paintExtent == 0.0) {
      if (visible) {
        properties.add(new DoubleProperty('paintExtent', paintExtent,
            unit: visible ? null : ' but visible'));
      }
      properties
          .add(new FlagProperty('visible', value: visible, ifFalse: 'hidden'));
    } else {
      // Negative paintExtent!
      properties
          .add(new DoubleProperty('paintExtent', paintExtent, tooltip: '!'));
    }
    properties
        .add(new DoubleProperty('paintOrigin', paintOrigin, defaultValue: 0.0));
    properties.add(new DoubleProperty('layoutExtent', layoutExtent,
        defaultValue: paintExtent));
    properties.add(new DoubleProperty('maxPaintExtent', maxPaintExtent));
    properties.add(new DoubleProperty('hitTestExtent', hitTestExtent,
        defaultValue: paintExtent));
    properties.add(new DiagnosticsProperty<bool>(
        'hasVisualOverflow', hasVisualOverflow,
        defaultValue: false));
    properties.add(new DoubleProperty(
        'scrollOffsetCorrection', scrollOffsetCorrection,
        defaultValue: null));
  }
}

/// Parent data structure used by parents of slivers that position their
/// children using layout offsets.
///
/// This data structure is optimised for fast layout. It is best used by parents
/// that expect to have many children whose relative positions don't change even
/// when the scroll offset does.
class SliverLogicalParentData extends ParentData {
  /// The position of the child relative to the zero scroll offset.
  ///
  /// The number of pixels from from the zero scroll offset of the parent sliver
  /// (the line at which its [SliverConstraints.scrollOffset] is zero) to the
  /// side of the child closest to that offset.
  ///
  /// In a typical list, this does not change as the parent is scrolled.
  double layoutOffset = 0.0;

  @override
  String toString() => 'layoutOffset=${layoutOffset.toStringAsFixed(1)}';
}

/// Parent data structure used by parents of slivers that position their
/// children using absolute coordinates.
///
/// For example, used by [RenderViewport].
///
/// This data structure is optimised for fast painting, at the cost of requiring
/// additional work during layout when the children change their offsets. It is
/// best used by parents that expect to have few children, especially if those
/// children will themselves be very tall relative to the parent.
class SliverPhysicalParentData extends ParentData {
  /// The position of the child relative to the parent.
  ///
  /// This is the distance from the top left visible corner of the parent to the
  /// top left visible corner of the sliver.
  Offset paintOffset = Offset.zero;

  /// Apply the [paintOffset] to the given [transform].
  ///
  /// Used to implement [RenderObject.applyPaintTransform] by slivers that use
  /// [SliverPhysicalParentData].
  void applyPaintTransform(Matrix4 transform) {
    transform.translate(paintOffset.dx, paintOffset.dy);
  }

  @override
  String toString() => 'paintOffset=$paintOffset';
}

String _debugCompareFloats(
    String labelA, double valueA, String labelB, double valueB) {
  if (valueA.toStringAsFixed(1) != valueB.toStringAsFixed(1)) {
    return 'The $labelA is ${valueA.toStringAsFixed(1)}, but '
        'the $labelB is ${valueB.toStringAsFixed(1)}. ';
  }
  return 'The $labelA is $valueA, but the $labelB is $valueB. '
      'Maybe you have fallen prey to floating point rounding errors, and should explicitly '
      'apply the min() or max() functions, or the clamp() method, to the $labelB? ';
}

/// Base class for the render objects that implement scroll effects in viewports.
///
/// A [RenderViewport] has a list of child slivers. Each sliver — literally a
/// slice of the viewport's contents — is laid out in turn, covering the
/// viewport in the process. (Every sliver is laid out each time, including
/// those that have zero extent because they are "scrolled off" or are beyond
/// the end of the viewport.)
///
/// Slivers participate in the _sliver protocol_, wherein during [layout] each
/// sliver receives a [SliverConstraints] object and computes a corresponding
/// [SliverGeometry] that describes where it fits in the viewport. This is
/// analogous to the box protocol used by [RenderBox], which gets a
/// [BoxConstraints] as input and computes a [Size].
///
/// Slivers have a leading edge, which is where the position described by
/// [SliverConstraints.scrollOffset] for this sliver begins. Slivers have
/// several dimensions, the primary of which is [SliverGeometry.paintExtent],
/// which describes the extent of the sliver along the main axis, starting from
/// the leading edge, reaching either the end of the viewport or the end of the
/// sliver, whichever comes first.
///
/// Slivers can change dimensions based on the changing constraints in a
/// non-linear fashion, to achieve various scroll effects. For example, the
/// various [RenderSliverPersistentHeader] subclasses, on which [SliverAppBar]
/// is based, achieve effects such as staying visible despite the scroll offset,
/// or reappearing at different offsets based on the user's scroll direction
/// ([SliverConstraints.userScrollDirection]).
///
/// ## Writing a RenderSliver subclass
///
/// Slivers can have sliver children, or children from another coordinate
/// system, typically box children. (For details on the box protocol, see
/// [RenderBox].) Slivers can also have different child models, typically having
/// either one child, or a list of children.
///
/// ### Examples of slivers
///
/// A good example of a sliver with a single child that is also itself a sliver
/// is [RenderSliverPadding], which indents its child. A sliver-to-sliver render
/// object such as this must construct a [SliverConstraints] object for its
/// child, then must take its child's [SliverGeometry] and use it to form its
/// own [geometry].
///
/// The other common kind of one-child sliver is a sliver that has a single
/// [RenderBox] child. An example of that would be [RenderSliverToBoxAdapter],
/// which lays out a single box and sizes itself around the box. Such a sliver
/// must use its [SliverConstraints] to create a [BoxConstraints] for the
/// child, lay the child out (using the child's [layout] method), and then use
/// the child's [RenderBox.size] to generate the sliver's [SliverGeometry].
///
/// The most common kind of sliver though is one with multiple children. The
/// most straight-forward example of this is [RenderSliverList], which arranges
/// its children one after the other in the main axis direction. As with the
/// one-box-child sliver case, it uses its [constraints] to create a
/// [BoxConstraints] for the children, and then it uses the aggregate
/// information from all its children to generate its [geometry]. Unlike the
/// one-child cases, however, it is judicious in which children it actually lays
/// out (and later paints). If the scroll offset is 1000 pixels, and it
/// previously determined that the first three children are each 400 pixels
/// tall, then it will skip the first two and start the layout with its third
/// child.
///
/// ### Layout
///
/// As they are laid out, slivers decide their [geometry], which includes their
/// size ([SliverGeometry.paintExtent]) and the position of the next sliver
/// ([SliverGeometry.layoutExtent]), as well as the position of each of their
/// children, based on the input [constraints] from the viewport such as the
/// scroll offset ([SliverConstraints.scrollOffset]).
///
/// For example, a sliver that just paints a box 100 pixels high would say its
/// [SliverGeometry.paintExtent] was 100 pixels when the scroll offset was zero,
/// but would say its [SliverGeometry.paintExtent] was 25 pixels when the scroll
/// offset was 75 pixels, and would say it was zero when the scroll offset was
/// 100 pixels or more. (This is assuming that
/// [SliverConstraints.remainingPaintExtent] was more than 100 pixels.)
///
/// The various dimensions that are provided as input to this system are in the
/// [constraints]. They are described in detail in the documentation for the
/// [SliverConstraints] class.
///
/// The [performLayout] function must take these [constraints] and create a
/// [SliverGeometry] object that it must then assign to the [geometry] property.
/// The different dimensions of the geometry that can be configured are
/// described in detail in the documentation for the [SliverGeometry] class.
///
/// ### Painting
///
/// In addition to implementing layout, a sliver must also implement painting.
/// This is achieved by overriding the [paint] method.
///
/// The [paint] method is called with an [Offset] from the [Canvas] origin to
/// the top-left corner of the sliver, _regardless of the axis direction_.
///
/// Subclasses should also override [applyPaintTransform] to provide the
/// [Matrix4] describing the position of each child relative to the sliver.
/// (This is used by, among other things, the accessibility layer, to determine
/// the bounds of the child.)
///
/// ### Hit testing
///
/// To implement hit testing, either override the [hitTestSelf] and
/// [hitTestChildren] methods, or, for more complex cases, instead override the
/// [hitTest] method directly.
///
/// To actually react to pointer events, the [handleEvent] method may be
/// implemented. By default it does nothing. (Typically gestures are handled by
/// widgets in the box protocol, not by slivers directly.)
///
/// ### Helper methods
///
/// There are a number of methods that a sliver should implement which will make
/// the other methods easier to implement. Each method listed below has detailed
/// documentation. In addition, the [RenderSliverHelpers] class can be used to
/// mix in some helpful methods.
///
/// #### childScrollOffset
///
/// If the subclass positions children anywhere other than at scroll offset
/// zero, it should override [childScrollOffset]. For example,
/// [RenderSliverList] and [RenderSliverGrid] override this method, but
/// [RenderSliverToBoxAdapter] does not.
///
/// This is used by, among other things, [Scrollable.ensureVisible].
///
/// #### childMainAxisPosition
///
/// Subclasses should implement [childMainAxisPosition] to describe where their
/// children are positioned.
///
/// #### childCrossAxisPosition
///
/// If the subclass positions children in the cross-axis at a position other
/// than zero, then it should override [childCrossAxisPosition]. For example
/// [RenderSliverGrid] overrides this method.
abstract class RenderSliver extends RenderObject {}
