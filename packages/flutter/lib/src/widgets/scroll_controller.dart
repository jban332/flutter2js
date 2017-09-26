// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'scroll_position.dart';

/// Controls a scrollable widget.
///
/// Scroll controllers are typically stored as member variables in [State]
/// objects and are reused in each [State.build]. A single scroll controller can
/// be used to control multiple scrollable widgets, but some operations, such
/// as reading the scroll [offset], require the controller to be used with a
/// single scrollable widget.
///
/// A scroll controller creates a [ScrollPosition] to manage the state specific
/// to an individual [Scrollable] widget. To use a custom [ScrollPosition],
/// subclass [ScrollController] and override [createScrollPosition].
///
/// A [ScrollController] is a [Listenable]. It notifies its listeners whenever
/// any of the attached [ScrollPosition]s notify _their_ listeners (i.e.
/// whenever any of them scroll).
///
/// Typically used with [ListView], [GridView], [CustomScrollView].
///
/// See also:
///
///  * [ListView], [GridView], [CustomScrollView], which can be controlled by a
///    [ScrollController].
///  * [Scrollable], which is the lower-level widget that creates and associates
///    [ScrollPosition] objects with [ScrollController] objects.
///  * [PageController], which is an analogous object for controlling a
///    [PageView].
///  * [ScrollPosition], which manages the scroll offset for an individual
///    scrolling widget.
///  * [ScrollNotification] and [NotificationListener], which can be used to watch
///    the scroll position without using a [ScrollController].
class ScrollController extends ChangeNotifier {
  /// Creates a controller for a scrollable widget.
  ///
  /// The values of `initialScrollOffset` and `keepScrollOffset` must not be null.
  ScrollController({
    double initialScrollOffset: 0.0,
    this.keepScrollOffset: true,
    this.debugLabel,
  });

  /// Each time a scroll completes, save the current scroll [offset] with
  /// [PageStorage] and restore it if this controller's scrollable is recreated.
  ///
  /// If this property is set to false, the scroll offset is never saved
  /// and [initialScrollOffset] is always used to initialize the scroll
  /// offset. If true (the default), the initial scroll offset is used the
  /// first time the controller's scrollable is created, since there's no
  /// scroll offset to restore yet. Subsequently the saved offset is
  /// restored and [initialScrollOffset] is ignored.
  ///
  /// See also:
  ///
  ///  * [PageStorageKey], which should be used when more than one
  ////   scrollable appears in the same route, to distinguish the [PageStorage]
  ///    locations used to save scroll offsets.
  final bool keepScrollOffset;

  /// A label that is used in the [toString] output. Intended to aid with
  /// identifying scroll controller instances in debug output.
  final String debugLabel;
}
