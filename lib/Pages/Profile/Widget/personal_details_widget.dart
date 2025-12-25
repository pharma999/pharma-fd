import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:home_care/Model/user_detail_model.dart';

class PersonalDetailsWidget extends StatelessWidget {
  final UserDetail user;

  const PersonalDetailsWidget({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          Get.offAllNamed("/personal-detail");
        },
        leading: const Icon(Icons.person_outline, color: Color(0xFF7B61FF)),
        title: const Text(
          'Personal Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
