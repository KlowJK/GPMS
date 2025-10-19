import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';
import 'package:GPMS/features/lecturer/viewmodels/bao_cao_viewmodel.dart';
import 'package:url_launcher/url_launcher.dart';

class DuyetBaoCao extends StatefulWidget {
  const DuyetBaoCao({super.key});

  @override
  State<DuyetBaoCao> createState() => _BaoCaoApiScreenState();
}

class _BaoCaoApiScreenState extends State<DuyetBaoCao> {
  late final BaoCaoService _service;
  late final BaoCaoViewModel _vm;
  late Future<List<ReportSubmission>> _futureReports;
  bool _initialLoad = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _service = BaoCaoService();
    _vm = BaoCaoViewModel(service: _service);

    _futureReports = _service.fetchList(
      status: BaoCaoViewModel.STATUS_CHO_DUYET,
    );

    // when the initial future completes, clear the initial-load flag
    _futureReports.whenComplete(() {
      if (mounted) setState(() => _initialLoad = false);
    });

    _vm.load(status: BaoCaoViewModel.STATUS_CHO_DUYET);
  }

  Future<void> _loadVersions() async {
    setState(() => _isRefreshing = true);

    final future = _service.fetchList(
      status: _vm.statusFilter ?? BaoCaoViewModel.STATUS_CHO_DUYET,
    );
    setState(() {
      _futureReports = future;
    });
    try {
      await future;
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  String _fmtDateShort(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
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
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'Danh sách báo cáo:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<List<ReportSubmission>>(
                    future: _futureReports,
                    builder: (ctx, snapshot) {
                      final reports = snapshot.data ?? [];
                      final isWaiting =
                          snapshot.connectionState == ConnectionState.waiting;
                      final hasError = snapshot.hasError;

                      if (isWaiting && _initialLoad && reports.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 12),
                                Text('Đang tải báo cáo...'),
                              ],
                            ),
                          ),
                        );
                      }

                      if (hasError) {
                        return Center(
                          child: Text('Lỗi khi tải dữ liệu: ${snapshot.error}'),
                        );
                      }

                      if (reports.isEmpty) {
                        return const Center(child: Text('Không có báo cáo'));
                      }
                      return Column(
                        children: reports.map((r) {
                          var student = StudentReport(
                            maSinhVien: r.maSinhVien ?? '-',
                            hoTenSV: r.tenSinhVien ?? '-',
                            file: r.duongDanFile ?? '-',
                            deTai: r.tenDeTai ?? '-',
                            phienBan: r.phienBan ?? 1,
                            trangThai: r.trangThai == 'DA_DUYET'
                                ? ReportStatus.submitted
                                : (r.trangThai == 'TU_CHOI')
                                ? ReportStatus.notSubmitted
                                : ReportStatus.pending,
                            ngayNop: r.ngayNop ?? DateTime.now(),
                            id: r.id,
                            lop: r.lop ?? '-',
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _StudentReportCard(
                              info: student,
                              vm: _vm,
                              onRefresh: _loadVersions,
                              onTap: () {},
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

class _HeaderBlock extends StatelessWidget {
  const _HeaderBlock({
    required this.from,
    required this.to,
    required this.title,
  });

  final DateTime from;
  final DateTime to;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ThreeBullets(),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Ngày bắt đầu : ${_fmtDateTime(from)}\n'
                'Ngày kết thúc : ${_fmtDateTime(to)}\n'
                '$title :',

                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _fmtDateTime(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}-${two(d.month)}-${d.year} '
        '${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }
}

class _ThreeBullets extends StatelessWidget {
  const _ThreeBullets();

  @override
  Widget build(BuildContext context) {
    Widget dot() => Opacity(
      opacity: 0.5,
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: 1.5, color: const Color(0xFFFFDD00)),
        ),
      ),
    );
    return Column(children: [dot(), dot(), dot()]);
  }
}

class _StudentReportCard extends StatefulWidget {
  const _StudentReportCard({
    required this.info,
    required this.onTap,
    required this.vm,
    required this.onRefresh,
    Key? key,
  }) : super(key: key);

  final StudentReport info;
  final VoidCallback onTap;
  final BaoCaoViewModel vm;
  final Future<void> Function() onRefresh;
  @override
  State<_StudentReportCard> createState() => _StudentReportCardState();
}

class _StudentReportCardState extends State<_StudentReportCard> {
  late ApproveStatus _status;
  double? _score;
  final TextEditingController _rejectReasonController = TextEditingController();

  Future<String?> _showRejectDialog() async {
    final _formKey = GlobalKey<FormState>();
    final _ctrl = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Lý do từ chối'),
        content: Form(
          key: _formKey,
          child: TextFormField(
            controller: _ctrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Nhập lý do...'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Vui lòng nhập lý do' : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(null),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
            ),
            onPressed: () {
              if (_formKey.currentState?.validate() ?? false) {
                Navigator.of(ctx).pop(_ctrl.text.trim());
              }
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _status = widget.info.trangThai == ReportStatus.pending
        ? ApproveStatus.pending
        : ApproveStatus.approved;
    _score = null;
  }

  Color statusColor(ReportStatus s) => s == ReportStatus.submitted
      ? const Color(0xFF00C409)
      : (s == ReportStatus.pending
            ? const Color(0xFFFFDD00)
            : const Color(0xFF6B7280));

  String statusText(ReportStatus s) => s == ReportStatus.submitted
      ? 'Đã duyệt'
      : (s == ReportStatus.pending ? 'Chờ duyệt' : 'Từ chối');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: widget.onTap,
      child: Card(
        elevation: 1,
        color: const Color(0xFFF1F3F6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.info.deTai,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.info.hoTenSV} - ${widget.info.maSinhVien}',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 2),
                      ],
                    ),
                  ),

                  // Status column placed at top-right
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          style: Theme.of(context).textTheme.bodyMedium,
                          children: [
                            TextSpan(
                              text: statusText(widget.info.trangThai),
                              style: TextStyle(
                                color: statusColor(widget.info.trangThai),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  const Text('File: '),
                  Flexible(
                    child: InkWell(
                      onTap: () async {
                        final url = widget.info.file;
                        if (url == null || !url.startsWith('http')) return;
                        final uri = Uri.parse(url);
                        if (!await canLaunchUrl(uri)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không thể mở tệp')),
                          );
                          return;
                        }
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                      child: Text(
                        (widget.info.file ?? '').startsWith('http')
                            ? 'Xem chi tiết'
                            : '—',
                        style: TextStyle(
                          decoration:
                              (widget.info.file ?? '').startsWith('http')
                              ? TextDecoration.underline
                              : TextDecoration.none,
                          color: (widget.info.file ?? '').startsWith('http')
                              ? Colors.blue
                              : Colors.black54,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Text(
                    'Phiên bản: ${widget.info.phienBan}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              Text(
                'Ngày nộp: ${widget.info.ngayNop.day}/${widget.info.ngayNop.month}/${widget.info.ngayNop.year}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (widget.info.trangThai == ReportStatus.pending)
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          final reason = await _showRejectDialog();
                          if (reason == null) return;

                          final idBaoCao = widget.info.id;

                          if (idBaoCao == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Không thể từ chối: thiếu id báo cáo',
                                ),
                              ),
                            );
                            return;
                          }

                          final ok = await widget.vm.reject(
                            idBaoCao: idBaoCao,
                            nhanXet: reason,
                          );
                          if (ok) {
                            setState(() {
                              _status = ApproveStatus.rejected;
                              _score = null;
                            });
                            // trigger parent reload
                            await widget.onRefresh();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Từ chối thất bại')),
                            );
                          }
                        },
                        child: const Text('Từ chối'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F7CD3),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () async {
                          final result = await showDialog<Map<String, dynamic>>(
                            context: context,
                            builder: (ctx) => GradeSheetDialog(
                              studentName: widget.info.hoTenSV,
                              studentId: widget.info.maSinhVien,
                              topic: widget.info.deTai,
                              className: widget.info.lop ?? '',
                            ),
                          );
                          if (result != null) {
                            final total = (result['total'] as double?) ?? 0.0;
                            final comment =
                                (result['comment'] as String?) ?? '';

                            final idBaoCao = widget.info.id;
                            if (idBaoCao == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Không thể duyệt: thiếu id báo cáo',
                                  ),
                                ),
                              );
                              return;
                            }

                            final ok = await widget.vm.approve(
                              idBaoCao: idBaoCao,
                              diemHuongDan: total,
                              nhanXet: comment.isEmpty ? null : comment,
                            );

                            if (ok) {
                              setState(() {
                                _status = ApproveStatus.approved;
                                _score = total;
                              });
                              await widget.onRefresh();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Duyệt thất bại')),
                              );
                            }
                          }
                        },
                        child: const Text('Duyệt'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum ApproveStatus { pending, approved, rejected }

class ReportVersion {
  int version;
  String date;
  String file;
  ApproveStatus status;
  double? score;

  ReportVersion({
    required this.version,
    required this.date,
    required this.file,
    required this.status,
    this.score,
  });
}

class ReportVersionCard extends StatefulWidget {
  const ReportVersionCard({
    super.key,
    required this.version,
    required this.student,
  });

  final ReportVersion version;
  final StudentReport student;

  @override
  State<ReportVersionCard> createState() => _ReportVersionCardState();
}

class _ReportVersionCardState extends State<ReportVersionCard> {
  late ApproveStatus _status;
  late double? _score;

  @override
  void initState() {
    super.initState();
    _status = widget.version.status;
    _score = widget.version.score;
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = _status == ApproveStatus.approved;
    final isRejected = _status == ApproveStatus.rejected;

    Color borderColor = Colors.grey.shade300;
    if (isApproved) borderColor = const Color(0xFF22C55E);
    if (isRejected) borderColor = const Color(0xFFEF4444);

    return Card(
      color: const Color(0xFFE4F6FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Phiên bản ${widget.version.version}:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),
            Text('Ngày nộp: ${widget.version.date}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('File: '),
                Flexible(
                  child: Text(
                    widget.version.file,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                if (_status != ApproveStatus.pending) ...[
                  Text(
                    _status == ApproveStatus.approved
                        ? 'Trạng thái: Đã duyệt'
                        : 'Trạng thái: Từ chối',
                    style: TextStyle(
                      color: _status == ApproveStatus.approved
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  if (_score != null)
                    Text(
                      'Điểm: ${_score!.toStringAsFixed(1)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Nút hành động (ẩn khi không còn pending)
            if (_status == ApproveStatus.pending)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () => setState(() {
                        _status = ApproveStatus.rejected;
                        _score = null;
                      }),
                      child: const Text('Từ chối'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7CD3),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      onPressed: () async {
                        final total = await showDialog<double>(
                          context: context,
                          builder: (ctx) => GradeSheetDialog(
                            studentName: widget.student.hoTenSV,
                            studentId: widget.student.maSinhVien,
                            topic: widget.student.deTai,
                            className: widget.student.lop ?? '',
                          ),
                        );
                        if (total != null) {
                          setState(() {
                            _status = ApproveStatus.approved;
                            _score = total;
                          });
                        }
                      },
                      child: const Text('Duyệt'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class GradeSheetDialog extends StatefulWidget {
  const GradeSheetDialog({
    super.key,
    this.studentName = '',
    this.studentId = '',
    this.topic = '',
    this.className = '',
  });

  final String studentName;
  final String studentId;
  final String topic;
  final String className;

  @override
  State<GradeSheetDialog> createState() => _GradeSheetDialogState();
}

class _GradeSheetDialogState extends State<GradeSheetDialog> {
  final _f1 = TextEditingController();
  final _f2 = TextEditingController();
  final _f3 = TextEditingController();
  final _commentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  double _total = 0;

  double _p(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  void _recalc() {
    setState(() {
      _total = (_p(_f1) + _p(_f2) + _p(_f3)) / 3;
    });
  }

  InputDecoration _boxDec() => const InputDecoration(
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    border: OutlineInputBorder(),
  );

  @override
  void dispose() {
    _f1.dispose();
    _f2.dispose();
    _f3.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      titlePadding: const EdgeInsets.only(top: 12),
      contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      title: const Center(
        child: Text(
          'Phiếu điểm',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      content: SingleChildScrollView(
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black.withOpacity(0.5)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Họ tên:', widget.studentName),
                _infoRow('Mã sinh viên:', widget.studentId),
                _infoRow('Lớp:', widget.className),
                const SizedBox(height: 6),
                const SizedBox(height: 6),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Đề tài: ',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          TextSpan(
                            text: widget.topic,
                            style: TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const Divider(height: 16),
                _scoreRow('Hình thức trình bày báo cáo', _f1),
                const SizedBox(height: 8),
                _scoreRow('Nội dung lý thuyết và cơ sở khoa học', _f2),
                const SizedBox(height: 8),
                _scoreRow('Mức độ nghiên cứu và phân tích', _f3),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Tổng điểm: '),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 70,
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: _total.toStringAsFixed(1),
                        ),
                        decoration: _boxDec().copyWith(
                          fillColor: Colors.black12,
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Comment input with validator
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: 'Nhận xét',
                    hintText: 'Nhập nhận xét',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Vui lòng nhập nhận xét';
                    }
                    return null;
                  },
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: 120,
                    height: 36,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F7CD3),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        if (_formKey.currentState?.validate() ?? false) {
                          Navigator.pop<Map<String, dynamic>>(context, {
                            'total': _total,
                            'comment': _commentController.text.trim(),
                          });
                        }
                      },
                      child: const Text('Xác nhận'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String left, String right) {
    return Row(
      children: [
        Expanded(child: Text(left)),
        Text(right, style: const TextStyle(fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _scoreRow(String label, TextEditingController c) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        const SizedBox(width: 12),
        SizedBox(
          width: 70,
          child: TextFormField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _boxDec().copyWith(
              errorStyle: const TextStyle(height: 0, fontSize: 0),
              errorMaxLines: 1,
            ),
            textAlign: TextAlign.right,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Nhập điểm';
              }
              final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
              if (parsed == null) return 'Điểm không hợp lệ';
              if (parsed < 0 || parsed > 10)
                return 'Điểm phải trong khoảng 0 - 10';
              return null;
            },
            onChanged: (_) => _recalc(),
          ),
        ),
      ],
    );
  }
}

enum ReportStatus { submitted, notSubmitted, pending }

class StudentReport {
  final int? id;
  final String hoTenSV;
  final String maSinhVien;
  final String deTai;
  final int phienBan;
  final String file;
  final ReportStatus trangThai;
  final DateTime ngayNop;
  final String lop;

  StudentReport({
    this.id,
    required this.hoTenSV,
    required this.maSinhVien,
    required this.deTai,
    required this.phienBan,
    required this.file,
    required this.trangThai,
    required this.ngayNop,
    required this.lop,
  });
}

/* ------------------------ Bottom Navigation (dummy) ------------------------ */
