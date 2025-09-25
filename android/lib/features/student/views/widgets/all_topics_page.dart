import 'package:flutter/material.dart';

class AllTopicsPage extends StatelessWidget {
  const AllTopicsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      30,
      (i) => ('Đề tài số ${i + 1}', 'Học kỳ 2 - 9/2025'),
    );
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Tất cả đề tài')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: items.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm đề tài...',
                    prefixIcon: const Icon(Icons.search),
                    border: border,
                    enabledBorder: border,
                    focusedBorder: border.copyWith(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    isDense: true,
                  ),
                  onSubmitted: (q) {},
                ),
              );
            }
            final (title, subtitle) = items[index - 1];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: const Icon(Icons.folder, size: 18),
              ),
              title: Text(title),
              subtitle: Text(subtitle),
              trailing: TextButton(onPressed: () {}, child: const Text('Xem')),
              onTap: () {},
            );
          },
        ),
      ),
    );
  }
}
