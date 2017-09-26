// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'constants.dart';

/// Signature for the callback used by ink effects to obtain the rectangle for the effect.
///
/// Used by [InkHighlight] and [InkSplash], for example.
typedef Rect RectCallback();

/// The various kinds of material in material design. Used to
/// configure the default behavior of [Material] widgets.
///
/// See also:
///
///  * [Material], in particular [Material.type]
///  * [kMaterialEdges]
enum MaterialType {
  /// Infinite extent using default theme canvas color.
  canvas,

  /// Rounded edges, card theme color.
  card,

  /// A circle, no color by default (used for floating action buttons).
  circle,

  /// Rounded edges, no color by default (used for [MaterialButton] buttons).
  button,

  /// A transparent piece of material that draws ink splashes and highlights.
  transparency
}

/// The border radii used by the various kinds of material in material design.
///
/// See also:
///
///  * [MaterialType]
///  * [Material]
final Map<MaterialType, BorderRadius> kMaterialEdges =
<MaterialType, BorderRadius>{
  MaterialType.canvas: null,
  MaterialType.card: new BorderRadius.circular(2.0),
  MaterialType.circle: null,
  MaterialType.button: new BorderRadius.circular(2.0),
  MaterialType.transparency: null,
};

/// An interface for creating [InkSplash]s and [InkHighlight]s on a material.
///
/// Typically obtained via [Material.of].
abstract class MaterialInkController {
  /// The color of the material.
  Color get color;
}

/// A piece of material.
///
/// Material is the central metaphor in material design. Each piece of material
/// exists at a given elevation, which influences how that piece of material
/// visually relates to other pieces of material and how that material casts
/// shadows.
///
/// Most user interface elements are either conceptually printed on a piece of
/// material or themselves made of material. Material reacts to user input using
/// [InkSplash] and [InkHighlight] effects. To trigger a reaction on the
/// material, use a [MaterialInkController] obtained via [Material.of].
///
/// If a material has a non-zero [elevation], then the material will clip its
/// contents because content that is conceptually printing on a separate piece
/// of material cannot be printed beyond the bounds of the material.
///
/// If the layout changes (e.g. because there's a list on the paper, and it's
/// been scrolled), a LayoutChangedNotification must be dispatched at the
/// relevant subtree. (This in particular means that Transitions should not be
/// placed inside Material.) Otherwise, in-progress ink features (e.g., ink
/// splashes and ink highlights) won't move to account for the new layout.
///
/// In general, the features of a [Material] should not change over time (e.g. a
/// [Material] should not change its [color] or [type]). The one exception is
/// the [elevation], changes to which will be animated.
///
/// See also:
///
/// * [MergeableMaterial], a piece of material that can split and remerge.
/// * [Card], a wrapper for a [Material] of [type] [MaterialType.card].
/// * <https://material.google.com/>
class Material extends StatelessWidget {
  /// Creates a piece of material.
  ///
  /// The [type] and the [elevation] arguments must not be null.
  const Material({
    Key key,
    this.type: MaterialType.canvas,
    this.elevation: 0.0,
    this.color,
    this.textStyle,
    this.borderRadius,
    this.child,
  })
      : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// The kind of material to show (e.g., card or canvas). This
  /// affects the shape of the widget, the roundness of its corners if
  /// the shape is rectangular, and the default color.
  final MaterialType type;

  /// The z-coordinate at which to place this material. This controls the size
  /// of the shadow below the material.
  ///
  /// If this is non-zero, the contents of the card are clipped, because the
  /// widget conceptually defines an independent printed piece of material.
  ///
  /// Defaults to 0. Changing this value will cause the shadow to animate over
  /// [kThemeChangeDuration].
  final double elevation;

  /// The color to paint the material.
  ///
  /// Must be opaque. To create a transparent piece of material, use
  /// [MaterialType.transparency].
  ///
  /// By default, the color is derived from the [type] of material.
  final Color color;

  /// The typographical style to use for text within this material.
  final TextStyle textStyle;

  /// If non-null, the corners of this box are rounded by this [BorderRadius].
  /// Otherwise, the corners specified for the current [type] of material are
  /// used.
  ///
  /// Must be null if [type] is [MaterialType.circle].
  final BorderRadius borderRadius;

  /// The ink controller from the closest instance of this class that
  /// encloses the given context.
  ///
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// MaterialInkController inkController = Material.of(context);
  /// ```
  static MaterialInkController of(BuildContext context) {
    return null;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new EnumProperty<MaterialType>('type', type));
    description.add(new DoubleProperty('elevation', elevation));
    description.add(
        new DiagnosticsProperty<Color>('color', color, defaultValue: null));
    textStyle?.debugFillProperties(description, prefix: 'textStyle.');
    description.add(new EnumProperty<BorderRadius>('borderRadius', borderRadius,
        defaultValue: null));
  }

  /// The default radius of an ink splash in logical pixels.
  static const double defaultSplashRadius = 35.0;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}

/// A visual reaction on a piece of [Material].
///
/// To add an ink feature to a piece of [Material], obtain the
/// [MaterialInkController] via [Material.of] and call
/// [MaterialInkController.addInkFeature].
abstract class InkFeature {
  /// Initializes fields for subclasses.
  InkFeature({
    @required this.controller,
    @required this.referenceBox,
    this.onRemoved,
  });

  /// The [MaterialInkController] associated with this [InkFeature].
  ///
  /// Typically used by subclasses to call
  /// [MaterialInkController.markNeedsPaint] when they need to repaint.
  final MaterialInkController controller;

  /// The render box whose visual position defines the frame of reference for this ink feature.
  final RenderBox referenceBox;

  /// Called when the ink feature is no longer visible on the material.
  final VoidCallback onRemoved;

  @override
  String toString() => describeIdentity(this);
}
