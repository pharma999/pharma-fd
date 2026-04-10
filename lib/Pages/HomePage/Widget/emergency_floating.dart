import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:home_care/Pages/Chatbot/chatbot_page.dart';

class ChatbotFloatingButton extends StatefulWidget {
  const ChatbotFloatingButton({super.key});

  @override
  State<ChatbotFloatingButton> createState() => _ChatbotFloatingButtonState();
}

class _ChatbotFloatingButtonState extends State<ChatbotFloatingButton>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Gradient animation
    _gradientController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    // Pulse animation
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

          return GestureDetector(
            onTap: () {
              Get.to(() => const ChatbotPage());
            },
            child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: alignmentTween.value,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF00BCD4),
                    Color(0xFF0097A7),
                    Color(0xFF006064),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00BCD4).withValues(alpha: 0.6),
                    blurRadius: 18,
                    spreadRadius: 3,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Chat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
