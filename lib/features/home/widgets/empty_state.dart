import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border_rounded,
            size: 64,
            color: Color(0xFFD3D1C7),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nothing saved yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF444441),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap + to save your first article',
            style: TextStyle(fontSize: 14, color: Color(0xFF888780)),
          ),
        ],
      ),
    );
  }
}