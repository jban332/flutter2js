// Copyright 2017 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _kBackGestureWidth = 20.0;
const double _kMinFlingVelocity = 1.0; // Screen widths per second.

// Fractional offset from offscreen to the right to fully on screen.
final FractionalOffsetTween _kRightMiddleTween = new FractionalOffsetTween(
  begin: FractionalOffset.topRight,
  end: FractionalOffset.topLeft,
);

// Fractional offset from fully on screen to 1/3 offscreen to the left.
final FractionalOffsetTween _kMiddleLeftTween = new FractionalOffsetTween(
  begin: FractionalOffset.topLeft,
  end: const FractionalOffset(-1.0 / 3.0, 0.0),
);

// Fractional offset from offscreen below to fully on screen.
final FractionalOffsetTween _kBottomUpTween = new FractionalOffsetTween(
  begin: FractionalOffset.bottomLeft,
  end: FractionalOffset.topLeft,
);

/// A modal route that replaces the entire screen with an iOS transition.
///
/// The page slides in from the right and exits in reverse. The page also shifts
/// to the left in parallax when another page enters to cover it.
///
/// The page slides in from the bottom and exits in reverse with no parallax
/// effect for fullscreen dialogs.
///
/// By default, when a modal route is replaced by another, the previous route
/// remains in memory. To free all the resources when this is not necessary, set
/// [maintainState] to false.
///
/// The type `T` specifies the return type of the route which can be supplied as
/// the route is popped from the stack via [Navigator.pop] when an optional
/// `result` can be provided.
///
/// See also:
///
///  * [MaterialPageRoute] for an adaptive [PageRoute] that uses a platform
///    appropriate transition.
class CupertinoPageRoute<T> extends PageRoute<T> {
  /// Creates a page route for use in an iOS designed app.
  ///
  /// The [builder], [settings], [maintainState], and [fullscreenDialog]
  /// arguments must not be null.
  CupertinoPageRoute({
    @required this.builder,
    RouteSettings settings: const RouteSettings(),
    this.maintainState: true,
    bool fullscreenDialog: false,
    this.hostRoute,
  })
      : super(settings: settings, fullscreenDialog: fullscreenDialog);

  /// Builds the primary contents of the route.
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  /// The route that owns this one.
  ///
  /// The [MaterialPageRoute] creates a [CupertinoPageRoute] to handle iOS-style
  /// navigation. When this happens, the [MaterialPageRoute] is the [hostRoute]
  /// of this [CupertinoPageRoute].
  ///
  /// The [hostRoute] is responsible for calling [dispose] on the route. When
  /// there is a [hostRoute], the [CupertinoPageRoute] must not be [install]ed.
  final PageRoute<T> hostRoute;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 350);

  @override
  Color get barrierColor => null;

  @override
  bool canTransitionFrom(TransitionRoute<dynamic> previousRoute) {
    return previousRoute is CupertinoPageRoute;
  }

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return nextRoute is CupertinoPageRoute && !nextRoute.fullscreenDialog;
  }

  @override
  void install(OverlayEntry insertionPoint) {
    assert(() {
      if (hostRoute == null) return true;
      throw new FlutterError(
          'Cannot install a subsidiary route (one with a hostRoute).\n'
              'This route ($this) cannot be installed, because it has a host route ($hostRoute).');
    });
    super.install(insertionPoint);
  }

  /// Whether a pop gesture is currently underway.
  ///
  /// This starts returning true when the [startPopGesture] method returns a new
  /// [NavigationGestureController]. It returns false if that has not yet
  /// occurred or if the most recent such gesture has completed.
  ///
  /// See also:
  ///
  ///  * [popGestureEnabled], which returns whether a pop gesture is appropriate
  ///    in the first place.
  bool get popGestureInProgress => false;

  /// Whether a pop gesture will be considered acceptable by [startPopGesture].
  ///
  /// This returns true if the user can edge-swipe to a previous route,
  /// otherwise false.
  ///
  /// This will return false if [popGestureInProgress] is true.
  ///
  /// This should only be used between frames, not during build.
  bool get popGestureEnabled {
    final PageRoute<T> route = hostRoute ?? this;
    // If there's nothing to go back to, then obviously we don't support
    // the back gesture.
    if (route.isFirst) return false;
    // If the route wouldn't actually pop if we popped it, then the gesture
    // would be really confusing (or would skip internal routes), so disallow it.
    if (route.willHandlePopInternally) return false;
    // If attempts to dismiss this route might be vetoed such as in a page
    // with forms, then do not allow the user to dismiss the route with a swipe.
    if (route.hasScopedWillPopCallback) return false;
    // Fullscreen dialogs aren't dismissable by back swipe.
    if (fullscreenDialog) return false;
    // If we're in an animation already, we cannot be manually swiped.
    if (route.controller.status != AnimationStatus.completed) return false;
    // If we're in a gesture already, we cannot start another.
    if (popGestureInProgress) return false;
    // Looks like a back gesture would be welcome!
    return true;
  }

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final Widget result = builder(context);
    assert(() {
      if (result == null) {
        throw new FlutterError(
            'The builder for route "${settings.name}" returned null.\n'
                'Route builders must never return null.');
      }
      return true;
    });
    return result;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (fullscreenDialog) {
      return new CupertinoFullscreenDialogTransition(
        animation: animation,
        child: child,
      );
    } else {
      return new CupertinoPageTransition(
        primaryRouteAnimation: animation,
        secondaryRouteAnimation: secondaryAnimation,
        // In the middle of a back gesture drag, let the transition be linear to
        // match finger motions.
        linearTransition: popGestureInProgress,
        child: child,
      );
    }
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

/// Provides an iOS-style page transition animation.
///
/// The page slides in from the right and exits in reverse. It also shifts to the left in
/// a parallax motion when another page enters to cover it.
class CupertinoPageTransition extends StatelessWidget {
  /// Creates an iOS-style page transition.
  ///
  ///  * `primaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when this screen is being pushed.
  ///  * `secondaryRouteAnimation` is a linear route animation from 0.0 to 1.0
  ///    when another screen is being pushed on top of this one.
  ///  * `linearTransition` is whether to perform primary transition linearly.
  ///    Used to precisely track back gesture drags.
  CupertinoPageTransition({
    Key key,
    @required Animation<double> primaryRouteAnimation,
    @required Animation<double> secondaryRouteAnimation,
    @required this.child,
    bool linearTransition,
  })
      : _primaryPositionAnimation = linearTransition
      ? _kRightMiddleTween.animate(primaryRouteAnimation)
      : _kRightMiddleTween.animate(new CurvedAnimation(
    parent: primaryRouteAnimation,
    curve: Curves.easeOut,
    reverseCurve: Curves.easeIn,
  )),
        _secondaryPositionAnimation =
        _kMiddleLeftTween.animate(new CurvedAnimation(
          parent: secondaryRouteAnimation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        )),
        super(key: key);

  // When this page is coming in to cover another page.
  final Animation<FractionalOffset> _primaryPositionAnimation;

  // When this page is becoming covered by another page.
  final Animation<FractionalOffset> _secondaryPositionAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // TODO(ianh): tell the transform to be un-transformed for hit testing
    // but not while being controlled by a gesture.
    return new SlideTransition(
      position: _secondaryPositionAnimation,
      child: new SlideTransition(
        position: _primaryPositionAnimation,
        child: child,
      ),
    );
  }
}

/// An iOS-style transition used for summoning fullscreen dialogs.
///
/// For example, used when creating a new calendar event by bringing in the next
/// screen from the bottom.
class CupertinoFullscreenDialogTransition extends StatelessWidget {
  /// Creates an iOS-style transition used for summoning fullscreen dialogs.
  CupertinoFullscreenDialogTransition({
    Key key,
    @required Animation<double> animation,
    @required this.child,
  })
      : _positionAnimation = _kBottomUpTween.animate(new CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  )),
        super(key: key);

  final Animation<FractionalOffset> _positionAnimation;

  /// The widget below this widget in the tree.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new SlideTransition(
      position: _positionAnimation,
      child: child,
    );
  }
}
