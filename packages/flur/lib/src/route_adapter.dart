import 'dart:async';

abstract class RouteAdapter {
  String get current;

  void assign(String value);

  void push(String value);

  Stream<String> get stream;
}
