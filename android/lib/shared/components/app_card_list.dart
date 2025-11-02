import 'package:flutter/material.dart';

class AppCardList<T> extends StatelessWidget {
  /// Dữ liệu từ API
  final Future<List<T>> future;

  /// Số item tối đa hiển thị (mặc định 5)
  final int maxItems;

  /// Hàm tạo `ListTile` từ item + trailingText
  final Widget Function(T item, String? trailingText) itemBuilder;

  /// Hàm lấy text cho `trailing` (ngày, phiên bản, v.v.)
  final String? Function(T item)? trailingTextBuilder;

  /// Icon cho `leading`
  final IconData? leadingIcon;

  /// Có hiển thị `trailingText` không? (true: có ngày, false: chỉ mũi tên)
  final bool showTrailingText;

  const AppCardList({
    super.key,
    required this.future,
    this.maxItems = 5,
    required this.itemBuilder,
    this.trailingTextBuilder,
    this.leadingIcon,
    this.showTrailingText = true,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<T>>(
      future: future,
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error
        if (snapshot.hasError) {
          return Center(child: Text('Lỗi: ${snapshot.error}'));
        }

        // Empty
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('Không có dữ liệu'));
        }

        final items = snapshot.data!.take(maxItems).toList();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            primary: false,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final item = items[i];
              final trailingText = trailingTextBuilder?.call(item);

              return itemBuilder(item, trailingText);
            },
          ),
        );
      },
    );
  }
}
