import 'package:flutter/foundation.dart';

/// ReactProps
@immutable
abstract class ReactProps {
  static final _propNamesFromCss = {};

  static final _propNamesToCss = {};

  /// Converts HTML attribute name to React property name.
  static String nameFromHtmlAttributeName(String name) {
    switch (name) {
      case "for":
        return "htmlFor";
      default:
        return nameFromKebabCase(name);
    }
  }

  /// Converts React property name to HTML attribute name.
  static String nameToHtmlAttributeName(String name) {
    switch (name) {
      case "htmlFor":
        return "for";
      default:
        return nameToKebabCase(name);
    }
  }
  /// Converts HTML attribute name to React property name.
  static String nameFromCssName(String name) {
    if (name.startsWith("-ms-")) return "ms${nameFromCssName(name.substring(3))}";
    return nameFromKebabCase(name);
  }

  /// Converts React property name to HTML attribute name.
  static String nameToCssName(String name) {
    if (name.startsWith("ms")) return "-ms${nameToCssName(name.substring(2))}";
    return nameToKebabCase(name);
  }

  /// Converts kebab-case identifier ("font-family") to camel-case identifier ("fontFamily").
  static String nameFromKebabCase(String name) {
    var result = _propNamesFromCss[name];
    if (result == null) {
      result = "";
      var from = 0;
      for (var i = 0; i < name.length; i++) {
        if (name.startsWith("-", i)) {
          result += name.substring(from, i);
          i++;
          from = i + 1;
          result += name.substring(i, from).toUpperCase();
        }
      }
      result += name.substring(from);
      _propNamesFromCss[name] = result;
    }
    return result;
  }

  /// Converts camel-case identifier ("fontFamily") to kebab-case identifier ("font-family").
  static String nameToKebabCase(String name) {
    final existing = _propNamesToCss[name];
    if (existing != null) {
      return existing;
    }
    var result = "";
    var lowerCaseName = name.toLowerCase();
    var from = 0;
    for (var i = 0; i < name.length; i++) {
      if (name.codeUnitAt(i) != lowerCaseName.codeUnitAt(i)) {
        result += name.substring(from, i);
        result += "-";
        from = i + 1;
        result += lowerCaseName.substring(i, from);
      }
    }
    result += name.substring(from);
    _propNamesFromCss[name] = result;
    return result;
  }

  /// Keys must be valid prop keys in React. For example, you must use
  /// "fontFamily" instead of "font-family" and "htmlFor" instead of "for".
  const factory ReactProps(Map<String, Object> props) = _ReactProps;

  /// Visits each prop.
  void forEachReactProp(void f(String name, Object value));
}

class _ReactProps implements ReactProps {
  final Map<String, Object> _map;

  const _ReactProps(this._map);

  @override
  void forEachReactProp(void f(String name, Object value)) {
    _map.forEach(f);
  }
}
