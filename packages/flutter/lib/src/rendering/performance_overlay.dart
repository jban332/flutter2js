// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// The options that control whether the performance overlay displays certain
/// aspects of the compositor.
enum PerformanceOverlayOption {
  // these must be in the order needed for their index values to match the
  // constants in //engine/src/sky/compositor/performance_overlay_layer.h

  /// Display the frame time and FPS of the last frame rendered. This field is
  /// updated every frame.
  ///
  /// This is the time spent by the rasterizer as it tries
  /// to convert the layer tree obtained from the widgets into OpenGL commands
  /// and tries to flush them onto the screen. When the total time taken by this
  /// step exceeds the frame slice, a frame is lost.
  displayRasterizerStatistics,

  /// Display the rasterizer frame times as they change over a set period of
  /// time in the form of a graph. The y axis of the graph denotes the total
  /// time spent by the rasterizer as a fraction of the total frame slice. When
  /// the bar turns red, a frame is lost.
  visualizeRasterizerStatistics,

  /// Display the frame time and FPS at which the interface can construct a
  /// layer tree for the rasterizer (whose behavior is described above) to
  /// consume.
  ///
  /// This involves all layout, animations, etc. When the total time taken by
  /// this step exceeds the frame slice, a frame is lost.
  displayEngineStatistics,

  /// Display the engine frame times as they change over a set period of time
  /// in the form of a graph. The y axis of the graph denotes the total time
  /// spent by the eninge as a fraction of the total frame slice. When the bar
  /// turns red, a frame is lost.
  visualizeEngineStatistics,
}
