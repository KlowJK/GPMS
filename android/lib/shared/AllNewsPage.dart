import 'package:flutter/material.dart';
import 'models/thong_bao_va_tin_tuc.dart';
import 'package:intl/intl.dart';
import 'NewsDetailPage.dart';

class AllNewsPage extends StatefulWidget {
  final List<ThongBaoVaTinTuc> notifications;
  const AllNewsPage({super.key, required this.notifications});

  @override
  State<AllNewsPage> createState() => _AllNewsPageState();
}

class _AllNewsPageState extends State<AllNewsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ThongBaoVaTinTuc> get _filteredNotifications {
    if (_searchQuery.isEmpty) return widget.notifications;
    return widget.notifications
        .where(
          (n) =>
              (n.tieuDe.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              n.noiDung.toLowerCase().contains(_searchQuery.toLowerCase())),
        )
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).dividerColor),
      borderRadius: BorderRadius.circular(10),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tất cả tin tức',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: SafeArea(
        child: Material(
          color: Colors.white,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: _filteredNotifications.length + 1,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tin tức...',
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
                    onChanged: (q) {
                      setState(() => _searchQuery = q);
                    },
                    onSubmitted: (q) {
                      setState(() => _searchQuery = q);
                    },
                  ),
                );
              }
              final notification = _filteredNotifications[index - 1];
              final formattedDate = DateFormat(
                'dd/MM/yy',
              ).format(notification.ngayDang);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.campaign, size: 18),
                ),
                title: Text(notification.tieuDe),
                subtitle: Text(
                  notification.noiDung,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          NewsDetailPage(notification: notification),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
