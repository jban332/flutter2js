// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';

import 'basic.dart';
import 'framework.dart';

/// A widget that describes this app in the operating system.
class Title extends flur.SingleChildUIPluginWidget {
  /// Creates a widget that describes this app to the operating system.
  Title({
    Key key,
    this.title,
    this.color,
    @required this.child,
  })
      : super(key: key);

  /// A one-line description of this app for use in the window manager.
  final String title;

  /// A color that the window manager should use to identify this app.
  final Color color;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    description.add(new StringProperty('title', title, defaultValue: null));
    description.add(
        new DiagnosticsProperty<Color>('color', color, defaultValue: null));
  }

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildTitle(context, this);
  }
}
