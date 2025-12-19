import 'package:flutter/material.dart';

class PromoCode extends StatelessWidget {
  const PromoCode({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Row(
        children: [
          Icon(Icons.local_offer_outlined, color: Colors.blue),
          SizedBox(width: 10),
          Expanded(child: Text("Apply Promo Code")),
          Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
