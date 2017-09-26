/// @nodoc
@JS("React")
library flur_react.internal.react;

import 'package:js/js.dart';
export 'js.dart';

Element createElement(dynamic type, [Props props, dynamic children]) {
  assert(type != null);
  return _createElement(type, props, children);
}

@JS("createElement")
external Element _createElement(dynamic type, Props props, dynamic children);

Class createClass(ClassDefinition props) {
  assert(props != null);
  return _createClass(props);
}

@JS("createClass")
external Class _createClass(ClassDefinition props);

@JS()
@anonymous
class Class {}

@JS()
@anonymous
class Element {}

@JS()
@anonymous
class ClassDefinition {
  @JS()
  external set render(Function _);

  @JS()
  external set getInitialState(Function _);

  @JS()
  external set componentDidMount(Function _);

  @JS()
  external set componentDidUnmount(Function _);

  external factory ClassDefinition();
}

@JS()
@anonymous
class Component {
  @JS()
  external Props get props;

  @JS()
  external dynamic get state;

  @JS()
  external void forceUpdate();

  @JS()
  external void setState(state);
}

@JS()
@anonymous
class Props {
  @JS()
  external Function get key;

  @JS()
  external Function get ref;

  external factory Props({Function key, Function ref});
}
