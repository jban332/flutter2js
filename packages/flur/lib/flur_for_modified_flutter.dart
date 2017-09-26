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
