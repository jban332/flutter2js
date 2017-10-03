// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flur/flur_for_modified_flutter.dart' as flur;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'divider.dart';
import 'icon_button.dart';
import 'icons.dart';
import 'list_tile.dart';
import 'theme.dart';

// Examples can assume:
// enum Commands { heroAndScholar, hurricaneCame }
// dynamic _heroAndScholar;

const Duration _kMenuDuration = const Duration(milliseconds: 300);
const double _kBaselineOffsetFromBottom = 20.0;
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;
const double _kMenuHorizontalPadding = 16.0;
const double _kMenuItemHeight = 48.0;
const double _kMenuDividerHeight = 16.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;
const double _kMenuVerticalPadding = 8.0;
const double _kMenuWidthStep = 56.0;
const double _kMenuScreenPadding = 8.0;

/// A base class for entries in a material design popup menu.
///
/// The popup menu widget uses this interface to interact with the menu items.
/// To show a popup menu, use the [showMenu] function. To create a button that
/// shows a popup menu, consider using [PopupMenuButton].
///
/// The type `T` is the type of the value(s) the entry represents. All the
/// entries in a given menu must represent values with consistent types.
///
/// A [PopupMenuEntry] may represent multiple values, for example a row with
/// several icons, or a single entry, for example a menu item with an icon (see
/// [PopupMenuItem]), or no value at all (for example, [PopupMenuDivider]).
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [CheckedPopupMenuItem], a popup menu item with a checkmark.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
abstract class PopupMenuEntry<T> extends flur.StatelessUIPluginWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const PopupMenuEntry({Key key}) : super(key: key);

  /// The amount of vertical space occupied by this entry.
  ///
  /// This value is used at the time the [showMenu] method is called, if the
  /// `initialValue` argument is provided, to determine the position of this
  /// entry when aligning the selected entry over the given `position`. It is
  /// otherwise ignored.
  double get height;

  /// Whether this entry represents a particular value.
  ///
  /// This method is used by [showMenu], when it is called, to align the entry
  /// representing the `initialValue`, if any, to the given `position`, and then
  /// later is called on each entry to determine if it should be highlighted (if
  /// the method returns true, the entry will have its background color set to
  /// the ambient [ThemeData.highlightColor]). If `initialValue` is null, then
  /// this method is not called.
  ///
  /// If the [PopupMenuEntry] represents a single value, this should return true
  /// if the argument matches that value. If it represents multiple values, it
  /// should return true if the argument matches any of them.
  bool represents(T value);
}

/// A horizontal divider in a material design popup menu.
///
/// This widget adapts the [Divider] for use in popup menus.
///
/// See also:
///
///  * [PopupMenuItem], for the kinds of items that this widget divides.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class PopupMenuDivider extends PopupMenuEntry<Null> {
  /// Creates a horizontal divider for a popup menu.
  ///
  /// By default, the divider has a height of 16 logical pixels.
  const PopupMenuDivider({Key key, this.height: _kMenuDividerHeight})
      : super(key: key);

  /// The height of the divider entry.
  ///
  /// Defaults to 16 pixels.
  @override
  final double height;

  @override
  bool represents(dynamic value) => false;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildPopupMenuDivider(context, this);
  }
}

/// An item in a material design popup menu.
///
/// To show a popup menu, use the [showMenu] function. To create a button that
/// shows a popup menu, consider using [PopupMenuButton].
///
/// To show a checkmark next to a popup menu item, consider using
/// [CheckedPopupMenuItem].
///
/// Typically the [child] of a [PopupMenuItem] is a [Text] widget. More
/// elaborate menus with icons can use a [ListTile]. By default, a
/// [PopupMenuItem] is 48 pixels high. If you use a widget with a different
/// height, it must be specified in the [height] property.
///
/// ## Sample code
///
/// Here, a [Text] widget is used with a popup menu item. The `WhyFarther` type
/// is an enum, not shown here.
///
/// ```dart
/// const PopupMenuItem<WhyFarther>(
///   value: WhyFarther.harder,
///   child: const Text('Working a lot harder'),
/// )
/// ```
///
/// See the example at [PopupMenuButton] for how this example could be used in a
/// complete menu, and see the example at [CheckedPopupMenuItem] for one way to
/// keep the text of [PopupMenuItem]s that use [Text] widgets in their [child]
/// slot aligned with the text of [CheckedPopupMenuItem]s or of [PopupMenuItem]
/// that use a [ListTile] in their [child] slot.
///
/// See also:
///
///  * [PopupMenuDivider], which can be used to divide items from each other.
///  * [CheckedPopupMenuItem], a variant of [PopupMenuItem] with a checkmark.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class PopupMenuItem<T> extends PopupMenuEntry<T> {
  /// Creates an item for a popup menu.
  ///
  /// By default, the item is [enabled].
  ///
  /// The `height` and `enabled` arguments must not be null.
  const PopupMenuItem({
    Key key,
    this.value,
    this.enabled: true,
    this.height: _kMenuItemHeight,
    @required this.child,
  })
      : super(key: key);

  /// The value that will be returned by [showMenu] if this entry is selected.
  final T value;

  /// Whether the user is permitted to select this entry.
  ///
  /// Defaults to true. If this is false, then the item will not react to
  /// touches.
  final bool enabled;

  /// The height of the entry.
  ///
  /// Defaults to 48 pixels.
  @override
  final double height;

  /// The widget below this widget in the tree.
  ///
  /// Typically a single-line [ListTile] (for menus with icons) or a [Text]. An
  /// appropriate [DefaultTextStyle] is put in scope for the child. In either
  /// case, the text should be short enough that it won't wrap.
  final Widget child;

  @override
  bool represents(T value) => value == this.value;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildPopupMenuItem(context, this);
  }
}

/// An item with a checkmark in a material design popup menu.
///
/// To show a popup menu, use the [showMenu] function. To create a button that
/// shows a popup menu, consider using [PopupMenuButton].
///
/// A [CheckedPopupMenuItem] is 48 pixels high, which matches the default height
/// of a [PopupMenuItem]. The horizontal layout uses a [ListTile]; the checkmark
/// is an [Icons.done] icon, shown in the [ListTile.leading] position.
///
/// ## Sample code
///
/// Suppose a `Commands` enum exists that lists the possible commands from a
/// particular popup menu, including `Commands.heroAndScholar` and
/// `Commands.hurricaneCame`, and further suppose that there is a
/// `_heroAndScholar` member field which is a boolean. The example below shows a
/// menu with one menu item with a checkmark that can toggle the boolean, and
/// one menu item without a checkmark for selecting the second option. (It also
/// shows a divider placed between the two menu items.)
///
/// ```dart
/// new PopupMenuButton<Commands>(
///   onSelected: (Commands result) {
///     switch (result) {
///       case Commands.heroAndScholar:
///         setState(() { _heroAndScholar = !_heroAndScholar; });
///         break;
///       case Commands.hurricaneCame:
///         // ...handle hurricane option
///         break;
///       // ...other items handled here
///     }
///   },
///   itemBuilder: (BuildContext context) => <PopupMenuEntry<Commands>>[
///     new CheckedPopupMenuItem<Commands>(
///       checked: _heroAndScholar,
///       value: Commands.heroAndScholar,
///       child: const Text('Hero and scholar'),
///     ),
///     const PopupMenuDivider(),
///     const PopupMenuItem<Commands>(
///       value: Commands.hurricaneCame,
///       child: const ListTile(leading: const Icon(null), title: const Text('Bring hurricane')),
///     ),
///     // ...other items listed here
///   ],
/// )
/// ```
///
/// In particular, observe how the second menu item uses a [ListTile] with a
/// blank [Icon] in the [ListTile.leading] position to get the same alignment as
/// the item with the checkmark.
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for picking a command (as opposed to
///    toggling a value).
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class CheckedPopupMenuItem<T> extends PopupMenuItem<T> {
  /// Creates a popup menu item with a checkmark.
  ///
  /// By default, the menu item is [enabled] but unchecked. To mark the item as
  /// checked, set [checked] to true.
  ///
  /// The `checked` and `enabled` arguments must not be null.
  const CheckedPopupMenuItem({
    Key key,
    T value,
    this.checked: false,
    bool enabled: true,
    Widget child,
  })
      : super(
          key: key,
          value: value,
          enabled: enabled,
          child: child,
        );

  /// Whether to display a checkmark next to the menu item.
  ///
  /// Defaults to false.
  ///
  /// When true, an [Icons.done] checkmark is displayed.
  ///
  /// When this popup menu item is selected, the checkmark will fade in or out
  /// as appropriate to represent the implied new state.
  final bool checked;

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Text]. An appropriate [DefaultTextStyle] is put in scope for
  /// the child. The text should be short enough that it won't wrap.
  ///
  /// This widget is placed in the [ListTile.title] slot of a [ListTile] whose
  /// [ListTile.leading] slot is an [Icons.done] icon.
  @override
  Widget get child => super.child;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildCheckedPopupMenuItem(context, this);
  }
}

/// Show a popup menu that contains the `items` at `position`. If `initialValue`
/// is specified then the first item with a matching value will be highlighted
/// and the value of `position` implies where the left, center point of the
/// highlighted item should appear. If `initialValue` is not specified then
/// `position` specifies the menu's origin.
///
/// The `context` argument is used to look up a [Navigator] to show the menu and
/// a [Theme] to use for the menu.
///
/// The `elevation` argument specifies the z-coordinate at which to place the
/// menu. The elevation defaults to 8, the appropriate elevation for popup
/// menus.
///
/// The positioning of the `initialValue` at the `position` is implemented by
/// iterating over the `items` to find the first whose
/// [PopupMenuEntry.represents] method returns true for `initialValue`, and then
/// summing the values of [PopupMenuEntry.height] for all the preceding widgets
/// in the list.
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [CheckedPopupMenuItem], a popup menu item with a checkmark.
///  * [PopupMenuButton], which provides an [IconButton] that shows a menu by
///    calling this method automatically.
Future<T> showMenu<T>(
    {@required BuildContext context,
    RelativeRect position,
    @required List<PopupMenuEntry<T>> items,
    T initialValue,
    double elevation: 8.0}) {
  assert(context != null);
  assert(items != null && items.isNotEmpty);
  return flur.UIPlugin.current.showMenu(
      context: context,
      position: position,
      items: items,
      initialValue: initialValue,
      elevation: elevation);
}

/// Signature for the callback invoked when a menu item is selected. The
/// argument is the value of the [PopupMenuItem] that caused its menu to be
/// dismissed.
///
/// Used by [PopupMenuButton.onSelected].
typedef void PopupMenuItemSelected<T>(T value);

/// Signature used by [PopupMenuButton] to lazily construct the items shown when
/// the button is pressed.
///
/// Used by [PopupMenuButton.itemBuilder].
typedef List<PopupMenuEntry<T>> PopupMenuItemBuilder<T>(BuildContext context);

/// Displays a menu when pressed and calls [onSelected] when the menu is dismissed
/// because an item was selected. The value passed to [onSelected] is the value of
/// the selected menu item.
///
/// One of [child] or [icon] may be provided, but not both. If [icon] is provided,
/// then [PopupMenuButton] behaves like an [IconButton].
///
/// If both are null, then a standard overflow icon is created (depending on the
/// platform).
///
/// ## Sample code
///
/// This example shows a menu with four items, selecting between an enum's
/// values and setting a `_selection` field based on the selection.
///
/// ```dart
/// // This is the type used by the popup menu below.
/// enum WhyFarther { harder, smarter, selfStarter, tradingCharter }
///
/// // This menu button widget updates a _selection field (of type WhyFarther,
/// // not shown here).
/// new PopupMenuButton<WhyFarther>(
///   onSelected: (WhyFarther result) { setState(() { _selection = result; }); },
///   itemBuilder: (BuildContext context) => <PopupMenuEntry<WhyFarther>>[
///     const PopupMenuItem<WhyFarther>(
///       value: WhyFarther.harder,
///       child: const Text('Working a lot harder'),
///     ),
///     const PopupMenuItem<WhyFarther>(
///       value: WhyFarther.smarter,
///       child: const Text('Being a lot smarter'),
///     ),
///     const PopupMenuItem<WhyFarther>(
///       value: WhyFarther.selfStarter,
///       child: const Text('Being a self-starter'),
///     ),
///     const PopupMenuItem<WhyFarther>(
///       value: WhyFarther.tradingCharter,
///       child: const Text('Placed in charge of trading charter'),
///     ),
///   ],
/// )
/// ```
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [CheckedPopupMenuItem], a popup menu item with a checkmark.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
class PopupMenuButton<T> extends flur.StatelessUIPluginWidget {
  /// Creates a button that shows a popup menu.
  ///
  /// The [itemBuilder] argument must not be null.
  const PopupMenuButton({
    Key key,
    @required this.itemBuilder,
    this.initialValue,
    this.onSelected,
    this.tooltip: 'Show menu',
    this.elevation: 8.0,
    this.padding: const EdgeInsets.all(8.0),
    this.child,
    this.icon,
  })
      : super(key: key);

  /// Called when the button is pressed to create the items to show in the menu.
  final PopupMenuItemBuilder<T> itemBuilder;

  /// The value of the menu item, if any, that should be highlighted when the menu opens.
  final T initialValue;

  /// Called when the user selects a value from the popup menu created by this button.
  final PopupMenuItemSelected<T> onSelected;

  /// Text that describes the action that will occur when the button is pressed.
  ///
  /// This text is displayed when the user long-presses on the button and is
  /// used for accessibility.
  final String tooltip;

  /// The z-coordinate at which to place the menu when open. This controls the
  /// size of the shadow below the menu.
  ///
  /// Defaults to 8, the appropriate elevation for popup menus.
  final double elevation;

  /// Matches IconButton's 8 dps padding by default. In some cases, notably where
  /// this button appears as the trailing element of a list item, it's useful to be able
  /// to set the padding to zero.
  final EdgeInsets padding;

  /// If provided, the widget used for this button.
  final Widget child;

  /// If provided, the icon used for this button.
  final Icon icon;

  @override
  Widget buildWithUIPlugin(BuildContext context, flur.UIPlugin plugin) {
    return plugin.buildPopupMenuButton(context, this);
  }
}
