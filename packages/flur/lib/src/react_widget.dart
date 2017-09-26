import 'package:flur/js.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'react_props.dart';

/// Renders HTML element.
///
/// In non-browser platforms, renders [ErrorWidget].
@immutable
class HtmlReactWidget extends StatelessWidget {
  final String type;
  final String className;

  /// HTML attributes.
  final ReactProps props;

  /// CSS style.
  final ReactProps style;

  /// Children. They can be anything.
  /// If an item is not [Widget], it's rendered as text.
  final List children;

  /// If set, the callback will receive the underlying DOM element.
  final ValueChanged<JsValue> onJsValue;

  const HtmlReactWidget(this.type,
      {Key key,
      this.className,
      this.props,
      this.style,
      this.children,
      this.onJsValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ErrorWidget(
        "Renderer is missing support for HtmlWidget. Can't render HTML element '${type}'");
  }
}

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
  final ValueChanged<JsValue> onJsValue;

  /// Type must be string or JsValue.
  const ReactWidget(this.type,
      {Key key, this.props, this.style, this.children, this.onJsValue})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return new ErrorWidget(
        "Renderer is missing support for ReactWidget. Can't render React component '${type}'");
  }
}
