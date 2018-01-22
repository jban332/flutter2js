import 'dart:typed_data';

import 'package:flutter/ui.dart';

class HtmlSemanticsUpdateBuilder implements SemanticsUpdateBuilder {
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

  @override
  SemanticsUpdate build() {
    return new HtmlSemanticsUpdate();
  }
}

class HtmlSemanticsUpdate extends SemanticsUpdate {
  @override
  void dispose() {}
}
