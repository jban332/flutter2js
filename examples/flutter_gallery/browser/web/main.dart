import 'package:flutter_gallery/main.dart' as app;
import 'package:flur_react/react.dart';
import 'package:flur_html/flur.dart';
import 'package:flur_html/mdl.dart';

void main() {
  RenderTreePlugin.current = new HtmlRenderTreePlugin();
  PlatformPlugin.current = new BrowserPlatformPlugin();
  UIPlugin.current = new MdlUIPlugin();

  // Run Flutter app
  app.main();
}
