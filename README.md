[![Join Gitter Chat Channel -](https://badges.gitter.im/flutter/flutter.svg)](https://gitter.im/flutter/flutter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Flutter2js
====

Flutter2js makes [Flutter](https://flutter.io) apps run in browser.

Find this useful? Become a contributor!

### Use cases
* Release a browser version of your Flutter app.
* Support devices not supported by Flutter.
* Ease migration between different technologies.

### Design
* We aim to use a combination of DOM elements, CSS, and Canvas API.
* We have defines ways to insert DOM elements in the render tree, including _HtmlCanvas_ (subclass of _dart:ui_ class _Canvas_) methods, _HtmlRenderObject_, and _HtmlWidget_.
* The aim is to optimize performance-critical widgets later (i.e. use HTML elements + CSS styling for them)
* We use [dart2js](https://webdev.dartlang.org/tools/dart2js). Unfortunately [dartdevc](https://webdev.dartlang.org/tools/dartdevc) seems to have issues with Flutter SDK packages.
* Patched Flutter SDK lives in a separate repository at: [github.com/flutter2js/flutter2js_packages](https://github.com/flutter2js/flutter2js_packages)
* This repository contains everything else.

## Status
* [X] Contains all Flutter SDK APIs (January 2018).
* [ ] Flutter SDK examples
  * [X] Compile with dart2js
  * [ ] Work adequately

# Getting started
## Method 1: Generate project with Dart2js
### 1.Install Dart SDK (dev channel)
See [instructions at dartlang.org](https://www.dartlang.org/install).

__Important__: You need the latest dev channel version of the Dart SDK (>=2.0.0-dev.19.0).

### 2.Install flutter2js
In command line:
```
$ pub global activate --source git https://github.com/flutter2js/flutter2js
```

If your system doesn't find "pub" command, look at [pub configuration instructions](https://www.dartlang.org/tools/pub/installing).

### 3.Generate project
In command line:
```
$ pub global run flutter2js create example --app-name=your_flutter_app --app-uri=path/to/flutter/app
```

### 4.Run your web app
First, install dependencies:
```
$ cd example
$ pub get
```

You can now start HTTP server:
```
$ pub serve
```

Your app is now running at [http://localhost:8080](http://localhost:8080)

## Method 2: Manual pubspec configuration
Look at [examples](https://github.com/flutter2js/flutter2js/tree/master/examples).

# Common issues
## Problem: App doesn't render
Unfortunately Flutter2js is work-in-progress. You can help!
