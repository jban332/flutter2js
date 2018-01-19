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
  // For all tests
  tearDown(() async {
    flur.UIPlugin.current = null;
    flur.PlatformPlugin.current = null;
    resetMockitoState();
  });

  group("", () {
    MockUIPlugin mockUIPlugin;
    MockPlatformPlugin mockPlatformPlugin;

    setUp(() async {
      mockUIPlugin = new MockUIPlugin();
      mockPlatformPlugin = new MockPlatformPlugin();
      flur.UIPlugin.current = mockUIPlugin;
      flur.PlatformPlugin.current = mockPlatformPlugin;
    });

    group("PlatformPlugin APIs: ", () {
      // TODO: Use some mocking framework?
      test("EventChannel", () async {
        await new EventChannel("testEventChannel").receiveBroadcastStream();
        expect(
            verify(mockPlatformPlugin.receiveEventChannelStream(any, any))
                .callCount,
            1);
      });
      test("MethodChannel", () async {
        await new MethodChannel("testMethodChannel").invokeMethod("x");
        expect(
            verify(mockPlatformPlugin.sendMethodChannelMessage(any, any))
                .callCount,
            1);
      });
      test("defaultTargetPlatform", () {
        expect(defaultTargetPlatform, equals(TargetPlatform.android));
      });
      test("Clipboard.getData", () async {
        await Clipboard.getData("someFormat");
        expect(verify(mockPlatformPlugin.clipboardGetData(any)).callCount, 1);
      });
      test("Clipboard.setData", () async {
        await Clipboard.setData(new ClipboardData(text: "abc"));
        expect(verify(mockPlatformPlugin.clipboardSetData(any)).callCount, 1);
      });
      test("SystemSound.play", () async {
        await SystemSound.play(SystemSoundType.click);
        expect(verify(mockPlatformPlugin.playSystemSound(any)).callCount, 1);
      });
      test("HapticFeedback", () async {
        await await HapticFeedback.vibrate();
        expect(verify(mockPlatformPlugin.vibrate()).callCount, 1);
      });
    });

    group("UIPlugin: Dialogs: ", () {
      test("showDialog", () async {
        await showDialog(
            context: new MockBuildContext(), child: new Text("Hello"));
        expect(
            verify(mockUIPlugin.showDialog(
                    barrierDismissible: any, context: any, child: any))
                .callCount,
            1);
      });
      test("showMenu", () async {
        await showMenu(
            context: new MockBuildContext(),
            items: [new PopupMenuItem(child: new Text("Hello"))]);
        expect(
            verify(mockUIPlugin.showMenu(
                    context: any,
                    elevation: any,
                    initialValue: any,
                    items: any,
                    position: any))
                .callCount,
            1);
      });
      test("showDatePicker", () async {
        final now = new DateTime.now();
        await showDatePicker(
            context: null, initialDate: now, firstDate: now, lastDate: now);
        expect(
            verify(mockUIPlugin.showDatePicker(
                    context: null,
                    initialDate: any,
                    firstDate: any,
                    lastDate: any,
                    selectableDayPredicate: any))
                .callCount,
            1);
      });
      test("showTimePicker", () async {
        await showTimePicker(
            context: new MockBuildContext(),
            initialTime: new TimeOfDay(hour: 0, minute: 0));
        expect(
            verify(mockUIPlugin.showTimePicker(context: any, initialTime: any))
                .callCount,
            1);
      });
    });
  });

  group("UIPlugin: Widgets: ", () {
    for (var constructor in constructors) {
      // Create widget
      final widget = constructor();

      test("${widget.runtimeType}", () {
        // Create UIPlugin that will capture the invocation
        final uiPlugin = new InvocationCapturingUIPlugin();
        flur.UIPlugin.current = uiPlugin;

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