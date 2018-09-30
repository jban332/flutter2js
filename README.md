[![Build Status](https://travis-ci.com/flutter2js/flutter2js.svg?branch=master)](https://travis-ci.com/flutter2js/flutter2js)
[![Join Gitter Chat Channel -](https://badges.gitter.im/flutter2js/flutter2js.svg)](https://gitter.im/flutter2js/flutter2js?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

# Introduction

Flutter2js is an experimental project that investigates feasibility of making
[Flutter](https://flutter.io) apps run in browser using drawing primitives (canvas, CSS and SVG).

Licensed under the [BSD 3-Clause License](LICENSE).

## Implications of the approach

__If the project gets drawing working__, the approach taken by this project ("drawing, no HTML elements") has the following implications:
* All Flutter widgets will work.
* Apps look (more or less) identical to iOS/Android.
* Scrolling/animation performance is bad compared to web apps (but possibly acceptable).
* Code size and accessibility are inevitably poor compared to normal web apps.

## Status
### Ready
 * [X] Flutter SDK and sample apps compile

### Next
 * [ ] "Hello world"-like examples draw correctly
 * [ ] Mouse/tap handling

You can help!

## Notes for developers
* The project uses [dart2js](https://webdev.dartlang.org/tools/dart2js). Unfortunately [dartdevc](https://webdev.dartlang.org/tools/dartdevc) seems to have issues with Flutter SDK packages.

# Getting started
## Hello world
### Clone Git repository
```
git clone https://github.com/flutter2js/flutter2js
```

### Try "Hello world"
```
cd examples/hello_world-browser
pub get
pub run webdev serve
```

Open browser at: _http://localhost:8080/main.html_

# Technical details
## Libraries from original Flutter SDK
Flutter SDK libraries are derived from the original Flutter SDK.

These include:
* _dart:ui_ ([original](https://github.com/flutter/engine/tree/master/lib/ui), [docs](https://docs.flutter.io/flutter/dart-ui/dart-ui-library.html))
  * Because Pub doesn't allow overriding "dart:something" packages, it's exposed as "package:flutter/ui.dart".
* _package:flutter_ ([original](https://github.com/flutter/flutter/tree/master/packages/flutter), [docs](https://docs.flutter.io/flutter/flutter/flutter-library.html))
* _package:flutter_localization_ ([original](https://github.com/flutter/flutter/tree/master/packages/flutter), [docs](https://docs.flutter.io/flutter/flutter_localization/flutter_localization-library.html))
* _package:flutter_test_ ([original](https://github.com/flutter/flutter/tree/master/packages/flutter_test), [docs](https://docs.flutter.io/flutter/flutter_test/flutter_test-library.html))

The modifications include:
* Many classes in _dart:ui_ such as _Canvas_ delegate implementation to _package:flutter2js_ or expose previously private/external fields.
* Eliminated usage of language features not supported by _dart2js_:
  * Assertions in initializers. After dart2js started to support them, this became unnecessary.
  * Some mixins ([issue #23770](https://github.com/dart-lang/sdk/issues/23770))
