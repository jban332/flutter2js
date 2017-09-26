import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flur/flur_for_modified_flutter.dart';
import 'package:flur/js.dart';
import 'package:flutter/widgets.dart';
import 'package:js/js.dart' as js;
import 'package:js/js_util.dart' as js_util;

import 'internal/react.dart' as reactApi;
import 'internal/react_dom.dart' as reactDomApi;
import 'internal/stateful_widget.dart' as reactStatefulWidgetApi;
import 'js_react_widget.dart';
import 'react_element.dart';

abstract class ReactRenderTreePlugin extends RenderTreePlugin {
  @override
  void runApp(Widget widget);

  reactApi.Element renderWidget(ReactElement parent, Widget widget) {
    assert(parent == null || parent.depth < 32,
        "Widget '${widget.runtimeType}' is too deep: ${parent.debugGetCreatorChain(32)}");
    if (widget == null) {
      return null;
    }
    if (widget is HtmlReactWidget) {
      return renderHtmlWidget(parent, widget);
    } else if (widget is ReactWidget) {
      return renderReactWidget(parent, widget);
    } else if (widget is JsReactElementBuildingWidget) {
      final element = new ReactElement(parent, widget);
      return widget.buildReactElement(element);
    } else if (widget is StatelessWidget) {
      return renderStatelessWidget(parent, widget);
    } else if (widget is StatefulWidget) {
      return renderStatefulWidget(parent, widget);
    } else if (widget is ProxyWidget) {
      if (widget is InheritedWidget) {
        final element = new ReactInheritedElement(parent, widget);
        return renderWidget(element, widget.child);
      }
      final element = new ReactProxyElement(parent, widget);
      return renderWidget(element, widget.child);
    } else if (widget is UIPluginWidget) {
      final context = new ReactElement(parent, widget);
      final builtWidget = widget.buildWithUIPlugin(context, UIPlugin.current);
      if (identical(widget, builtWidget)) {
        throw new StateError(
            "Class '${widget.runtimeType}' buildWithUIPlugin(...) returned itself");
      }
      return renderWidget(context, builtWidget);
    } else {
      throw new ArgumentError.value(widget);
    }
  }

  reactApi.Element renderHtmlWidget(
      ReactElement parentElement, HtmlReactWidget widget) {
    final element = new ReactElement(parentElement, widget);
    final jsType = widget.type;
    final jsProps = propsToJs(element, widget, widget.props);
    final jsChildren = childrenToJs(element, widget.children);
    return reactApi.createElement(jsType, jsProps, jsChildren);
  }

  reactApi.Element renderReactWidget(
      ReactElement parentElement, ReactWidget widget) {
    final element = new ReactElement(parentElement, widget);
    final jsType = typeToJs(widget.type);
    final jsProps = propsToJs(element, widget, widget.props);
    final jsChildren = childrenToJs(element, widget.children);
    return reactApi.createElement(jsType, jsProps, jsChildren);
  }

  reactApi.Element renderStatelessWidget(
      ReactElement parentElement, StatelessWidget widget) {
    final element = new ReactElement(parentElement, widget);
    // ignore: INVALID_USE_OF_PROTECTED_MEMBER
    final builtWidget = widget.build(element);
    assert(builtWidget != null,
        "Widget '${widget.runtimeType}' method 'build(...)' returned null.");
    return renderWidget(element, builtWidget);
  }

  reactApi.Element renderStatefulWidget(
      ReactElement parentElement, StatefulWidget widget) {
    // Construct props
    final dynamic props = new reactStatefulWidgetApi.StatefulProps(
      parentBuildContext: parentElement,
      widget: widget,
      renderTreePlugin: this,
      key: widgetToReactKey(widget),
    );

    // Call React.createElement
    return reactApi.createElement(reactStatefulWidgetApi.statefulClass, props);
  }

  dynamic typeToJs(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is JsValue) return value.unsafeValue;
    throw new UnsupportedError("Invalid React type: ${value}");
  }

  /// Builds React key.
  dynamic widgetToReactKey(Widget widget) {
    final key = widget.key;
    if (key == null) {
      return null;
    }
    if (key is ValueKey) {
      return key.value;
    } else if (key is GlobalObjectKey) {
      return key.value;
    }
    return key;
  }

  dynamic propsToJs(Element parent, Widget widget, ReactProps props) {
    final jsProps = js_util.newObject();
    final key = widgetToReactKey(widget);
    if (key != null) {
      js_util.setProperty(jsProps, "key", key);
    }
    if (widget is HtmlReactWidget) {
      final onRef = widget.onJsValue;
      if (onRef != null) {
        js_util.setProperty(jsProps, "ref", js.allowInterop((ref) {
          onRef(JsValue.fromJs(ref));
        }));
      }
      final className = widget.className;
      if (className != null) {
        js_util.setProperty(jsProps, "className", className);
      }
      final style = widget.style;
      if (style != null) {
        final jsStyle = js_util.newObject();
        if (props != null) {
          props.forEachReactProp((k, v) {
            js_util.setProperty(jsProps, k, valueToJs(parent, v));
          });
        }
        js_util.setProperty(jsProps, "style", jsStyle);
      }
    } else if (widget is ReactWidget) {
      final onRef = widget.onJsValue;
      if (onRef != null) {
        js_util.setProperty(jsProps, "ref", js.allowInterop((ref) {
          onRef(JsValue.fromJs(ref));
        }));
      }
      final style = widget.style;
      if (style != null) {
        final jsStyle = js_util.newObject();
        if (props != null) {
          props.forEachReactProp((k, v) {
            js_util.setProperty(jsProps, k, valueToJs(parent, v));
          });
        }
        js_util.setProperty(jsProps, "style", jsStyle);
      }
    }
    if (props != null) {
      props.forEachReactProp((k, v) {
        js_util.setProperty(jsProps, k, valueToJs(parent, v));
      });
    }
    return jsProps;
  }

  dynamic childrenToJs(Element parent, Iterable children) {
    if (children == null) {
      return null;
    } else if (children is Iterable) {
      final result = reactApi.newArray();
      for (var item in children) {
        result.add(valueToJs(parent, item));
      }
      return result;
    } else {
      throw new ArgumentError.value(children);
    }
  }

  dynamic valueToJs(Element parent, Object value) {
    if (value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is DateTime) {
      return value;
    }
    if (value is Function) {
      return js.allowInterop(value);
    }
    if (value is Widget) {
      return renderWidget(parent, value);
    }
    if (value is Iterable) {
      final result = reactApi.newArray();
      for (var item in value) {
        result.add(valueToJs(parent, item));
      }
      return result;
    }
    if (value is Map) {
      final result = js_util.newObject();
      value.forEach((k, v) {
        js_util.setProperty(result, k as String, valueToJs(parent, v));
      });
      return result;
    }
    if (value is ReactProps) {
      final jsProps = js_util.newObject();
      value.forEachReactProp((k, v) {
        js_util.setProperty(jsProps, k, valueToJs(parent, v));
      });
      return jsProps;
    }
    throw new ArgumentError.value(value, "Can't convert into JS value");
  }
}

class ReactDomRenderTreePlugin extends ReactRenderTreePlugin {
  final String selector;

  ReactDomRenderTreePlugin({this.selector: "#flur"}) {}

  @override
  void runApp(Widget widget) {
    assert(widget != null);
    final htmlElement = html.querySelector(selector);
    if (htmlElement == null) {
      throw new StateError(
          "Can't find HTML element '${selector}', where the app should be rendered.");
    }
    final reactElement = renderWidget(null, widget);
    assert(reactElement != null);
    reactDomApi.render(reactElement, htmlElement);
  }
}
