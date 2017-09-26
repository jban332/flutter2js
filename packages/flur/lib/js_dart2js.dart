import 'dart:js' as js;
import 'dart:js_util' as js_util;

import 'js.dart';

typedef _F0();
typedef _F1(a);
typedef _F2(a, b);
typedef _F3(a, b, c);
typedef _F4(a, b, c, d);

class JsValueImpl extends JsValue {
  static final JsValueImpl global = new JsValueImpl(js.context);

  JsValueImpl(dynamic value) : super(value);

  static dynamic dartToJs(Object value) {
    if (value == null ||
        value is bool ||
        value is num ||
        value is String ||
        value is DateTime) return value;
    if (value is Iterable) {
      return new js.JsArray.from(value.map(dartToJs));
    }
    if (value is Map) {
      final result = js_util.newObject();
      value.forEach((k, v) {
        js_util.setProperty(result, k as String, dartToJs(v));
      });
      return result;
    }
    if (value is JsValue) {
      return value.unsafeValue;
    }
    if (value is Function) {
      if (value is _F0) {
        return () {
          return value();
        };
      }
      if (value is _F1) {
        return (a) {
          return value(JsValue.fromJs(a));
        };
      }
      if (value is _F2) {
        return (a, b) {
          return value(JsValue.fromJs(a), JsValue.fromJs(b));
        };
      }
      if (value is _F3) {
        return (a, b, c) {
          return value(JsValue.fromJs(a), JsValue.fromJs(b), JsValue.fromJs(c));
        };
      }
      if (value is _F4) {
        return (a, b, c, d) {
          return value(JsValue.fromJs(a), JsValue.fromJs(b), JsValue.fromJs(c),
              JsValue.fromJs(d));
        };
      }
      return throw new ArgumentError.value(value);
    }
    throw new ArgumentError.value(
        value, "Can't convert Dart value into Javascript");
  }

  @override
  JsValueImpl getIndex(int index) {
    final result = js_util.getProperty(unsafeValue, index);
    if (result == null) return null;
    return new JsValueImpl(result);
  }

  @override
  JsValueImpl get(String key) {
    final result = js_util.getProperty(unsafeValue, key);
    if (result == null) return null;
    return new JsValueImpl(result);
  }

  @override
  JsValueImpl putIndex(int index, Object value) {
    final result = js_util.setProperty(unsafeValue, index, dartToJs(value));
    if (result == null) return null;
    return new JsValueImpl(result);
  }

  @override
  void put(String key, Object value) {
    js_util.setProperty(unsafeValue, key, dartToJs(value));
  }

  @override
  JsValueImpl callMethod(String method, List args) {
    if (args != null) {
      args = args.map(dartToJs).toList();
    }
    final result = js_util.callMethod(unsafeValue, method, args);
    if (result == null) return null;
    return new JsValueImpl(result);
  }
}
