import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'html_element_widget.dart';
import 'react_widget.dart';
import 'ui_plugin.dart';

/// Renders the underlying primitives, such HTML elements or React components.
///
/// Examples: React, Vue.
abstract class RenderTreePlugin {
  static RenderTreePlugin current;

  void runApp(Widget widget);

  Widget buildHtmlElementWidget(
      BuildContext context, HtmlElementWidget widget) {
    throw new UnimplementedError(
        "'${this.runtimeType}' is missing support for HtmlElementWidget.");
  }

  Widget buildReactWidget(BuildContext context, ReactWidget widget) {
    throw new UnimplementedError(
        "'${this.runtimeType}' is missing support for ReactWidget.");
  }

  // A special case because otherwise we risk infinite recursion.
  Widget buildErrorWidget(BuildContext context, ErrorWidget widget) {
    try {
      return UIPlugin.current.buildErrorWidget(context, widget);
    } catch (e) {
      return new Text(widget.message);
    }
  }
}

void runAppInFlur(Widget widget) {
  WidgetsFlutterBinding.ensureInitialized();
  RenderTreePlugin.current.runApp(widget);
}
