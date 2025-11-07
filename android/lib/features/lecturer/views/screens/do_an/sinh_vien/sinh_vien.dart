import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/lecturer/models/sinh_vien_item.dart';
import 'package:GPMS/features/lecturer/viewmodels/sinh_vien_viewmodel.dart';
import 'package:GPMS/features/lecturer/views/screens/do_an/chi_tiet_de_tai.dart';
import 'package:GPMS/core/exception/error_code.dart';
import 'package:GPMS/features/lecturer/viewmodels/de_cuong_viewmodel.dart';
import 'package:GPMS/features/lecturer/models/chi_tiet_de_tai_args.dart';

String _txt(String? s, {String fb = '—'}) =>
    (s == null || s.trim().isEmpty) ? fb : s.trim();

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => _SinhVienTabState();
}

class _SinhVienTabState extends State<SinhVienTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<SinhVienViewModel>(
      builder: (context, vm, _) {
        return Column(
          children: [
            // Header with search box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Search box
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) => vm.setSearchQuery(query),
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search),
                        hintText: 'Tìm kiếm sinh viên...',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        suffixIcon: vm.searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  vm.clearSearch();
                                },
                              )
                            : null,
                      ),
                      onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Title with count
                  Row(
                    children: [
                      Text(
                        'Danh sách sinh viên (${vm.filteredCount})',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Body
            Expanded(child: _buildBody(vm)),
          ],
        );
      },
    );
  }

  Widget _buildBody(SinhVienViewModel vm) {
    // Error state
    if (vm.hasError && vm.items.isEmpty) {
      return _ErrorView(
        message: vm.error!,
        errorCode: vm.errorCode,
        onRetry: () => vm.retry(),
      );
    }

    // Loading state
    if (vm.isLoading && vm.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Empty state (after search or no data)
    if (vm.filteredItems.isEmpty) {
      return _EmptyCenter(
        text: vm.searchQuery.isNotEmpty
            ? 'Không tìm thấy sinh viên phù hợp'
            : 'Không có sinh viên.',
      );
    }

    // List with refresh
    return RefreshIndicator(
      onRefresh: () => vm.fetchList(),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
        itemCount: vm.filteredItems.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final item = vm.filteredItems[i];
          return _SinhVienCard(
            item: item,
            onTap: () => _navigateToDetail(context, item),
          );
        },
      ),
    );
  }

  void _navigateToDetail(BuildContext context, SinhVienItem item) {
    // Get DeCuongViewModel from context to pass to detail screen
    final deCuongVm = context.read<DeCuongViewModel>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: deCuongVm,
          child: ChiTietDeTai(
            data: ChiTietDeTaiArgs(
              maSV: _txt(item.maSV),
              hoTen: _txt(item.hoTen),
              tenLop: _txt(item.tenLop),
              soDienThoai: _txt(item.soDienThoai),
              tenDeTai: _txt(item.tenDeTai),
              cvUrl: item.cvUrl,
            ),
          ),
        ),
      ),
    );
  }
}

class _SinhVienCard extends StatelessWidget {
  const _SinhVienCard({required this.item, this.onTap});

  final SinhVienItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF9FAFB),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFDBEAFE),
                child: Icon(Icons.person, color: Colors.black54),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _txt(item.hoTen, fb: 'Sinh viên'),
                            style: Theme.of(context).textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _txt(item.maSV),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _txt(item.tenLop),
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Đề tài: ${_txt(item.tenDeTai)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyCenter extends StatelessWidget {
  const _EmptyCenter({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
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
      ),
    );
  }
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
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Icon(
          Icons.error_outline,
          color: Theme.of(context).colorScheme.error,
          size: 36,
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
}
