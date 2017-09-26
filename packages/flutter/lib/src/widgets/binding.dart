// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/ui.dart' show AppLifecycleState, Locale;

import 'app.dart';
import 'focus_manager.dart';
import 'framework.dart';

export 'package:flutter/ui.dart' show AppLifecycleState, Locale;

export 'binding_run_app.dart';

/// Interface for classes that register with the Widgets layer binding.
///
/// See [WidgetsBinding.addObserver] and [WidgetsBinding.removeObserver].
///
/// This class can be extended directly, to get default behaviors for all of the
/// handlers, or can used with the `implements` keyword, in which case all the
/// handlers must be implemented (and the analyzer will list those that have
/// been omitted).
///
/// ## Sample code
///
/// This [StatefulWidget] implements the parts of the [State] and
/// [WidgetsBindingObserver] protocols necessary to react to application
/// lifecycle messages. See [didChangeAppLifecycleState].
///
/// ```dart
/// class AppLifecycleReactor extends StatefulWidget {
///   const AppLifecycleReactor({ Key key }) : super(key: key);
///
///   @override
///   _AppLifecycleReactorState createState() => new _AppLifecycleReactorState();
/// }
///
/// class _AppLifecycleReactorState extends State<AppLifecycleReactor> with WidgetsBindingObserver {
///   @override
///   void initState() {
///     super.initState();
///     WidgetsBinding.instance.addObserver(this);
///   }
///
///   @override
///   void dispose() {
///     WidgetsBinding.instance.removeObserver(this);
///     super.dispose();
///   }
///
///   AppLifecycleState _notification;
///
///   @override
///   void didChangeAppLifecycleState(AppLifecycleState state) {
///     setState(() { _notification = state; });
///   }
///
///   @override
///   Widget build(BuildContext context) {
///     return new Text('Last notification: $_notification');
///   }
/// }
/// ```
///
/// To respond to other notifications, replace the [didChangeAppLifecycleState]
/// method above with other methods from this class.
abstract class WidgetsBindingObserver {
  /// Called when the system tells the app to pop the current route.
  /// For example, on Android, this is called when the user presses
  /// the back button.
  ///
  /// Observers are notified in registration order until one returns
  /// true. If none return true, the application quits.
  ///
  /// Observers are expected to return true if they were able to
  /// handle the notification, for example by closing an active dialog
  /// box, and false otherwise. The [WidgetsApp] widget uses this
  /// mechanism to notify the [Navigator] widget that it should pop
  /// its current route if possible.
  Future<bool> didPopRoute() => new Future<bool>.value(false);

  /// Called when the host tells the app to push a new route onto the
  /// navigator.
  ///
  /// Observers are expected to return true if they were able to
  /// handle the notification.  Observers are notified in registration
  /// order until one returns true.
  Future<bool> didPushRoute(String route) => new Future<bool>.value(false);

  /// Called when the application's dimensions change. For example,
  /// when a phone is rotated.
  ///
  /// ## Sample code
  ///
  /// This [StatefulWidget] implements the parts of the [State] and
  /// [WidgetsBindingObserver] protocols necessary to react when the device is
  /// rotated (or otherwise changes dimensions).
  ///
  /// ```dart
  /// class MetricsReactor extends StatefulWidget {
  ///   const MetricsReactor({ Key key }) : super(key: key);
  ///
  ///   @override
  ///   _MetricsReactorState createState() => new _MetricsReactorState();
  /// }
  ///
  /// class _MetricsReactorState extends State<MetricsReactor> with WidgetsBindingObserver {
  ///   @override
  ///   void initState() {
  ///     super.initState();
  ///     WidgetsBinding.instance.addObserver(this);
  ///   }
  ///
  ///   @override
  ///   void dispose() {
  ///     WidgetsBinding.instance.removeObserver(this);
  ///     super.dispose();
  ///   }
  ///
  ///   Size _lastSize;
  ///
  ///   @override
  ///   void didChangeMetrics() {
  ///     setState(() { _lastSize = ui.window.physicalSize; });
  ///   }
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return new Text('Last size: $_lastSize');
  ///   }
  /// }
  /// ```
  ///
  /// In general, this is unnecessary as the layout system takes care of
  /// automatically recomputing the application geometry when the application
  /// size changes.
  ///
  /// See also:
  ///
  ///  * [MediaQuery.of], which provides a similar service with less
  ///    boilerplate.
  void didChangeMetrics() {}

  /// Called when the system tells the app that the user's locale has
  /// changed. For example, if the user changes the system language
  /// settings.
  void didChangeLocale(Locale locale) {}

  /// Called when the system puts the app in the background or returns
  /// the app to the foreground.
  ///
  /// An example of implementing this method is provided in the class-level
  /// documentation for the [WidgetsBindingObserver] class.
  void didChangeAppLifecycleState(AppLifecycleState state) {}

  /// Called when the system is running low on memory.
  void didHaveMemoryPressure() {}
}

/// The glue between the widgets layer and the Flutter engine.
abstract class WidgetsBinding extends BindingBase {
  // This class is intended to be used as a mixin, and should not be
  // extended directly.
  factory WidgetsBinding._() => null;

  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
  }

  /// The current [WidgetsBinding], if one has been created.
  ///
  /// If you need the binding to be constructed before calling [runApp],
  /// you can ensure a Widget binding has been constructed by calling the
  /// `WidgetsFlutterBinding.ensureInitialized()` function.
  static WidgetsBinding get instance => _instance;
  static WidgetsBinding _instance;

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();
  }

  /// The object in charge of the focus tree.
  ///
  /// Rarely used directly. Instead, consider using [FocusScope.of] to obtain
  /// the [FocusScopeNode] for a given [BuildContext].
  ///
  /// See [FocusManager] for more details.
  final FocusManager focusManager = new FocusManager();

  final List<WidgetsBindingObserver> _observers = <WidgetsBindingObserver>[];

  /// Registers the given object as a binding observer. Binding
  /// observers are notified when various application events occur,
  /// for example when the system locale changes. Generally, one
  /// widget in the widget tree registers itself as a binding
  /// observer, and converts the system state into inherited widgets.
  ///
  /// For example, the [WidgetsApp] widget registers as a binding
  /// observer and passes the screen size to a [MediaQuery] widget
  /// each time it is built, which enables other widgets to use the
  /// [MediaQuery.of] static method and (implicitly) the
  /// [InheritedWidget] mechanism to be notified whenever the screen
  /// size changes (e.g. whenever the screen rotates).
  ///
  /// See also:
  ///
  ///  * [removeObserver], to release the resources reserved by this method.
  ///  * [WidgetsBindingObserver], which has an example of using this method.
  void addObserver(WidgetsBindingObserver observer) => _observers.add(observer);

  /// Unregisters the given observer. This should be used sparingly as
  /// it is relatively expensive (O(N) in the number of registered
  /// observers).
  ///
  /// See also:
  ///
  ///  * [addObserver], for the method that adds observers in the first place.
  ///  * [WidgetsBindingObserver], which has an example of using this method.
  bool removeObserver(WidgetsBindingObserver observer) =>
      _observers.remove(observer);

  /// Notify all the observers that the locale has changed (using
  /// [WidgetsBindingObserver.didChangeLocale]), giving them the
  /// `locale` argument.
  void dispatchLocaleChanged(Locale locale) {
    for (WidgetsBindingObserver observer in _observers)
      observer.didChangeLocale(locale);
  }

  /// Called when the system pops the current route.
  ///
  /// This first notifies the binding observers (using
  /// [WidgetsBindingObserver.didPopRoute]), in registration order,
  /// until one returns true, meaning that it was able to handle the
  /// request (e.g. by closing a dialog box). If none return true,
  /// then the application is shut down.
  ///
  /// [WidgetsApp] uses this in conjunction with a [Navigator] to
  /// cause the back button to close dialog boxes, return from modal
  /// pages, and so forth.
  Future<Null> handlePopRoute() async {
    for (WidgetsBindingObserver observer
    in new List<WidgetsBindingObserver>.from(_observers)) {
      if (await observer.didPopRoute()) return;
    }
  }

  /// Called when the host tells the app to push a new route onto the
  /// navigator.
  Future<Null> handlePushRoute(String route) async {
    for (WidgetsBindingObserver observer
    in new List<WidgetsBindingObserver>.from(_observers)) {
      if (await observer.didPushRoute(route)) return;
    }
  }

  /// Called when the application lifecycle state changes.
  ///
  /// Notifies all the observers using
  /// [WidgetsBindingObserver.didChangeAppLifecycleState].
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    for (WidgetsBindingObserver observer in _observers)
      observer.didChangeAppLifecycleState(state);
  }

  int _deferFirstFrameReportCount = 0;

  /// Tell the framework not to report the frame it is building as a "useful"
  /// first frame until there is a corresponding call to [allowFirstFrameReport].
  ///
  /// This is used by [WidgetsApp] to report the first frame.
  //
  // TODO(ianh): This method should only be available in debug and profile modes.
  void deferFirstFrameReport() {
    assert(_deferFirstFrameReportCount >= 0);
    _deferFirstFrameReportCount += 1;
  }

  /// When called after [deferFirstFrameReport]: tell the framework to report
  /// the frame it is building as a "useful" first frame.
  ///
  /// This method may only be called once for each corresponding call
  /// to [deferFirstFrameReport].
  ///
  /// This is used by [WidgetsApp] to report the first frame.
  //
  // TODO(ianh): This method should only be available in debug and profile modes.
  void allowFirstFrameReport() {
    assert(_deferFirstFrameReportCount >= 1);
    _deferFirstFrameReportCount -= 1;
  }

  /// Whether we are currently in a frame. This is used to verify
  /// that frames are not scheduled redundantly.
  ///
  /// This is public so that test frameworks can change it.
  ///
  /// This flag is not used in release builds.
  @protected
  bool debugBuildingDirtyElements = false;

  /// The [Element] that is at the root of the hierarchy (and which wraps the
  /// [RenderView] object at the root of the rendering hierarchy).
  ///
  /// This is initialized the first time [runApp] is called.
  Element get renderViewElement => _renderViewElement;
  Element _renderViewElement;

  /// Takes a widget and attaches it to the [renderViewElement], creating it if
  /// necessary.
  ///
  /// This is called by [runApp] to configure the widget tree.
  ///
  /// See also [RenderObjectToWidgetAdapter.attachToRenderTree].
  void attachRootWidget(Widget rootWidget) {}

  @override
  Future<Null> performReassemble() {
    deferFirstFrameReport();
    // TODO(hansmuller): eliminate the value variable after analyzer bug
    // https://github.com/flutter/flutter/issues/11646 is fixed.
    final Future<Null> value = super.performReassemble();
    return value.then((Null _) {
      allowFirstFrameReport();
    });
  }
}

/// Print a string representation of the currently running app.
void debugDumpApp() {}

/// A concrete binding for applications based on the Widgets framework.
/// This is the glue that binds the framework to the Flutter engine.
class WidgetsFlutterBinding extends BindingBase {
  /// Returns an instance of the [WidgetsBinding], creating and
  /// initializing it if necessary. If one is created, it will be a
  /// [WidgetsFlutterBinding]. If one was previously initialized, then
  /// it will at least implement [WidgetsBinding].
  ///
  /// You only need to call this method if you need the binding to be
  /// initialized before calling [runApp].
  ///
  /// In the `flutter_test` framework, [testWidgets] initializes the
  /// binding instance to a [TestWidgetsFlutterBinding], not a
  /// [WidgetsFlutterBinding].
  static WidgetsBinding ensureInitialized() {
    if (WidgetsBinding.instance == null) new WidgetsFlutterBinding();
    return WidgetsBinding.instance;
  }
}
