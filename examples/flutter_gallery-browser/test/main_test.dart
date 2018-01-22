import 'dart:async';
import '../web/main.dart' as app;
import 'package:test/test.dart';
import 'dart:html' as html;

void main() {
  test("Running the app", () async {
    // Check that the document is blank
    expect(html.querySelectorAll("div").length, equals(0));

    // Render
    app.main();
    await new Future.delayed(const Duration(milliseconds: 100));

    // Check that the document is non-blank
    expect(html.querySelectorAll("div").length, isNot(equals(0)));
  });
}