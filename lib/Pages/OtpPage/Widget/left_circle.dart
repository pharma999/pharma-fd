import 'package:flutter/material.dart';

class LeftCircleWidget extends StatelessWidget {
  const LeftCircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFFA8D930);
    final hsl = HSLColor.fromColor(baseColor);
    final lighter = hsl
        .withLightness((hsl.lightness + 0.15).clamp(0.0, 1.0))
        .toColor();
    final darker = hsl
        .withLightness((hsl.lightness - 0.15).clamp(0.0, 1.0))
        .toColor();

    return Container(
      width: 350,
      height: 350,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [darker, lighter],
          stops: const [0.0, 0.6],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
