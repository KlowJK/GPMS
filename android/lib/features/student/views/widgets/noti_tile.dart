import 'package:flutter/material.dart';

class NotiTile extends StatelessWidget {
  const NotiTile({
    required this.color,
    required this.title,
    required this.subtitle,
    this.warn = false,
  });
  final Color color;
  final String title;
  final String subtitle;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color,
        child: Icon(
          warn ? Icons.warning_amber_rounded : Icons.notifications,
          size: 18,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
      onTap: () {},
    );
  }
}
