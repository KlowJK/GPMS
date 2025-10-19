import 'package:GPMS/features/lecturer/models/student_supervised.dart';
import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';
import 'package:GPMS/features/lecturer/viewmodels/bao_cao_viewmodel.dart';

import 'package:GPMS/features/lecturer/views/screens/bao_cao/report_detail_screen.dart';

class SinhVienTab extends StatefulWidget {
  const SinhVienTab({super.key});

  @override
  State<SinhVienTab> createState() => _BaoCaoApiScreenState();
}

class _BaoCaoApiScreenState extends State<SinhVienTab> {
  late final BaoCaoService _service;
  late final BaoCaoViewModel _vm;
  late Future<List<StudentSupervised>> _futureSupervisedStudents;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  @override
  void initState() {
    super.initState();
    _service = BaoCaoService();
    _vm = BaoCaoViewModel(service: _service);
    _futureSupervisedStudents = _service.fetchSupervisedStudents();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text);
    });
    try {
      _vm.load();
    } catch (e, st) {
      debugPrint('BaoCaoViewModel.load() threw: $e\n$st');
    }
  }

  Future<void> _loadVersions() async {
    try {
      final future = _service.fetchSupervisedStudents();
      setState(() {
        _futureSupervisedStudents = future;
      });
      await future;
    } catch (e, st) {
      debugPrint('Failed to refresh supervised students: $e\n$st');
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadVersions,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
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
                                onChanged: (v) => setState(
                                  () => _query = v,
                                ), // update immediately
                                textInputAction: TextInputAction.search,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.search),
                                  hintText: 'Tìm kiếm sinh viên...',
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  suffixIcon: _query.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(
                                              () => _query = '',
                                            ); // ensure UI updates
                                          },
                                        )
                                      : null,
                                ),
                                onSubmitted: (_) {
                                  FocusScope.of(context).unfocus();
                                  setState(
                                    () {},
                                  ); // triggers rebuild and applies filter
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Danh sách sinh viên:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<List<StudentSupervised>>(
                    future: _futureSupervisedStudents,
                    builder: (ctx, sn) {
                      if (sn.connectionState == ConnectionState.waiting &&
                          (sn.data == null || sn.data!.isEmpty)) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (sn.hasError) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text('Lỗi khi tải sinh viên: ${sn.error}'),
                        );
                      }
                      final students = sn.data ?? [];

                      final q = _query.trim().toLowerCase();
                      final filtered = q.isEmpty
                          ? students
                          : students.where((s) {
                              final target = '${s.hoTen ?? ''} ${s.maSV ?? ''} '
                                  .toLowerCase();
                              return target.contains(q);
                            }).toList();

                      if (filtered.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Không có sinh viên'),
                        );
                      }
                      return Column(
                        children: filtered.map((s) {
                          // dart
                          final statusKey = s.trangThaiBaoCao;
                          String statusLabel;
                          Color statusColor;

                          switch (statusKey) {
                            case 'CHO_DUYET':
                              statusLabel = 'Chờ duyệt';
                              statusColor = Colors.amber;
                              break;
                            case 'DA_DUYET':
                              statusLabel = 'Đã duyệt';
                              statusColor = const Color(0xFF16A34A);
                              break;
                            case 'TU_CHOI':
                              statusLabel = 'Từ chối';
                              statusColor = const Color(0xFFDC2626);
                              break;
                            default:
                              statusLabel = statusKey ?? '-';
                              statusColor = Colors.grey;
                          }

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                              title: Text(s.hoTen ?? s.maSV ?? '-'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s.tenLop ?? '-',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Đề tài: ${s.tenDeTai ?? '-'}',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              trailing: Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              onTap: () {
                                final studentSupervised = StudentSupervised(
                                  hoTen: s.hoTen ?? '-',
                                  maSV: s.maSV ?? '-',
                                  tenLop: s.tenLop ?? '-',
                                  tenDeTai: s.tenDeTai ?? '-',
                                  trangThaiBaoCao:
                                      statusLabel, // or map to your ReportStatus enum if needed
                                );

                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ReportDetailScreen(
                                      student: studentSupervised,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
