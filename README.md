# What is this?

Flur is an experimental project to make [Flutter](https://flutter.io) apps run in browser or React Native.

Like the project? Contributions are welcome!

## Use cases
* Develop apps for Flutter and release a (basic) mobile browser versions without additional development.
* Support devices that are not supported by Flutter.
* Integrate components written for the web platform, including React components.
* Integrate components written for React Native platform.

## Status (September 2017)
* Early and experimental version.
* Works for developers who build render trees out of _StatelessWidget_, _StatefulWidget_, _HtmlWidget_, and _ReactWidget_.
* Most Flutter SDK widgets haven't been implemented yet (your _UIPlugin_ will throw _UnimplementedError_). If you use Flutter SDK widgets, expect to subclass the _UIPlugin_ you use and spend time on improving it.

## Found a bug?
When the issue is unacceptably rendered Flutter widget, you can often just subclass the `UIPlugin` you use and override the troublesome method.

If you want to share your fix with others, [create a pull request](https://github.com/jban332/chick/pulls) or share your fix in [issues](https://github.com/jban332/chick/issues).

## Authors
  * jban332 <jban332@gmail.com>
  * Contributor? Add your name/email here.

## License

Licensed under the [Apache License, version 2.0](LICENSE).

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
    return new HTMLWidget("input", props:{
      "type": "checkbox",
    });
  }
}
```

Lower-level Flutter APIs such as drawing and plugin communication are delegated to an instance of Flur class `Platform`.
You can customize it too.

Before invoking Flutter's `runApp`, you must set `defaultUIPlugin` you are going to use:

```dart
import 'package:flur_react_native/flur.dart' as flur;
import 'package:flutter/widgets.dart';

void main() {
    flur.UIPlugin.current = new MyUIPlugin();
    
    runApp(new SomeApp());
}
```

## Getting started: Browser

See more more documentation at [github.com/jban332/flur_browser](https://github.com/jban332/flur_react_native).

## Getting started: React Native

See more more documentation at [github.com/jban332/flur_react_native](https://github.com/jban332/flur_react_native).