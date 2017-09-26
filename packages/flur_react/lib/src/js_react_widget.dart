import 'package:flur/flur.dart';
import 'package:flur/js.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import 'internal/react.dart' as reactApi;

/// An abstract widget that provides raw Javascript React element.
///
/// Such widget can avoid the cost of converting Dart values to Javascript.
///
/// See also:
///   * [JsReactWidget]
///   * [JsReactElementWidget]
abstract class JsReactElementBuildingWidget extends StatelessWidget {
  /// Throws [UnimplementedError].
  ///
  /// Invocation of this method means that the invoker (subclass of
  /// [RenderTreePlugin]) does not understand that this is a React widget.
  @override
  Widget build(BuildContext context) {
    return throw new UnimplementedError();
  }

  dynamic buildReactElement(BuildContext context);
}

/// A widget that builds React element out of Javascript arguments.
class JsReactWidget extends JsReactElementBuildingWidget {
  final dynamic type;
  final dynamic props;
  final dynamic children;

  JsReactWidget(this.type, [this.props, this.children]);

  @override
  dynamic buildReactElement(BuildContext context) {
    return reactApi.createElement(type, props, children);
  }
}

/// A widget that contains an already-created React element.
class JsReactElementWidget extends JsReactElementBuildingWidget {
  final reactApi.Element element;

  JsReactElementWidget(this.element);

  @override
  dynamic buildReactElement(BuildContext context) => element;
}

abstract class StatelessReactWidget extends StatelessWidget implements ReactProps {
  JsValue get type;
  final ReactProps style;
  const StatelessReactWidget({Key key, this.style}) : super(key: key);

  List buildReactChildren(BuildContext context) => const [];

  @protected
  @mustCallSuper
  void buildReactProps(BuildContext context, JsValue props) {
    if (style != null) {
      props.put("style", style);
    }
  }
}

abstract class StatefulReactWidget extends StatefulWidget {
  final ReactProps style;
  const StatefulReactWidget({Key key, this.style}) : super(key: key);
  @override
  RnState createState();
}

abstract class RnState<T extends StatefulReactWidget> extends State<T> {
  JsValue get type;

  @protected
  @mustCallSuper
  void buildReactProps(BuildContext context, JsValue props) {
    final style = widget.style;
    if (style != null) {
      props.put("style", style);
    }
  }

  List buildReactChildren(BuildContext context) => const [];
}

abstract class MultiChildStatelessReactWidget extends StatelessWidget {
  JsValue get type;

  final ReactProps style;
  final List<Widget> children;
  const MultiChildStatelessReactWidget({Key key, this.style, List<Widget> this.children}) : super(key: key);

  @protected
  @mustCallSuper
  void buildReactProps(BuildContext context, JsValue props) {
    if (style != null) {
      props.put("style", style);
    }
  }

  List buildReactChildren(BuildContext context) => const [];

  @override
  Widget build(BuildContext context) {
    final props = JsValue.newObject();
    buildReactProps(context, props);
    return new JsReactWidget(type.unsafeValue, props, JsValue.fromDart(buildReactChildren(context)).unsafeValue);
  }
}