import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
    required this.horizontalPadding,
  });

  final String title;
  final String actionText;
  final VoidCallback onAction;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(
      context,
    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600);
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          children: [
            Text(title, style: textStyle),
            const Spacer(),
            TextButton(onPressed: onAction, child: Text(actionText)),
          ],
        ),
      ),
    );
  }
}
