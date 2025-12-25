import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isGold;
  const StatusCard({
    required this.label,
    required this.value,
    required this.isGold,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGold ? const Color(0xFFFFF8E1) : const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                isGold ? Icons.stars : Icons.check_circle,
                size: 16,
                color: isGold ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isGold ? Colors.orange[800] : Colors.green[800],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
