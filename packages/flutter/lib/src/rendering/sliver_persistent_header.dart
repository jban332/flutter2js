// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// Specifies how a floating header is to be "snapped" (animated) into or out
/// of view.
///
/// See also:
///
///  * [RenderSliverFloatingPersistentHeader.maybeStartSnapAnimation] and
///    [RenderSliverFloatingPersistentHeader.maybeStopSnapAnimation], which
///    start or stop the floating header's animation.
///  * [SliverAppBar], which creates a header that can be pinned, floating,
///    and snapped into view via the corresponding parameters.
class FloatingHeaderSnapConfiguration {
  /// Creates an object that specifies how a floating header is to be "snapped"
  /// (animated) into or out of view.
  FloatingHeaderSnapConfiguration({
    @required this.vsync,
    this.curve: Curves.ease,
    this.duration: const Duration(milliseconds: 300),
  });

  /// The [TickerProvider] for the [AnimationController] that causes a
  /// floating header to snap in or out of view.
  final TickerProvider vsync;

  /// The snap animation curve.
  final Curve curve;

  /// The snap animation's duration.
  final Duration duration;
}
