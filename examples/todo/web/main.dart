import 'package:flur/flur.dart';
import 'package:flur/js.dart';
import 'package:flur_react/react.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';

void main() {
  // Set UX engine
  RenderTreePlugin.current = new ReactDomRenderTreePlugin();

  // Run Flutter app
  runApp(new TodoList());
}

class TodoList extends StatefulWidget {
  TodoList();
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  final List<TodoItem> items = [];
  var firstBuild = true;

  TodoListState() {
    _assertReceivesRef();
  }

  @override
  Widget build(BuildContext context) {
    _assertStateCorrect();

    return new HtmlReactWidget("ul",
        className: "exampleClass exampleClass2",
        children: [
      items.map((item) {
        return new HtmlReactWidget("li", children: [
          item,
          _buildRemoveButton(context, item),
          _buildUpButton(context, item)
        ], key:new ValueKey(item));
      }),
      new HtmlReactWidget("li", children: [_buildAddButton(context)]),
    ], onJsValue:_assertRefCorrect);
  }


  // Debugging: Check that state has all fields filled.
  _assertStateCorrect() {
    assert(context!=null);
    assert(this.widget!=null);
    assert(this.context!=null);
  }

  // Debugging: Check that we receive React ref
  var _receivedRef = false;
  _assertReceivesRef() {
    new Timer(new Duration(seconds: 1), () {
      assert(_receivedRef == true, "Did not receive 'ref'");
    });
  }

  // Debugging: Checks that received React ref is correct
  _assertRefCorrect(JsValue value) {
    if (value==null) {
      return;
    }
    _receivedRef = true;
    final className = value.get("className").asDartObject();
    assert(className == "exampleClass exampleClass2", "'ref' has wrong CSS class: ${className}");
    final isCorrectClass = value.get("classList").callMethod("contains", ["exampleClass"]).asDartObject() as bool;
    assert(isCorrectClass);
  }

  _buildAddButton(context) {
    return new HtmlReactWidget("button",
        props: new ReactProps({
          "onClick": ($this, event) {
            add();
          },
        }),
        children: [
          "Add",
        ]);
  }

  _buildRemoveButton(context, TodoItem item) {
    return new HtmlReactWidget("button",
        props: new ReactProps({
          "onClick": ($this, event) {
            remove(item);
          },
        }),
        children: [
          "Remove",
        ]);
  }

  _buildUpButton(context, TodoItem item) {
    return new HtmlReactWidget("button",
        props: new ReactProps({
          "onClick": ($this, event) {
            up(item);
          },
        }),
        children: [
          "Up",
        ]);
  }

  void add() {
    setState(() {
      items.add(new TodoItem("Item #${items.length+1}"));
    });
  }

  void up(TodoItem item) {
    setState(() {
      final i = items.indexOf(item);
      if (i > 0) {
        items.removeAt(i);
        items.insert(i - 1, item);
      }
    });
  }

  void remove(TodoItem item) {
    setState(() {
      items.remove(item);
    });
  }
}

class TodoItem extends StatelessWidget {
  final String value;
  TodoItem(this.value);

  @override
  Widget build(BuildContext context) {
    assert(context!=null);
    return new HtmlReactWidget("span", children: ["TODO: ", value]);
  }
}
