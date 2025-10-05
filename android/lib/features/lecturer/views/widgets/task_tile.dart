import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.title,
    required this.subtitle,
    required this.actionText,
  });
  final String title;
  final String subtitle;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: const Icon(Icons.task_alt, size: 18),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: Text(actionText)),
      onTap: () {},
    );
  }
}
