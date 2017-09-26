# What is this?
A Flutter SDK modification needed by [Flur](https://github.com/jban332/flur).

# Contents
* Contains most of [package:flutter](https://github.com/flutter/flutter/tree/master/packages/flutter).
* We also had to add a modified version of [dart:ui](https://github.com/flutter/engine/tree/master/lib/ui) package.
* A short description of modifications:
  * Nearly all Flutter SDK widgets delegate implementation to Flur.
  * Flutter SDK methods such as _showDialog(...)_ or _HapticFeedback.vibrate()_ delegate implementation to Flur.
  * Some methods/constructors in _dart:ui_ such as _new Canvas()_) delegate implementation to Flur or expose
    previously unavailable fields.
  * Removed source code dealing with things that Flur doesn't support (render objects and custom gesture recognizers).
* Known issues:
  * Animation support is lacking.
* We also had to remove usage of Flutter-only language features ([assertions in initializers](https://github.com/dart-lang/sdk/issues/27141) and [some
  mixins](https://github.com/dart-lang/sdk/issues/15101)).
    * We hope that the standard dart2js / dev_compiler toolchain will support them in the future.

# Usage

In your _pubspec.yaml_:
```yaml
dependency_overrides:
  flutter:
    git: "git://github.com/jban332/flur_modified_flutter.git"
```

# License
Licensed under the BSD 3-Clause License. See the full license [here](LICENSE).

See also original licenses of [package:flutter](https://github.com/flutter/flutter/blob/master/LICENSE) and [dart:ui](https://github.com/flutter/engine/blob/master/LICENSE).