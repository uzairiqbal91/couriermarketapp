import 'package:flutter/material.dart';

class LabelSet extends StatelessWidget {
  final dynamic labelText;
  final dynamic valueText;
  final dynamic fallback;

  final EdgeInsetsGeometry padding;
  final Axis direction;
  final MainAxisSize mainAxisSize;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;

  final Widget? spacer;

  const LabelSet(
    this.labelText,
    this.valueText, {
    this.fallback = "n/a",
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.direction = Axis.horizontal,
    this.spacer = const SizedBox(width: 2),
    Key? key,
  }) : super(key: key);

  const LabelSet.vertical(
    this.labelText,
    this.valueText, {
    this.fallback = "n/a",
    this.padding = const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacer,
    Key? key,
  })  : this.direction = Axis.vertical,
        super(key: key);

  @override
  Widget build(BuildContext context) => Padding(
        padding: this.padding,
        child: Flex(
          direction: this.direction,
          mainAxisSize: this.mainAxisSize,
          mainAxisAlignment: this.mainAxisAlignment,
          crossAxisAlignment: this.crossAxisAlignment,
          children: (<Widget?>[
            DefaultTextStyle.merge(
              style: TextStyle(fontWeight: FontWeight.bold),
              child: this.labelText.runtimeType == String ? Text(this.labelText) : labelText,
            ),
            if (this.spacer != null) this.spacer,
            DefaultTextStyle.merge(
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: isValueNull ? FontWeight.w300 : null),
              child: effectiveValue()!,
            ),
          ]).where((element) => element != null).toList() as List<Widget>,
        ),
      );

  bool get isValueNull => this.valueText == null;

  Widget? effectiveValue() {
    if (isValueNull) return this.fallback.runtimeType == String ? Text(this.fallback) : fallback;
    return this.valueText.runtimeType == String ? Text(this.valueText) : this.valueText;
  }
}
