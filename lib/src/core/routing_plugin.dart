import 'dart:async';

/// Manages route history.
abstract class RoutingPlugin {
  String get current;

  Stream<String> get stream;

  void assign(String value);

  void push(String value);
}
