// ============================================================
// HOW TO ADD "FIND DOCTOR" BUTTON IN YOUR CHAT SCREEN
// ============================================================
// Drop this widget anywhere in your chat bubble / bot message area.
//
// Example usage inside your ChatScreen's message builder:
//
//   if (message.isBot && message.showDoctorButton) {
//     return Column(children: [
//       ChatBubble(message: message),
//       FindDoctorButton(specialist: message.specialist ?? 'General Physician'),
//     ]);
//   }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../resources/AppTheme.dart';

class FindDoctorButton extends StatelessWidget {
  final String specialist;

  const FindDoctorButton({
    super.key,
    this.specialist = 'General Physician',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/doctor-finder', arguments: {'specialist': specialist});
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.local_hospital, color: AppColors.white, size: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Find Doctor',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    specialist,
                    style: TextStyle(
                      color: AppColors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}