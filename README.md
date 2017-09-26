# What is this?

Flur was an experiment to make [Flutter](https://flutter.io) apps run in browser.

## License

Licensed under the [Apache License, version 2.0](packages/flur/LICENSE).

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
## 1. Install dependencies
#### Mandatory:
* Install Dart SDK
  * See [instructions at dartlang.org](https://www.dartlang.org/install).
#### Recommended:
* Install Flutter SDK
  * See [instructions at flutter.io](https://flutter.io/setup/).
  * If you don't install Flutter SDK
    1. Skip step 2 ("Create a Flutter app"),
    2. Copy-paste the app implementation from Step 2 to Step 3.
    3. In your `pubspec.yaml`, move `flutter` from `dependency_overrides` to `dependencies`.
* Install [Dart plugin for your IDE](https://www.dartlang.org/tools).

## 2. Create a Flutter app
Create an empty directory for your Flutter app. For example, `hello_flutter`.

We need to create two files:
  * /pubspec.yaml
  * /lib/main.dart

Create `"pubspec.yaml"`:

```yaml
name: hello_flutter
version: 0.0.1

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

Now we can use Flutter version of Pub package manager to download all required packages.
Open a terminal and run:
```
$ flutter packages get
```


Create `"lib/main.dart"`:

```dart
import 'package:flutter/material.dart';

void main() {
    runApp(new Hello(who:"world!"));
}

class Hello extends StatelessWidget {
  final String who;
  
  Hello({this.who:"you"});
  
  @override
  build(context) {
    return new Center(
      child: new Text("Hello ${who}!"),
    );
  }
}
```

## 3. Create a browser version of the app
Create an empty directory for your browser app. For example, `"hello_browser"`.

We need to create three files:
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
    # Use latest version of Flur core API
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flur_react"
  flur_html:
    # Use latest version of Flur core API
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flur_html"
dependency_overrides:
  flutter:
    git: "git://github.com/jban332/flur_modified_flutter.git"

# The last
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
// Import your previosly created app
import 'package:hello_flutter/main.dart' as app;

// Import Flur API
import 'package:flur_react/flur.dart' as flur;

void main() {
  // Configure Flur
  flur.UIPlugin.current = new flur.MdlUIPlugin();
  
  // Configure Flur
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

## 4. Test in your browser
Open a terminal and run:

```$ pub serve```