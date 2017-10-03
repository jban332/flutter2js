import 'dart:mirrors';

import 'package:flur/flur.dart' as flur;
import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'src/constructor_list.dart';

void main() {
  MockUIPlugin uiPlugin;
  MockPlatformPlugin platformPlugin;

  setUp(() {
    flur.UIPlugin.current = new MockUIPlugin();
    flur.PlatformPlugin.current = new MockPlatformPlugin();
  });

  tearDown(() async {
    flur.UIPlugin.current = null;
  });

  group("PlatformPlugin APIs: ", () {
    // TODO: Use some mocking framework?
    test("EventChannel", () async {
      await new EventChannel("testEventChannel").receiveBroadcastStream();
      expect(verify(platformPlugin.receiveEventChannelStream(any)).callCount, 1);
    });
    test("MethodChannel", () async {
      await new MethodChannel("testMethodChannel").invokeMethod("x");
      expect(verify(platformPlugin.sendMethodChannelMessage(any, any)).callCount, 1);
    });
    test("defaultTargetPlatform", () {
      expect(defaultTargetPlatform, equals(TargetPlatform.android));
    });
    test("Clipboard.getData", () async {
      await Clipboard.getData("someFormat");
      expect(verify(platformPlugin.clipboardGetData(any)).callCount, 1);
    });
    test("Clipboard.setData", () async {
      await Clipboard.setData(new ClipboardData(text: "abc"));
      expect(verify(platformPlugin.clipboardSetData(any)).callCount, 1);
    });
    test("SystemSound.play", () async {
      await SystemSound.play(SystemSoundType.click);
      expect(verify(platformPlugin.playSystemSound(any)).callCount, 1);
    });
    test("HapticFeedback", () async {
      await await HapticFeedback.vibrate();
      expect(verify(platformPlugin.vibrate()).callCount, 1);
    });
  });

  group("UIPlugin: Dialogs: ", () {
    test("showDialog", () async {
      await showDialog(
          context: new MockBuildContext(), child: new Text("Hello"));
      expect(verify(uiPlugin.showDialog(context: any, child: any)).callCount, 1);
    });
    test("showMenu", () async {
      await showMenu(
          context: new MockBuildContext(),
          items: [new PopupMenuItem(child: new Text("Hello"))]);
      expect(verify(uiPlugin.showMenu(context: null, items: null)).callCount, 1);
    });
    test("showDatePicker", () async {
      final now = new DateTime.now();
      await showDatePicker(
          context: null, initialDate: now, firstDate: now, lastDate: now);
      expect(verify(uiPlugin.showDatePicker(context: null, initialDate: null, firstDate: null, lastDate: null)).callCount, 1);
    });
    test("showTimePicker", () async {
      await showTimePicker(
          context: new MockBuildContext(),
          initialTime: new TimeOfDay(hour: 0, minute: 0));
      expect(verify(uiPlugin.showTimePicker(context: null, initialTime: null)).callCount, 1);
    });
  });

  group("UIPlugin: Widgets: ", () {
    for (var constructor in constructors) {
      final uiPlugin = new InvocationCapturingUIPlugin();
      flur.UIPlugin.current = uiPlugin;
      final widget = constructor();
      test("${widget.runtimeType}", () {
        // Build widget
        if (widget is flur.UIPluginWidget) {
          // ignore: INVALID_USE_OF_PROTECTED_MEMBER
          widget.buildWithUIPlugin(widget.createElement(), uiPlugin);
        } else if (widget is StatelessWidget) {
          // ignore: INVALID_USE_OF_PROTECTED_MEMBER
          widget.build(widget.createElement());
        } else if (widget is StatefulWidget) {
          // ignore: INVALID_USE_OF_PROTECTED_MEMBER
          widget.createState();
        } else {
          fail("${widget.runtimeType} does not implement '${flur
              .UIPluginWidget}' or '${StatelessWidget}', or ${StatefulWidget}");
        }

        // Test that invocation was received
        expect(verify(uiPlugin.showDialog(context: any, child: any)).callCount, 1);
        final invocation = uiPlugin.lastInvocation;
        expect(invocation, isNotNull);

        // Test that method name matches type name
        final args = invocation.positionalArguments;
        final methodName = MirrorSystem.getName(invocation.memberName);
        if (methodName.startsWith("build") && args.length == 2) {
          // Example signature:
          //   buildText(BuildContext context, Text widget)
          //
          // Test that input looks normal
          expect(args, hasLength(equals(2)));
          expect(args[0], new isInstanceOf<BuildContext>());
          expect(args[1].runtimeType, equals(widget.runtimeType));

          // Test that method name and widget type match.
          final expectedWidgetName = methodName.substring("build".length);
          final actualWidgetName =
              MirrorSystem.getName(reflect(args[1]).type.simpleName);
          expect(actualWidgetName, equals(expectedWidgetName));
        } else if (methodName.startsWith("create") &&
            methodName.endsWith("State")) {
          // Example signature:
          //   createOverlayState(Overlay overlay)

          // Test that method name and widget type match.
          final expectedWidgetName = methodName.substring(
              "create".length, methodName.length - "State".length);
          final actualWidgetName =
              MirrorSystem.getName(reflect(args[0]).type.simpleName);
          expect(actualWidgetName, equals(expectedWidgetName));
        } else {
          fail("Unexpected method name '${methodName}'");
        }
      });
    }
  });
}

// Couldn't find a way to access Invocation objects in Mockito so...
class InvocationCapturingUIPlugin implements flur.UIPlugin {
  Invocation lastInvocation;

  InvocationCapturingUIPlugin();

  noSuchMethod(Invocation invocation) {
    this.lastInvocation = invocation;
  }
}

class MockUIPlugin extends Mock implements flur.UIPlugin {}

class MockPlatformPlugin extends Mock implements flur.PlatformPlugin {}

class MockBuildContext extends Mock implements BuildContext {}

//
// States
//
// Flur has added some protected methods that are normally private.
//

class OverlayStateImpl extends OverlayState {
  @override
  void insert(OverlayEntry entry, {OverlayEntry above}) {}

  // Added by Flur
  @override
  void remove(OverlayEntry entry) {}

  @override
  void insertAll(Iterable<OverlayEntry> entries, {OverlayEntry above}) {}

  @override
  Widget build(BuildContext context) {
    return null;
  }
}
