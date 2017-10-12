import 'dart:async';
import 'dart:html' as html;

import 'package:flur/flur.dart';
import 'package:flutter/widgets.dart';

class UrlFragmentRouteAdapter extends RouteAdapter {
  @override
  String get current {
    var value = html.window.location.hash;
    if (value.startsWith("#")) value = value.substring(1);
    if (value == "") {
      value = Navigator.defaultRouteName;
    }
    return value;
  }

  @override
  void push(String value) {
    html.window.location.hash = value;
  }

  @override
  void assign(String value) {
    html.window.location.hash = value;
  }

  @override
  Stream<String> get stream => html.window.onHashChange.map((event) => current);
}

class UrlPathRouteAdapter extends RouteAdapter {
  final String prefix;

  UrlPathRouteAdapter({this.prefix: ""});

  @override
  String get current {
    var value = html.window.location.pathname;
    if (value == "") {
      value = Navigator.defaultRouteName;
    }
    return value;
  }

  @override
  void assign(String value) {
    html.window.location.pathname = "${prefix}${value}";
  }

  @override
  void push(String value) {
    html.window.location.pathname = "${prefix}${value}";
    _streamController.add(value);
  }

  final StreamController<String> _streamController =
      new StreamController<String>();

  @override
  Stream<String> get stream => _streamController.stream;
}
