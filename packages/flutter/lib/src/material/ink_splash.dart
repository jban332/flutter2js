// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'material.dart';

const Duration _kUnconfirmedSplashDuration = const Duration(seconds: 1);
const Duration _kSplashFadeDuration = const Duration(milliseconds: 200);

const double _kSplashInitialSize = 0.0; // logical pixels
const double _kSplashConfirmedVelocity = 1.0; // logical pixels per millisecond

/// A visual reaction on a piece of [Material] to user input.
///
/// This object is rarely created directly. Instead of creating an ink splash
/// directly, consider using an [InkResponse] or [InkWell] widget, which uses
/// gestures (such as tap and long-press) to trigger ink splashes.
///
/// See also:
///
///  * [InkResponse], which uses gestures to trigger ink highlights and ink
///    splashes in the parent [Material].
///  * [InkWell], which is a rectangular [InkResponse] (the most common type of
///    ink response).
///  * [Material], which is the widget on which the ink splash is painted.
///  * [InkHighlight], which is an ink feature that emphasizes a part of a
///    [Material].
class InkSplash extends InkFeature {
  /// Begin a splash, centered at position relative to [referenceBox].
  ///
  /// The [controller] argument is typically obtained via
  /// `Material.of(context)`.
  ///
  /// If `containedInkWell` is true, then the splash will be sized to fit
  /// the well rectangle, then clipped to it when drawn. The well
  /// rectangle is the box returned by `rectCallback`, if provided, or
  /// otherwise is the bounds of the [referenceBox].
  ///
  /// If `containedInkWell` is false, then `rectCallback` should be null.
  /// The ink splash is clipped only to the edges of the [Material].
  /// This is the default.
  ///
  /// When the splash is removed, `onRemoved` will be called.
  InkSplash({
    @required MaterialInkController controller,
    @required RenderBox referenceBox,
    Offset position,
    Color color,
    bool containedInkWell: false,
    RectCallback rectCallback,
    BorderRadius borderRadius = BorderRadius.zero,
    double radius,
    VoidCallback onRemoved,
  });

  /// The color of the splash.
  Color get color => _color;
  Color _color;

  set color(Color value) {}

  /// The user input is confirmed.
  ///
  /// Causes the reaction to propagate faster across the material.
  void confirm() {}

  /// The user input was canceled.
  ///
  /// Causes the reaction to gradually disappear.
  void cancel() {}
}
