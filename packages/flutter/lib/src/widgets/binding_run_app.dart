import 'package:flur/flur_for_modified_flutter.dart' as flur;

import 'basic.dart';
import 'framework.dart';

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
  final plugin = flur.RenderTreePlugin.current;
  assert(plugin!=null, "RenderTreePlugin.current is null");
  plugin.runApp(app);
}
