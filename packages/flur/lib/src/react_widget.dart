import 'package:flur/js.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'render_tree_plugin.dart';
import 'react_props.dart';

/// Renders React component.
///
/// In non-React platforms, renders [ErrorWidget].
@immutable
class ReactWidget extends StatelessWidget {
  /// React component class.
  final JsValue type;

  /// Must be valid props in React.
  final ReactProps props;

  /// Must be valid props in React.
  final ReactProps style;

  /// Children. They can be anything.
  /// If an item is not [Widget], it's rendered as text.
  final List children;

  /// If set, the callback will receive the underlying React component.
  ///
  /// This is useful for stateful React components when you want to observe or
  /// mutate the state.
  final ValueChanged<JsValue> onRef;

  /// Type must be string or JsValue.
  const ReactWidget(this.type,
      {Key key, this.props, this.style, this.children, this.onRef})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RenderTreePlugin.current.buildReactWidget(context, this);
  }
}
