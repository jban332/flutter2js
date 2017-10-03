// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';

import 'object.dart';

/// The layout constraints for the root render object.
@immutable
class ViewConfiguration {
  /// Creates a view configuration.
  ///
  /// By default, the view has zero [size] and a [devicePixelRatio] of 1.0.
  const ViewConfiguration(
      {this.size: Size.zero, this.devicePixelRatio: 1.0, this.orientation});

  /// The size of the output surface.
  final Size size;

  /// The pixel density of the output surface.
  final double devicePixelRatio;

  /// The orientation of the output surface (aspirational).
  final int orientation;

  /// Creates a transformation matrix that applies the [devicePixelRatio].
  Matrix4 toMatrix() {
    return new Matrix4.diagonal3Values(devicePixelRatio, devicePixelRatio, 1.0);
  }

  @override
  String toString() => '$size at ${devicePixelRatio}x';
}
