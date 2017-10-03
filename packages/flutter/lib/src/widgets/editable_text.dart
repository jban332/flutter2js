// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'basic.dart';
import 'focus_manager.dart';
import 'framework.dart';
import 'media_query.dart';
import 'text_selection.dart';

export 'package:flutter/services.dart'
    show TextEditingValue, TextSelection, TextInputType;

/// Signature for the callback that reports when the user changes the selection
/// (including the cursor location).
typedef void SelectionChangedCallback(TextSelection selection, bool longPress);

const Duration _kCursorBlinkHalfPeriod = const Duration(milliseconds: 500);

// Number of cursor ticks during which the most recently entered character
// is shown in an obscured text field.
const int _kObscureShowLatestCharCursorTicks = 3;

/// A controller for an editable text field.
///
/// Whenever the user modifies a text field with an associated
/// [TextEditingController], the text field updates [value] and the controller
/// notifies its listeners. Listeners can then read the [text] and [selection]
/// properties to learn what the user has typed or how the selection has been
/// updated.
///
/// Similarly, if you modify the [text] or [selection] properties, the text
/// field will be notified and will update itself appropriately.
///
/// A [TextEditingController] can also be used to provide an initial value for a
/// text field. If you build a text field with a controller that already has
/// [text], the text field will use that text as its initial value.
///
/// See also:
///
///  * [TextField], which is a Material Design text field that can be controlled
///    with a [TextEditingController].
///  * [EditableText], which is a raw region of editable text that can be
///    controlled with a [TextEditingController].
class TextEditingController extends ValueNotifier<TextEditingValue> {
  /// Creates a controller for an editable text field.
  ///
  /// This constructor treats a null [text] argument as if it were the empty
  /// string.
  TextEditingController({String text})
      : super(text == null
            ? TextEditingValue.empty
            : new TextEditingValue(text: text));

  /// Creates a controller for an editiable text field from an initial [TextEditingValue].
  ///
  /// This constructor treats a null [value] argument as if it were
  /// [TextEditingValue.empty].
  TextEditingController.fromValue(TextEditingValue value)
      : super(value ?? TextEditingValue.empty);

  /// The current string the user is editing.
  String get text => value.text;

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set text(String newText) {
    value = value.copyWith(
        text: newText,
        selection: const TextSelection.collapsed(offset: -1),
        composing: TextRange.empty);
  }

  /// The currently selected [text].
  ///
  /// If the selection is collapsed, then this property gives the offset of the
  /// cursor within the text.
  TextSelection get selection => value.selection;

  /// Setting this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set selection(TextSelection newSelection) {
    if (newSelection.start > text.length || newSelection.end > text.length)
      throw new FlutterError('invalid text selection: $newSelection');
    value = value.copyWith(selection: newSelection, composing: TextRange.empty);
  }

  /// Set the [value] to empty.
  ///
  /// After calling this function, [text] will be the empty string and the
  /// selection will be invalid.
  ///
  /// Calling this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clear() {
    value = TextEditingValue.empty;
  }

  /// Set the composing region to an empty range.
  ///
  /// The composing region is the range of text that is still being composed.
  /// Calling this function indicates that the user is done composing that
  /// region.
  ///
  /// Calling this will notify all the listeners of this [TextEditingController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this method should only be called between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  void clearComposing() {
    value = value.copyWith(composing: TextRange.empty);
  }
}

/// A basic text input field.
///
/// This widget interacts with the [TextInput] service to let the user edit the
/// text it contains. It also provides scrolling, selection, and cursor
/// movement. This widget does not provide any focus management (e.g.,
/// tap-to-focus).
///
/// Rather than using this widget directly, consider using [TextField], which
/// is a full-featured, material-design text input field with placeholder text,
/// labels, and [Form] integration.
///
/// See also:
///
///  * [TextField], which is a full-featured, material-design text input field
///    with placeholder text, labels, and [Form] integration.
class EditableText extends flur.StatelessUIPluginWidget {
  /// Creates a basic text input control.
  ///
  /// The [maxLines] property can be set to null to remove the restriction on
  /// the number of lines. By default, it is 1, meaning this is a single-line
  /// text field. If it is not null, it must be greater than zero.
  ///
  /// The [controller], [focusNode], [style], [cursorColor], and [textAlign]
  /// arguments must not be null.
  EditableText({
    Key key,
    @required this.controller,
    @required this.focusNode,
    this.obscureText: false,
    this.autocorrect: true,
    @required this.style,
    @required this.cursorColor,
    this.textAlign: TextAlign.start,
    this.textDirection,
    this.textScaleFactor,
    this.maxLines: 1,
    this.autofocus: false,
    this.selectionColor,
    this.selectionControls,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.onSelectionChanged,
    List<TextInputFormatter> inputFormatters,
  })
      : inputFormatters = maxLines == 1
            ? (<TextInputFormatter>[
                BlacklistingTextInputFormatter.singleLineFormatter
              ]..addAll(
                inputFormatters ?? const Iterable<TextInputFormatter>.empty()))
            : inputFormatters,
        super(key: key);

  /// Controls the text being edited.
  final TextEditingController controller;

  /// Controls whether this widget has keyboard focus.
  final FocusNode focusNode;

  /// Whether to hide the text being edited (e.g., for passwords).
  ///
  /// Defaults to false.
  final bool obscureText;

  /// Whether to enable autocorrection.
  ///
  /// Defaults to true.
  final bool autocorrect;

  /// The text style to use for the editable text.
  final TextStyle style;

  /// How the text should be aligned horizontally.
  ///
  /// Defaults to [TextAlign.start].
  final TextAlign textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the text is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrow phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection textDirection;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  ///
  /// Defaults to the [MediaQueryData.textScaleFactor] obtained from the ambient
  /// [MediaQuery], or 1.0 if there is no [MediaQuery] in scope.
  final double textScaleFactor;

  /// The color to use when painting the cursor.
  final Color cursorColor;

  /// The maximum number of lines for the text to span, wrapping if necessary.
  ///
  /// If this is 1 (the default), the text will not wrap, but will scroll
  /// horizontally instead.
  ///
  /// If this is null, there is no limit to the number of lines. If it is not
  /// null, the value must be greater than zero.
  final int maxLines;

  /// Whether this input field should focus itself if nothing else is already focused.
  /// If true, the keyboard will open as soon as this input obtains focus. Otherwise,
  /// the keyboard is only shown after the user taps the text field.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// The color to use when painting the selection.
  final Color selectionColor;

  /// Optional delegate for building the text selection handles and toolbar.
  final TextSelectionControls selectionControls;

  /// The type of keyboard to use for editing the text.
  final TextInputType keyboardType;

  /// Called when the text being edited changes.
  final ValueChanged<String> onChanged;

  /// Called when the user indicates that they are done editing the text in the field.
  final ValueChanged<String> onSubmitted;

  /// Called when the user changes the selection of text (including the cursor
  /// location).
  final SelectionChangedCallback onSelectionChanged;

  /// Optional input validation and formatting overrides. Formatters are run
  /// in the provided order when the text input changes.
  final List<TextInputFormatter> inputFormatters;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new DiagnosticsProperty<TextEditingController>(
        'controller', controller));
    description.add(new DiagnosticsProperty<FocusNode>('focusNode', focusNode));
    description.add(new DiagnosticsProperty<bool>('obscureText', obscureText,
        defaultValue: false));
    description.add(new DiagnosticsProperty<bool>('autocorrect', autocorrect,
        defaultValue: true));
    style?.debugFillProperties(description);
    description.add(new EnumProperty<TextAlign>('textAlign', textAlign,
        defaultValue: null));
    description.add(new EnumProperty<TextDirection>(
        'textDirection', textDirection,
        defaultValue: null));
    description.add(new DoubleProperty('textScaleFactor', textScaleFactor,
        defaultValue: null));
    description.add(new IntProperty('maxLines', maxLines, defaultValue: 1));
    description.add(new DiagnosticsProperty<bool>('autofocus', autofocus,
        defaultValue: false));
    description.add(new EnumProperty<TextInputType>(
        'keyboardType', keyboardType,
        defaultValue: null));
  }

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildEditableText(context, this);
  }
}
