// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'box.dart';
import 'object.dart';

/// Parent data used by [RenderTable] for its children.
class TableCellParentData extends BoxParentData {
  /// Where this cell should be placed vertically.
  TableCellVerticalAlignment verticalAlignment;

  /// The column that the child was in the last time it was laid out.
  int x;

  /// The row that the child was in the last time it was laid out.
  int y;

  @override
  String toString() => '${super.toString()}; ${verticalAlignment == null
      ? "default vertical alignment"
      : "$verticalAlignment"}';
}

/// Base class to describe how wide a column in a [RenderTable] should be.
///
/// To size a column to a specific number of pixels, use a [FixedColumnWidth].
/// This is the cheapest way to size a column.
///
/// Other algorithms that are relatively cheap include [FlexColumnWidth], which
/// distributes the space equally among the flexible columns,
/// [FractionColumnWidth], which sizes a column based on the size of the
/// table's container.
@immutable
abstract class TableColumnWidth {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const TableColumnWidth();

  /// The flex factor to apply to the cell if there is any room left
  /// over when laying out the table. The remaining space is
  /// distributed to any columns with flex in proportion to their flex
  /// value (higher values get more space).
  ///
  /// The `cells` argument is an iterable that provides all the cells
  /// in the table for this column. Walking the cells is by definition
  /// O(N), so algorithms that do that should be considered expensive.
  double flex(Iterable<RenderBox> cells) => null;

  @override
  String toString() => '$runtimeType';
}

/// Sizes the column according to the intrinsic dimensions of all the
/// cells in that column.
///
/// This is a very expensive way to size a column.
///
/// A flex value can be provided. If specified (and non-null), the
/// column will participate in the distribution of remaining space
/// once all the non-flexible columns have been sized.
class IntrinsicColumnWidth extends TableColumnWidth {
  /// Creates a column width based on intrinsic sizing.
  ///
  /// This sizing algorithm is very expensive.
  const IntrinsicColumnWidth({double flex}) : _flex = flex;

  final double _flex;

  @override
  double flex(Iterable<RenderBox> cells) => _flex;
}

/// Sizes the column to a specific number of pixels.
///
/// This is the cheapest way to size a column.
class FixedColumnWidth extends TableColumnWidth {
  /// Creates a column width based on a fixed number of logical pixels.
  ///
  /// The [value] argument must not be null.
  const FixedColumnWidth(this.value);

  /// The width the column should occupy in logical pixels.
  final double value;

  @override
  String toString() => '$runtimeType($value)';
}

/// Sizes the column to a fraction of the table's constraints' maxWidth.
///
/// This is a cheap way to size a column.
class FractionColumnWidth extends TableColumnWidth {
  /// Creates a column width based on a fraction of the table's constraints'
  /// maxWidth.
  ///
  /// The [value] argument must not be null.
  const FractionColumnWidth(this.value);

  /// The fraction of the table's constraints' maxWidth that this column should
  /// occupy.
  final double value;

  @override
  String toString() => '$runtimeType($value)';
}

/// Sizes the column by taking a part of the remaining space once all
/// the other columns have been laid out.
///
/// For example, if two columns have a [FlexColumnWidth], then half the
/// space will go to one and half the space will go to the other.
///
/// This is a cheap way to size a column.
class FlexColumnWidth extends TableColumnWidth {
  /// Creates a column width based on a fraction of the remaining space once all
  /// the other columns have been laid out.
  ///
  /// The [value] argument must not be null.
  const FlexColumnWidth([this.value = 1.0]);

  /// The reaction of the of the remaining space once all the other columns have
  /// been laid out that this column should occupy.
  final double value;

  @override
  double flex(Iterable<RenderBox> cells) {
    return value;
  }

  @override
  String toString() => '$runtimeType($value)';
}

/// Sizes the column such that it is the size that is the maximum of
/// two column width specifications.
///
/// For example, to have a column be 10% of the container width or
/// 100px, whichever is bigger, you could use:
///
///     const MaxColumnWidth(const FixedColumnWidth(100.0), FractionColumnWidth(0.1))
///
/// Both specifications are evaluated, so if either specification is
/// expensive, so is this.
class MaxColumnWidth extends TableColumnWidth {
  /// Creates a column width that is the maximum of two other column widths.
  const MaxColumnWidth(this.a, this.b);

  /// A lower bound for the width of this column.
  final TableColumnWidth a;

  /// Another lower bound for the width of this column.
  final TableColumnWidth b;

  @override
  double flex(Iterable<RenderBox> cells) {
    final double aFlex = a.flex(cells);
    if (aFlex == null) return b.flex(cells);
    final double bFlex = b.flex(cells);
    if (bFlex == null) return null;
    return math.max(aFlex, bFlex);
  }

  @override
  String toString() => '$runtimeType($a, $b)';
}

/// Sizes the column such that it is the size that is the minimum of
/// two column width specifications.
///
/// For example, to have a column be 10% of the container width but
/// never bigger than 100px, you could use:
///
///     const MinColumnWidth(const FixedColumnWidth(100.0), FractionColumnWidth(0.1))
///
/// Both specifications are evaluated, so if either specification is
/// expensive, so is this.
class MinColumnWidth extends TableColumnWidth {
  /// Creates a column width that is the minimum of two other column widths.
  const MinColumnWidth(this.a, this.b);

  /// An upper bound for the width of this column.
  final TableColumnWidth a;

  /// Another upper bound for the width of this column.
  final TableColumnWidth b;

  @override
  double flex(Iterable<RenderBox> cells) {
    final double aFlex = a.flex(cells);
    if (aFlex == null) return b.flex(cells);
    final double bFlex = b.flex(cells);
    if (bFlex == null) return null;
    return math.min(aFlex, bFlex);
  }

  @override
  String toString() => '$runtimeType($a, $b)';
}

/// Vertical alignment options for cells in [RenderTable] objects.
///
/// This is specified using [TableCellParentData] objects on the
/// [RenderObject.parentData] of the children of the [RenderTable].
enum TableCellVerticalAlignment {
  /// Cells with this alignment are placed with their top at the top of the row.
  top,

  /// Cells with this alignment are vertically centered in the row.
  middle,

  /// Cells with this alignment are placed with their bottom at the bottom of the row.
  bottom,

  /// Cells with this alignment are aligned such that they all share the same
  /// baseline. Cells with no baseline are top-aligned instead. The baseline
  /// used is specified by [RenderTable.textBaseline]. It is not valid to use
  /// the baseline value if [RenderTable.textBaseline] is not specified.
  ///
  /// This vertial alignment is relatively expensive because it causes the table
  /// to compute the baseline for each cell in the row.
  baseline,

  /// Cells with this alignment are sized to be as tall as the row, then made to fit the row.
  /// If all the cells have this alignment, then the row will have zero height.
  fill
}
