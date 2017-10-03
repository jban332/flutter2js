import 'package:flur/flur.dart';
import 'package:flur_html/flur.dart';
import 'package:flur_html/mdl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:async';
import 'dart:html' as html;

void main() {
  RenderTreePlugin.current = new HtmlRenderTreePlugin();
  PlatformPlugin.current = new BrowserPlatformPlugin();
  UIPlugin.current = new MdlUIPlugin();

  // Run Flutter app
  runApp(new TodoList(
      [new TodoItem("First")..child.items.add(new TodoItem("Subitem"))]));
}

class TodoList extends StatefulWidget {
  final List<TodoItem> items;
  TodoList(this.items);
  createState() => new TodoListState();
}

class TodoListState extends State<TodoList> {
  List<TodoItem> items;
  var firstBuild = true;

  @override
  void initState() {
    super.initState();
    assert(items == null);
    this.items = new List.from(widget.items);
  }

  TodoListState() {
    _assertReceivesRef();
  }

  @override
  Widget build(BuildContext context) {
    _assertStateCorrect();
    final items = this.items.map((item) {
      final buttonsRow = new Row(children: [
        _buildRemoveButton(context, item),
        _buildUpButton(context, item),
      ]);
      return new Container(
        alignment: FractionalOffset.topCenter,
        padding: new EdgeInsets.all(8.0),
        decoration: new BoxDecoration(),
        child: new Column(children: [
          buttonsRow,
          new Text(item.value),
        ]),
      );
    });
    return new HtmlElementWidget(
      "div",
      className: "exampleClass exampleClass2",
      children: [
        new Column(children: [
          items.toList(),
          _buildAddButton(context),
        ]),
      ],
      onDomElement: _assertRefCorrect,
    );
  }

  // Debugging: Check that state has all fields filled.
  void _assertStateCorrect() {
    assert(context != null);
    assert(items != null);
    assert(this.widget != null);
    assert(this.context != null);
  }

  // Debugging: Check that we receive React ref
  var _receivedRef = false;

  void _assertReceivesRef() {
    new Timer(new Duration(seconds: 1), () {
      assert(_receivedRef == true, "Did not receive 'ref'");
    });
  }

  // Debugging: Checks that received React ref is correct
  void _assertRefCorrect(html.Element value) {
    if (value == null) {
      return;
    }
    _receivedRef = true;
    final className = value.className;
    assert(className == "exampleClass exampleClass2",
        "'ref' has wrong CSS class: '${className}'");
  }

  Widget _buildAddButton(context) {
    return new HtmlElementWidget("button", eventHandlers: {
      "click": (event) {
        add();
      },
    }, children: [
      "Add",
    ]);
  }

  Widget _buildRemoveButton(context, TodoItem item) {
    return new IconButton(
        icon: const Icon(Icons.delete),
        onPressed: () {
          remove(item);
        });
  }

  Widget _buildUpButton(context, TodoItem item) {
    return new IconButton(
        icon: const Icon(Icons.arrow_upward),
        onPressed: () {
          up(item);
        });
  }

  void add() {
    setState(() {
      items.add(new TodoItem());
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
  static int n = 1;
  final String value;
  final TodoList child = new TodoList([]);
  TodoItem([String value]) : this.value = value ?? "Item #${n}" {
    n++;
  }

  @override
  Widget build(BuildContext context) {
    assert(context != null);
    return new HtmlElementWidget("p", children: ["TODO: ", value, child]);
  }
}
