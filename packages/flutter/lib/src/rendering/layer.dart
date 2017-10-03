// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';

import 'node.dart';

/// A composited layer.
///
/// During painting, the render tree generates a tree of composited layers that
/// are uploaded into the engine and displayed by the compositor. This class is
/// the base class for all composited layers.
///
/// Most layers can have their properties mutated, and layers can be moved to
/// different parents. The scene must be explicitly recomposited after such
/// changes are made; the layer tree does not maintain its own dirty state.
///
/// To composite the tree, create a [SceneBuilder] object, pass it to the
/// root [Layer] object's [addToScene] method, and then call
/// [SceneBuilder.build] to obtain a [Scene]. A [Scene] can then be painted
/// using [Window.render].
///
/// See also:
///
///  * [RenderView.compositeFrame], which implements this recomposition protocol
///    for painting [RenderObject] trees on the the display.
abstract class Layer extends AbstractNode with DiagnosticableTreeMixin {}
