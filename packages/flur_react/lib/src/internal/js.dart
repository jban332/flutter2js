/// @nodoc
@JS()
library flur_react.internal.js;

import 'package:js/js.dart';
import 'package:js/js_util.dart';

@JS("Array")
external get _array;

dynamic newArray([List items]) => callConstructor(_array, items??const[]);

@JS("Array")
class Array {
  @JS()
  external void add(dynamic item);
}