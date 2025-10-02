import 'package:flutter/material.dart';

class CouncilScreen extends StatelessWidget {
  const CouncilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final councils = <_Council>[
      _Council(
        name: 'Hội đồng A',
        from: DateTime(2025, 10, 16),
        to: DateTime(2025, 10, 17),
        statusText: 'Sắp diễn ra',
        statusColor: const Color(0xFF0EB216),
      ),
      _Council(
        name: 'Hội đồng A',
        from: DateTime(2025, 10, 16),
        to: DateTime(2025, 10, 17),
        statusText: 'Sắp diễn ra',
        statusColor: const Color(0xFF0EB216),
      ),
    ];

    final maxBodyWidth = MediaQuery.of(context).size.width >= 820
        ? 720.0
        : double.infinity;

    return Scaffold(
      // AppBar giống ảnh (nền xanh, chữ trắng, căn giữa)
      appBar: AppBar(
        backgroundColor: const Color(0xFF2F7CD3),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Hội đồng',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 1,
        shadowColor: Colors.black12,
      ),

      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxBodyWidth),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              children: [
                const SizedBox(height: 8),
                Text(
                  'Danh sách hội đồng phản biện:',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                ...councils
                    .map<Widget>((c) => _CouncilCard(council: c))
                    .withSeparator(const SizedBox(height: 10)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Card theo đúng style ảnh: nền xanh nhạt, bo 12, icon bên trái, chữ đậm cho nhãn
class _CouncilCard extends StatelessWidget {
  const _CouncilCard({required this.council});
  final _Council council;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE4F6FF),
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
          // Icon tròn nền xanh nhạt giống ảnh
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFDBEAFE),
            child: const Icon(Icons.apartment_outlined, color: Colors.black54),
          ),
          const SizedBox(width: 12),

          // Nội dung
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labelValue('Tên hội đồng:', council.name),
                const SizedBox(height: 6),
                _labelValue(
                  'Ngày bảo vệ:',
                  '${_fmt(council.from)} - ${_fmt(council.to)}',
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Text(
                      'Trạng thái: ',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Flexible(
                      child: Text(
                        council.statusText,
                        style: TextStyle(
                          color: council.statusColor,
                          fontWeight: FontWeight.w600,
                        ),
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

  Widget _labelValue(String label, String value) {
    return RichText(
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
  }

  String _fmt(DateTime d) {
    String two(int x) => x.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year}';
  }
}

/// Model gọn nhẹ
class _Council {
  final String name;
  final DateTime from;
  final DateTime to;
  final String statusText;
  final Color statusColor;

  _Council({
    required this.name,
    required this.from,
    required this.to,
    required this.statusText,
    required this.statusColor,
  });
}

/// Tiện ích nhỏ để chèn separator giữa các phần tử (Flutter 3.22+ có `.intersperse`)
extension SeparatorsOnWidgets on Iterable<Widget> {
  Iterable<Widget> withSeparator(Widget separator) sync* {
    var first = true;
    for (final w in this) {
      if (!first) yield separator;
      first = false;
      yield w;
    }
  }
}
