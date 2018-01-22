import 'dart:async';

/// Manages route history.
abstract class RoutingPlugin {
  String get current;

  void assign(String value);

  void push(String value);

  Stream<String> get stream;
}
