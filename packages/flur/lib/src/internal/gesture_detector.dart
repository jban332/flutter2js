// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// Factory for creating gesture recognizers.
///
/// `T` is the type of gesture recognizer this class manages.
///
/// Used by [RawGestureDetector.gestures].
@optionalTypeArgs
abstract class GestureRecognizerFactory<T extends GestureRecognizer> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const GestureRecognizerFactory();

  /// Must return an instance of T.
  T constructor();

  /// Must configure the given instance (which will have been created by
  /// `constructor`).
  ///
  /// This normally means setting the callbacks.
  void initializer(T instance);

  bool _debugAssertTypeMatches(Type type) {
    assert(type == T,
        'GestureRecognizerFactory of type $T was used where type $type was specified.');
    return true;
  }
}

/// Signature for closures that implement [GestureRecognizerFactory.constructor].
typedef T GestureRecognizerFactoryConstructor<T extends GestureRecognizer>();

/// Signature for closures that implement [GestureRecognizerFactory.initializer].
typedef void GestureRecognizerFactoryInitializer<T extends GestureRecognizer>(
    T instance);

/// Factory for creating gesture recognizers that delegates to callbacks.
///
/// Used by [RawGestureDetector.gestures].
class GestureRecognizerFactoryWithHandlers<T extends GestureRecognizer>
    extends GestureRecognizerFactory<T> {
  /// Creates a gesture recognizer factory with the given callbacks.
  ///
  /// The arguments must not be null.
  const GestureRecognizerFactoryWithHandlers(
      this._constructor, this._initializer);

  final GestureRecognizerFactoryConstructor<T> _constructor;

  final GestureRecognizerFactoryInitializer<T> _initializer;

  @override
  T constructor() => _constructor();

  @override
  void initializer(T instance) => _initializer(instance);
}

@override
Widget buildGestureDetector(BuildContext context, GestureDetector $this) {
  final Map<Type, GestureRecognizerFactory> gestures =
      <Type, GestureRecognizerFactory>{};
  if ($this.onTapDown != null ||
      $this.onTapUp != null ||
      $this.onTap != null ||
      $this.onTapCancel != null) {
    gestures[TapGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
      () => new TapGestureRecognizer(debugOwner: $this),
      (TapGestureRecognizer instance) {
        instance
          ..onTapDown = $this.onTapDown
          ..onTapUp = $this.onTapUp
          ..onTap = $this.onTap
          ..onTapCancel = $this.onTapCancel;
      },
    );
  }

  if ($this.onDoubleTap != null) {
    gestures[DoubleTapGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
      () => new DoubleTapGestureRecognizer(debugOwner: $this),
      (DoubleTapGestureRecognizer instance) {
        instance..onDoubleTap = $this.onDoubleTap;
      },
    );
  }

  if ($this.onLongPress != null) {
    gestures[LongPressGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
      () => new LongPressGestureRecognizer(debugOwner: $this),
      (LongPressGestureRecognizer instance) {
        instance..onLongPress = $this.onLongPress;
      },
    );
  }

  if ($this.onVerticalDragDown != null ||
      $this.onVerticalDragStart != null ||
      $this.onVerticalDragUpdate != null ||
      $this.onVerticalDragEnd != null ||
      $this.onVerticalDragCancel != null) {
    gestures[VerticalDragGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
      () => new VerticalDragGestureRecognizer(debugOwner: $this),
      (VerticalDragGestureRecognizer instance) {
        instance
          ..onDown = $this.onVerticalDragDown
          ..onStart = $this.onVerticalDragStart
          ..onUpdate = $this.onVerticalDragUpdate
          ..onEnd = $this.onVerticalDragEnd
          ..onCancel = $this.onVerticalDragCancel;
      },
    );
  }

  if ($this.onHorizontalDragDown != null ||
      $this.onHorizontalDragStart != null ||
      $this.onHorizontalDragUpdate != null ||
      $this.onHorizontalDragEnd != null ||
      $this.onHorizontalDragCancel != null) {
    gestures[HorizontalDragGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<
            HorizontalDragGestureRecognizer>(
      () => new HorizontalDragGestureRecognizer(debugOwner: $this),
      (HorizontalDragGestureRecognizer instance) {
        instance
          ..onDown = $this.onHorizontalDragDown
          ..onStart = $this.onHorizontalDragStart
          ..onUpdate = $this.onHorizontalDragUpdate
          ..onEnd = $this.onHorizontalDragEnd
          ..onCancel = $this.onHorizontalDragCancel;
      },
    );
  }

  if ($this.onPanDown != null ||
      $this.onPanStart != null ||
      $this.onPanUpdate != null ||
      $this.onPanEnd != null ||
      $this.onPanCancel != null) {
    gestures[PanGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
      () => new PanGestureRecognizer(debugOwner: $this),
      (PanGestureRecognizer instance) {
        instance
          ..onDown = $this.onPanDown
          ..onStart = $this.onPanStart
          ..onUpdate = $this.onPanUpdate
          ..onEnd = $this.onPanEnd
          ..onCancel = $this.onPanCancel;
      },
    );
  }

  if ($this.onScaleStart != null ||
      $this.onScaleUpdate != null ||
      $this.onScaleEnd != null) {
    gestures[ScaleGestureRecognizer] =
        new GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      () => new ScaleGestureRecognizer(debugOwner: $this),
      (ScaleGestureRecognizer instance) {
        instance
          ..onStart = $this.onScaleStart
          ..onUpdate = $this.onScaleUpdate
          ..onEnd = $this.onScaleEnd;
      },
    );
  }

  return new RawGestureDetector(
    gestures: gestures,
    behavior: $this.behavior,
    excludeFromSemantics: $this.excludeFromSemantics,
    child: $this.child,
  );
}

/// A widget that detects gestures described by the given gesture
/// factories.
///
/// For common gestures, use a [GestureRecognizer].
/// [RawGestureDetector] is useful primarily when developing your
/// own gesture recognizers.
///
/// Configuring the gesture recognizers requires a carefully constructed map, as
/// described in [gestures] and as shown in the example below.
///
/// ## Sample code
///
/// This example shows how to hook up a [TapGestureRecognizer]. It assumes that
/// the code is being used inside a [State] object with a `_last` field that is
/// then displayed as the child of the gesture detector.
///
/// ```dart
/// new RawGestureDetector(
///   gestures: <Type, GestureRecognizerFactory>{
///     TapGestureRecognizer: new GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
///       () => new TapGestureRecognizer(),
///       (TapGestureRecognizer instance) {
///         instance
///           ..onTapDown = (TapDownDetails details) { setState(() { _last = 'down'; }); }
///           ..onTapUp = (TapUpDetails details) { setState(() { _last = 'up'; }); }
///           ..onTap = () { setState(() { _last = 'tap'; }); }
///           ..onTapCancel = () { setState(() { _last = 'cancel'; }); };
///       },
///     ),
///   },
///   child: new Container(width: 300.0, height: 300.0, color: Colors.yellow, child: new Text(_last)),
/// )
/// ```
///
/// See also:
///
///  * [GestureDetector], a less flexible but much simpler widget that does the same thing.
///  * [Listener], a widget that reports raw pointer events.
///  * [GestureRecognizer], the class that you extend to create a custom gesture recognizer.
class RawGestureDetector extends StatefulWidget {
  /// Creates a widget that detects gestures.
  ///
  /// By default, gesture detectors contribute semantic information to the tree
  /// that is used by assistive technology. This can be controlled using
  /// [excludeFromSemantics].
  const RawGestureDetector(
      {Key key,
      this.child,
      this.gestures: const <Type, GestureRecognizerFactory>{},
      this.behavior,
      this.excludeFromSemantics: false})
      : super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// The gestures that this widget will attempt to recognize.
  ///
  /// This should be a map from [GestureRecognizer] subclasses to
  /// [GestureRecognizerFactory] subclasses specialized with the same type.
  ///
  /// This value can be late-bound at layout time using
  /// [RawGestureDetectorState.replaceGestureRecognizers].
  final Map<Type, GestureRecognizerFactory> gestures;

  /// How this gesture detector should behave during hit testing.
  final HitTestBehavior behavior;

  /// Whether to exclude these gestures from the semantics tree. For
  /// example, the long-press gesture for showing a tooltip is
  /// excluded because the tooltip itself is included in the semantics
  /// tree directly and so having a gesture to show it would result in
  /// duplication of information.
  final bool excludeFromSemantics;

  @override
  RawGestureDetectorState createState() => new RawGestureDetectorState();
}

/// State for a [RawGestureDetector].
class RawGestureDetectorState extends State<RawGestureDetector> {
  Map<Type, GestureRecognizer> _recognizers = const <Type, GestureRecognizer>{};

  @override
  void initState() {
    super.initState();
    _syncAll(widget.gestures);
  }

  @override
  void didUpdateWidget(RawGestureDetector oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAll(widget.gestures);
  }

  /// This method can be called after the build phase, during the
  /// layout of the nearest descendant [RenderObjectWidget] of the
  /// gesture detector, to update the list of active gesture
  /// recognizers.
  ///
  /// The typical use case is [Scrollable]s, which put their viewport
  /// in their gesture detector, and then need to know the dimensions
  /// of the viewport and the viewport's child to determine whether
  /// the gesture detector should be enabled.
  ///
  /// The argument should follow the same conventions as
  /// [RawGestureDetector.gestures]. It acts like a temporary replacement for
  /// that value until the next build.
  void replaceGestureRecognizers(Map<Type, GestureRecognizerFactory> gestures) {
    _syncAll(gestures);
  }

  @override
  void dispose() {
    for (GestureRecognizer recognizer in _recognizers.values)
      recognizer.dispose();
    _recognizers = null;
    super.dispose();
  }

  void _syncAll(Map<Type, GestureRecognizerFactory> gestures) {
    assert(_recognizers != null);
    final Map<Type, GestureRecognizer> oldRecognizers = _recognizers;
    _recognizers = <Type, GestureRecognizer>{};
    for (Type type in gestures.keys) {
      assert(gestures[type] != null);
      assert(gestures[type]._debugAssertTypeMatches(type));
      assert(!_recognizers.containsKey(type));
      _recognizers[type] = oldRecognizers[type] ?? gestures[type].constructor();
      assert(
          _recognizers[type].runtimeType == type,
          'GestureRecognizerFactory of type $type created a GestureRecognizer of type ${_recognizers[type]
          .runtimeType}. The GestureRecognizerFactory must be specialized with the type of the class that it returns from its constructor method.');
      gestures[type].initializer(_recognizers[type]);
    }
    for (Type type in oldRecognizers.keys) {
      if (!_recognizers.containsKey(type)) oldRecognizers[type].dispose();
    }
  }

  void _handlePointerDown(PointerDownEvent event) {
    assert(_recognizers != null);
    for (GestureRecognizer recognizer in _recognizers.values)
      recognizer.addPointer(event);
  }

  HitTestBehavior get _defaultBehavior {
    return widget.child == null
        ? HitTestBehavior.translucent
        : HitTestBehavior.deferToChild;
  }

  @override
  Widget build(BuildContext context) {
    Widget result = new Listener(
        onPointerDown: _handlePointerDown,
        behavior: widget.behavior ?? _defaultBehavior,
        child: widget.child);
    return result;
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    if (_recognizers == null) {
      description.add(new DiagnosticsNode.message('DISPOSED'));
    } else {
      final List<String> gestures = _recognizers.values
          .map<String>(
              (GestureRecognizer recognizer) => recognizer.debugDescription)
          .toList();
      description.add(new IterableProperty<String>('gestures', gestures,
          ifEmpty: '<none>'));
      description.add(new IterableProperty<GestureRecognizer>(
          'recognizers', _recognizers.values,
          level: DiagnosticLevel.fine));
    }
    description.add(new EnumProperty<HitTestBehavior>(
        'behavior', widget.behavior,
        defaultValue: null));
  }
}
