// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flur/flur.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/ui.dart' show AppLifecycleState, Locale;
import 'package:flutter/ui.dart' as ui show window;

import 'app.dart';
import 'focus_manager.dart';
import 'framework.dart';

export 'package:flutter/ui.dart' show AppLifecycleState, Locale;

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
abstract class WidgetsBinding extends RendererBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;
    ui.window.onLocaleChanged = handleLocaleChanged;
    SystemChannels.navigation.setMethodCallHandler(_handleNavigationInvocation);
    SystemChannels.lifecycle.setMessageHandler(_handleLifecycleMessage);
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

    registerSignalServiceExtension(
        name: 'debugDumpApp',
        callback: () {
          debugDumpApp();
          return debugPrintDone;
        });

    registerBoolServiceExtension(
        name: 'showPerformanceOverlay',
        getter: () =>
            new Future<bool>.value(WidgetsApp.showPerformanceOverlayOverride),
        setter: (bool value) {});

    registerBoolServiceExtension(
        name: 'debugAllowBanner',
        getter: () =>
            new Future<bool>.value(WidgetsApp.debugAllowBannerOverride),
        setter: (bool value) {});

    registerBoolServiceExtension(
        name: 'debugWidgetInspector',
        getter: () async => WidgetsApp.debugShowWidgetInspectorOverride,
        setter: (bool value) {});
  }

  /// The [BuildOwner] in charge of executing the build pipeline for the
  /// widget tree rooted at this binding.
  BuildOwner get buildOwner => _buildOwner;
  final BuildOwner _buildOwner = new BuildOwner();

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

  /// Called when the system locale changes.
  ///
  /// Calls [dispatchLocaleChanged] to notify the binding observers.
  ///
  /// See [Window.onLocaleChanged].
  void handleLocaleChanged() {
    dispatchLocaleChanged(ui.window.locale);
  }

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
    SystemNavigator.pop();
  }

  /// Called when the host tells the app to push a new route onto the
  /// navigator.
  Future<Null> handlePushRoute(String route) async {
    for (WidgetsBindingObserver observer
        in new List<WidgetsBindingObserver>.from(_observers)) {
      if (await observer.didPushRoute(route)) return;
    }
  }

  Future<dynamic> _handleNavigationInvocation(MethodCall methodCall) {
    switch (methodCall.method) {
      case 'popRoute':
        return handlePopRoute();
      case 'pushRoute':
        return handlePushRoute(methodCall.arguments);
    }
    return new Future<Null>.value();
  }

  /// Called when the application lifecycle state changes.
  ///
  /// Notifies all the observers using
  /// [WidgetsBindingObserver.didChangeAppLifecycleState].
  void handleAppLifecycleStateChanged(AppLifecycleState state) {
    for (WidgetsBindingObserver observer in _observers)
      observer.didChangeAppLifecycleState(state);
  }

  Future<String> _handleLifecycleMessage(String message) async {
    switch (message) {
      case 'AppLifecycleState.paused':
        handleAppLifecycleStateChanged(AppLifecycleState.paused);
        break;
      case 'AppLifecycleState.resumed':
        handleAppLifecycleStateChanged(AppLifecycleState.resumed);
        break;
      case 'AppLifecycleState.inactive':
        handleAppLifecycleStateChanged(AppLifecycleState.inactive);
        break;
      case 'AppLifecycleState.suspending':
        handleAppLifecycleStateChanged(AppLifecycleState.suspending);
        break;
    }
    return null;
  }

  /// Whether we are currently in a frame. This is used to verify
  /// that frames are not scheduled redundantly.
  ///
  /// This is public so that test frameworks can change it.
  ///
  /// This flag is not used in release builds.
  @protected
  bool debugBuildingDirtyElements = false;
}

/// Inflate the given widget and attach it to the screen.
///
/// The widget is given constraints during layout that force it to fill the
/// entire screen. If you wish to align your widget to one side of the screen
/// (e.g., the top), consider using the [Align] widget. If you wish to center
/// your widget, you can also use the [Center] widget
///
/// Calling [runApp] again will detach the previous root widget from the screen
/// and attach the given widget in its place. The new widget tree is compared
/// against the previous widget tree and any differences are applied to the
/// underlying render tree, similar to what happens when a [StatefulWidget]
/// rebuilds after calling [State.setState].
///
/// Initializes the binding using [WidgetsFlutterBinding] if necessary.
///
/// See also:
///
/// * [WidgetsBinding.attachRootWidget], which creates the root widget for the
///   widget hierarchy.
/// * [RenderObjectToWidgetAdapter.attachToRenderTree], which creates the root
///   element for the element hierarchy.
/// * [WidgetsBinding.handleBeginFrame], which pumps the widget pipeline to
///   ensure the widget, element, and render trees are all built.
void runApp(Widget app) {
  flur.runAppInFlur(app);
}

/// Print a string representation of the currently running app.
void debugDumpApp() {}

/// A concrete binding for applications based on the Widgets framework.
/// This is the glue that binds the framework to the Flutter engine.
class WidgetsFlutterBinding extends WidgetsBinding {
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
