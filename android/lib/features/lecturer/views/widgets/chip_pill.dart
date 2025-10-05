import 'package:flutter/material.dart';

class ChipPill extends StatelessWidget {
  const ChipPill({required this.label, this.selected = false});
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      showCheckmark: false,
      selectedColor: cs.primaryContainer,
      shape: const StadiumBorder(),
    );
  }
}
