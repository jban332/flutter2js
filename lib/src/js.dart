import 'dart:async';
import 'dart:typed_data';

import 'package:flur/src/platform_plugin.dart';
import 'package:meta/meta.dart';

// Q: Why we have our own JS interoperability layer?
// A: 1.Flutter compiler doesn't like dependencies on 'dart:js'.
//    2.We may want to do our own JS <-> Dart translations.

class JsExposedFunction {
  final int argsLength;
  final Function function;

  JsExposedFunction(this.function, {@required this.argsLength}) {
    if (argsLength < 0 || argsLength > 4) {
      throw new ArgumentError();
    }
  }

  Object apply($this, List args) {
    final argsLength = this.argsLength;
    while (args.length < argsLength) {
      args.add(null);
    }
    switch (this.argsLength) {
      case 0:
        return function($this);
      case 1:
        return function($this, args[0]);
      case 2:
        return function($this, args[0], args[1]);
      case 3:
        return function($this, args[0], args[1], args[2]);
      case 4:
        return function($this, args[0], args[1], args[2], args[3]);
      case 5:
        return function($this, args[0], args[1], args[2], args[3], args[4]);
      default:
        throw new UnsupportedError("Function takes 'this' and 0..5 arguments.");
    }
  }
}

/// Reference to native Javascript value.
///
/// This wrapper is used to eliminate dependency to 'dart:js'.
///
/// Dart -> JS conversion rules:
///   * Dart [JsValue] -> Native JS object
///   * Dart [JsExposedFunction] -> Native JS function
///   * Dart null -> JS null
///   * Dart bool -> JS boolean
///   * Dart num -> JS number
///   * Dart String -> JS String
///   * Dart DateTime -> JS Date
///   * Dart Uint8List -> JS Uint8Array
///   * Dart List -> JS Array
///   * Dart Map -> JS Object
///   * Anything else -> throw an error
abstract class JsValue {
  static final _array = PlatformPlugin.current.jsGlobal.get("Array");
  static final _object = PlatformPlugin.current.jsGlobal.get("Object");

  static JsValue get global => PlatformPlugin.current.jsGlobal;

  /// Contains the raw value.
  /// Use VERY carefully.
  final dynamic unsafeValue;

  JsValue(this.unsafeValue);

  bool get isArray => identical(_prototype.unsafeValue, _array.unsafeValue);

  bool get isObject => identical(_prototype.unsafeValue, _object.unsafeValue);

  Iterable<String> get keys =>
      _object.callMethod("keys", [this]).asDartObject();

  int get length => get("length").unsafeValue as int;

  JsValue get _prototype => _object.callMethod("getPrototypeOf", [this]);

  JsValue apply(List args, {Object thisArg}) =>
      callMethod("apply", [thisArg, args]);

  /// Returns a tree made of null, bool, num, String, List, and Map.
  /// If the method encounters any non-JSON value, an error is thrown.
  Object asDartJsonTree({int maxDepth: 8}) {
    final unsafeValue = this.unsafeValue;
    if (unsafeValue == null ||
        unsafeValue is bool ||
        unsafeValue is num ||
        unsafeValue is String) {
      return unsafeValue;
    }
    if (isArray) {
      if (maxDepth <= 0) {
        throw new ArgumentError("Too deep JSON tree.");
      }
      maxDepth--;
      return new List.generate(
          this.length, (i) => getIndex(i).asDartJsonTree(maxDepth: maxDepth));
    }
    if (isObject) {
      if (maxDepth <= 0) {
        throw new ArgumentError("Too deep JSON tree.");
      }
      maxDepth--;
      final map = {};
      for (var key in keys) {
        map[key] = get(key).asDartJsonTree(maxDepth: maxDepth);
      }
      return map;
    }
    throw new StateError("The value is not a JSON tree, found: ${toString()}");
  }

  /// Returns a tree made of null, bool, num, String, DateTime, List, and Map.
  /// Other values are returned as JsValue.
  Object asDartObject({int maxDepth: 8}) {
    final unsafeValue = this.unsafeValue;
    if (unsafeValue == null ||
        unsafeValue is bool ||
        unsafeValue is num ||
        unsafeValue is String ||
        unsafeValue is DateTime ||
        unsafeValue is Uint8List) {
      return unsafeValue;
    }
    if (isArray) {
      if (maxDepth <= 0) {
        throw new ArgumentError("Too deep JSON tree.");
      }
      maxDepth--;
      return new List.generate(
          this.length, (i) => getIndex(i).asDartObject(maxDepth: maxDepth));
    }
    if (isObject) {
      if (maxDepth <= 0) {
        throw new ArgumentError("Too deep JSON tree.");
      }
      maxDepth--;
      final map = {};
      for (var key in keys) {
        map[key] = get(key).asDartObject(maxDepth: maxDepth);
      }
      return map;
    }
    return this;
  }

  Future<JsValue> asFuture({bool captureStackTrace: true}) {
    if (unsafeValue == null) {
      return null;
    }
    final completer = new Completer<JsValue>();
    final onValue = ($this, value) {
      completer.complete(value);
    };
    final onError = ($this, error) {
      completer.completeError(
          error, captureStackTrace ? StackTrace.current : null);
    };
    callMethod("then", [onValue, onError]);
    return completer.future;
  }

  JsValue get(String key);

  JsValue getIndex(int index);

  JsValue callMethod(String name, List args);

  void put(String name, Object value);

  void putIndex(int index, Object value);

  @override
  String toString() {
    final name = get("constructor").get("name").unsafeValue;
    if (name is String && name.length < 64) {
      return "[JsValue:${name}]";
    }
    return "[JsValue:unknown_type]";
  }
}
