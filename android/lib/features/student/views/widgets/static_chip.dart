import 'package:flutter/material.dart';

class StaticChip extends StatelessWidget {
  const StaticChip({required this.label, this.selected = false});
  final String label;
  final bool selected;
  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {},
      showCheckmark: false,
      shape: const StadiumBorder(),
    );
  }
}
