import 'package:flutter/material.dart';
import 'static_chip.dart';
import 'all_topics_page.dart';

class TopicLibraryCard extends StatelessWidget {
  const TopicLibraryCard({required this.gap});
  final double gap;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(gap),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ô tìm kiếm
            TextField(
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
            SizedBox(height: gap),
            // Bộ lọc (chips)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                StaticChip(label: 'Đợt 2', selected: true),
                StaticChip(label: '2023'),
                StaticChip(label: 'AI'),
                StaticChip(label: 'Web'),
                StaticChip(label: 'Mobile'),
                StaticChip(label: 'IoT'),
              ],
            ),
            SizedBox(height: gap),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AllTopicsPage()),
                ),
                icon: const Icon(Icons.list_alt),
                label: const Text('Xem tất cả đề tài'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
