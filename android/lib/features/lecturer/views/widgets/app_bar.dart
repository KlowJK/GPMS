import 'package:flutter/material.dart';

class _HeaderBar extends StatelessWidget implements PreferredSizeWidget {
  _HeaderBar({super.key});
  final double _height = 60;
  @override
  Size get preferredSize => Size.fromHeight(_height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF2563EB),
      elevation: 1,
      centerTitle: false,
      titleSpacing: 12,
      title: Row(
        children: [
          Container(
            width: 55,
            height: 55,
            child: Image.asset("assets/images/logo.png"),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRƯỜNG ĐẠI HỌC THỦY LỢI',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '  KHOA CÔNG NGHỆ THÔNG TIN',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          tooltip: 'Thông báo',
          icon: const Icon(Icons.notifications_outlined),
          color: Colors.white,
        ),
        const SizedBox(width: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.person, size: 18),
          ),
        ),
      ],
    );
  }
}
