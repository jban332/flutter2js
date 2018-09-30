import 'dart:async';

import 'package:flutter/widgets.dart';

/// Opens URIs in the user's device.
///
/// In web browser, URIs are typically opened by changing the current URL of
/// the browser.
///
/// Subclasses may expose more information about the handler.
abstract class UriHandler {
  /// Important: App may stop at any point after invoking the method
  /// so you should not assume that the future ever completes.
  Future handleUri(Uri uri, {BuildContext buildContext});
}
