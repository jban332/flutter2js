/// @nodoc
///
/// Helpers for modified 'package:flutter' classes.
/// DO NOT USE YOURSELF.
library flur.for_modified_flutter;

import 'package:flutter/widgets.dart';

import 'flur.dart';

export 'flur.dart';

abstract class StatefulUIPluginWidget extends StatefulWidget {
  const StatefulUIPluginWidget({Key key}) : super(key: key);

  @override
  State createState() {
    return createStateWithUIPlugin(UIPlugin.current);
  }

  State createStateWithUIPlugin(UIPlugin engine);
}

abstract class StatelessUIPluginWidget extends StatelessWidget
    implements UIPluginWidget {
  const StatelessUIPluginWidget({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildWithUIPlugin(context, UIPlugin.current);
  }
}

abstract class UIPluginState<T extends StatefulWidget> extends State<T> {
  @override
  Widget build(BuildContext context) {
    return buildWithUIPlugin(context, UIPlugin.current);
  }

  Widget buildWithUIPlugin(BuildContext context, UIPlugin engine);
}

abstract class UIPluginWidget extends Widget {
  Widget buildWithUIPlugin(BuildContext context, UIPlugin engine);
}

abstract class SingleChildUIPluginWidget extends StatelessUIPluginWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SingleChildUIPluginWidget({Key key, this.child}) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget buildWithUIPlugin(BuildContext context, UIPlugin plugin);
}

abstract class MultiChildUIPluginWidget extends StatelessUIPluginWidget {
  /// Initializes fields for subclasses.
  ///
  /// The [children] argument must not be null and must not contain any null
  /// objects.
  MultiChildUIPluginWidget({Key key, this.children: const <Widget>[]})
      : super(key: key) {
    assert(children != null);
    assert(children.every((w) => w != null));
  }

  /// The widgets below this widget in the tree.
  ///
  /// If this list is going to be mutated, it is usually wise to put [Key]s on
  /// the widgets, so that the framework can match old configurations to new
  /// configurations and maintain the underlying render objects.
  final List<Widget> children;
}
