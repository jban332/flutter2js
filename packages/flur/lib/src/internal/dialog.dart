import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

Future<T> showDialog<T>({
  @required BuildContext context,
  bool barrierDismissible: true,
  @required Widget child,
}) {
  return Navigator.push(
      context,
      new _DialogRoute<T>(
        child: child,
        theme: Theme.of(context, shadowThemeOnly: true),
        barrierDismissible: barrierDismissible,
      ));
}

// Default Dialog implementation from Flutter
class _DialogRoute<T> extends PopupRoute<T> {
  final Widget child;

  final ThemeData theme;
  final bool _barrierDismissible;

  _DialogRoute({
    @required this.theme,
    bool barrierDismissible: true,
    @required this.child,
  })
      : _barrierDismissible = barrierDismissible;

  @override
  Color get barrierColor => Colors.black54;

  @override
  bool get barrierDismissible => _barrierDismissible;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 150);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return theme != null ? new Theme(data: theme, child: child) : child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return new FadeTransition(
        opacity: new CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child);
  }
}
