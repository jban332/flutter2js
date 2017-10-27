import 'dart:async';
import 'dart:html' as html;

import 'package:flutter/widgets.dart';

import 'dom_element_widget.dart';

/// A widget that supports infinite scrolling.
class DomSliverWidget extends StatefulWidget {
  final String tagName;
  final String className;
  final Map<String, String> attributes;
  final Map<String, String> style;
  final Map<String, ValueChanged<html.Event>> eventListeners;

  /// The amount of items to add at each expansion iteration.
  final int initial;
  final int step;

  /// Delegate that builds items.
  final SliverChildDelegate delegate;

  DomSliverWidget(this.delegate,
      {Key key,
      this.tagName: "div",
      this.initial: 100,
      this.step: 10,
      this.className,
      this.attributes,
      this.style,
      this.eventListeners})
      : super(key: key);

  @override
  DomSliverState createState() => new DomSliverState();
}

class DomSliverState extends State<DomSliverWidget> {
  /// Previously built items.
  List<Widget> builtChildren = <Widget>[];

  // The length we try to achieve.
  int _attemptedLength = 1;

  Timer _timer;

  @override
  void initState() {
    super.initState();
    _attemptedLength = widget.step;
  }

  // Invoked when more items should be added.
  @override
  Widget build(BuildContext context) {
    final widget = this.widget;

    // Declare children
    // Use previously built children, if any
    final children = new List.from(this.builtChildren ?? const []);

    // Cache the children so we don't need to rebuild them
    this.builtChildren = children;

    var changedChildren = false;

    if (children.length > _attemptedLength) {
      // We have too many children.
      // Remove the last ones.
      children.length = _attemptedLength;
      changedChildren = true;
    } else {
      // While we have too few children
      // try add more children
      while (children.length < _attemptedLength) {
        final item = widget.delegate.build(context, children.length);
        if (item == null) {
          // No more children
          break;
        }
        // Delegate gave us an additional child
        children.add(item);
        changedChildren = true;
      }

      // We accept the current length.
      _attemptedLength = children.length;
    }

    // Event listeners
    final eventListeners = <String, ValueChanged<html.Event>>{};
    widget.eventListeners?.forEach((k, v) {
      eventListeners[k] = v;
    });

    // Whenever user scrolls,
    // inspect layout to see if we should expand.
    final nextListener = eventListeners["onScroll"];
    eventListeners["onScroll"] = (html.Event event) {
      inspectLayout(event.target as html.Element);
      if (nextListener != null) {
        nextListener(event);
      }
    };

    // If children were changed,
    // schedule layout inspection.
    //
    // This will ensure sure that if we didn't add enough children,
    // we will add more in the next iteration.
    final ValueChanged<html.Element> onLayout = changedChildren == false
        ? null
        : (node) {
            inspectLayout(node);
          };

    // Return
    return new DomElementWidget.withTag(widget.tagName,
        className: widget.className,
        attributes: widget.attributes,
        style: widget.style,
        eventListeners: eventListeners,
        children: children,
        onLayout: onLayout);
  }

  /// Invoked when DOM node has been attached or user has scrolled.
  ///
  /// The method adds items until:
  ///   * There are no more items available.
  ///   * OR there is enough items after the current scroll position.
  void inspectLayout(html.Element target) {
    final scrollTop = target.scrollTop;
    final scrollBottom = target.scrollTop + target.scrollHeight;

    // Check whether we should expand
    if (scrollBottom > target.clientHeight - target.scrollHeight) {
      expand();
    }

    // Search first and last visible item
    int start, end;
    var i = -1;
    for (var item in target.children) {
      i++;
      if (start == null && item.offsetTop >= scrollTop) {
        start = i;
      } else if (item.offsetTop >= scrollBottom) {
        end = i - 1;
        break;
      }
    }
    start ??= -1;
    end ??= start < 0 ? -1 : target.children.length - 1;

    // Tell delegate about the visible items
    widget.delegate.didFinishLayout(start, end);
  }

  /// Adds items.
  /// The amount of items is determined by [DomSliverWidget.step].
  void expand() {
    setState(() {
      _attemptedLength += widget.step;
    });
  }

  @override
  void didUpdateWidget(DomSliverWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If all items should be rebuilt
    final delegate = widget.delegate;
    final oldDelegate = oldWidget.delegate;
    if (!identical(delegate, oldDelegate) &&
        delegate.shouldRebuild(oldDelegate)) {
      // Clear all children
      this.builtChildren = null;
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    _cancelTimer();
  }

  void _cancelTimer() {
    if (_timer != null) {
      _timer.cancel();
      _timer = null;
    }
  }
}
