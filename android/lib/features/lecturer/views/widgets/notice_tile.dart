import 'package:flutter/material.dart';

class NoticeTile extends StatelessWidget {
  const NoticeTile({
    required this.title,
    required this.subtitle,
    required this.badgeColor,
  });
  final String title;
  final String subtitle;
  final Color badgeColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: badgeColor,
        child: const Icon(Icons.notifications, size: 18),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
      onTap: () {},
    );
  }
}
