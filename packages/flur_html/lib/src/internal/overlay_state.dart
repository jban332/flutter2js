// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flur/flur.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flur_html/flur.dart';

class HtmlOverlayEntry extends StatelessWidget {
  final OverlayEntry entry;
  final int z;

  HtmlOverlayEntry(this.entry, this.z) {
    assert(entry != null);
  }

  @override
  Widget build(BuildContext context) {
    final child = this.entry.builder(context);
    return new HtmlElementWidget(
      "div",
      debugCreator: this,
      style: <String, String>{
        "border": "0",
        "margin": "0",
        "padding": "0",
        "background": "rgba(255, 255, 255, 0.0)",
        "position": "absolute",
        "left": "0",
        "right": "0",
        "top": "0",
        "bottom": "0",
        "width": "auto",
        "height": "auto",
        "z-index": z.toString(),
      },
      children: [child],
    );
  }
}

/// The current state of an [Overlay].
///
/// Used to insert [OverlayEntry]s into the overlay using the [insert] and
/// [insertAll] functions.
class HtmlOverlayState extends OverlayState {
  final List<OverlayEntry> _entries = <OverlayEntry>[];

  @override
  Widget build(BuildContext context) {
    // These lists are filled backwards. For the offstage children that
    // does not matter since they aren't rendered, but for the onstage
    // children we reverse the list below before adding it to the tree.
    final List<Widget> onstageChildren = <Widget>[];
    final List<Widget> offstageChildren = <Widget>[];
    bool onstage = true;
    for (int i = _entries.length - 1; i >= 0; i -= 1) {
      final OverlayEntry entry = _entries[i];
      if (onstage) {
        onstageChildren.add(new HtmlOverlayEntry(entry, i));
        if (entry.opaque) onstage = false;
      } else if (entry.maintainState) {
        offstageChildren.add(new TickerMode(
            enabled: false, child: new HtmlOverlayEntry(entry, i)));
      }
    }
    return new HtmlElementWidget(
      "div",
      debugCreator: this,
      children: onstageChildren,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder description) {
    super.debugFillProperties(description);
    // TODO(jacobr): use IterableProperty instead as that would
    // provide a slightly more consistent string summary of the List.
    description
        .add(new DiagnosticsProperty<List<OverlayEntry>>('entries', _entries));
  }

  /// (DEBUG ONLY) Check whether a given entry is visible (i.e., not behind an
  /// opaque entry).
  ///
  /// This is an O(N) algorithm, and should not be necessary except for debug
  /// asserts. To avoid people depending on it, this function is implemented
  /// only in checked mode.
  bool debugIsVisible(OverlayEntry entry) {
    bool result = false;
    assert(_entries.contains(entry));
    assert(() {
      for (int i = _entries.length - 1; i > 0; i -= 1) {
        final OverlayEntry candidate = _entries[i];
        if (candidate == entry) {
          result = true;
          break;
        }
        if (candidate.opaque) break;
      }
      return true;
    }());
    return result;
  }

  @override
  void initState() {
    super.initState();
    insertAll(widget.initialEntries);
  }

  /// Insert the given entry into the overlay.
  ///
  /// If [above] is non-null, the entry is inserted just above [above].
  /// Otherwise, the entry is inserted on top.

  @override
  void insert(OverlayEntry entry, {OverlayEntry above}) {
    assert(above == null || _entries.contains(above));
    setState(() {
      final int index =
          above == null ? _entries.length : _entries.indexOf(above) + 1;
      _entries.insert(index, entry);
    });
  }

  /// Insert all the entries in the given iterable.
  ///
  /// If [above] is non-null, the entries are inserted just above [above].
  /// Otherwise, the entries are inserted on top.

  @override
  void insertAll(Iterable<OverlayEntry> entries, {OverlayEntry above}) {
    assert(above == null || _entries.contains(above));
    if (entries.isEmpty) return;
    setState(() {
      final int index =
          above == null ? _entries.length : _entries.indexOf(above) + 1;
      _entries.insertAll(index, entries);
    });
  }

  @override
  void remove(OverlayEntry entry) {
    if (mounted) {
      _entries.remove(entry);
      setState(() {});
    }
  }
}
