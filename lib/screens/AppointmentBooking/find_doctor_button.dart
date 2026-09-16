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
import '../../../resources/app_theme.dart';
import '../../resources/responsive.dart';

class FindDoctorButton extends StatelessWidget {
  final String specialist;

  const FindDoctorButton({
    super.key,
    this.specialist = 'General Physician',
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.wp(4).clamp(12.0, 20.0), vertical: context.hp(1)),
      child: GestureDetector(
        onTap: () {
          Get.toNamed('/doctor-finder', arguments: {'specialist': specialist});
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: context.r(20), vertical: context.hp(1.6).clamp(10.0, 16.0)),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            borderRadius: BorderRadius.circular(context.r(14)),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha:0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.local_hospital, color: AppColors.white, size: context.r(22)),
              SizedBox(width: context.wp(2.5)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Doctor',
                    style: TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: context.sp(15),
                    ),
                  ),
                  Text(
                    specialist,
                    style: TextStyle(
                      color: AppColors.white.withValues(alpha:0.8),
                      fontSize: context.sp(12),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: AppColors.white, size: context.r(14)),
            ],
          ),
        ),
      ),
    );
  }
}

