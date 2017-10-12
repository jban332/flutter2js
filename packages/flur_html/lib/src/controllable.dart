import 'package:flutter/widgets.dart';

/// A [StatefulBuilder] that listens events from a [Listenable].
class Controllable extends StatefulWidget {
  final Listenable controller;
  final WidgetBuilder builder;

  Controllable(this.controller, this.builder) {
    assert(controller != null);
  }

  @override
  State createState() => new _ControllableState();
}

class _ControllableState extends State<Controllable> {
  VoidCallback _callback;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context);
  }

  @override
  void initState() {
    super.initState();
    _callback = () {
      this.setState(() {});
    };
    widget.controller.addListener(_callback);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_callback);
  }

  @override
  void didUpdateWidget(Controllable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widget = this.widget;
    if (!identical(oldWidget, widget)) {
      oldWidget.controller.removeListener(_callback);
      widget.controller.addListener(_callback);
    }
  }
}

typedef Widget ValueControllableBuilder<T>(BuildContext context, T value);

/// A [StatefulBuilder] that listens events from a [Listenable].
/// Widget is only rebuilt if the value is different from the previous value.
///
/// See also:
///   * [Controllable]
class ValueControllable<T> extends StatefulWidget {
  final ValueNotifier<T> controller;
  final ValueControllableBuilder builder;

  ValueControllable(this.controller, this.builder);

  createState() => new _ValueControllableState();
}

class _ValueControllableState<T> extends State<ValueControllable<T>> {
  VoidCallback _callback;
  T _value;

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _value);
  }

  @override
  void initState() {
    super.initState();
    _value = widget.controller.value;
    _callback = () {
      final oldValue = _value;
      final newValue = widget.controller.value;
      if (newValue != oldValue) {
        this.setState(() {
          _value = newValue;
        });
      }
    };
    widget.controller.addListener(_callback);
  }

  @override
  void deactivate() {
    super.deactivate();
    widget.controller.removeListener(_callback);
  }

  @override
  void didUpdateWidget(ValueControllable oldWidget) {
    super.didUpdateWidget(oldWidget);
    final widget = this.widget;
    if (!identical(oldWidget, widget)) {
      oldWidget.controller.removeListener(_callback);
      widget.controller.addListener(_callback);
    }
  }
}
