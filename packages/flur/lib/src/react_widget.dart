import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'render_tree_plugin.dart';

/// Renders React component.
///
/// In non-React platforms, renders [ErrorWidget].
@immutable
class ReactWidget extends StatelessWidget {
  final Object type;

  final ReactProps _props;

  final ReactProps _style;

  final ValueChanged<dynamic> _onRef;

  final List children;

  const ReactWidget(this.type,
      {Key key,
      ReactProps props,
      ReactProps style,
      this.children,
      ValueChanged<dynamic> onRef})
      : this._props = props,
        this._style = style,
        this._onRef = onRef,
        super(key: key);

  void forEachReactProp(void f(String name, Object value)) {
    _props?.forEachReactProp(f);
    if (_style != null) {
      f("style", _style);
    }
    if (_onRef != null) {
      f("ref", _onRef);
    }
  }

  @override
  Widget build(BuildContext context) {
    return RenderTreePlugin.current.buildReactWidget(context, this);
  }
}

@immutable
abstract class ReactProps {
  const factory ReactProps(Map<String, Object> props) = _ReactProps;

  /// Visits each prop.
  void forEachReactProp(void f(String name, Object value));
}

class _ReactProps implements ReactProps {
  final Map<String, Object> _map;

  const _ReactProps(this._map);

  @override
  void forEachReactProp(void f(String name, Object value)) {
    _map.forEach(f);
  }
}
