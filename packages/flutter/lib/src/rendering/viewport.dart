// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'object.dart';
import 'viewport_offset.dart';

/// An interface for render objects that are bigger on the inside.
///
/// Some render objects, such as [RenderViewport], present a portion of their
/// content, which can be controlled by a [ViewportOffset]. This interface lets
/// the framework recognize such render objects and interact with them without
/// having specific knowledge of all the various types of viewports.
abstract class RenderAbstractViewport extends RenderObject {
  // This class is intended to be used as an interface with the implements
  // keyword, and should not be extended directly.
  factory RenderAbstractViewport._() => null;

  /// Returns the [RenderAbstractViewport] that most tightly encloses the given
  /// render object.
  ///
  /// If the object does not have a [RenderAbstractViewport] as an ancestor,
  /// this function returns null.
  static RenderAbstractViewport of(RenderObject object) {
    while (object != null) {
      if (object is RenderAbstractViewport) return object;
      object = object.parent;
    }
    return null;
  }

  /// Returns the offset that would be needed to reveal the target render object.
  ///
  /// The `alignment` argument describes where the target should be positioned
  /// after applying the returned offset. If `alignment` is 0.0, the child must
  /// be positioned as close to the leading edge of the viewport as possible. If
  /// `alignment` is 1.0, the child must be positioned as close to the trailing
  /// edge of the viewport as possible. If `alignment` is 0.5, the child must be
  /// positioned as close to the center of the viewport as possible.
  ///
  /// The target might not be a direct child of this viewport but it must be a
  /// descendant of the viewport and there must not be any other
  /// [RenderAbstractViewport] objects between the target and this object.
  double getOffsetToReveal(RenderObject target, double alignment);
}
