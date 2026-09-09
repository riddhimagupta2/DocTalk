import 'package:flutter/material.dart';
import '../../resources/AppTheme.dart';
import '../../resources/responsive.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: (context.hp(6.5)).clamp(48.0, 58.0),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(14)),
          ),
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
        ),
        child: isLoading
            ? SizedBox(
          width: context.r(22),
          height: context.r(22),
          child: const CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: context.r(18)),
              SizedBox(width: context.r(8)),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: context.sp(16),
                fontWeight: FontWeight.w700,
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
