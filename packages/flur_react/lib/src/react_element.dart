import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'internal/stateful_widget.dart' as reactApi;

class ReactElement implements Element {
  final ReactElement parent;

  @override
  final Widget widget;

  ReactElement(this.parent, this.widget);

  @override
  dynamic get slot {
    throw new UnimplementedError();
  }

  @override
  void performRebuild() {
    throw new UnimplementedError();
  }

  @override
  void rebuild() {
    throw new UnimplementedError();
  }

  @override
  void markNeedsBuild() {}

  @override
  bool get dirty {
    return false;
  }

  @override
  List<DiagnosticsNode> debugDescribeChildren() {
    return [];
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {}

  @override
  String toStringShort() {
    return "[${Element}:${widget}]";
  }

  @override
  String debugGetCreatorChain(int limit) {
    final List<String> chain = <String>[];
    ReactElement node = this;
    while (chain.length < limit && node != null) {
      chain.add(node.toStringShort());
      node = node.parent;
    }
    if (node != null) chain.add('\u22EF');
    return chain.join(' \u2190 ');
  }

  @override
  void didChangeDependencies() {
    throw new UnimplementedError();
  }

  @override
  void visitAncestorElements(bool visitor(Element element)) {
    ReactElement ancestor = parent;
    while (ancestor != null) {
      if (!visitor(ancestor)) {
        return;
      }
      ancestor = ancestor.parent;
    }
  }

  @override
  RenderObject ancestorRenderObjectOfType(TypeMatcher matcher) {
    throw new UnimplementedError();
  }

  @override
  State ancestorStateOfType(TypeMatcher matcher) {
    ReactElement ancestor = parent;
    while (ancestor != null) {
      if (ancestor is ReactStatefulElement) {
        final state = ancestor.state;
        if (matcher.check(state)) {
          return state;
        }
      }
      ancestor = ancestor.parent;
    }
    return null;
  }

  @override
  Widget ancestorWidgetOfExactType(Type targetType) {
    ReactElement ancestor = parent;
    while (ancestor != null) {
      final widget = ancestor.widget;
      if (identical(widget.runtimeType, targetType)) {
        return widget;
      }
      ancestor = ancestor.parent;
    }
    return null;
  }

  @override
  InheritedElement ancestorInheritedElementForWidgetOfExactType(
      Type targetType) {
    ReactElement ancestor = parent;
    while (ancestor != null) {
      final widget = ancestor.widget;
      if (identical(widget.runtimeType, targetType)) {
        return ancestor as InheritedElement;
      }
      ancestor = ancestor.parent;
    }
    return null;
  }

  @override
  InheritedWidget inheritFromWidgetOfExactType(Type targetType) {
    return ancestorWidgetOfExactType(targetType) as InheritedWidget;
  }

  @override
  Size get size {
    throw new UnimplementedError();
  }

  @override
  RenderObject findRenderObject() {
    throw new UnimplementedError();
  }

  @override
  void unmount() {
    throw new UnimplementedError();
  }

  @override
  void debugDeactivated() {
    throw new UnimplementedError();
  }

  @override
  void deactivate() {
    throw new UnimplementedError();
  }

  @override
  void activate() {
    throw new UnimplementedError();
  }

  @override
  void forgetChild(Element child) {
    throw new UnimplementedError();
  }

  @override
  void deactivateChild(Element child) {
    throw new UnimplementedError();
  }

  @override
  Element inflateWidget(Widget newWidget, dynamic newSlot) {
    throw new UnimplementedError();
  }

  @override
  void attachRenderObject(dynamic newSlot) {
    throw new UnimplementedError();
  }

  @override
  void detachRenderObject() {
    throw new UnimplementedError();
  }

  @override
  void updateSlotForChild(Element child, dynamic newSlot) {
    throw new UnimplementedError();
  }

  @override
  void update(Widget newWidget) {
    throw new UnimplementedError();
  }

  @override
  void mount(Element parent, dynamic newSlot) {
    throw new UnimplementedError();
  }

  @override
  Element updateChild(Element child, Widget newWidget, dynamic newSlot) {
    throw new UnimplementedError();
  }

  @override
  void visitChildElements(ElementVisitor visitor) {
    throw new UnimplementedError();
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    throw new UnimplementedError();
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    throw new UnimplementedError();
  }

  @override
  RenderObject get renderObject {
    throw new UnimplementedError();
  }

  @override
  BuildOwner get owner {
    throw new UnimplementedError();
  }

  @override
  int get depth {
    final parent = this.parent;
    return parent == null ? 0 : parent.depth + 1;
  }

  @override
  String toString({DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    return this.toStringShallow(minLevel:minLevel);
  }

  @override
  String toStringShallow(
      {String joiner: ', ', DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    return "[${Element}:${widget.runtimeType}]";
  }

  @override
  DiagnosticsNode toDiagnosticsNode({String name, DiagnosticsTreeStyle style}) {
    throw new UnimplementedError();
  }

  @override
  String toStringDeep(
      {String prefixLineOne: '',
      String prefixOtherLines,
      DiagnosticLevel minLevel: DiagnosticLevel.debug}) {
    throw new UnimplementedError();
  }
}

class ReactProxyElement extends ReactElement implements ProxyElement {
  @override
  ProxyWidget get widget => super.widget;
  ReactProxyElement(ReactElement parent, ProxyWidget widget) : super(parent, widget);

  @override
  Widget build() {
    return widget;
  }

  @override
  void notifyClients(ProxyWidget oldWidget) {}
}

class ReactInheritedElement extends ReactProxyElement
    implements InheritedElement {
  @override
  InheritedWidget get widget => super.widget;
  ReactInheritedElement(ReactElement parent, InheritedWidget widget) : super(parent, widget);

  @override
  void dispatchDidChangeDependencies() {}
}

/// A helper that extends [StatefulElement] and makes its state mutable.
class ReactStatefulElement extends ReactElement implements StatefulElement {
  final reactApi.StatefulComponent reactComponent;
  final State state;

  @override
  StatefulWidget widget;

  ReactStatefulElement(ReactElement parent, this.reactComponent, StatefulWidget widget)
      : // ignore: INVALID_USE_OF_PROTECTED_MEMBER
        this.state = widget.createState(),
        this.widget = widget,
        super(parent, widget);

  @override
  void markNeedsBuild() {
    reactComponent.forceUpdate();
  }

  @override
  Widget build() {
    // ignore: INVALID_USE_OF_PROTECTED_MEMBER
    State.setElement(state, this);
    // ignore: INVALID_USE_OF_PROTECTED_MEMBER
    return state.build(this);
  }

  @override
  void update(Widget newWidget) {
    this.widget = widget;
  }
}
