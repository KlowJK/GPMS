import 'package:flutter/material.dart';

class SearchField extends StatelessWidget {
  const SearchField({required this.hintText});
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onSubmitted: (v) {
        /* TODO: tìm kiếm */
      },
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}
