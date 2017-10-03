// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/ui.dart' as ui;

import 'box.dart';
import 'debug.dart';
import 'object.dart';
import 'view.dart';

export 'package:flutter/gestures.dart' show HitTestResult;

/// The glue between the render tree and the Flutter engine.
abstract class RendererBinding extends SchedulerBinding
    implements ServicesBinding, HitTestable {
  /// FLUR: Copied from ServicesBinding
  static final String _licenseSeparator = '\n' + ('-' * 80) + '\n';

  /// FLUR: Copied from ServicesBinding
  Stream<LicenseEntry> _addLicenses() async* {
    final String rawLicenses =
        await rootBundle.loadString('LICENSE', cache: false);
    final List<String> licenses = rawLicenses.split(_licenseSeparator);
    for (String license in licenses) {
      final int split = license.indexOf('\n\n');
      if (split >= 0) {
        yield new LicenseEntryWithLineBreaks(
            license.substring(0, split).split('\n'),
            license.substring(split + 2));
      } else {
        yield new LicenseEntryWithLineBreaks(const <String>[], license);
      }
    }
  }

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;

    /// FLUR: Copied from ServicesBinding
    ui.window..onPlatformMessage = BinaryMessages.handlePlatformMessage;
    LicenseRegistry.addLicense(_addLicenses);
  }

  /// The current [RendererBinding], if one has been created.
  static RendererBinding get instance => _instance;
  static RendererBinding _instance;

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();

    assert(() {
      // these service extensions only work in checked mode
      registerBoolServiceExtension(
          name: 'debugPaint',
          getter: () async => debugPaintSizeEnabled,
          setter: (bool value) {
            if (debugPaintSizeEnabled == value) return new Future<Null>.value();
            debugPaintSizeEnabled = value;
            return _forceRepaint();
          });
      registerBoolServiceExtension(
          name: 'debugPaintBaselinesEnabled',
          getter: () async => debugPaintBaselinesEnabled,
          setter: (bool value) {
            if (debugPaintBaselinesEnabled == value)
              return new Future<Null>.value();
            debugPaintBaselinesEnabled = value;
            return _forceRepaint();
          });
      registerBoolServiceExtension(
          name: 'repaintRainbow',
          getter: () async => debugRepaintRainbowEnabled,
          setter: (bool value) {
            final bool repaint = debugRepaintRainbowEnabled && !value;
            debugRepaintRainbowEnabled = value;
            if (repaint) return _forceRepaint();
            return new Future<Null>.value();
          });
      return true;
    }());

    registerSignalServiceExtension(
        name: 'debugDumpRenderTree',
        callback: () {
          debugDumpRenderTree();
          return debugPrintDone;
        });

    registerSignalServiceExtension(
        name: 'debugDumpLayerTree',
        callback: () {
          debugDumpLayerTree();
          return debugPrintDone;
        });

    registerSignalServiceExtension(
        name: 'debugDumpSemanticsTreeInTraversalOrder',
        callback: () {
          debugDumpSemanticsTree(DebugSemanticsDumpOrder.traversal);
          return debugPrintDone;
        });

    registerSignalServiceExtension(
        name: 'debugDumpSemanticsTreeInInverseHitTestOrder',
        callback: () {
          debugDumpSemanticsTree(DebugSemanticsDumpOrder.inverseHitTest);
          return debugPrintDone;
        });

    registerStringServiceExtension(
        // ext.flutter.evict value=foo.png will cause foo.png to be evicted from the rootBundle cache
        // and cause the entire image cache to be cleared. This is used by hot reload mode to clear
        // out the cache of resources that have changed.
        // TODO(ianh): find a way to only evict affected images, not all images
        name: 'evict',
        getter: () async => '',
        setter: (String value) async {
          rootBundle.evict(value);
          imageCache.clear();
        });
  }

  /// Returns a [ViewConfiguration] configured for the [RenderView] based on the
  /// current environment.
  ///
  /// This is called during construction and also in response to changes to the
  /// system metrics.
  ///
  /// Bindings can override this method to change what size or device pixel
  /// ratio the [RenderView] will use. For example, the testing framework uses
  /// this to force the display into 800x600 when a test is run on the device
  /// using `flutter run`.
  ViewConfiguration createViewConfiguration() {
    final double devicePixelRatio = ui.window.devicePixelRatio;
    return new ViewConfiguration(
      size: ui.window.physicalSize / devicePixelRatio,
      devicePixelRatio: devicePixelRatio,
    );
  }

  @override
  void hitTest(HitTestResult result, Offset position) {}

  Future<Null> _forceRepaint() {
    return endOfFrame;
  }
}

/// Prints a textual representation of the entire render tree.
void debugDumpRenderTree() {}

/// Prints a textual representation of the entire layer tree.
void debugDumpLayerTree() {}

/// Prints a textual representation of the entire semantics tree.
/// This will only work if there is a semantics client attached.
/// Otherwise, a notice that no semantics are available will be printed.
///
/// The order in which the children of a [SemanticsNode] will be printed is
/// controlled by the [childOrder] parameter.
void debugDumpSemanticsTree(DebugSemanticsDumpOrder childOrder) {}

/// A concrete binding for applications that use the Rendering framework
/// directly. This is the glue that binds the framework to the Flutter engine.
///
/// You would only use this binding if you are writing to the
/// rendering layer directly. If you are writing to a higher-level
/// library, such as the Flutter Widgets library, then you would use
/// that layer's binding.
///
/// See also [BindingBase].
class RenderingFlutterBinding extends RendererBinding
    implements GestureBinding {
  /// Creates a binding for the rendering layer.
  ///
  /// The `root` render box is attached directly to the [renderView] and is
  /// given constraints that require it to fill the window.
  RenderingFlutterBinding({RenderBox root});

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    ui.window.onPointerDataPacket = _handlePointerDataPacket;
  }

  @override
  void unlocked() {
    super.unlocked();
    _flushPointerEventQueue();
  }

  /// The singleton instance of this object.
  static GestureBinding get instance => _instance;
  static GestureBinding _instance;

  final Queue<PointerEvent> _pendingPointerEvents = new Queue<PointerEvent>();

  void _handlePointerDataPacket(ui.PointerDataPacket packet) {
    // We convert pointer data to logical pixels so that e.g. the touch slop can be
    // defined in a device-independent manner.
    _pendingPointerEvents.addAll(
        PointerEventConverter.expand(packet.data, ui.window.devicePixelRatio));
    if (!locked) _flushPointerEventQueue();
  }

  /// Dispatch a [PointerCancelEvent] for the given pointer soon.
  ///
  /// The pointer event will be dispatch before the next pointer event and
  /// before the end of the microtask but not within this function call.
  void cancelPointer(int pointer) {
    if (_pendingPointerEvents.isEmpty && !locked)
      scheduleMicrotask(_flushPointerEventQueue);
    _pendingPointerEvents.addFirst(new PointerCancelEvent(pointer: pointer));
  }

  void _flushPointerEventQueue() {
    assert(!locked);
    while (_pendingPointerEvents.isNotEmpty)
      _handlePointerEvent(_pendingPointerEvents.removeFirst());
  }

  /// A router that routes all pointer events received from the engine.
  final PointerRouter pointerRouter = new PointerRouter();

  /// The gesture arenas used for disambiguating the meaning of sequences of
  /// pointer events.
  final GestureArenaManager gestureArena = new GestureArenaManager();

  /// State for all pointers which are currently down.
  ///
  /// The state of hovering pointers is not tracked because that would require
  /// hit-testing on every frame.
  final Map<int, HitTestResult> _hitTests = <int, HitTestResult>{};

  void _handlePointerEvent(PointerEvent event) {
    assert(!locked);
    HitTestResult result;
    if (event is PointerDownEvent) {
      assert(!_hitTests.containsKey(event.pointer));
      result = new HitTestResult();
      hitTest(result, event.position);
      _hitTests[event.pointer] = result;
      assert(() {
        if (debugPrintHitTestResults) debugPrint('$event: $result');
        return true;
      }());
    } else if (event is PointerUpEvent || event is PointerCancelEvent) {
      result = _hitTests.remove(event.pointer);
    } else if (event.down) {
      result = _hitTests[event.pointer];
    } else {
      return; // We currently ignore add, remove, and hover move events.
    }
    if (result != null) dispatchEvent(event, result);
  }

  /// Determine which [HitTestTarget] objects are located at a given position.
  @override // from HitTestable
  void hitTest(HitTestResult result, Offset position) {
    result.add(new HitTestEntry(this));
  }

  /// Dispatch an event to a hit test result's path.
  ///
  /// This sends the given event to every [HitTestTarget] in the entries
  /// of the given [HitTestResult], and catches exceptions that any of
  /// the handlers might throw. The `result` argument must not be null.
  @override // from HitTestDispatcher
  void dispatchEvent(PointerEvent event, HitTestResult result) {
    assert(!locked);
    assert(result != null);
    for (HitTestEntry entry in result.path) {
      try {
        entry.target.handleEvent(event, entry);
      } catch (exception, stack) {
        FlutterError
            .reportError(new FlutterErrorDetailsForPointerEventDispatcher(
                exception: exception,
                stack: stack,
                library: 'gesture library',
                context: 'while dispatching a pointer event',
                event: event,
                hitTestEntry: entry,
                informationCollector: (StringBuffer information) {
                  information.writeln('Event:');
                  information.writeln('  $event');
                  information.writeln('Target:');
                  information.write('  ${entry.target}');
                }));
      }
    }
  }

  @override // from HitTestTarget
  void handleEvent(PointerEvent event, HitTestEntry entry) {
    pointerRouter.route(event);
    if (event is PointerDownEvent) {
      gestureArena.close(event.pointer);
    } else if (event is PointerUpEvent) {
      gestureArena.sweep(event.pointer);
    }
  }
}

/// Variant of [FlutterErrorDetails] with extra fields for the gesture
/// library's binding's pointer event dispatcher ([GestureBinding.dispatchEvent]).
///
/// See also [FlutterErrorDetailsForPointerRouter], which is also used by the
/// gesture library.
class FlutterErrorDetailsForPointerEventDispatcher extends FlutterErrorDetails {
  /// Creates a [FlutterErrorDetailsForPointerEventDispatcher] object with the given
  /// arguments setting the object's properties.
  ///
  /// The gesture library calls this constructor when catching an exception
  /// that will subsequently be reported using [FlutterError.onError].
  const FlutterErrorDetailsForPointerEventDispatcher(
      {dynamic exception,
      StackTrace stack,
      String library,
      String context,
      this.event,
      this.hitTestEntry,
      InformationCollector informationCollector,
      bool silent: false})
      : super(
            exception: exception,
            stack: stack,
            library: library,
            context: context,
            informationCollector: informationCollector,
            silent: silent);

  /// The pointer event that was being routed when the exception was raised.
  final PointerEvent event;

  /// The hit test result entry for the object whose handleEvent method threw
  /// the exception.
  ///
  /// The target object itself is given by the [HitTestEntry.target] property of
  /// the hitTestEntry object.
  final HitTestEntry hitTestEntry;
}
