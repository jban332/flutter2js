import 'dart:html' as html;
import 'dart:isolate';

import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/ui.dart' as ui;
import 'package:flutter/widgets.dart';

import 'internal/image.dart';

/// The number of logical pixels (Flutter concept) in a CSS 'em' unit.
const int cssEmInLogicalPixels = 16;

String cssFromBlendMode(BlendMode value) {
  if (value == null) {
    return null;
  }
  switch (value) {
    case BlendMode.color:
      return "color";
    case BlendMode.colorBurn:
      return "color-burn";
    case BlendMode.colorDodge:
      return "color-dodge";
    case BlendMode.darken:
      return "darken";
    case BlendMode.difference:
      return "difference";
    case BlendMode.exclusion:
      return "exclusion";
    case BlendMode.hardLight:
      return "hard-light";
    case BlendMode.hue:
      return "hue";
    case BlendMode.lighten:
      return "lighten";
    case BlendMode.luminosity:
      return "luminosity";
    case BlendMode.multiply:
      return "multiply";
    case BlendMode.overlay:
      return "overlay";
    case BlendMode.screen:
      return "screen";
    case BlendMode.softLight:
      return "soft-light";
    default:
      return "normal";
  }
}

String cssFromBorderSide(BorderSide value) {
  if (value == null) {
    return null;
  }
  switch (value.style) {
    case BorderStyle.none:
      return "none";
    default:
      return "${(value.width ?? 1.0).round()}px solid ${cssFromColor(
          value.color)}";
  }
}

String cssFromColor(Color value) {
  if (value == null) {
    return null;
  }
  return "#${value.toString()}";
}

String cssFromFontStyle(FontStyle value) {
  if (value == null) {
    return null;
  }
  switch (value) {
    case FontStyle.italic:
      return "italic";
    default:
      return "normal";
  }
}

String cssFromFontWeight(FontWeight value) {
  if (value == null) {
    return null;
  }
  switch (value) {
    case FontWeight.bold:
      return "bold";
    case FontWeight.w100:
      return "100";
    case FontWeight.w200:
      return "200";
    case FontWeight.w200:
      return "300";
    case FontWeight.w300:
      return "400";
    case FontWeight.w400:
      return "500";
    case FontWeight.w500:
      return "500";
    case FontWeight.w600:
      return "600";
    case FontWeight.w700:
      return "700";
    case FontWeight.w800:
      return "800";
    case FontWeight.w900:
      return "900";
    default:
      return "normal";
  }
}

String cssFromImageRepeat(ImageRepeat value) {
  if (value == null) return null;
  switch (value) {
    case ImageRepeat.repeat:
      return "repeat";
    case ImageRepeat.repeatX:
      return "repeat-x";
    case ImageRepeat.repeatY:
      return "repeat-y";
    default:
      return "no-repeat";
  }
}

String cssFromLogicalPixels(double value) {
  if (value == null) return "1em";
  value = value / cssEmInLogicalPixels;
  return "${value}em";
}

String cssFromPositionValue(double value) {
  return value == null ? "auto" : cssFromLogicalPixels(value);
}

String cssFromRadius(Radius value) {
  if (value == null) {
    return null;
  }
  return "${(value.x + value.y) * 0.5}px";
}

String cssFromFactional(double value) {
  if (value == null) {
    return null;
  }
  return "${value * 100}%";
}

String cssFromTextAlign(TextAlign value) {
  if (value == null) {
    return null;
  }
  switch (value) {
    case TextAlign.right:
      return "right";
    case TextAlign.left:
      return "left";
    case TextAlign.justify:
      return "justify";
    default:
      return "center";
  }
}

String cssFromTextDecoration(TextDecoration value) {
  if (value == null) {
    return null;
  }
  if (value == TextDecoration.lineThrough) {
    return "linethrough";
  }
  if (value == TextDecoration.overline) {
    return "overline";
  }
  if (value == TextDecoration.underline) {
    return "underline";
  }
  return "none";
}

String cssFromTextOverflow(TextOverflow value) {
  if (value == null) {
    return null;
  }
  switch (value) {
    case TextOverflow.ellipsis:
      return "ellipsis";
    case TextOverflow.fade:
      return "fade";
    default:
      return "clip";
  }
}

void cssFromTextStyle(TextStyle style, html.CssStyleDeclaration css) {
  if (style == null) {
    return null;
  }
  {
    final color = style.color;
    if (color != null) {
      css.color = cssFromColor(color);
    }
  }
  {
    final fontSize = style.fontSize;
    if (fontSize == null) {
      css.fontSize = cssFromLogicalPixels(fontSize);
    }
  }
  {
    final fontFamily = style.fontFamily;
    if (fontFamily != null) {
      css.fontFamily = "'${fontFamily}'";
    }
  }
  {
    final fontWeight = style.fontWeight;
    if (fontWeight != null) {
      css.fontWeight = cssFromFontWeight(fontWeight);
    }
  }
  {
    final fontStyle = style.fontStyle;
    if (fontStyle != null) {
      css.fontStyle = cssFromFontStyle(fontStyle);
    }
  }
  {
    final decoration = style.decoration;
    if (decoration != null) {
      css.textDecoration = cssFromTextDecoration(decoration);
    }
  }
  {
    final letterSpacing = style.letterSpacing;
    if (letterSpacing != null) {
      css.letterSpacing = cssFromLogicalPixels(letterSpacing);
    }
  }
  {
    final wordSpacing = style.wordSpacing;
    if (wordSpacing != null) {
      css.wordSpacing = cssFromLogicalPixels(wordSpacing);
    }
  }
}

String cssFromTransformMatrix(Matrix4 value) {
  if (value == null) {
    return null;
  }
  final sb = new StringBuffer();
  sb.write("matrix(");
  for (var i = 0; i < 2; i++) {
    for (var j = 0; j < 2; j++) {
      if (i > 0 || j > 0) {
        sb.write(", ");
      }
      sb.write(value.index(j, i));
    }
  }
  sb.write(")");
  return sb.toString();
}

void debugDomElement(BuildContext context, html.Element node, Widget widget) {
  assert(() {
    node.setAttribute("data-flutter-name", widget.runtimeType.toString());
    return true;
  });
}

void imageSrcFromImage(ui.Image image, void callback(String uri)) {
  if (image == null) {
    callback(null);
  }
  if (image is HtmlEngineImage) {
    callback(image.uri);
  } else {
    throw new ArgumentError.value(image);
  }
}

void imageSrcFromImageProvider(
    ImageProvider imageProvider, void callback(String uri)) {
  if (imageProvider == null) {
    callback(null);
  }
  if (imageProvider is NetworkImage) {
    callback(imageProvider.url);
  } else if (imageProvider is ExactAssetImage) {
    if (imageProvider.package == null) {
      callback("/assets/${imageProvider.assetName}");
    } else {
      final uri = Uri
          .parse("package:${imageProvider.package}/${imageProvider.assetName}");
      Isolate.resolvePackageUri(uri).then((uri) {
        callback(uri.toString());
      });
    }
  } else if (imageProvider is AssetImage) {
    if (imageProvider.package == null) {
      callback("/assets/${imageProvider.assetName}");
    } else {
      final uri = Uri
          .parse("package:${imageProvider.package}/${imageProvider.assetName}");
      Isolate.resolvePackageUri(uri).then((uri) {
        callback(uri.toString());
      });
    }
  } else {
    // Couldn't obtain an URI.
    // This means we will have to load the image to memory and create a DataURI,
    // which is a lot more expensive.
    imageProvider.resolve(new ImageConfiguration()).addListener((info, bool) {
      imageSrcFromImage(info.image, callback);
    });
  }
}
