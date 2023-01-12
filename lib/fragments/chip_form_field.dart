import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ChipFormField extends StatelessWidget {
  final List<Widget> chips;
  final List<int> selectedIndexes;
  final InputDecoration decoration;

  final void Function(List<int> newSelection)? onSelectionChange;
  final void Function(int idx)? onSelectionAdded;
  final void Function(int idx)? onSelectionRemoved;

  ChipFormField({
    this.decoration = const InputDecoration(),
    required this.chips,
    required this.selectedIndexes,
    this.onSelectionChange,
    this.onSelectionAdded,
    this.onSelectionRemoved,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InputDecorator(
      decoration: decoration,
      child: Wrap(
        children: _buildChips(context),
        spacing: 8,
        runSpacing: 4,
      ),
    );
  }

  List<Widget> _buildChips(context) => chips
      .asMap()
      .map<int, Widget>((int i, Widget e) => MapEntry(
            i,
            FilterChip(
              label: e,
              selected: selectedIndexes.contains(i),
              onSelected: (bool value) => _setIndex(i, value),
            ),
          ))
      .values
      .toList();

  void _setIndex(int idx, bool value) {
    if (value && !selectedIndexes.contains(idx)) {
      if (onSelectionAdded != null) onSelectionAdded!(idx);
      if (onSelectionChange != null) onSelectionChange!(selectedIndexes..add(idx));
    } else if (!value && selectedIndexes.contains(idx)) {
      if (onSelectionRemoved != null) onSelectionRemoved!(idx);
      if (onSelectionChange != null) onSelectionChange!(selectedIndexes..remove(idx));
    }
  }
}
