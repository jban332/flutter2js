import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'html_render_objects.dart';

/// Renders HTML element.
///
/// In non-browser platforms, renders [ErrorWidget].
@immutable
class HtmlElementWidget extends MultiChildRenderObjectWidget {
  final String name;
  final String className;

  /// Widget or state who built this widget.
  /// In checked mode, type of the creator will be rendered (HTML attribute "data-flutter-name").
  final dynamic debugName;

  /// HTML attributes.
  final Map<String, String> attributes;

  /// HTML attributes.
  final Map<String, ValueChanged> eventHandlers;

  /// CSS style.
  final Map<String, String> style;

  /// If set, the callback will receive the underlying DOM element when
  /// the element is mounted and null when the element is unmounted.
  final ValueChanged<dynamic> onDomElement;

  HtmlElementWidget(this.name,
      {Key key,
      this.className,
      this.attributes,
      this.eventHandlers,
      this.style,
      List<Widget> children,
      this.onDomElement,
      this.debugName})
      : super(key: key, children: children);

  html.Element buildHtmlElement() {
    final htmlElement = new html.Element.tag(name);
    forEachAttribute((k, v) {
      htmlElement.setAttribute(k, v);
    });
    forEachEventHandler((eventName, eventHandler) {
      new html.EventStreamProvider<html.Event>(eventName)
          .forElement(htmlElement)
          .listen((event) {
        eventHandler(event);
      });
    });
    final style = htmlElement.style;
    forEachStyleProperty((k, v) {
      style.setProperty(k, v);
    });
    return htmlElement;
  }

  RenderObject createRenderObject(BuildContext c) {
    return new HtmlRenderNode(buildHtmlElement());
  }

  void forEachAttribute(void f(String name, String value)) {
    final className = this.className;
    if (className != null) {
      f("class", className);
    }
    assert(() {
      final debugLabel = this.debugName;
      if (debugLabel != null) {
        f("data-debug", debugLabel.runtimeType.toString());
      }
      return true;
    }());
    attributes?.forEach(f);
  }

  void forEachEventHandler(void f(String name, ValueChanged<dynamic> value)) {
    eventHandlers?.forEach(f);
  }

  void forEachStyleProperty(void f(String name, String value)) {
    style?.forEach(f);
  }
}
