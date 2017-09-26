import 'package:flutter/foundation.dart';

/// In React, HTML/CSS use camelCase instead of kebab-base.
/// For example, you must use "fontFamily" instead of "font-family".
///
/// The following special cases exist:
///   * HTML attribute "for" is "htmlFor" in React
///     (because "for" is a reserved word in Javasript).
///   * CSS prefix "-ms" is "ms" in React, not "Ms".
///   * Inner HTML is set with:
///     `"{dangerouslySetInnerHtml": {"html":"content"}}`.
@immutable
abstract class ReactProps {
  const factory ReactProps(Map<String, Object> props) = _ReactProps;

  /// Visits each prop.
  void forEachReactProp(void f(String name, Object value));

  static final _cachedPropNamesFromCss = {};
  static final _cachedPropNamesToCss = {};

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
    if (name.startsWith("-ms-"))
      return "ms${nameFromCssName(name.substring(3))}";
    return nameFromKebabCase(name);
  }

  /// Converts React property name to HTML attribute name.
  static String nameToCssName(String name) {
    if (name.startsWith("ms")) return "-ms${nameToCssName(name.substring(2))}";
    return nameToKebabCase(name);
  }

  /// Converts kebab-case identifier ("font-family") to camel-case identifier ("fontFamily").
  static String nameFromKebabCase(String name) {
    var result = _cachedPropNamesFromCss[name];
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
      if (from == 0) {
        result = name;
      } else {
        result += name.substring(from);
      }
      _cachedPropNamesFromCss[name] = result;
    }
    return result;
  }

  /// Converts camel-case identifier ("fontFamily") to kebab-case identifier ("font-family").
  static String nameToKebabCase(String name) {
    final existing = _cachedPropNamesToCss[name];
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
    if (from == 0) {
      result = name;
    } else {
      result += name.substring(from);
    }
    _cachedPropNamesFromCss[name] = result;
    return result;
  }
}

class _ReactProps implements ReactProps {
  final Map<String, Object> _map;

  const _ReactProps(this._map);

  @override
  void forEachReactProp(void f(String name, Object value)) {
    _map.forEach(f);
  }
}
