import 'package:flutter/material.dart';
import 'package:GPMS/features/home/models/de_tai.dart';
import 'package:GPMS/shared/components/topic_detail_page.dart';
import 'package:provider/provider.dart';
import 'package:GPMS/features/home/viewmodels/home_viewmodel.dart';

class AllTopicsPage extends StatefulWidget {
  const AllTopicsPage({super.key});

  @override
  State<AllTopicsPage> createState() => _AllTopicsPageState();
}

class _AllTopicsPageState extends State<AllTopicsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedDot;
  String? _selectedNamHoc;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });

    // Load topics từ ViewModel nếu chưa có
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<HomeViewModel>();
      if (viewModel.topics == null && !viewModel.isLoading) {
        viewModel.loadInitialData();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<DeTai> _filter(List<DeTai> list) {
    return list.where((dt) {
      final matchesSearch = dt.deTai.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesDot =
          _selectedDot == null || dt.idDotBaoVe.toString() == _selectedDot;
      final matchesNam =
          _selectedNamHoc == null || dt.namHoc == _selectedNamHoc;
      return matchesSearch && matchesDot && matchesNam;
    }).toList();
  }

  Set<String> _getUniqueDots(List<DeTai> list) {
    return list.map((e) => e.idDotBaoVe.toString()).toSet();
  }

  Set<String> _getUniqueNamHoc(List<DeTai> list) {
    return list.map((e) => e.namHoc).toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Tất cả đề tài',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF2563EB),
      ),
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          // Loading state
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Error state
          if (viewModel.hasError && viewModel.topics == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => viewModel.retry(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Empty state
          if (viewModel.topics == null || viewModel.topics!.isEmpty) {
            return const Center(child: Text('Không có đề tài'));
          }

          // Data available
          final allDeTai = viewModel.topics!;
          final filtered = _filter(allDeTai);
          final dots = _getUniqueDots(allDeTai);
          final namHocs = _getUniqueNamHoc(allDeTai);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm đề tài...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        DropdownButton<String>(
                          hint: const Text('Đợt'),
                          value: _selectedDot,
                          items: dots
                              .map(
                                (d) => DropdownMenuItem(
                                  value: d,
                                  child: Text('Đợt $d'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedDot = v),
                        ),
                        DropdownButton<String>(
                          hint: const Text('Năm học'),
                          value: _selectedNamHoc,
                          items: namHocs
                              .map(
                                (n) =>
                                    DropdownMenuItem(value: n, child: Text(n)),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => _selectedNamHoc = v),
                        ),
                        if (_selectedDot != null || _selectedNamHoc != null)
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _selectedDot = null;
                                _selectedNamHoc = null;
                              });
                            },
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Xóa bộ lọc'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy đề tài phù hợp',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async {
                          try {
                            await viewModel.refreshData();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Không thể làm mới: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: ListView.builder(
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final dt = filtered[i];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                child: const Icon(Icons.description, size: 18),
                              ),
                              title: Text(
                                dt.deTai,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('${dt.hocKy} - ${dt.namHoc}'),
                              trailing: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          TopicDetailPage(deTai: dt),
                                    ),
                                  );
                                },
                                child: const Text('Xem'),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
