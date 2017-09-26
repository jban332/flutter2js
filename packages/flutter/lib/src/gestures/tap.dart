// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'events.dart';

/// Details for [GestureTapDownCallback], such as position.
class TapDownDetails {
  /// Creates details for a [GestureTapDownCallback].
  ///
  /// The [globalPosition] argument must not be null.
  TapDownDetails({this.globalPosition: Offset.zero});

  /// The global position at which the pointer contacted the screen.
  final Offset globalPosition;
}

/// Signature for when a pointer that might cause a tap has contacted the
/// screen.
///
/// The position at which the pointer contacted the screen is available in the
/// `details`.
typedef void GestureTapDownCallback(TapDownDetails details);

/// Details for [GestureTapUpCallback], such as position.
class TapUpDetails {
  /// Creates details for a [GestureTapUpCallback].
  ///
  /// The [globalPosition] argument must not be null.
  TapUpDetails({this.globalPosition: Offset.zero});

  /// The global position at which the pointer contacted the screen.
  final Offset globalPosition;
}

/// Signature for when a pointer that will trigger a tap has stopped contacting
/// the screen.
///
/// The position at which the pointer stopped contacting the screen is available
/// in the `details`.
typedef void GestureTapUpCallback(TapUpDetails details);

/// Signature for when a tap has occurred.
typedef void GestureTapCallback();

/// Signature for when the pointer that previously triggered a
/// [GestureTapDownCallback] will not end up causing a tap.
typedef void GestureTapCancelCallback();
