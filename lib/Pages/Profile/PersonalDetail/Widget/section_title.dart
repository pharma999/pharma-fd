import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  const SectionTitle({required this.icon, required this.title, this.color, super.key});

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? const Color(0xFF8E54E9);
    return Row(
      children: [
        Icon(icon, size: 18, color: themeColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: themeColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
