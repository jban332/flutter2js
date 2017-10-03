// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'debug.dart';
import 'framework.dart';

export 'package:flutter/rendering.dart'
    show
        FixedColumnWidth,
        FlexColumnWidth,
        FractionColumnWidth,
        IntrinsicColumnWidth,
        MaxColumnWidth,
        MinColumnWidth,
        TableBorder,
        TableCellVerticalAlignment,
        TableColumnWidth;

/// A horizontal group of cells in a [Table].
///
/// Every row in a table must have the same number of children.
///
/// The alignment of individual cells in a row can be controlled using a
/// [TableCell].
@immutable
class TableRow {
  /// Creates a row in a [Table].
  const TableRow({this.key, this.decoration, this.children});

  /// An identifier for the row.
  final LocalKey key;

  /// A decoration to paint behind this row.
  ///
  /// Row decorations fill the horizontal and vertical extent of each row in
  /// the table, unlike decorations for individual cells, which might not fill
  /// either.
  final Decoration decoration;

  /// The widgets that comprise the cells in this row.
  ///
  /// Children may be wrapped in [TableCell] widgets to provide per-cell
  /// configuration to the [Table], but children are not required to be wrapped
  /// in [TableCell] widgets.
  final List<Widget> children;

  @override
  String toString() {
    final StringBuffer result = new StringBuffer();
    result.write('TableRow(');
    if (key != null) result.write('$key, ');
    if (decoration != null) result.write('$decoration, ');
    if (children == null) {
      result.write('child list is null');
    } else if (children.isEmpty) {
      result.write('no children');
    } else {
      result.write('$children');
    }
    result.write(')');
    return result.toString();
  }
}

/// A widget that uses the table layout algorithm for its children.
///
/// If you only have one row, the [Row] widget is more appropriate. If you only
/// have one column, the [SliverList] or [Column] widgets will be more
/// appropriate.
///
/// Rows size vertically based on their contents. To control the column widths,
/// use the [columnWidths] property.
///
/// For more details about the table layout algorithm, see [RenderTable].
/// To control the alignment of children, see [TableCell].
class Table extends flur.StatelessUIPluginWidget {
  /// Creates a table.
  ///
  /// The [children], [defaultColumnWidth], and [defaultVerticalAlignment]
  /// arguments must not be null.
  Table(
      {Key key,
      this.children: const <TableRow>[],
      this.columnWidths,
      this.defaultColumnWidth: const FlexColumnWidth(1.0),
      this.border,
      this.defaultVerticalAlignment: TableCellVerticalAlignment.top,
      this.textBaseline})
      : super(key: key) {
    assert(() {
      final List<Widget> flatChildren = children
          .expand((TableRow row) => row.children)
          .toList(growable: false);
      if (debugChildrenHaveDuplicateKeys(this, flatChildren)) {
        throw new FlutterError(
            'Two or more cells in this Table contain widgets with the same key.\n'
            'Every widget child of every TableRow in a Table must have different keys. The cells of a Table are '
            'flattened out for processing, so separate cells cannot have duplicate keys even if they are in '
            'different rows.');
      }
      return true;
    });
  }

  /// The rows of the table.
  ///
  /// Every row in a table must have the same number of children, and all the
  /// children must be non-null.
  final List<TableRow> children;

  /// How the horizontal extents of the columns of this table should be determined.
  ///
  /// If the [Map] has a null entry for a given column, the table uses the
  /// [defaultColumnWidth] instead. By default, that uses flex sizing to
  /// distribute free space equally among the columns.
  ///
  /// The [FixedColumnWidth] class can be used to specify a specific width in
  /// pixels. That is the cheapest way to size a table's columns.
  ///
  /// The layout performance of the table depends critically on which column
  /// sizing algorithms are used here. In particular, [IntrinsicColumnWidth] is
  /// quite expensive because it needs to measure each cell in the column to
  /// determine the intrinsic size of the column.
  final Map<int, TableColumnWidth> columnWidths;

  /// How to determine with widths of columns that don't have an explicit sizing algorithm.
  ///
  /// Specifically, the [defaultColumnWidth] is used for column `i` if
  /// `columnWidths[i]` is null.
  final TableColumnWidth defaultColumnWidth;

  /// The style to use when painting the boundary and interior divisions of the table.
  final TableBorder border;

  /// How cells that do not explicitly specify a vertical alignment are aligned vertically.
  final TableCellVerticalAlignment defaultVerticalAlignment;

  /// The text baseline to use when aligning rows using [TableCellVerticalAlignment.baseline].
  final TextBaseline textBaseline;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildTable(context, this);
  }
}

/// A widget that controls how a child of a [Table] is aligned.
///
/// A [TableCell] widget must be a descendant of a [Table], and the path from
/// the [TableCell] widget to its enclosing [Table] must contain only
/// [TableRow]s, [StatelessWidget]s, or [StatefulWidget]s (not
/// other kinds of widgets, like [RenderObjectWidget]s).
class TableCell extends flur.SingleChildUIPluginWidget {
  final Widget child;

  /// Creates a widget that controls how a child of a [Table] is aligned.
  const TableCell({Key key, this.verticalAlignment, @required this.child})
      : super(key: key);

  /// How this cell is aligned vertically.
  final TableCellVerticalAlignment verticalAlignment;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new EnumProperty<TableCellVerticalAlignment>(
        'verticalAlignment', verticalAlignment));
  }

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildTableCell(context, this);
  }
}
