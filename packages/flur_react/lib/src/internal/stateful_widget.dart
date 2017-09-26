/// @nodoc
@JS("React")
library flur_react.internal.stateful_widget;

import 'package:flur_react/react.dart';
import 'package:flutter/widgets.dart' as flutter;
import 'package:js/js.dart';
import 'package:meta/meta.dart';

import 'react.dart' as reactApi;
import '../react_element.dart';

final reactApi.Class statefulClass = () {
  final classProps = new reactApi.ClassDefinition();
  classProps.render = allowInteropCaptureThis(render);
  classProps.getInitialState = allowInteropCaptureThis(getInitialState);
  return reactApi.createClass(classProps);
}();

@JS()
@anonymous
class StatefulComponent {
  @JS()
  external StatefulProps get props;

  @JS()
  external StatefulState get state;

  @JS()
  external void forceUpdate();

  @JS()
  external void setState(StatefulState state);
}

@JS()
@anonymous
class StatefulProps {
  external factory StatefulProps(
      {@required flutter.BuildContext parentBuildContext,
      @required flutter.Widget widget,
      @required ReactRenderTreePlugin renderTreePlugin,
      Function ref,
      Object key});
  @JS()
  external flutter.BuildContext get parentElement;
  @JS()
  external flutter.StatefulWidget get widget;
  @JS()
  external ReactRenderTreePlugin get renderTreePlugin;
  @JS()
  external Function get ref;
  @JS()
  external String get key;
}

@JS()
@anonymous
class StatefulState {
  @JS()
  external ReactStatefulElement get element;

  external factory StatefulState({ReactStatefulElement element});
}

StatefulState getInitialState(StatefulComponent $this) {
  // Get widget
  final props = $this.props;
  final widget = props.widget;
  if (widget == null) {
    throw new StateError("React element property 'widget' is null.");
  }

  // Construct state
  // ignore: INVALID_USE_OF_PROTECTED_MEMBER
  final element = new ReactStatefulElement(props.parentElement, $this, widget);
  return new StatefulState(element:element);
}

dynamic render(StatefulComponent $this) {
  // Get element
  final element = $this.state.element;
  if (element == null) {
    throw new StateError("React state.element is null.");
  }

  // Get props
  final props = $this.props;
  if (props == null) {
    throw new StateError("React element properties is null.");
  }

  // Update element widget
  final widget = props.widget;
  if (widget == null) {
    throw new StateError("React element property 'widget' is null.");
  }
  element.update(widget);

  // Build child widget tree
  final builtWidget = element.build();

  // Get RenderTreePlugin
  final renderTreePlugin = props.renderTreePlugin;
  if (renderTreePlugin == null) {
    throw new StateError("React element property 'renderTreePlugin' is null");
  }

  // Render the child
  return renderTreePlugin.renderWidget(element, builtWidget);
}