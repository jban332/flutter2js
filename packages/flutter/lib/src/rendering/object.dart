// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/painting.dart';
import 'package:vector_math/vector_math_64.dart';

import 'binding.dart';
import 'layer.dart';
import 'node.dart';

export 'package:flutter/foundation.dart'
    show
        FlutterError,
        InformationCollector,
        DiagnosticsNode,
        DiagnosticsProperty,
        StringProperty,
        DoubleProperty,
        EnumProperty,
        IntProperty,
        DiagnosticPropertiesBuilder;
export 'package:flutter/gestures.dart' show HitTestEntry, HitTestResult;
export 'package:flutter/painting.dart';

/// Base class for data associated with a [RenderObject] by its parent.
///
/// Some render objects wish to store data on their children, such as their
/// input parameters to the parent's layout algorithm or their position relative
/// to other children.
class ParentData {
  /// Called when the RenderObject is removed from the tree.
  @protected
  @mustCallSuper
  void detach() {}

  @override
  String toString() => '<none>';
}

/// Signature for painting into a [PaintingContext].
///
/// The `offset` argument is the offset from the origin of the coordinate system
/// of the [PaintingContext.canvas] to the coordinate system of the callee.
///
/// Used by many of the methods of [PaintingContext].
typedef void PaintingContextCallback(PaintingContext context, Offset offset);

/// A place to paint.
///
/// Rather than holding a canvas directly, [RenderObject]s paint using a painting
/// context. The painting context has a [Canvas], which receives the
/// individual draw operations, and also has functions for painting child
/// render objects.
///
/// When painting a child render object, the canvas held by the painting context
/// can change because the draw operations issued before and after painting the
/// child might be recorded in separate compositing layers. For this reason, do
/// not hold a reference to the canvas across operations that might paint
/// child render objects.
///
/// New [PaintingContext] objects are created automatically when using
/// [PaintingContext.repaintCompositedChild] and [pushLayer].
abstract class PaintingContext {
  /// The bounds within which the painting context's [canvas] will record
  /// painting commands.
  ///
  /// A render object provided with this [PaintingContext] (e.g. in its
  /// [RenderObject.paint] method) is permitted to paint outside the region that
  /// the render object occupies during layout, but is not permitted to paint
  /// outside these canvas paints bounds. These paint bounds are used to
  /// construct memory-efficient composited layers, which means attempting to
  /// paint outside these bounds can attempt to write to pixels that do not
  /// exist in the composited layer.
  ///
  /// The [canvasBounds] rectangle is in the [canvas] coordinate system.
  Rect get canvasBounds;

  /// The canvas on which to paint.
  ///
  /// The current canvas can change whenever you paint a child using this
  /// context, which means it's fragile to hold a reference to the canvas
  /// returned by this getter.
  ///
  /// Only calls within the [canvasBounds] will be recorded.
  Canvas get canvas;

  /// Hints that the painting in the current layer is complex and would benefit
  /// from caching.
  ///
  /// If this hint is not set, the compositor will apply its own heuristics to
  /// decide whether the current layer is complex enough to benefit from
  /// caching.
  void setIsComplexHint();

  /// Hints that the painting in the current layer is likely to change next frame.
  ///
  /// This hint tells the compositor not to cache the current layer because the
  /// cache will not be used in the future. If this hint is not set, the
  /// compositor will apply its own heuristics to decide whether the current
  /// layer is likely to be reused in the future.
  void setWillChangeHint();

  /// Adds a composited leaf layer to the recording.
  ///
  /// After calling this function, the [canvas] property will change to refer to
  /// a new [Canvas] that draws on top of the given layer.
  ///
  /// A [RenderObject] that uses this function is very likely to require its
  /// [RenderObject.alwaysNeedsCompositing] property to return true. That informs
  /// ancestor render objects that this render object will include a composited
  /// layer, which, for example, causes them to use composited clips.
  ///
  /// See also:
  ///
  ///  * [pushLayer], for adding a layer and using its canvas to paint with that
  ///    layer.
  void addLayer(Layer layer);

  /// Appends the given layer to the recording, and calls the `painter` callback
  /// with that layer, providing the `childPaintBounds` as the paint bounds of
  /// the child. Canvas recording commands are not guaranteed to be stored
  /// outside of the paint bounds.
  ///
  /// The given layer must be an unattached orphan. (Providing a newly created
  /// object, rather than reusing an existing layer, satisfies that
  /// requirement.)
  ///
  /// The `offset` is the offset to pass to the `painter`.
  ///
  /// If the `childPaintBounds` are not specified then the current layer's paint
  /// bounds are used. This is appropriate if the child layer does not apply any
  /// transformation or clipping to its contents. The `childPaintBounds`, if
  /// specified, must be in the coordinate system of the new layer, and should
  /// not go outside the current layer's paint bounds.
  ///
  /// See also:
  ///
  ///  * [addLayer], for pushing a leaf layer whose canvas is not used.
  void pushLayer(
      Layer childLayer, PaintingContextCallback painter, Offset offset,
      {Rect childPaintBounds});

  /// Clip further painting using a rectangle.
  ///
  /// * `needsCompositing` is whether the child needs compositing. Typically
  ///   matches the value of [RenderObject.needsCompositing] for the caller.
  /// * `offset` is the offset from the origin of the canvas' coordinate system
  ///   to the origin of the caller's coordinate system.
  /// * `clipRect` is rectangle (in the caller's coodinate system) to use to
  ///   clip the painting done by [painter].
  /// * `painter` is a callback that will paint with the [clipRect] applied. This
  ///   function calls the [painter] synchronously.
  void pushClipRect(bool needsCompositing, Offset offset, Rect clipRect,
      PaintingContextCallback painter);

  /// Clip further painting using a rounded rectangle.
  ///
  /// * `needsCompositing` is whether the child needs compositing. Typically
  ///   matches the value of [RenderObject.needsCompositing] for the caller.
  /// * `offset` is the offset from the origin of the canvas' coordinate system
  ///   to the origin of the caller's coordinate system.
  /// * `bounds` is the region of the canvas (in the caller's coodinate system)
  ///   into which `painter` will paint in.
  /// * `clipRRect` is the rounded-rectangle (in the caller's coodinate system)
  ///   to use to clip the painting done by `painter`.
  /// * `painter` is a callback that will paint with the `clipRRect` applied. This
  ///   function calls the `painter` synchronously.
  void pushClipRRect(bool needsCompositing, Offset offset, Rect bounds,
      RRect clipRRect, PaintingContextCallback painter);

  /// Clip further painting using a path.
  ///
  /// * `needsCompositing` is whether the child needs compositing. Typically
  ///   matches the value of [RenderObject.needsCompositing] for the caller.
  /// * `offset` is the offset from the origin of the canvas' coordinate system
  ///   to the origin of the caller's coordinate system.
  /// * `bounds` is the region of the canvas (in the caller's coodinate system)
  ///   into which `painter` will paint in.
  /// * `clipPath` is the path (in the coodinate system of the caller) to use to
  ///   clip the painting done by `painter`.
  /// * `painter` is a callback that will paint with the `clipPath` applied. This
  ///   function calls the `painter` synchronously.
  void pushClipPath(bool needsCompositing, Offset offset, Rect bounds,
      Path clipPath, PaintingContextCallback painter);

  /// Transform further painting using a matrix.
  ///
  /// * `needsCompositing` is whether the child needs compositing. Typically
  ///   matches the value of [RenderObject.needsCompositing] for the caller.
  /// * `offset` is the offset from the origin of the canvas' coordinate system
  ///   to the origin of the caller's coordinate system.
  /// * `transform` is the matrix to apply to the paiting done by `painter`.
  /// * `painter` is a callback that will paint with the `transform` applied. This
  ///   function calls the `painter` synchronously.
  void pushTransform(bool needsCompositing, Offset offset, Matrix4 transform,
      PaintingContextCallback painter);

  /// Blend further paiting with an alpha value.
  ///
  /// * `offset` is the offset from the origin of the canvas' coordinate system
  ///   to the origin of the caller's coordinate system.
  /// * `alpha` is the alpha value to use when blending the painting done by
  ///   `painter`. An alpha value of 0 means the painting is fully transparent
  ///   and an alpha value of 255 means the painting is fully opaque.
  /// * `painter` is a callback that will paint with the `alpha` applied. This
  ///   function calls the `painter` synchronously.
  ///
  /// A [RenderObject] that uses this function is very likely to require its
  /// [RenderObject.alwaysNeedsCompositing] property to return true. That informs
  /// ancestor render objects that this render object will include a composited
  /// layer, which, for example, causes them to use composited clips.
  void pushOpacity(Offset offset, int alpha, PaintingContextCallback painter);

  @override
  String toString() => '$runtimeType#$hashCode';
}

/// An abstract set of layout constraints.
///
/// Concrete layout models (such as box) will create concrete subclasses to
/// communicate layout constraints between parents and children.
///
/// ## Writing a Constraints subclass
///
/// When creating a new [RenderObject] subclass with a new layout protocol, one
/// will usually need to create a new [Constraints] subclass to express the
/// input to the layout algorithms.
///
/// A [Constraints] subclass should be immutable (all fields final). There are
/// several members to implement, in addition to whatever fields, constructors,
/// and helper methods one may find useful for a particular layout protocol:
///
/// * The [isTight] getter, which should return true if the object represents a
///   case where the [RenderObject] class has no choice for how to lay itself
///   out. For example, [BoxConstraints] returns true for [isTight] when both
///   the minimum and maximum widths and the minimum and maximum heights are
///   equal.
///
/// * The [isNormalized] getter, which should return true if the object
///   represents its data in its canonical form. Sometimes, it is possible for
///   fields to be redundant with each other, such that several different
///   representations have the same implications. For example, a
///   [BoxConstraints] instance with its minimum width greater than its maximum
///   width is equivalent to one where the maximum width is set to that minimum
///   width (`2<w<1` is equivalent to `2<w<2`, since minimum constraints have
///   priority). This getter is used by the default implementation of
///   [debugAssertIsValid].
///
/// * The [debugAssertIsValid] method, which should assert if there's anything
///   wrong with the constraints object. (We use this approach rather than
///   asserting in constructors so that our constructors can be `const` and so
///   that it is possible to create invalid constraints temporarily while
///   building valid ones.) See the implementation of
///   [BoxConstraints.debugAssertIsValid] for an example of the detailed checks
///   that can be made.
///
/// * The [==] operator and the [hashCode] getter, so that constraints can be
///   compared for equality. If a render object is given constraints that are
///   equal, then the rendering library will avoid laying the object out again
///   if it is not dirty.
///
/// * The [toString] method, which should describe the constraints so that they
///   appear in a usefully readable form in the output of [debugDumpRenderTree].
@immutable
abstract class Constraints {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const Constraints();

  /// Whether there is exactly one size possible given these constraints
  bool get isTight;

  /// Whether the constraint is expressed in a consistent manner.
  bool get isNormalized;

  /// Asserts that the constraints are valid.
  ///
  /// This might involve checks more detailed than [isNormalized].
  ///
  /// For example, the [BoxConstraints] subclass verifies that the constraints
  /// are not [double.NAN].
  ///
  /// If the `isAppliedConstraint` argument is true, then even stricter rules
  /// are enforced. This argument is set to true when checking constraints that
  /// are about to be applied to a [RenderObject] during layout, as opposed to
  /// constraints that may be further affected by other constraints. For
  /// example, the asserts for verifying the validity of
  /// [RenderConstrainedBox.additionalConstraints] do not set this argument, but
  /// the asserts for verifying the argument passed to the [RenderObject.layout]
  /// method do.
  ///
  /// The `informationCollector` argument takes an optional callback which is
  /// called when an exception is to be thrown. The collected information is
  /// then included in the message after the error line.
  ///
  /// Returns the same as [isNormalized] if asserts are disabled.
  bool debugAssertIsValid(
      {bool isAppliedConstraint: false,
      InformationCollector informationCollector}) {
    assert(isNormalized);
    return isNormalized;
  }
}

/// Signature for a function that is called for each [RenderObject].
///
/// Used by [RenderObject.visitChildren] and [RenderObject.visitChildrenForSemantics].
typedef void RenderObjectVisitor(RenderObject child);

/// Signature for a function that is called during layout.
///
/// Used by [RenderObject.invokeLayoutCallback].
typedef void LayoutCallback<T extends Constraints>(T constraints);

/// An object in the render tree.
///
/// The [RenderObject] class hierarchy is the core of the rendering
/// library's reason for being.
///
/// [RenderObject]s have a [parent], and have a slot called [parentData] in
/// which the parent [RenderObject] can store child-specific data, for example,
/// the child position. The [RenderObject] class also implements the basic
/// layout and paint protocols.
///
/// The [RenderObject] class, however, does not define a child model (e.g.
/// whether a node has zero, one, or more children). It also doesn't define a
/// coordinate system (e.g. whether children are positioned in cartesian
/// coordinates, in polar coordinates, etc) or a specific layout protocol (e.g.
/// whether the layout is width-in-height-out, or constraint-in-size-out, or
/// whether the parent sets the size and position of the child before or after
/// the child lays out, etc; or indeed whether the children are allowed to read
/// their parent's [parentData] slot).
///
/// The [RenderBox] subclass introduces the opinion that the layout
/// system uses cartesian coordinates.
///
/// ## Writing a RenderObject subclass
///
/// In most cases, subclassing [RenderObject] itself is overkill, and
/// [RenderBox] would be a better starting point. However, if a render object
/// doesn't want to use a cartesian coordinate system, then it should indeed
/// inherit from [RenderObject] directly. This allows it to define its own
/// layout protocol by using a new subclass of [Constraints] rather than using
/// [BoxConstraints], and by potentially using an entirely new set of objects
/// and values to represent the result of the output rather than just a [Size].
/// This increased flexibility comes at the cost of not being able to rely on
/// the features of [RenderBox]. For example, [RenderBox] implements an
/// intrinsic sizing protocol that allows you to measure a child without fully
/// laying it out, in such a way that if that child changes size, the parent
/// will be laid out again (to take into account the new dimensions of the
/// child). This is a subtle and bug-prone feature to get right.
///
/// Most aspects of writing a [RenderBox] apply to writing a [RenderObject] as
/// well, and therefore the discussion at [RenderBox] is recommended background
/// reading. The main differences are around layout and hit testing, since those
/// are the aspects that [RenderBox] primarily specializes.
///
/// ### Layout
///
/// A layout protocol begins with a subclass of [Constraints]. See the
/// discussion at [Constraints] for more information on how to write a
/// [Constraints] subclass.
///
/// The [performLayout] method should take the [constraints], and apply them.
/// The output of the layout algorithm is fields set on the object that describe
/// the geometry of the object for the purposes of the parent's layout. For
/// example, with [RenderBox] the output is the [RenderBox.size] field. This
/// output should only be read by the parent if the parent specified
/// `parentUsesSize` as true when calling [layout] on the child.
///
/// Anytime anything changes on a render object that would affect the layout of
/// that object, it should call [markNeedsLayout].
///
/// ### Hit Testing
///
/// Hit testing is even more open-ended than layout. There is no method to
/// override, you are expected to provide one.
///
/// The general behaviour of your hit-testing method should be similar to the
/// behavior described for [RenderBox]. The main difference is that the input
/// need not be an [Offset]. You are also allowed to use a different subclass of
/// [HitTestEntry] when adding entries to the [HitTestResult]. When the
/// [handleEvent] method is called, the same object that was added to the
/// [HitTestResult] will be passed in, so it can be used to track information
/// like the precise coordinate of the hit, in whatever coordinate system is
/// used by the new layout protocol.
///
/// ### Adapting from one protocol to another
///
/// In general, the root of a Flutter render object tree is a [RenderView]. This
/// object has a single child, which must be a [RenderBox]. Thus, if you want to
/// have a custom [RenderObject] subclass in the render tree, you have two
/// choices: you either need to replace the [RenderView] itself, or you need to
/// have a [RenderBox] that has your class as its child. (The latter is the much
/// more common case.)
///
/// This [RenderBox] subclass converts from the box protocol to the protocol of
/// your class.
///
/// In particular, this means that for hit testing it overrides
/// [RenderBox.hitTest], and calls whatever method you have in your class for
/// hit testing.
///
/// Similarly, it overrides [performLayout] to create a [Constraints] object
/// appropriate for your class and passes that to the child's [layout] method.
///
/// ### Layout interactions between render objects
///
/// In general, the layout of a render box should only depend on the output of
/// its child's layout, and then only if `parentUsesSize` is set to true in the
/// [layout] call. Furthermore, if it is set to true, the parent must call the
/// child's [layout] if the child is to be rendered, because otherwise the
/// parent will not be notified when the child changes its layout outputs.
///
/// It is possible to set up render object protocols that transfer additional
/// information. For example, in the [RenderBox] protocol you can query your
/// children's intrinsic dimensions and baseline geometry. However, if this is
/// done then it is imperative that the child call [markNeedsLayout] on the
/// parent any time that additional information changes, if the parent used it
/// in the last layout phase. For an example of how to implement this, see the
/// [RenderBox.markNeedsLayout] method. It overrides
/// [RenderObject.markNeedsLayout] so that if a parent has queried the intrinsic
/// or baseline information, it gets marked dirty whenever the child's geometry
/// changes.
abstract class RenderObject extends AbstractNode with DiagnosticableTreeMixin {
  dynamic debugCreator;

  /// Initializes internal fields for subclasses.
  RenderObject();

  void markNeedsLayout() {}

  /// Data for use by the parent render object.
  ///
  /// The parent data is used by the render object that lays out this object
  /// (typically this object's parent in the render tree) to store information
  /// relevant to itself and to any other nodes who happen to know exactly what
  /// the data means. The parent data is opaque to the child.
  ///
  ///  * The parent data field must not be directly set, except by calling
  ///    [setupParentData] on the parent node.
  ///  * The parent data can be set before the child is added to the parent, by
  ///    calling [setupParentData] on the future parent node.
  ///  * The conventions for using the parent data depend on the layout protocol
  ///    used between the parent and child. For example, in box layout, the
  ///    parent data is completely opaque but in sector layout the child is
  ///    permitted to read some fields of the parent data.
  ParentData parentData;

  /// Called by subclasses when they decide a render object is a child.
  ///
  /// Only for use by subclasses when changing their child lists. Calling this
  /// in other cases will lead to an inconsistent tree and probably cause crashes.
  @override
  void adoptChild(RenderObject child) {
    assert(child != null);
    super.adoptChild(child);
  }

  /// Called by subclasses when they decide a render object is no longer a child.
  ///
  /// Only for use by subclasses when changing their child lists. Calling this
  /// in other cases will lead to an inconsistent tree and probably cause crashes.
  @override
  void dropChild(RenderObject child) {
    assert(child != null);
    assert(child.parentData != null);
    child.parentData.detach();
    child.parentData = null;
    super.dropChild(child);
  }

  /// Calls visitor for each immediate child of this render object.
  ///
  /// Override in subclasses with children and call the visitor for each child.
  void visitChildren(RenderObjectVisitor visitor) {}

  /// Returns a human understandable name.
  @override
  String toStringShort() {
    String header = describeIdentity(this);
    return header;
  }

  @override
  String toString({DiagnosticLevel minLevel}) => toStringShort();

  @protected
  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    description.add(new DiagnosticsProperty<dynamic>('creator', debugCreator,
        defaultValue: null, level: DiagnosticLevel.debug));
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() => <DiagnosticsNode>[];
}

/// Generic mixin for render objects with one child.
///
/// Provides a child model for a render object subclass that has a unique child.
abstract class RenderObjectWithChildMixin<ChildType extends RenderObject>
    extends RenderObject {

  /// Checks whether the given render object has the correct [runtimeType] to be
  /// a child of this render object.
  ///
  /// Does nothing if assertions are disabled.
  ///
  /// Always returns true.
  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw new FlutterError(
            'A $runtimeType expected a child of type $ChildType but received a '
            'child of type ${child.runtimeType}.\n'
            'RenderObjects expect specific types of children because they '
            'coordinate with their children during layout and paint. For '
            'example, a RenderSliver cannot be the child of a RenderBox because '
            'a RenderSliver does not understand the RenderBox layout protocol.\n'
            '\n'
            'The $runtimeType that expected a $ChildType child was created by:\n'
            '  $debugCreator\n'
            '\n'
            'The ${child
                .runtimeType} that did not match the expected child type '
            'was created by:\n'
            '  ${child.debugCreator}\n');
      }
      return true;
    }());
    return true;
  }

  ChildType _child;

  /// The render object's unique child
  ChildType get child => _child;

  set child(ChildType value) {
    if (_child != null) dropChild(_child);
    _child = value;
    if (_child != null) adoptChild(_child);
  }

  @override
  void redepthChildren() {
    if (_child != null) redepthChild(_child);
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    if (_child != null) visitor(_child);
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return child != null
        ? <DiagnosticsNode>[child.toDiagnosticsNode(name: 'child')]
        : <DiagnosticsNode>[];
  }
}

/// Parent data to support a doubly-linked list of children.
abstract class ContainerParentDataMixin<ChildType extends RenderObject>
    extends ParentData {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory ContainerParentDataMixin._() => null;

  /// The previous sibling in the parent's child list.
  ChildType previousSibling;

  /// The next sibling in the parent's child list.
  ChildType nextSibling;

  /// Clear the sibling pointers.
  @override
  void detach() {
    super.detach();
    if (previousSibling != null) {
      final ContainerParentDataMixin<ChildType> previousSiblingParentData =
          previousSibling.parentData;
      assert(previousSibling != this);
      assert(previousSiblingParentData.nextSibling == this);
      previousSiblingParentData.nextSibling = nextSibling;
    }
    if (nextSibling != null) {
      final ContainerParentDataMixin<ChildType> nextSiblingParentData =
          nextSibling.parentData;
      assert(nextSibling != this);
      assert(nextSiblingParentData.previousSibling == this);
      nextSiblingParentData.previousSibling = previousSibling;
    }
    previousSibling = null;
    nextSibling = null;
  }
}

/// Generic mixin for render objects with a list of children.
///
/// Provides a child model for a render object subclass that has a doubly-linked
/// list of children.
abstract class ContainerRenderObjectMixin<ChildType extends RenderObject,
        ParentDataType extends ContainerParentDataMixin<ChildType>>
    extends RenderObject {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory ContainerRenderObjectMixin._() => null;

  bool _debugUltimatePreviousSiblingOf(ChildType child, {ChildType equals}) {
    ParentDataType childParentData = child.parentData;
    while (childParentData.previousSibling != null) {
      assert(childParentData.previousSibling != child);
      child = childParentData.previousSibling;
      childParentData = child.parentData;
    }
    return child == equals;
  }

  bool _debugUltimateNextSiblingOf(ChildType child, {ChildType equals}) {
    ParentDataType childParentData = child.parentData;
    while (childParentData.nextSibling != null) {
      assert(childParentData.nextSibling != child);
      child = childParentData.nextSibling;
      childParentData = child.parentData;
    }
    return child == equals;
  }

  int _childCount = 0;

  /// The number of children.
  int get childCount => _childCount;

  /// Checks whether the given render object has the correct [runtimeType] to be
  /// a child of this render object.
  ///
  /// Does nothing if assertions are disabled.
  ///
  /// Always returns true.
  bool debugValidateChild(RenderObject child) {
    assert(() {
      if (child is! ChildType) {
        throw new FlutterError(
            'A $runtimeType expected a child of type $ChildType but received a '
            'child of type ${child.runtimeType}.\n'
            'RenderObjects expect specific types of children because they '
            'coordinate with their children during layout and paint. For '
            'example, a RenderSliver cannot be the child of a RenderBox because '
            'a RenderSliver does not understand the RenderBox layout protocol.\n'
            '\n'
            'The $runtimeType that expected a $ChildType child was created by:\n'
            '  $debugCreator\n'
            '\n'
            'The ${child
                .runtimeType} that did not match the expected child type '
            'was created by:\n'
            '  ${child.debugCreator}\n');
      }
      return true;
    }());
    return true;
  }

  ChildType _firstChild;
  ChildType _lastChild;

  void _insertIntoChildList(ChildType child, {ChildType after}) {
    final ParentDataType childParentData = child.parentData;
    assert(childParentData.nextSibling == null);
    assert(childParentData.previousSibling == null);
    _childCount += 1;
    assert(_childCount > 0);
    if (after == null) {
      // insert at the start (_firstChild)
      childParentData.nextSibling = _firstChild;
      if (_firstChild != null) {
        final ParentDataType _firstChildParentData = _firstChild.parentData;
        _firstChildParentData.previousSibling = child;
      }
      _firstChild = child;
      _lastChild ??= child;
    } else {
      assert(_firstChild != null);
      assert(_lastChild != null);
      assert(_debugUltimatePreviousSiblingOf(after, equals: _firstChild));
      assert(_debugUltimateNextSiblingOf(after, equals: _lastChild));
      final ParentDataType afterParentData = after.parentData;
      if (afterParentData.nextSibling == null) {
        // insert at the end (_lastChild); we'll end up with two or more children
        assert(after == _lastChild);
        childParentData.previousSibling = after;
        afterParentData.nextSibling = child;
        _lastChild = child;
      } else {
        // insert in the middle; we'll end up with three or more children
        // set up links from child to siblings
        childParentData.nextSibling = afterParentData.nextSibling;
        childParentData.previousSibling = after;
        // set up links from siblings to child
        final ParentDataType childPreviousSiblingParentData =
            childParentData.previousSibling.parentData;
        final ParentDataType childNextSiblingParentData =
            childParentData.nextSibling.parentData;
        childPreviousSiblingParentData.nextSibling = child;
        childNextSiblingParentData.previousSibling = child;
        assert(afterParentData.nextSibling == child);
      }
    }
  }

  /// Insert child into this render object's child list after the given child.
  ///
  /// If `after` is null, then this inserts the child at the start of the list,
  /// and the child becomes the new [firstChild].
  void insert(ChildType child, {ChildType after}) {
    assert(child != this, 'A RenderObject cannot be inserted into itself.');
    assert(after != this,
        'A RenderObject cannot simultaneously be both the parent and the sibling of another RenderObject.');
    assert(child != after, 'A RenderObject cannot be inserted after itself.');
    assert(child != _firstChild);
    assert(child != _lastChild);
    adoptChild(child);
    _insertIntoChildList(child, after: after);
  }

  /// Append child to the end of this render object's child list.
  void add(ChildType child) {
    insert(child, after: _lastChild);
  }

  /// Add all the children to the end of this render object's child list.
  void addAll(List<ChildType> children) {
    if (children != null) for (ChildType child in children) add(child);
  }

  void _removeFromChildList(ChildType child) {
    final ParentDataType childParentData = child.parentData;
    assert(_debugUltimatePreviousSiblingOf(child, equals: _firstChild));
    assert(_debugUltimateNextSiblingOf(child, equals: _lastChild));
    assert(_childCount >= 0);
    if (childParentData.previousSibling == null) {
      assert(_firstChild == child);
      _firstChild = childParentData.nextSibling;
    } else {
      final ParentDataType childPreviousSiblingParentData =
          childParentData.previousSibling.parentData;
      childPreviousSiblingParentData.nextSibling = childParentData.nextSibling;
    }
    if (childParentData.nextSibling == null) {
      assert(_lastChild == child);
      _lastChild = childParentData.previousSibling;
    } else {
      final ParentDataType childNextSiblingParentData =
          childParentData.nextSibling.parentData;
      childNextSiblingParentData.previousSibling =
          childParentData.previousSibling;
    }
    childParentData.previousSibling = null;
    childParentData.nextSibling = null;
    _childCount -= 1;
  }

  /// Remove this child from the child list.
  ///
  /// Requires the child to be present in the child list.
  void remove(ChildType child) {
    _removeFromChildList(child);
    dropChild(child);
  }

  /// Remove all their children from this render object's child list.
  ///
  /// More efficient than removing them individually.
  void removeAll() {
    ChildType child = _firstChild;
    while (child != null) {
      final ParentDataType childParentData = child.parentData;
      final ChildType next = childParentData.nextSibling;
      childParentData.previousSibling = null;
      childParentData.nextSibling = null;
      dropChild(child);
      child = next;
    }
    _firstChild = null;
    _lastChild = null;
    _childCount = 0;
  }

  /// Move this child in the child list to be before the given child.
  ///
  /// More efficient than removing and re-adding the child. Requires the child
  /// to already be in the child list at some position. Pass null for before to
  /// move the child to the end of the child list.
  void move(ChildType child, {ChildType after}) {
    assert(child != this);
    assert(after != this);
    assert(child != after);
    assert(child.parent == this);
    final ParentDataType childParentData = child.parentData;
    if (childParentData.previousSibling == after) return;
    _removeFromChildList(child);
    _insertIntoChildList(child, after: after);
  }

  @override
  void redepthChildren() {
    ChildType child = _firstChild;
    while (child != null) {
      redepthChild(child);
      final ParentDataType childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
  }

  @override
  void visitChildren(RenderObjectVisitor visitor) {
    ChildType child = _firstChild;
    while (child != null) {
      visitor(child);
      final ParentDataType childParentData = child.parentData;
      child = childParentData.nextSibling;
    }
  }

  /// The first child in the child list.
  ChildType get firstChild => _firstChild;

  /// The last child in the child list.
  ChildType get lastChild => _lastChild;

  /// The previous child before the given child in the child list.
  ChildType childBefore(ChildType child) {
    assert(child != null);
    assert(child.parent == this);
    final ParentDataType childParentData = child.parentData;
    return childParentData.previousSibling;
  }

  /// The next child after the given child in the child list.
  ChildType childAfter(ChildType child) {
    assert(child != null);
    assert(child.parent == this);
    final ParentDataType childParentData = child.parentData;
    return childParentData.nextSibling;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    final List<DiagnosticsNode> children = <DiagnosticsNode>[];
    if (firstChild != null) {
      ChildType child = firstChild;
      int count = 1;
      while (true) {
        children.add(child.toDiagnosticsNode(name: 'child $count'));
        if (child == lastChild) break;
        count += 1;
        final ParentDataType childParentData = child.parentData;
        child = childParentData.nextSibling;
      }
    }
    return children;
  }
}

/// Variant of [FlutterErrorDetails] with extra fields for the rendering
/// library.
class FlutterErrorDetailsForRendering extends FlutterErrorDetails {
  /// Creates a [FlutterErrorDetailsForRendering] object with the given
  /// arguments setting the object's properties.
  ///
  /// The rendering library calls this constructor when catching an exception
  /// that will subsequently be reported using [FlutterError.onError].
  const FlutterErrorDetailsForRendering(
      {dynamic exception,
      StackTrace stack,
      String library,
      String context,
      this.renderObject,
      InformationCollector informationCollector,
      bool silent: false})
      : super(
            exception: exception,
            stack: stack,
            library: library,
            context: context,
            informationCollector: informationCollector,
            silent: silent);

  /// The RenderObject that was being processed when the exception was caught.
  final RenderObject renderObject;
}
