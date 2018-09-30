import 'package:flutter/widgets.dart';

/// Singleton returned by [WidgetsFlutterBinding.instance].
final WidgetsFlutterBindingImplementation widgetsFlutterBinding =
    new WidgetsFlutterBindingImplementation();

class WidgetsFlutterBindingImplementation extends WidgetsFlutterBinding {
  WidgetsFlutterBindingImplementation() : super.constructor();
}
