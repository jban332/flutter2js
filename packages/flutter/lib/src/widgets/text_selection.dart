// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'basic.dart';
import 'editable_text.dart';
import 'framework.dart';

/// Which type of selection handle to be displayed.
///
/// With mixed-direction text, both handles may be the same type. Examples:
///
/// * LTR text: 'the <quick brown> fox':
///   The '<' is drawn with the [left] type, the '>' with the [right]
///
/// * RTL text: 'xof <nworb kciuq> eht':
///   Same as above.
///
/// * mixed text: '<the nwor<b quick fox'
///   Here 'the b' is selected, but 'brown' is RTL. Both are drawn with the
///   [left] type.
enum TextSelectionHandleType {
  /// The selection handle is to the left of the selection end point.
  left,

  /// The selection handle is to the right of the selection end point.
  right,

  /// The start and end of the selection are co-incident at this point.
  collapsed,
}

/// Signature for reporting changes to the selection component of a
/// [TextEditingValue] for the purposes of a [TextSelectionOverlay]. The
/// [caretRect] argument gives the location of the caret in the coordinate space
/// of the [RenderBox] given by the [TextSelectionOverlay.renderObject].
///
/// Used by [TextSelectionOverlay.onSelectionOverlayChanged].
typedef void TextSelectionOverlayChanged(
    TextEditingValue value, Rect caretRect);

/// An interface for manipulating the selection, to be used by the implementor
/// of the toolbar widget.
abstract class TextSelectionDelegate {
  /// Gets the current text input.
  TextEditingValue get textEditingValue;

  /// Sets the current text input (replaces the whole line).
  set textEditingValue(TextEditingValue value);

  /// Hides the text selection toolbar.
  void hideToolbar();
}

/// An interface for building the selection UI, to be provided by the
/// implementor of the toolbar widget.
///
/// Override text operations such as [handleCut] if needed.
abstract class TextSelectionControls {
  /// Builds a selection handle of the given type.
  ///
  /// The top left corner of this widget is positioned at the bottom of the
  /// selection position.
  Widget buildHandle(BuildContext context, TextSelectionHandleType type,
      double textLineHeight);

  /// Builds a toolbar near a text selection.
  ///
  /// Typically displays buttons for copying and pasting text.
  Widget buildToolbar(BuildContext context, Rect globalEditableRegion,
      Offset position, TextSelectionDelegate delegate);

  /// Returns the size of the selection handle.
  Size get handleSize;

  /// Copy the current selection of the text field managed by the given
  /// `delegate` to the [Clipboard]. Then, remove the selected text from the
  /// text field and hide the toolbar.
  ///
  /// This is called by subclasses when their cut affordance is activated by
  /// the user.
  void handleCut(TextSelectionDelegate delegate) {}

  /// Copy the current selection of the text field managed by the given
  /// `delegate` to the [Clipboard]. Then, move the cursor to the end of the
  /// text (collapsing the selection in the process), and hide the toolbar.
  ///
  /// This is called by subclasses when their copy affordance is activated by
  /// the user.
  void handleCopy(TextSelectionDelegate delegate) {}

  /// Paste the current clipboard selection (obtained from [Clipboard]) into
  /// the text field managed by the given `delegate`, replacing its current
  /// selection, if any. Then, hide the toolbar.
  ///
  /// This is called by subclasses when their paste affordance is activated by
  /// the user.
  ///
  /// This function is asynchronous since interacting with the clipboard is
  /// asynchronous. Race conditions may exist with this API as currently
  /// implemented.
  // TODO(ianh): https://github.com/flutter/flutter/issues/11427
  Future<Null> handlePaste(TextSelectionDelegate delegate) async {}

  /// Adjust the selection of the text field managed by the given `delegate` so
  /// that everything is selected.
  ///
  /// Does not hide the toolbar.
  ///
  /// This is called by subclasses when their select-all affordance is activated
  /// by the user.
  void handleSelectAll(TextSelectionDelegate delegate) {
    delegate.textEditingValue = new TextEditingValue(
      text: delegate.textEditingValue.text,
      selection: new TextSelection(
          baseOffset: 0, extentOffset: delegate.textEditingValue.text.length),
    );
  }
}
