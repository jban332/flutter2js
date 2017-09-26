/// @nodoc
@JS("ReactDOM")
library flur_react.internal.react_dom;

import 'dart:html' as html;
import 'package:js/js.dart';
import 'react.dart' as reactApi;

void render(reactApi.Element reactElement, html.Element htmlElement) {
  assert(reactElement != null);
  assert(htmlElement != null);
  _render(reactElement, htmlElement);
}

@JS("render")
external void _render(reactApi.Element reactElement, html.Element htmlElement);
