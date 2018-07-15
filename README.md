[![Join Gitter Chat Channel -](https://badges.gitter.im/flutter/flutter.svg)](https://gitter.im/flutter/flutter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Flutter2js
====

Flutter2js is a project _attempts_ to make [Flutter](https://flutter.io) apps run in browser.

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

## Next
* [ ] Flutter SDK examples
  * [ ] Work adequately
