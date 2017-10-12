import 'package:flutter/material.dart';

const double _kChipHeight = 32.0;
const double _kAvatarDiamater = _kChipHeight;

const TextStyle _kLabelStyle = const TextStyle(
  inherit: false,
  fontSize: 13.0,
  fontWeight: FontWeight.w400,
  color: Colors.black87,
  textBaseline: TextBaseline.alphabetic,
);

@override
Widget buildChip(BuildContext context, Chip widget) {
  assert(debugCheckHasMaterial(context));
  final bool deletable = widget.onDeleted != null;
  double startPadding = 12.0;
  double endPadding = 12.0;

  final List<Widget> children = <Widget>[];

  if (widget.avatar != null) {
    startPadding = 0.0;
    children.add(new ExcludeSemantics(
      child: new Container(
        margin: const EdgeInsetsDirectional.only(end: 8.0),
        width: _kAvatarDiamater,
        height: _kAvatarDiamater,
        child: widget.avatar,
      ),
    ));
  }

  children.add(new Flexible(
    child: new DefaultTextStyle(
      style: widget.labelStyle ?? _kLabelStyle,
      child: widget.label,
    ),
  ));

  if (deletable) {
    endPadding = 0.0;
    children.add(new GestureDetector(
      onTap: Feedback.wrapForTap(widget.onDeleted, context),
      child: new Tooltip(
        message:
            widget.deleteButtonTooltipMessage ?? 'Delete "${widget.label}"',
        child: new Container(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: new Icon(
            Icons.cancel,
            size: 18.0,
            color: widget.deleteIconColor ?? Colors.black54,
          ),
        ),
      ),
    ));
  }

  return new Semantics(
    container: true,
    child: new Container(
      height: _kChipHeight,
      padding:
          new EdgeInsetsDirectional.only(start: startPadding, end: endPadding),
      decoration: new BoxDecoration(
        color: widget.backgroundColor ?? Colors.grey.shade300,
        borderRadius: new BorderRadius.circular(16.0),
      ),
      child: new Row(
        children: children,
        mainAxisSize: MainAxisSize.min,
      ),
    ),
  );
}
