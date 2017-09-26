// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'arena.dart';
import 'debug.dart';
import 'events.dart';

/// Generic signature for callbacks passed to
/// [GestureRecognizer.invokeCallback]. This allows the
/// [GestureRecognizer.invokeCallback] mechanism to be generically used with
/// anonymous functions that return objects of particular types.
typedef T RecognizerCallback<T>();

/// The base class that all gesture recognizers inherit from.
///
/// Provides a basic API that can be used by classes that work with
/// gesture recognizers but don't care about the specific details of
/// the gestures recognizers themselves.
///
/// See also:
///
///  * [GestureDetector], the widget that is used to detect gestures.
///  * [debugPrintRecognizerCallbacksTrace], a flag that can be set to help
///    debug issues with gesture recognizers.
abstract class GestureRecognizer extends GestureArenaMember
    with DiagnosticableTreeMixin {
  /// Initializes the gesture recognizer.
  ///
  /// The argument is optional and is only used for debug purposes (e.g. in the
  /// [toString] serialization).
  GestureRecognizer({this.debugOwner});

  /// The recognizer's owner.
  ///
  /// This is used in the [toString] serialization to report the object for which
  /// this gesture recognizer was created, to aid in debugging.
  final Object debugOwner;

  /// Registers a new pointer that might be relevant to this gesture
  /// detector.
  ///
  /// The owner of this gesture recognizer calls addPointer() with the
  /// PointerDownEvent of each pointer that should be considered for
  /// this gesture.
  ///
  /// It's the GestureRecognizer's responsibility to then add itself
  /// to the global pointer router (see [PointerRouter]) to receive
  /// subsequent events for this pointer, and to add the pointer to
  /// the global gesture arena manager (see [GestureArenaManager]) to track
  /// that pointer.
  void addPointer(PointerDownEvent event);

  /// Releases any resources used by the object.
  ///
  /// This method is called by the owner of this gesture recognizer
  /// when the object is no longer needed (e.g. when a gesture
  /// recognizer is being unregistered from a [GestureDetector], the
  /// GestureDetector widget calls this method).
  @mustCallSuper
  void dispose() {}

  /// Returns a very short pretty description of the gesture that the
  /// recognizer looks for, like 'tap' or 'horizontal drag'.
  String get debugDescription;

  /// Invoke a callback provided by the application, catching and logging any
  /// exceptions.
  ///
  /// The `name` argument is ignored except when reporting exceptions.
  ///
  /// The `debugReport` argument is optional and is used when
  /// [debugPrintRecognizerCallbacksTrace] is true. If specified, it must be a
  /// callback that returns a string describing useful debugging information,
  /// e.g. the arguments passed to the callback.
  @protected
  T invokeCallback<T>(String name, RecognizerCallback<T> callback,
      {String debugReport()}) {
    assert(callback != null);
    T result;
    try {
      assert(() {
        if (debugPrintRecognizerCallbacksTrace) {
          final String report = debugReport != null ? debugReport() : null;
          // The 19 in the line below is the width of the prefix used by
          // _debugLogDiagnostic in arena.dart.
          final String prefix =
          debugPrintGestureArenaDiagnostics ? ' ' * 19 + '❙ ' : '';
          debugPrint(
              '$prefix$this calling $name callback.${ report?.isNotEmpty == true
                  ? " $report"
                  : "" }');
        }
        return true;
      });
      result = callback();
    } catch (exception, stack) {
      FlutterError.reportError(new FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'gesture',
          context: 'while handling a gesture',
          informationCollector: (StringBuffer information) {
            information.writeln('Handler: $name');
            information.writeln('Recognizer:');
            information.writeln('  $this');
          }));
    }
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new DiagnosticsProperty<Object>('debugOwner', debugOwner,
        defaultValue: null));
  }
}
