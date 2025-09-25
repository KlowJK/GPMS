import 'package:flutter/material.dart';

class TaskTile extends StatelessWidget {
  const TaskTile({
    required this.title,
    required this.subtitle,
    required this.actionText,
    this.statusColor,
    this.overdue = false,
  });

  final String title;
  final String subtitle;
  final String actionText;
  final Color? statusColor;
  final bool overdue;

  @override
  Widget build(BuildContext context) {
    final borderColor = statusColor ?? const Color(0xFFD1D5DB);
    return Container(
      color: overdue ? const Color(0xFFFEF2F2) : null,
      child: ListTile(
        leading: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: borderColor, width: 2),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        title: Text(title),
        subtitle: Row(
          children: [
            Text(subtitle),
            if (overdue) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Quá hạn',
                  style: TextStyle(color: Color(0xFF991B1B), fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        trailing: TextButton(onPressed: () {}, child: Text(actionText)),
        onTap: () {},
      ),
    );
  }
}
