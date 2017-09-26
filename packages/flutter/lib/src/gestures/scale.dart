// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'events.dart';
import 'velocity_tracker.dart';

/// Details for [GestureScaleStartCallback].
class ScaleStartDetails {
  /// Creates details for [GestureScaleStartCallback].
  ///
  /// The [focalPoint] argument must not be null.
  ScaleStartDetails({this.focalPoint: Offset.zero});

  /// The initial focal point of the pointers in contact with the screen.
  /// Reported in global coordinates.
  final Offset focalPoint;

  @override
  String toString() => 'ScaleStartDetails(focalPoint: $focalPoint)';
}

/// Details for [GestureScaleUpdateCallback].
class ScaleUpdateDetails {
  /// Creates details for [GestureScaleUpdateCallback].
  ///
  /// The [focalPoint] and [scale] arguments must not be null. The [scale]
  /// argument must be greater than or equal to zero.
  ScaleUpdateDetails({
    this.focalPoint: Offset.zero,
    this.scale: 1.0,
  });

  /// The focal point of the pointers in contact with the screen. Reported in
  /// global coordinates.
  final Offset focalPoint;

  /// The scale implied by the pointers in contact with the screen. A value
  /// greater than or equal to zero.
  final double scale;

  @override
  String toString() =>
      'ScaleUpdateDetails(focalPoint: $focalPoint, scale: $scale)';
}

/// Details for [GestureScaleEndCallback].
class ScaleEndDetails {
  /// Creates details for [GestureScaleEndCallback].
  ///
  /// The [velocity] argument must not be null.
  ScaleEndDetails({this.velocity: Velocity.zero});

  /// The velocity of the last pointer to be lifted off of the screen.
  final Velocity velocity;

  @override
  String toString() => 'ScaleEndDetails(velocity: $velocity)';
}

/// Signature for when the pointers in contact with the screen have established
/// a focal point and initial scale of 1.0.
typedef void GestureScaleStartCallback(ScaleStartDetails details);

/// Signature for when the pointers in contact with the screen have indicated a
/// new focal point and/or scale.
typedef void GestureScaleUpdateCallback(ScaleUpdateDetails details);

/// Signature for when the pointers are no longer in contact with the screen.
typedef void GestureScaleEndCallback(ScaleEndDetails details);
