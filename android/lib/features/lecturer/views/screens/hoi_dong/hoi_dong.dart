import 'dart:async';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_item.dart';
import 'package:GPMS/features/lecturer/services/hoi_dong_service.dart';

class HoiDong extends StatefulWidget {
  const HoiDong({super.key});
  @override
  State<HoiDong> createState() => _HoiDongState();
}

class _HoiDongState extends State<HoiDong> {
  final _items = <HoiDongItem>[];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ⬇️ Gọi alias static trong service (service tự lấy teacherId từ AuthService)
      final list = await HoiDongService.listByLecturer();

      setState(() {
        _items
          ..clear()
          ..addAll(list);
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  (String, Color) _statusOf(DateTime? from, DateTime? to) {
    if (from == null && to == null) {
      return ('Chưa đặt lịch', Colors.grey.shade700);
    }
    if (from == null || to == null) {
      return ('Thiếu thông tin lịch', const Color(0xFFC9B325));
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);
    if (today.isBefore(start)) return ('Sắp diễn ra', const Color(0xFF0EB216));
    if (today.isAfter(end)) return ('Đã kết thúc', const Color(0xFFDC2626));
    return ('Đang diễn ra', const Color(0xFF1D4ED8));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Hội đồng', style: TextStyle(fontWeight: FontWeight.w700)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Danh sách hội đồng phản biện:',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ),
            Expanded(
              child: _error != null
                  ? _ErrorView(message: _error!, onRetry: _load)
                  : _loading
                  ? const Center(child: CircularProgressIndicator())
                  : (_items.isEmpty
                  ? const Center(child: Text('Không có hội đồng nào.'))
                  : RefreshIndicator(
                onRefresh: _load,
                child: ListView.separated(
                  padding:
                  const EdgeInsets.fromLTRB(12, 4, 12, 24),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 10),
                  itemBuilder: (_, i) {
                    final c = _items[i];
                    final status =
                    _statusOf(c.thoiGianBatDau, c.thoiGianKetThuc);
                    return _CouncilCard(
                      name: c.tenHoiDong,
                      from: c.thoiGianBatDau,
                      to: c.thoiGianKetThuc,
                      statusText: status.$1,
                      statusColor: status.$2,
                    );
                  },
                ),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class _CouncilCard extends StatelessWidget {
  const _CouncilCard({
    required this.name,
    required this.from,
    required this.to,
    required this.statusText,
    required this.statusColor,
  });

  final String name;
  final DateTime? from;
  final DateTime? to;
  final String statusText;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    String two(int x) => x.toString().padLeft(2, '0');
    String fmt(DateTime? d) =>
        d == null ? '—' : '${two(d.day)}/${two(d.month)}/${d.year}';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE4F6FF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Color(0x19000000), blurRadius: 3, offset: Offset(0, 1)),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFDBEAFE),
            child: Icon(Icons.apartment_outlined, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelValue('Tên hội đồng:', name),
                _labelValue('Ngày bảo vệ:', '${fmt(from)} - ${fmt(to)}'),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text('Trạng thái: ',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                    Flexible(
                      child: Text(
                        statusText,
                        style: TextStyle(
                            color: statusColor, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelValue(String label, String value) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      children: [
        TextSpan(
            text: '$label ', style: const TextStyle(fontWeight: FontWeight.w700)),
        TextSpan(
            text: value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 16),
      Icon(Icons.error_outline,
          color: Theme.of(context).colorScheme.error, size: 32),
      const SizedBox(height: 8),
      Text('Lỗi: $message', style: Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height: 12),
      FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh),
          label: const Text('Thử lại')),
    ],
  );
}
