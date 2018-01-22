[![Build Status](https://travis-ci.org/jban332/flutter2js.svg?branch=master)](https://travis-ci.org/jban332/flutter2js) [![Join Gitter Chat Channel -](https://badges.gitter.im/flutter/flutter.svg)](https://gitter.im/flutter/flutter?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Flutter2js
====

Flutter2js aims to make [Flutter](https://flutter.io) apps run in browser.

The project is work-in-progress. Interested? Become a contributor!

### Use cases
* Release a browser version of your Flutter app.
* Support devices not supported by Flutter.
* Ease migration between different technologies.

### Design
* We aim to use a combination of DOM elements, CSS, and Canvas API.
* We have defines ways to pass DOM trees from widgets to the rendering engine.
  * _HtmlCanvas_ (subclass of _dart:ui_ class _Canvas_) methods
  * _HtmlRenderObject_
  * _HtmlWidget_
* The aim is to optimize performance-critical widgets later.

### Project structure
* Patched Flutter packages live in a separate repository at: [github.com/jban332/flutter2js_packages](https://github.com/jban332/flutter2js_packages)
* This repository contains:
  * A browser implementation of Flutter rendering engine.
  * A project generator (`flutter2js` executable).

## Status
* [X] Contains all Flutter SDK APIs (January 2018).
* [ ] Example apps work.

## Authors
  * jban332 <jban332@gmail.com>
  * Contributor? Add your name/email here.

# Getting started
## 1.Install Dart
See instructions [here](https://www.dartlang.org/install).

Make sure you have _$HOME/.pub-cache/bin_ in your PATH.
Otherwise flutter2js CLI activation will fail. In OS X and Linux, you can:
```
$ echo 'export PATH=$PATH:~/.pub-cache/bin' >> ~/.profile
```

## 2.Activate flutter2js CLI
```
$ pub global activate --source git https://github.com/jban332/flutter2js
```

If you later want to deactivate, use `pub global deactivate flutter2js`.

## 3.Create project
```
$ flutter2js create example --app=your_app,your_uri
```

Replace:
* "your_app" with your existing app name
* "your_uri" with URI of your existing directory ("../my_app") or repository (e.g. "https://github.com/example_user/example_project").

## 4.Start local web server
```
$ cd example
$ pub get
$ pub serve
```

You can now open web browser at [http://localhost:8080](http://localhost:8080)

# Common issues
## Problem: App doesn't render
Unfortunately Flutter2js is work-in-progress. You can help!