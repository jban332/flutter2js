# What is this?

Flur (_Flutter + React_) is an __experiment__ to make [Flutter](https://flutter.io) apps run in browser.

# Results of the experiment
* Able to run "Hello world" type applications.
* Very few widgets have been actually implemented by the provided `HtmlUIPlugin`. Most will throw `UnimplementedError`. Navigation and animation support is lacking.
* Flutter "Stocks" example app is about ~400 kB after it's minified (~100 kB after gzipping). Does not include React or the app assets.

# How it works?
We modified `"package:flutter"` so that fundamental built-in widgets (`Text`, `TextInput`, `CupertinoTabBar`, etc.) delegate building to an instance of `UIPlugin`.

When you compile your Flutter app to Javascript, you just tell package manager to use the Flur version of Flutter.

By overriding methods of `UIPlugin`, we can define how built-in widgets are rendered. The framework contains `HtmlReactWidget` and `ReactWidget`, which allow you to render HTML and React components. You could use Flur in React Native too.

For example:

```dart
import 'package:flutter/widgets.dart';
import 'package:flur/flur.dart' as flur;

class MyUIPlugin extends flur.UIPlugin {
  @override
  Widget buildCheckbox(BuildContext context, Checkbox widget) {
    return new HtmlReactWidget("input", props:{
      "type": "checkbox",
    });
  }
}
```

## Details
* Contains most of [package:flutter](https://github.com/flutter/flutter/tree/master/packages/flutter).
* We also had to add a modified version of [dart:ui](https://github.com/flutter/engine/tree/master/lib/ui) package.
* A short description of modifications:
  * Nearly all Flutter SDK widgets delegate implementation to Flur.
  * Flutter SDK methods such as _showDialog(...)_ or _HapticFeedback.vibrate()_ delegate implementation to Flur.
  * Some methods/constructors in _dart:ui_ such as _new Canvas()_ delegate implementation to Flur or expose
    previously unavailable fields.
  * Removed source code dealing with things that Flur doesn't support (render objects and custom gesture recognizers).
* We also had to remove usage of Flutter-only language features ([assertions in initializers](https://github.com/dart-lang/sdk/issues/27141) and [some
  mixins](https://github.com/dart-lang/sdk/issues/15101)).

# Getting started
Create an empty directory for your browser app. For example, `"hello_browser"`.

You need to create three files:
  * /pubspec.yaml
  * /web/main.dart
  * /web/index.html

## pubspec.yaml
Create `"pubspec.yaml"`:

```yaml
name: hello_browser

dependencies:
  
  hello_flutter:
    # Relative path to your previously created Flutter app
    path: "../hello_flutter"
  
  flur_react:
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flur_react"
  
  flur_html:
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flur_html"

dependency_overrides:
  
  flutter:
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flutter"

dev_dependencies:
  browser: ^0.10.0
  dart_to_js_script_rewriter: ^1.0.1

transformers:
- dart_to_js_script_rewriter
```

Now we can ask Pub package manager to download all required packages. Open a terminal and run:
```
$ pub get
```

## main.dart
In your project directory, create `"web/main.dart"`:

```dart
// Import your previously created Flutter app
import 'package:hello_flutter/main.dart' as app;

// Import Flur
import 'package:flur_html/flur.dart' as flur_html;
import 'package:flur_react/flur.dart' as flur_react;

void main() {
  // Use "Material Design Lite" UIPlugin
  flur.UIPlugin.current = new flur_html.MdlUIPlugin();
  
  // Use React for handling your widget tree
  flur.RenderTreePlugin.current = new flur_react.ReactDomRenderTreePlugin();
 
  // Run your Flutter app
  app.main();
}
```

## index.html
In your project directory, create `"web/index.html"`:

```html
<html>
<head>
    <script src="packages/flur_react/third_party/react/react.js"></script>
    <script src="packages/flur_react/third_party/react/react-dom.js"></script>
    <script defer src="main.dart" type="application/dart"></script>
    <script defer src="packages/browser/dart.js"></script>
</head>
<body>
    <div id="flur"></div>
</body>
</html>

```

Now you can test your web app:

```$ pub serve```
