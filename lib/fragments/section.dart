import 'package:flutter/material.dart';

class Section extends StatelessWidget {
  final Widget child;
  final Widget? title;
  final Widget? trailing;
  final bool? centerTitle;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  Section({
    required this.child,
    this.title,
    this.trailing,
    this.centerTitle,
    this.margin = const EdgeInsets.all(8),
    this.padding = const EdgeInsets.all(16),
    Key? key,
  }) : super(key: key);

  _getEffectiveCenterTitle(ThemeData theme) {
    if (this.centerTitle != null) return this.centerTitle;
    switch (theme.platform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var titleBar;
    if ((title != null) || (trailing != null)) {
      List<Widget> children = [];
      if (title != null) children.add(Expanded(child: title!));
      if (trailing != null) children.add(trailing!);
      titleBar = Row(
        //TODO(AAllport): Use a stack or something to get some  better layouting on IOS
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: children,
      );
    }

    var content = titleBar == null
        ? child
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              DefaultTextStyle(
                style: Theme.of(context).textTheme.subtitle1!,
                textAlign: _getEffectiveCenterTitle(Theme.of(context)) ? TextAlign.center : TextAlign.start,
                child: titleBar,
              ),
              Divider(),
              child,
            ],
          );

    return Card(
      margin: this.margin,
      child: Padding(
        padding: this.padding,
        child: content,
      ),
    );
  }
}
