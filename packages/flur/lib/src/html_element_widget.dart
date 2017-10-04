import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'render_tree_plugin.dart';

/// Renders HTML element.
///
/// In non-browser platforms, renders [ErrorWidget].
@immutable
class HtmlElementWidget extends StatelessWidget {
  final String type;
  final String className;

  /// Widget or state who built this widget.
  /// In checked mode, type of the creator will be rendered (HTML attribute "data-flutter-name").
  final dynamic debugCreator;

  /// HTML attributes.
  final Map<String, dynamic> attributes;

  /// HTML attributes.
  final Map<String, ValueChanged> eventHandlers;

  /// CSS style.
  final Map<String, dynamic> style;

  /// Children. They can be anything.
  /// If an item is not [Widget], it's rendered as text.
  final List children;

  /// If set, the callback will receive the underlying DOM element when
  /// the element is mounted and null when the element is unmounted.
  final ValueChanged<dynamic> onDomElement;

  const HtmlElementWidget(this.type,
      {Key key,
      this.className,
      this.attributes,
      this.eventHandlers,
      this.style,
      this.children,
      this.onDomElement,
      this.debugCreator})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RenderTreePlugin.current.buildHtmlElementWidget(context, this);
  }

  void forEachEventHandler(void f(String name, ValueChanged<dynamic> value)) {
    eventHandlers?.forEach(f);
  }

  void forEachAttribute(void f(String name, String value)) {
    final className = this.className;
    if (className != null) {
      f("class", className);
    }
    assert(() {
      final debugCreator = this.debugCreator;
      if (debugCreator != null) {
        f("data-flutter-name", debugCreator.runtimeType.toString());
      }
      return true;
    }());
    attributes?.forEach(f);
  }

  void forEachStyleProperty(void f(String name, String value)) {
    style?.forEach(f);
  }
}
