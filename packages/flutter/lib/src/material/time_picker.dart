// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flur/flur.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'time.dart';

/// Shows a dialog containing a material design time picker.
///
/// The returned Future resolves to the time selected by the user when the user
/// closes the dialog. If the user cancels the dialog, null is returned.
///
/// To show a dialog with [initialTime] equal to the current time:
/// ```dart
/// showTimePicker(
///   initialTime: new TimeOfDay.now(),
///   context: context
/// );
/// ```
///
/// See also:
///
///  * [showDatePicker]
///  * <https://material.google.com/components/pickers.html#pickers-time-pickers>
Future<TimeOfDay> showTimePicker(
    {@required BuildContext context, @required TimeOfDay initialTime}) async {
  assert(context != null);
  assert(initialTime != null);
  return flur.UIPlugin.current
      .showTimePicker(context: context, initialTime: initialTime);
}
