// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'material.dart';

/// The base type for [MaterialSlice] and [MaterialGap].
///
/// All [MergeableMaterialItem] objects need a [LocalKey].
@immutable
abstract class MergeableMaterialItem {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  ///
  /// The argument is the [key], which must not be null.
  const MergeableMaterialItem(this.key);

  /// The key for this item of the list.
  ///
  /// The key is used to match parts of the mergeable material from frame to
  /// frame so that state is maintained appropriately even as slices are added
  /// or removed.
  final LocalKey key;
}

/// A class that can be used as a child to [MergeableMaterial]. It is a slice
/// of [Material] that animates merging with other slices.
///
/// All [MaterialSlice] objects need a [LocalKey].
class MaterialSlice extends MergeableMaterialItem {
  /// Creates a slice of [Material] that's mergeable within a
  /// [MergeableMaterial].
  const MaterialSlice({
    @required LocalKey key,
    @required this.child,
  }) :
        super(key);

  /// The contents of this slice.
  final Widget child;

  @override
  String toString() {
    return 'MergeableSlice(key: $key, child: $child)';
  }
}

/// A class that represents a gap within [MergeableMaterial].
///
/// All [MaterialGap] objects need a [LocalKey].
class MaterialGap extends MergeableMaterialItem {
  /// Creates a Material gap with a given size.
  const MaterialGap({
    @required LocalKey key,
    this.size: 16.0
  }) :
        super(key);

  /// The main axis extent of this gap. For example, if the [MergeableMaterial]
  /// is vertical, then this is the height of the gap.
  final double size;

  @override
  String toString() {
    return 'MaterialGap(key: $key, child: $size)';
  }
}

/// Displays a list of [MergeableMaterialItem] children. The list contains
/// [MaterialSlice] items whose boundaries are either "merged" with adjacent
/// items or separated by a [MaterialGap]. The [children] are distributed along
/// the given [mainAxis] in the same way as the children of a [ListBody]. When
/// the list of children changes, gaps are automatically animated open or closed
/// as needed.
///
/// To enable this widget to correlate its list of children with the previous
/// one, each child must specify a key.
///
/// When a new gap is added to the list of children the adjacent items are
/// animated apart. Similarly when a gap is removed the adjacent items are
/// brought back together.
///
/// When a new slice is added or removed, the app is responsible for animating
/// the transition of the slices, while the gaps will be animated automatically.
///
/// See also:
///
///  * [Card], a piece of material that does not support splitting and merging
///    but otherwise looks the same.
class MergeableMaterial extends flur.StatelessUIPluginWidget {
  /// Creates a mergeable Material list of items.
  const MergeableMaterial({
    Key key,
    this.mainAxis: Axis.vertical,
    this.elevation: 2,
    this.hasDividers: false,
    this.children: const <MergeableMaterialItem>[]
  }) : super(key: key);

  /// The children of the [MergeableMaterial].
  final List<MergeableMaterialItem> children;

  /// The main layout axis.
  final Axis mainAxis;

  /// The z-coordinate at which to place all the [Material] slices.
  ///
  /// The following elevations have defined shadows: 1, 2, 3, 4, 6, 8, 9, 12, 16, 24
  ///
  /// Defaults to 2, the appropriate elevation for cards.
  final int elevation;

  /// Whether connected pieces of [MaterialSlice] have dividers between them.
  final bool hasDividers;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(new EnumProperty<Axis>('mainAxis', mainAxis));
    properties.add(new DoubleProperty('elevation', elevation.toDouble()));
  }

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildMergeableMaterial(context, this);
  }
}