// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'theme.dart';

const Duration _kTransitionDuration = const Duration(milliseconds: 200);

/// Text and styles used to label an input field.
///
/// The [TextField] and [InputDecorator] classes use [InputDecoration] objects
/// to describe their decoration. (In fact, this class is merely the
/// configuration of an [InputDecorator], which does all the heavy lifting.)
///
/// See also:
///
///  * [TextField], which is a text input widget that uses an
///    [InputDecoration].
///  * [InputDecorator], which is a widget that draws an [InputDecoration]
///    around an arbitrary child widget.
///  * [Decoration] and [DecoratedBox], for drawing arbitrary decorations
///    around other widgets.
@immutable
class InputDecoration {
  /// Creates a bundle of text and styles used to label an input field.
  ///
  /// Sets the [isCollapsed] property to false. To create a decoration that does
  /// not reserve space for [labelText] or [errorText], use
  /// [InputDecoration.collapsed].
  const InputDecoration({
    this.icon,
    this.labelText,
    this.labelStyle,
    this.helperText,
    this.helperStyle,
    this.hintText,
    this.hintStyle,
    this.errorText,
    this.errorStyle,
    this.isDense: false,
    this.hideDivider: false,
    this.prefixText,
    this.prefixStyle,
    this.suffixText,
    this.suffixStyle,
  })
      : isCollapsed = false;

  /// Creates a decoration that is the same size as the input field.
  ///
  /// This type of input decoration does not include a divider or an icon and
  /// does not reserve space for [labelText] or [errorText].
  ///
  /// Sets the [isCollapsed] property to true.
  const InputDecoration.collapsed({
    @required this.hintText,
    this.hintStyle,
  })
      : icon = null,
        labelText = null,
        labelStyle = null,
        helperText = null,
        helperStyle = null,
        errorText = null,
        errorStyle = null,
        isDense = false,
        isCollapsed = true,
        hideDivider = true,
        prefixText = null,
        prefixStyle = null,
        suffixText = null,
        suffixStyle = null;

  /// An icon to show before the input field.
  ///
  /// The size and color of the icon is configured automatically using an
  /// [IconTheme] and therefore does not need to be explicitly given in the
  /// icon widget.
  ///
  /// See [Icon], [ImageIcon].
  final Widget icon;

  /// Text that describes the input field.
  ///
  /// When the input field is empty and unfocused, the label is displayed on
  /// top of the input field (i.e., at the same location on the screen where
  /// text my be entered in the input field). When the input field receives
  /// focus (or if the field is non-empty), the label moves above (i.e.,
  /// vertically adjacent to) the input field.
  final String labelText;

  /// The style to use for the [labelText] when the label is above (i.e.,
  /// vertically adjacent to) the input field.
  ///
  /// When the [labelText] is on top of the input field, the text uses the
  /// [hintStyle] instead.
  ///
  /// If null, defaults of a value derived from the base [TextStyle] for the
  /// input field and the current [Theme].
  final TextStyle labelStyle;

  /// Text that provides context about the field’s value, such as how the value
  /// will be used.
  ///
  /// If non-null, the text is displayed below the input field, in the same
  /// location as [errorText]. If a non-null [errorText] value is specified then
  /// the helper text is not shown.
  final String helperText;

  /// The style to use for the [helperText].
  final TextStyle helperStyle;

  /// Text that suggests what sort of input the field accepts.
  ///
  /// Displayed on top of the input field (i.e., at the same location on the
  /// screen where text my be entered in the input field) when the input field
  /// is empty and either (a) [labelText] is null or (b) the input field has
  /// focus.
  final String hintText;

  /// The style to use for the [hintText].
  ///
  /// Also used for the [labelText] when the [labelText] is displayed on
  /// top of the input field (i.e., at the same location on the screen where
  /// text my be entered in the input field).
  ///
  /// If null, defaults of a value derived from the base [TextStyle] for the
  /// input field and the current [Theme].
  final TextStyle hintStyle;

  /// Text that appears below the input field.
  ///
  /// If non-null, the divider that appears below the input field is red.
  final String errorText;

  /// The style to use for the [errorText].
  ///
  /// If null, defaults of a value derived from the base [TextStyle] for the
  /// input field and the current [Theme].
  final TextStyle errorStyle;

  /// Whether the input field is part of a dense form (i.e., uses less vertical
  /// space).
  ///
  /// Defaults to false.
  final bool isDense;

  /// Whether the decoration is the same size as the input field.
  ///
  /// A collapsed decoration cannot have [labelText], [errorText], an [icon], or
  /// a divider because those elements require extra space.
  ///
  /// To create a collapsed input decoration, use [InputDecoration..collapsed].
  final bool isCollapsed;

  /// Whether to hide the divider below the input field and above the error text.
  ///
  /// Defaults to false.
  final bool hideDivider;

  /// Optional text prefix to place on the line before the input.
  ///
  /// Uses the [prefixStyle]. Uses [hintStyle] if [prefixStyle] isn't
  /// specified. Prefix is not returned as part of the input.
  final String prefixText;

  /// The style to use for the [prefixText].
  ///
  /// If null, defaults to the [hintStyle].
  final TextStyle prefixStyle;

  /// Optional text suffix to place on the line after the input.
  ///
  /// Uses the [suffixStyle]. Uses [hintStyle] if [suffixStyle] isn't
  /// specified. Suffix is not returned as part of the input.
  final String suffixText;

  /// The style to use for the [suffixText].
  ///
  /// If null, defaults to the [hintStyle].
  final TextStyle suffixStyle;

  /// Creates a copy of this input decoration but with the given fields replaced
  /// with the new values.
  ///
  /// Always sets [isCollapsed] to false.
  InputDecoration copyWith({
    Widget icon,
    String labelText,
    TextStyle labelStyle,
    String helperText,
    TextStyle helperStyle,
    String hintText,
    TextStyle hintStyle,
    String errorText,
    TextStyle errorStyle,
    bool isDense,
    bool hideDivider,
    String prefixText,
    TextStyle prefixStyle,
    String suffixText,
    TextStyle suffixStyle,
  }) {
    return new InputDecoration(
      icon: icon ?? this.icon,
      labelText: labelText ?? this.labelText,
      labelStyle: labelStyle ?? this.labelStyle,
      helperText: helperText ?? this.helperText,
      helperStyle: helperStyle ?? this.helperStyle,
      hintText: hintText ?? this.hintText,
      hintStyle: hintStyle ?? this.hintStyle,
      errorText: errorText ?? this.errorText,
      errorStyle: errorStyle ?? this.errorStyle,
      isDense: isDense ?? this.isDense,
      hideDivider: hideDivider ?? this.hideDivider,
      prefixText: prefixText ?? this.prefixText,
      prefixStyle: prefixStyle ?? this.prefixStyle,
      suffixText: suffixText ?? this.suffixText,
      suffixStyle: suffixStyle ?? this.suffixStyle,
    );
  }

  @override
  bool operator ==(dynamic other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    final InputDecoration typedOther = other;
    return typedOther.icon == icon &&
        typedOther.labelText == labelText &&
        typedOther.labelStyle == labelStyle &&
        typedOther.helperText == helperText &&
        typedOther.helperStyle == helperStyle &&
        typedOther.hintText == hintText &&
        typedOther.hintStyle == hintStyle &&
        typedOther.errorText == errorText &&
        typedOther.errorStyle == errorStyle &&
        typedOther.isDense == isDense &&
        typedOther.isCollapsed == isCollapsed &&
        typedOther.hideDivider == hideDivider &&
        typedOther.prefixText == prefixText &&
        typedOther.prefixStyle == prefixStyle &&
        typedOther.suffixText == suffixText &&
        typedOther.suffixStyle == suffixStyle;
  }

  @override
  int get hashCode {
    return hashValues(
      icon,
      labelText,
      labelStyle,
      helperText,
      helperStyle,
      hintText,
      hintStyle,
      errorText,
      errorStyle,
      isDense,
      isCollapsed,
      hideDivider,
      prefixText,
      prefixStyle,
      suffixText,
      suffixStyle,
    );
  }

  @override
  String toString() {
    final List<String> description = <String>[];
    if (icon != null) description.add('icon: $icon');
    if (labelText != null) description.add('labelText: "$labelText"');
    if (helperText != null) description.add('helperText: "$helperText"');
    if (hintText != null) description.add('hintText: "$hintText"');
    if (errorText != null) description.add('errorText: "$errorText"');
    if (isDense) description.add('isDense: $isDense');
    if (isCollapsed) description.add('isCollapsed: $isCollapsed');
    if (hideDivider) description.add('hideDivider: $hideDivider');
    if (prefixText != null) description.add('prefixText: $prefixText');
    if (prefixStyle != null) description.add('prefixStyle: $prefixStyle');
    if (suffixText != null) description.add('suffixText: $suffixText');
    if (suffixStyle != null) description.add('suffixStyle: $suffixStyle');
    return 'InputDecoration(${description.join(', ')})';
  }
}

/// Displays the visual elements of a Material Design text field around an
/// arbitrary widget.
///
/// Use [InputDecorator] to create widgets that look and behave like a
/// [TextField] but can be used to input information other than text.
///
/// The configuration of this widget is primarily provided in the form of an
/// [InputDecoration] object.
///
/// Requires one of its ancestors to be a [Material] widget.
///
/// See also:
///
///  * [TextField], which uses an [InputDecorator] to draw labels and other
///    visual elements around a text entry widget.
///  * [Decoration] and [DecoratedBox], for drawing arbitrary decorations
///    around other widgets.
class InputDecorator extends flur.StatelessUIPluginWidget {
  /// Creates a widget that displayes labels and other visual elements similar
  /// to a [TextField].
  ///
  /// The [isFocused] and [isEmpty] arguments must not be null.
  const InputDecorator({
    Key key,
    @required this.decoration,
    this.baseStyle,
    this.textAlign,
    this.isFocused: false,
    this.isEmpty: false,
    this.child,
  })
      : super(key: key);

  /// The text and styles to use when decorating the child.
  final InputDecoration decoration;

  /// The style on which to base the label, hint, and error styles if the
  /// [decoration] does not provide explicit styles.
  ///
  /// If null, defaults to a text style from the current [Theme].
  final TextStyle baseStyle;

  /// How the text in the decoration should be aligned horizontally.
  final TextAlign textAlign;

  /// Whether the input field has focus.
  ///
  /// Determines the position of the label text and the color of the divider.
  ///
  /// Defaults to false.
  final bool isFocused;

  /// Whether the input field is empty.
  ///
  /// Determines the position of the label text and whether to display the hint
  /// text.
  ///
  /// Defaults to false.
  final bool isEmpty;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(
        new DiagnosticsProperty<InputDecoration>('decoration', decoration));
    description.add(new EnumProperty<TextStyle>('baseStyle', baseStyle));
    description.add(new DiagnosticsProperty<bool>('isFocused', isFocused));
    description.add(new DiagnosticsProperty<bool>('isEmpty', isEmpty));
  }

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildInputDecorator(context, this);
  }
}
