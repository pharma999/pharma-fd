import 'package:flutter/material.dart';

class SearchBarUi extends StatelessWidget {
  const SearchBarUi({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFF6BC4FF)], // 🌈 Gradient colors
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, color: Colors.grey),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search your services...",
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
