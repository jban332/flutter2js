import 'js.dart';

class JsValueImpl extends JsValue {
  static JsValueImpl get global => new JsValueImpl(null);

  static dynamic dartToJs(Object value) {
    throw new UnsupportedError("Javascript is not available in Flutter.");
  }

  JsValueImpl(dynamic value) : super(value) {
    throw new UnsupportedError("Javascript is not available in Flutter.");
  }

  @override
  JsValueImpl getIndex(int index) {
    return null;
  }

  @override
  JsValueImpl get(String key) {
    return null;
  }

  @override
  JsValueImpl putIndex(int index, Object value) {
    return null;
  }

  @override
  void put(String key, Object value) {}

  @override
  JsValueImpl callMethod(String method, List args) {
    return null;
  }
}
