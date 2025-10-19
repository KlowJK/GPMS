import 'package:flutter/material.dart';
import 'package:GPMS/features/lecturer/models/bao_cao.dart';
import 'package:GPMS/features/lecturer/models/student_supervised.dart';
import 'package:GPMS/features/lecturer/viewmodels/bao_cao_viewmodel.dart';
import 'package:GPMS/features/lecturer/services/bao_cao_service.dart';
import 'package:intl/intl.dart';

class ReportDetailScreen extends StatefulWidget {
  const ReportDetailScreen({super.key, required this.student});

  final StudentSupervised student;

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late final BaoCaoService service;
  final _vm = BaoCaoViewModel(service: BaoCaoService());
  bool _loading = false;
  List<ReportSubmission> _versions = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVersions();
  }

  Future<void> _loadVersions() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _vm.fetchStudentReports(maSinhVien: widget.student.maSV ?? '');
      setState(() {
        _versions = List<ReportSubmission>.from(_vm.items);
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _versions = [];
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        title: const Text('Thông tin chi tiết'),
      ),

      body: RefreshIndicator(
        onRefresh: _loadVersions,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: const EdgeInsets.only(top: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                    child: Center(
                      child: Text(
                        'Đề tài: ${(widget.student.tenDeTai?.isEmpty ?? true) ? '—' : widget.student.tenDeTai!}',
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  _InfoRow(label: 'Họ tên', value: widget.student.hoTen ?? '—'),
                  const Divider(height: 1),
                  _InfoRow(
                    label: 'Mã sinh viên',
                    value: widget.student.maSV ?? '—',
                  ),
                  const Divider(height: 1.5),
                  _InfoRow(label: 'Lớp', value: widget.student.tenLop ?? '—'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Các phiên bản báo cáo:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ..._versions
                .map(
                  (v) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ReportVersionCard(
                      version: v,
                      student: widget.student,
                      vm: _vm,
                    ),
                  ),
                )
                .toList(),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      title: Text(label),

      trailing: Text(
        value,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

enum ApproveStatus { pending, approved, rejected }

class ReportVersionCard extends StatefulWidget {
  const ReportVersionCard({
    super.key,
    required this.version,
    required this.student,
    required this.vm,
  });

  final ReportSubmission version;
  final StudentSupervised student;
  final BaoCaoViewModel vm;

  @override
  State<ReportVersionCard> createState() => _ReportVersionCardState();
}

class _ReportVersionCardState extends State<ReportVersionCard> {
  late ApproveStatus _status;
  late double? _score;
  final TextEditingController _rejectReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _status = widget.version.trangThai == 'DA_DUYET'
        ? ApproveStatus.approved
        : (widget.version.trangThai == 'TU_CHOI'
              ? ApproveStatus.rejected
              : ApproveStatus.pending);
    _score = widget.version.diemBaoCao;
  }

  @override
  void dispose() {
    _rejectReasonController.dispose();
    super.dispose();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '—';
    DateTime? dt;
    if (value is DateTime) {
      dt = value;
    } else if (value is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is String) {
      // if already dd/MM/yyyy, return as-is
      final ddMmYyyy = RegExp(r'^\d{1,2}\/\d{1,2}\/\d{4}$');
      if (ddMmYyyy.hasMatch(value)) return value;
      dt = DateTime.tryParse(value);
    }
    if (dt == null) return value.toString();
    return DateFormat('dd/MM/yyyy').format(dt);
  }

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
  Widget build(BuildContext context) {
    final isApproved = _status == ApproveStatus.approved;
    final isRejected = _status == ApproveStatus.rejected;

    Color borderColor = Colors.grey.shade300;

    return Card(
      color: const Color(0xFFF1F3F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    'Phiên bản ${widget.version.phienBan}:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Text(
                          _status == ApproveStatus.approved
                              ? 'Đã duyệt'
                              : (_status == ApproveStatus.rejected
                                    ? 'Từ chối'
                                    : 'Chờ duyệt'),
                          style: TextStyle(
                            color: _status == ApproveStatus.approved
                                ? const Color(0xFF16A34A)
                                : (_status == ApproveStatus.rejected
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFFF59E0B)),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 4),
            Text('Ngày nộp: ${_formatDate(widget.version.ngayNop)}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('File: '),
                Flexible(
                  child: Text(
                    (widget.version.duongDanFile ?? '').startsWith('http')
                        ? 'Xem chi tiết'
                        : '—',
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (_status != ApproveStatus.pending && _score != null)
              Text(
                'Điểm: ${_score!.toStringAsFixed(1)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 8),

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
                      onPressed: () async {
                        final reason = await _showRejectDialog();
                        if (reason == null) return;

                        final idBaoCao = widget.version.id;

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
                            studentName: widget.student.hoTen ?? '',
                            studentId: widget.student.maSV ?? '',
                            topic: widget.student.tenDeTai ?? '',
                            className: widget.student.tenLop ?? '',
                          ),
                        );
                        if (result != null) {
                          final total = (result['total'] as double?) ?? 0.0;
                          final comment = (result['comment'] as String?) ?? '';

                          final idBaoCao = (widget.version as dynamic).id;
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
                            idBaoCao: idBaoCao as int,
                            diemHuongDan: total,
                            nhanXet: comment.isEmpty ? null : comment,
                          );

                          if (ok) {
                            setState(() {
                              _status = ApproveStatus.approved;
                              _score = total;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Đã duyệt')),
                            );
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
