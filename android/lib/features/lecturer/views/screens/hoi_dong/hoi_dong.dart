import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/models/hoi_dong_item.dart';
import 'package:GPMS/features/lecturer/viewmodels/hoi_dong_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/widgets/custom_app_bar.dart';
import 'package:GPMS/features/lecturer/views/screens/hoi_dong/hoi_dong_detail_screen.dart';
import 'package:GPMS/core/exception/error_code.dart';

class HoiDongScreen extends StatefulWidget {
  const HoiDongScreen({super.key, required this.teacherId});
  final int teacherId;

  @override
  State<HoiDongScreen> createState() => _HoiDongScreenState();
}

class _HoiDongScreenState extends State<HoiDongScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<HoiDongViewModel>();
      vm.fetchByLecturer(idGiangVien: widget.teacherId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HoiDongViewModel>(
      builder: (context, vm, _) {
        return Scaffold(
          appBar: const CustomAppBar(),
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Danh sách hội đồng phản biện:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                Expanded(child: _buildBody(vm)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(HoiDongViewModel vm) {
    if (vm.hasError && vm.items.isEmpty) {
      return _ErrorView(
        message: vm.error!,
        errorCode: vm.errorCode,
        onRetry: () => vm.fetchByLecturer(idGiangVien: widget.teacherId),
      );
    }

    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.items.isEmpty) {
      return const _EmptyView(text: 'Không có hội đồng nào');
    }

    return RefreshIndicator(
      onRefresh: () => vm.fetchByLecturer(idGiangVien: widget.teacherId),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
        itemCount: vm.items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final c = vm.items[i];
          final status = _getStatus(c.thoiGianBatDau, c.thoiGianKetThuc);
          return _CouncilCard(
            council: c,
            statusText: status.$1,
            statusColor: status.$2,
            diaDiem: c.diaDiem,
            onTap: () => _navigateToDetail(context, vm, c),
          );
        },
      ),
    );
  }

  void _navigateToDetail(
    BuildContext context,
    HoiDongViewModel vm,
    HoiDongItem council,
  ) {
    if (council.id == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: vm,
          child: HoiDongDetailScreen(
            hoiDongId: council.id!,
            hoiDongName: council.tenHoiDong ?? 'Hội đồng',
          ),
        ),
      ),
    );
  }

  (String, Color) _getStatus(DateTime? from, DateTime? to) {
    if (from == null && to == null)
      return ('Chưa đặt lịch', Colors.grey.shade700);
    if (from == null || to == null)
      return ('Thiếu thông tin lịch', const Color(0xFFC9B325));

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(from.year, from.month, from.day);
    final end = DateTime(to.year, to.month, to.day);

    if (today.isBefore(start)) return ('Sắp diễn ra', const Color(0xFF0EB216));
    if (today.isAfter(end)) return ('Đã kết thúc', const Color(0xFFDC2626));
    return ('Đang diễn ra', const Color(0xFF1D4ED8));
  }
}

class _CouncilCard extends StatelessWidget {
  const _CouncilCard({
    required this.council,
    required this.statusText,
    required this.statusColor,
    required this.onTap,
    this.diaDiem,
  });

  final HoiDongItem council;
  final String statusText;
  final Color statusColor;
  final String? diaDiem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
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
                  _labelValue('${council.tenHoiDong}' ?? '-', ''),
                  const SizedBox(height: 6),

                  // status row removed from here
                  Row(
                    children: [
                      const Text(
                        'Địa điểm: ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Flexible(
                        child: Text(
                          diaDiem ?? 'Chưa xác định',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  _labelValue(
                    'Ngày diễn ra:',
                    '${_fmt(council.thoiGianBatDau)} - ${_fmt(council.thoiGianKetThuc)}',
                  ),
                ],
              ),
            ),

            IntrinsicWidth(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      statusText,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value) => RichText(
    text: TextSpan(
      style: const TextStyle(color: Colors.black87, fontSize: 14),
      children: [
        TextSpan(
          text: '$label ',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        TextSpan(
          text: value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    ),
  );

  String _fmt(DateTime? d) {
    if (d == null) return '—';
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.info_outline,
          size: 40,
          color: Theme.of(context).disabledColor,
        ),
        const SizedBox(height: 8),
        Text(text, textAlign: TextAlign.center),
      ],
    ),
  );
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    this.errorCode,
    required this.onRetry,
  });
  final String message;
  final ErrorCode? errorCode;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(24),
    children: [
      const SizedBox(height: 16),
      Icon(
        Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        size: 32,
      ),
      const SizedBox(height: 8),
      Text(
        'Lỗi: $message',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      const SizedBox(height: 12),
      FilledButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh),
        label: const Text('Thử lại'),
      ),
    ],
  );
}
