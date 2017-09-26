## What is this?

Flur is an experiment to make [Flutter](https://flutter.io) apps run in browser.

The project is just an experiment and not usable for production.

## Results of the experiment 
* Code size: Flutter "Stocks" application is about ~400 kB after it's minified (~100 kB after gzipping). Does not include React.

## How it works?
We modified `"package:flutter"` so that fundamental built-in widgets (`Text`, `TextInput`, `CupertinoTabBar`, etc.) delegate building to an instance of `UIPlugin`.
This version of Flutter lives in [github.com/jban332/flur_modified_flutter](https://github.com/jban332/flur_modified_flutter).

When you compile Flutter app to Javascript, you just tell package manager to use the `flur_modified_flutter.

By overriding methods of `UIPlugin`, we can define how built-in widgets are rendered.
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

Lower-level Flutter APIs such as drawing and plugin communication are delegated to an instance of Flur class `Platform`.
You can customize it too.

Before invoking Flutter's `runApp`, you must set `defaultUIPlugin` you are going to use:

```dart
import 'flur_rn' as flur;
import 'package:flutter/widgets.dart';

void main() {
    flur.UIPlugin.current = new MyUIPlugin();
    
    runApp(new SomeApp());
}
```

# Getting started
Create an empty directory for your browser app. For example, `"hello_browser"`.

You need to create three files:
  * /pubspec.yaml
  * /web/main.dart
  * /web/index.html

Create `"pubspec.yaml"`:

```yaml
name: hello_browser

dependencies:
  hello_flutter_app:
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
    git: "git://github.com/jban332/flur_modified_flutter.git"

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

In your project directory, create `"web/main.dart"`:

```dart
// Import your previosly created Flutter app
import 'package:hello_flutter/main.dart' as app;

// Import Flur API
import 'package:flur_react/flur.dart' as flur;

void main() {
  // Configure Flur
  flur.UIPlugin.current = new flur.MdlUIPlugin();
  flur.RenderTreePlugin.current = new flur.ReactDomRenderTreePlugin();
 
  // Start app
  app.main();
}
```

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
