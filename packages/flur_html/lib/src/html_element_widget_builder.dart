import 'package:flur/flur.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HtmlElementWidgetBuilder {
  final Widget debugCreator;
  final String type;
  Map<String, String> _attributes;
  Map<String, String> style;
  Map<String, ValueChanged> _eventHandlers;
  List _children;
  HtmlElementWidgetBuilder(this.debugCreator, this.type) {}

  void set className(String value) {
    _attributes["class"] = value;
  }

  void setAttribute(String name, String value) {
    if (value == null) return;
    var attributes = this._attributes;
    if (attributes == null) {
      attributes = <String, String>{};
      this._attributes = attributes;
    }
  }

  void setStyleProperty(String name, String value) {
    if (value == null) return;
    var style = this.style;
    if (style == null) {
      style = <String, String>{};
      this.style = style;
    }
    style[name] = value;
  }

  void setVoidCallback(String name, VoidCallback value) {
    if (value == null) return;
    var eventHandlers = this._eventHandlers;
    if (eventHandlers == null) {
      eventHandlers = <String, ValueChanged>{};
      this._eventHandlers = eventHandlers;
    }
    eventHandlers[name] = (event) {
      value();
    };
  }

  void setValueChanged(String name, ValueChanged value) {
    if (value == null) return;
    var eventHandlers = this._eventHandlers;
    if (eventHandlers == null) {
      eventHandlers = <String, ValueChanged>{};
      this._eventHandlers = eventHandlers;
    }
    eventHandlers[name] = value;
  }

  void _addChild(Object value) {
    var children = this._children;
    if (children == null) {
      children = [];
      this._children = children;
    }
    children.add(value);
  }

  void addText(String value) {
    _addChild(value);
  }

  void addWidget(Widget value) {
    _addChild(value);
  }

  HtmlElementWidget build() {
    return new HtmlElementWidget(type,
        debugCreator: debugCreator,
        attributes: _attributes,
        eventHandlers: _eventHandlers,
        style: style);
  }
}
