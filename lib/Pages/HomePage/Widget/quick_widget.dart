import 'package:flutter/material.dart';
import 'package:home_care/Controller/quick_controller.dart';

class QuickWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const QuickWidget({
    super.key,
    this.icon = Icons.quickreply_sharp, // ⚡ default icon
    this.label = "Quick",
    this.backgroundColor = const Color(0xFF00BCD4),
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    final QuickController controller = QuickController();
    return GestureDetector(
      onTap: () => controller.quick(),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: backgroundColor.withValues(alpha: .4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 30),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
