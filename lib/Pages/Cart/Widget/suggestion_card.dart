import 'package:flutter/material.dart';

class SuggestionCard extends StatelessWidget {
  final String title;
  final String price;
  final IconData icon;
  final Color color;

  const SuggestionCard({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, size: 16, color: color),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Text(price, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
