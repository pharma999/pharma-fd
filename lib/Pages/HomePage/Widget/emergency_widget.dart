import 'package:flutter/material.dart';

class EmergencyUi extends StatefulWidget {
  const EmergencyUi({super.key});

  @override
  State<EmergencyUi> createState() => _EmergencyUiState();
}

class _EmergencyUiState extends State<EmergencyUi>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Controls the flowing gradient
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Controls the pulsing (scaling)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
      lowerBound: 0.95,
      upperBound: 1.05,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseController,
      child: AnimatedBuilder(
        animation: _gradientController,
        builder: (context, child) {
          final alignmentTween =
              AlignmentTween(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ).animate(
                CurvedAnimation(
                  parent: _gradientController,
                  curve: Curves.easeInOut,
                ),
              );

          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: alignmentTween.value,
                end: Alignment.bottomRight,
                colors: [
                  Colors.red.shade900,
                  Colors.red.shade700,
                  Colors.red.shade500,
                  Colors.red.shade400,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: .6),
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 30,
                ),
                SizedBox(height: 6),
                Text(
                  "Emergency",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
