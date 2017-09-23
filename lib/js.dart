library flur.js;

import 'dart:js' as js;
import 'dart:js_util' as js_util;
import 'flur.dart';

class JsPlatformPlugin extends PlatformPlugin {
  @override
  JsValue get jsGlobal => new _JsValueImpl(js.context);
}

class _JsValueImpl extends JsValue {
  _JsValueImpl(dynamic value) : super(value);

  static dynamic _dartToJs(Object value) {
    if (value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is DateTime) return value;
    if (value is Iterable) {
      return new js.JsArray.from(value);
    }
    if (value is Map) {
      final result = js_util.newObject();
      value.forEach((k, v) {
        js_util.setProperty(result, k, v);
      });
      return result;
    }
    if (value is JsValue) {
      return value.unsafeValue;
    }
    throw new ArgumentError.value(
        value, "Can't convert Dart value into Javascript");
  }

  @override
  _JsValueImpl getIndex(int index) {
    final result = js_util.getProperty(unsafeValue, index);
    if (result == null) return null;
    return new _JsValueImpl(result);
  }

  @override
  _JsValueImpl get(String key) {
    final result = js_util.getProperty(unsafeValue, key);
    if (result == null) return null;
    return new _JsValueImpl(result);
  }

  @override
  _JsValueImpl putIndex(int index, Object value) {
    final result = js_util.setProperty(unsafeValue, index, _dartToJs(value));
    if (result == null) return null;
    return new _JsValueImpl(result);
  }

  @override
  void put(String key, Object value) {
    js_util.setProperty(unsafeValue, key, value);
  }

  @override
  _JsValueImpl callMethod(String method, List args) {
    if (args != null) {
      args = args.map(_dartToJs).toList();
    }
    final result = js_util.callMethod(unsafeValue, method, args);
    if (result == null) return null;
    return new _JsValueImpl(result);
  }
}
