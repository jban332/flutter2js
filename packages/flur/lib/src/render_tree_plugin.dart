import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Renders the underlying primitives, such HTML elements or React components.
///
/// Examples: React, Vue.
abstract class RenderTreePlugin {
  static RenderTreePlugin current;

  void runApp(Widget widget);
}
