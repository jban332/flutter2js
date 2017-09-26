// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'debug.dart';

export 'package:flutter/gestures.dart' show HitTestResult;

/// The glue between the render tree and the Flutter engine.
abstract class RendererBinding implements BindingBase {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The current [RendererBinding], if one has been created.
  static RendererBinding get instance => _instance;
  static RendererBinding _instance;

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    assert(() {
      // these service extensions only work in checked mode
      registerBoolServiceExtension(
          name: 'debugPaint',
          getter: () async => debugPaintSizeEnabled,
          setter: (bool value) {});
      registerBoolServiceExtension(
          name: 'debugPaintBaselinesEnabled',
          getter: () async => debugPaintBaselinesEnabled,
          setter: (bool value) {});
      registerBoolServiceExtension(
          name: 'repaintRainbow',
          getter: () async => debugRepaintRainbowEnabled,
          setter: (bool value) {});
      return true;
    });

    registerSignalServiceExtension(
        name: 'debugDumpRenderTree',
        callback: () {
          debugDumpRenderTree();
          return debugPrintDone;
        });

    registerSignalServiceExtension(
        name: 'debugDumpLayerTree',
        callback: () {
          debugDumpLayerTree();
          return debugPrintDone;
        });

    registerSignalServiceExtension(
        name: 'debugDumpSemanticsTreeInTraversalOrder',
        callback: () {
          debugDumpSemanticsTree(DebugSemanticsDumpOrder.traversal);
          return debugPrintDone;
        });

    registerSignalServiceExtension(
        name: 'debugDumpSemanticsTreeInInverseHitTestOrder',
        callback: () {
          debugDumpSemanticsTree(DebugSemanticsDumpOrder.inverseHitTest);
          return debugPrintDone;
        });
  }
}

/// Prints a textual representation of the entire render tree.
void debugDumpRenderTree() {}

/// Prints a textual representation of the entire layer tree.
void debugDumpLayerTree() {}

/// Prints a textual representation of the entire semantics tree.
/// This will only work if there is a semantics client attached.
/// Otherwise, a notice that no semantics are available will be printed.
///
/// The order in which the children of a [SemanticsNode] will be printed is
/// controlled by the [childOrder] parameter.
void debugDumpSemanticsTree(DebugSemanticsDumpOrder childOrder) {}
