import 'package:flutter/material.dart';

class CartAppBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMore;

  const CartAppBar({
    super.key,
    required this.onBack,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(onPressed: onBack, icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20)),
        const Text(
          "My Cart",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        IconButton(onPressed: onMore, icon: const Icon(Icons.more_vert)),
      ],
    );
  }
}
