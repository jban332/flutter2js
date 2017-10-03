# Flur [![Join Gitter Chat Channel -](https://badges.gitter.im/flutter/flutter.svg)](https://gitter.im/flutter/flutter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Flur is an experiment to make [Flutter](https://flutter.io) apps run in browser.

Like the project? Contributions and sponsorships are welcome!

## Use cases
* Release a (basic) web version of your Flutter app without additional development.

## Status
* [X] Runs "Hello World" level apps.
* [X] Flutter SDK example apps compile.
  * "Hello world" example is approximately 120 kB after gzipping (checked mode). 
  * "Stocks" example is approximately 220 kB after gzipping (checked mode). 
  * "Gallery" example is approximately 600 kB after gzipping (checked mode). With checked mode disabled, this comes down to 260kb.

Most Flutter widgets and features do not work adequately.

## Authors
  * jban332 <jban332@gmail.com>
  * Contributor? Add your name/email here.

## How it works?
We modified _"package:flutter"_ so that fundamental built-in widgets (_Text_, _TextInput_, _CupertinoTabBar_, etc.) delegate building to an instance of _UIPlugin_.

The framework contains _HtmlElementWidget_, which allows you to render HTML elements. In Flur, it will render a HTML element. Outside Flur, it will render an error message.

When you compile your Flutter app to Javascript, you just tell package manager to use the Flur version of Flutter.

### UIPlugin
By overriding methods of [UIPlugin](https://github.com/jban332/flur/blob/master/packages/flur/lib/src/ui_plugin.dart), we can define how built-in widgets are rendered.

For example:

```dart
import 'package:flutter/widgets.dart';
import 'package:flur/flur.dart' as flur;

class MyUIPlugin extends flur.UIPlugin {
  @override
  Widget buildCheckbox(BuildContext context, Checkbox widget) {
    return new HtmlElementWidget("input", attributes:{
      "type": "checkbox",
    });
  }
}
```

Flur comes with the following _UIPlugin_ implementations:
  * [HtmlUIPlugin](https://github.com/jban332/flur/blob/master/packages/flur_html/lib/src/html_ui_plugin.dart) - Base class for HTML-based user interfaces.
  * [MdlUIPlugin](https://github.com/jban332/flur/blob/master/packages/flur_html/lib/mdl.dart) - Uses [Material Design Lite](https://getmdl.io/) CSS framework.

## Useful information for contributors
### Package "flutter"
* The package contains nearly all of [original flutter package](https://github.com/flutter/flutter/tree/master/packages/flutter).
* We also had to add a modified version of [dart:ui](https://github.com/flutter/engine/tree/master/lib/ui) package.
* A short description of modifications:
  * Nearly all widgets delegate implementation to Flur.
  * Methods such as _showDialog(...)_ or _HapticFeedback.vibrate()_ delegate implementation to Flur.
  * Some classes in _dart:ui_ such as _Canvas_ delegate implementation to Flur or expose
    previously private/external fields.
  * Removed source code dealing with things that Flur doesn't plan to support.
  * Removed usage of language features not supported by _dart2js_ ([assertions in initializers](https://github.com/dart-lang/sdk/issues/30968) and [some mixins](https://github.com/dart-lang/sdk/issues/23770)).

### Package "flur_html"
* _HtmlRenderTreePlugin_ re-uses Flutter rendering tree implementation. Every _RenderObject_ must be a _DomRenderObject_.
* _HtmlUIPlugin_ is missing answers to many important questions such as:
  * What is the best way to implement Flutter layout with CSS?
  * What is the best way to support "parent data" widgets?

## Getting started
### 1.Get dependencies
* Mandatory:
  * Install Dart SDK
    * See [instructions at dartlang.org](https://www.dartlang.org/install).
* Recommended:
  * Install [Dart plugin for your IDE](https://www.dartlang.org/tools).

### 2.Create your project files
Create an empty directory for your browser app. For example, `"hello_browser"`.

You need to create three files:
  * /pubspec.yaml
  * /web/main.dart
  * /web/index.html

#### pubspec.yaml
```yaml
name: hello_browser

dependencies:
  
  hello_flutter:
    # Relative path to your previously created Flutter app
    path: "../hello_flutter"
  
  flur_html: "any"

dependency_overrides:
  flur:
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flur"
  flur_html:
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flur_html"  
  flutter:
    git:
      url: "git://github.com/jban332/flur.git"
      path: "packages/flutter"

dev_dependencies:
  browser: ^0.10.0
  dart_to_js_script_rewriter: ^1.0.1

transformers:
- dart_to_js_script_rewriter
- $dart2js:
    # Checked mode makes debugging a lot easier
    checked: true
```

#### Run 'pub get'
Now we can ask Pub package manager to download all required packages.

Open a terminal and run:
```
$ pub get
```

#### web/main.dart
```dart
// Import your previously created Flutter app
import 'package:hello_flutter/main.dart' as app;

// Import Flur
import 'package:flur_html/flur.dart' as flur;

void main() {
  // Use "Material Design Lite" UIPlugin
  flur.UIPlugin.current = new flur.MdlUIPlugin();
  
  // Use HtmlRenderTreePlugin for handling your rendering tree
  flur.RenderTreePlugin.current = new flur.HtmlRenderTreePlugin();
 
  // Run your Flutter app
  app.main();
}
```

#### web/index.html
```html
<html>
<head>
    <!-- Material Design Lite CSS library -->
    <link href="packages/flur_html/third_party/mdl/material.min.css" rel="stylesheet" />
    <script src="packages/flur_html/third_party/mdl/material.min.js"></script>
    
    <!-- Our app -->
    <script defer src="main.dart" type="application/dart"></script>
    <script defer src="packages/browser/dart.js"></script>
</head>
<body>
    <div id="flur"></div>
</body>
</html>

```

### 3.Run your app
Open a terminal and run:
```
$ pub serve
```

### 4.Compile your app
Open a terminal and run:
```
$ pub build
```
