import 'package:stocks/main.dart' as app;
import 'package:flur_react/react.dart';
import 'package:flur_html/flur.dart';
import 'package:flur_html/mdl.dart';

void main() {
  // Configure
  PlatformPlugin.current = new BrowserPlatformPlugin();
  UIPlugin.current = new MdlUIPlugin();
  RenderTreePlugin.current = new ReactDomRenderTreePlugin();

  // Run Flutter app
  app.main();
}
