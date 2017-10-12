// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/ui.dart' as ui show window;

import 'view.dart';

export 'package:flutter/gestures.dart' show HitTestResult;

/// The glue between the render tree and the Flutter engine.
abstract class RendererBinding extends SchedulerBinding
    implements ServicesBinding {
  @override
  void initInstances() {
    super.initInstances();
    _instance = this;

    ui.window..onPlatformMessage = BinaryMessages.handlePlatformMessage;
    LicenseRegistry.addLicense(_addLicenses);
  }

  /// The current [RendererBinding], if one has been created.
  static RendererBinding get instance => _instance;
  static RendererBinding _instance;

  @override
  void initServiceExtensions() {
    super.initServiceExtensions();
  }

  /// Called when the platform text scale factor changes.
  ///
  /// See [Window.onTextScaleFactorChanged].
  void handleTextScaleFactorChanged() {}

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

  /// Schedule a frame to run as soon as possible, rather than waiting for
  /// the engine to request a frame.
  ///
  /// This is used during application startup so that the first frame (which is
  /// likely to be quite expensive) gets a few extra milliseconds to run.
  void scheduleWarmUpFrame() {
    // We use timers here to ensure that microtasks flush in between.
    //
    // We call resetEpoch after this frame so that, in the hot reload case, the
    // very next frame pretends to have occurred immediately after this warm-up
    // frame. The warm-up frame's timestamp will typically be far in the past
    // (the time of the last real frame), so if we didn't reset the epoch we
    // would see a sudden jump from the old time in the warm-up frame to the new
    // time in the "real" frame. The biggest problem with this is that implicit
    // animations end up being triggered at the old time and then skipping every
    // frame and finishing in the new time.
    Timer.run(() {
      handleBeginFrame(null);
    });
    Timer.run(() {
      handleDrawFrame();
      resetEpoch();
    });
  }

  static final String _licenseSeparator = '\n' + ('-' * 80) + '\n';

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
}

/// A concrete binding for applications that use the Rendering framework
/// directly. This is the glue that binds the framework to the Flutter engine.
///
/// You would only use this binding if you are writing to the
/// rendering layer directly. If you are writing to a higher-level
/// library, such as the Flutter Widgets library, then you would use
/// that layer's binding.
///
/// See also [BindingBase].
class RenderingFlutterBinding extends RendererBinding with GestureBinding {
  initInstances() {
    super.initInstances();
    initGestureBinding();
  }

  // FLUR: None of the methods are appropriate.

  /// A router that routes all pointer events received from the engine.
  final PointerRouter pointerRouter = new PointerRouter();

  /// The gesture arenas used for disambiguating the meaning of sequences of
  /// pointer events.
  final GestureArenaManager gestureArena = new GestureArenaManager();
}
