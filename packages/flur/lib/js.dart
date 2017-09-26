library flur.js;

import 'dart:async';
import 'dart:typed_data';

import 'package:flur/js.dart';

import 'js_flutter.dart' if (dart.library.js) 'js_dart2js.dart';

export 'js_flutter.dart' if (dart.library.js) 'js_dart2js.dart';

/// Wraps a Javascript value.
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
  static final _array = JsValue.global.get("Array");
  static final _object = JsValue.global.get("Object");

  static JsValue get global => JsValueImpl.global;

  static JsValue fromJs(dynamic value) {
    if (value == null) return null;
    return new JsValueImpl(value);
  }

  static JsValue fromDart(dynamic value) {
    if (value == null) return null;
    return new JsValueImpl(JsValueImpl.dartToJs(value));
  }

  static JsValue newObject() {
    return fromJs(const {});
  }

  /// Contains the raw Javascript value.
  final dynamic unsafeValue;

  JsValue(this.unsafeValue);

  JsValue get _prototype => _object.callMethod("getPrototypeOf", [this]);

  bool get isArray => identical(_prototype.unsafeValue, _array.unsafeValue);

  bool get isObject => identical(_prototype.unsafeValue, _object.unsafeValue);

  Iterable<String> get keys =>
      _object.callMethod("keys", [this])._asDartList(maxDepth: 1);

  int get length => get("length").unsafeValue as int;

  JsValue apply(List args, {Object thisArg}) =>
      callMethod("apply", [thisArg, args]);

  Object _asDartList({int maxDepth: 1}) {
    if (maxDepth < 1) {
      throw new ArgumentError("Too deep JSON tree.");
    }
    maxDepth--;
    return new List.generate(
        this.length, (i) => getIndex(i).asDartObject(maxDepth: maxDepth));
  }

  Object _asDartMap({int maxDepth: 1}) {
    if (maxDepth < 1) {
      throw new ArgumentError("Too deep JSON tree.");
    }
    maxDepth--;
    final map = {};
    for (var key in keys) {
      map[key] = get(key).asDartObject(maxDepth: maxDepth);
    }
    return map;
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
        unsafeValue is Uint8List ||
        unsafeValue is Function) {
      return unsafeValue;
    }
    if (isArray) {
      return _asDartList(maxDepth: maxDepth);
    }
    if (isObject) {
      return _asDartMap(maxDepth: maxDepth);
    }
    throw new StateError(
        "The Javascript value can't be converted to Dart value: ${toString()}");
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

  @override
  int get hashCode {
    final value = this.unsafeValue;
    if (value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is DateTime) return value.hashCode;
    return 0;
  }

  @override
  operator ==(other) {
    if (other is JsValue) {
      return identical(unsafeValue, other.unsafeValue);
    }
    return false;
  }
}
