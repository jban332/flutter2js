// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';

import 'framework.dart';

/// The signature of the [LayoutBuilder] builder function.
typedef Widget LayoutWidgetBuilder(
    BuildContext context, BoxConstraints constraints);

/// Builds a widget tree that can depend on the parent widget's size.
///
/// Similar to the [Builder] widget except that the framework calls the [builder]
/// function at layout time and provides the parent widget's constraints. This
/// is useful when the parent constrains the child's size and doesn't depend on
/// the child's intrinsic size. The [LayoutBuilder]'s final size will match its
/// child's size.
///
/// If the child should be smaller than the parent, consider wrapping the child
/// in an [Align] widget. If the child might want to be bigger, consider
/// wrapping it in a [SingleChildScrollView].
///
/// See also:
///
/// * [Builder], which calls a `builder` function at build time.
/// * [StatefulBuilder], which passes its `builder` function a `setState` callback.
/// * [CustomSingleChildLayout], which positions its child during layout.
class LayoutBuilder extends StatelessWidget {
  /// Creates a widget that defers its building until layout.
  ///
  /// The [builder] argument must not be null.
  const LayoutBuilder({Key key, @required this.builder}) : super(key: key);

  /// Called at layout time to construct the widget tree. The builder must not
  /// return null.
  final LayoutWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return builder(context, new BoxConstraints());
  }
}
