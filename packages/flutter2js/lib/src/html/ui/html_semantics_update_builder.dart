import 'dart:typed_data';

import 'package:flutter/ui.dart';

import '../logging.dart';

class HtmlSemanticsUpdate extends SemanticsUpdate {
  @override
  void dispose() {}
}

class HtmlSemanticsUpdateBuilder extends Object with HasDebugName implements SemanticsUpdateBuilder {
  final String debugName;

  HtmlSemanticsUpdateBuilder() : this.debugName = allocateDebugName( "SemanticsUpdateBuilder") {
    logConstructor(this);
  }

  @override
  SemanticsUpdate build() {
    logMethod(this, "build");
    return new HtmlSemanticsUpdate();
  }

  @override
  void updateNode(
      {int id,
      int flags,
      int actions,
      Rect rect,
      String label,
      String hint,
      String value,
      String increasedValue,
      String decreasedValue,
      TextDirection textDirection,
      Float64List transform,
      Int32List children}) {}
}
