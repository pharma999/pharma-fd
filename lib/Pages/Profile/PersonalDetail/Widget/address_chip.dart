import 'package:flutter/material.dart';

class AddressChip extends StatelessWidget {
  final String text;
  const AddressChip({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF8E54E9),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
