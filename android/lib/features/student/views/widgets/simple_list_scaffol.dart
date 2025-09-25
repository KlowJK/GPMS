import 'package:flutter/material.dart';

class SimpleListScaffold extends StatelessWidget {
  const SimpleListScaffold({
    required this.title,
    required this.items,
    required this.icon,
  });
  final String title;
  final List<(String, String)> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final (t, s) = items[i];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Icon(icon, size: 18),
            ),
            title: Text(t),
            subtitle: Text(s),
            trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
            onTap: () {},
          );
        },
      ),
    );
  }
}
