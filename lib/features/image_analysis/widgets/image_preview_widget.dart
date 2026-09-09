import 'dart:io';
import 'package:flutter/material.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/responsive.dart';

class ImagePreviewWidget extends StatelessWidget {
  final File imageFile;
  final VoidCallback onRemove;
  final VoidCallback onRetake;

  const ImagePreviewWidget({
    Key? key,
    required this.imageFile,
    required this.onRemove,
    required this.onRetake,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final previewHeight = context.hp(32).clamp(200.0, 360.0);

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(context.r(20)),
          child: Image.file(
            imageFile,
            width: double.infinity,
            height: previewHeight,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: context.r(12),
          right: context.r(12),
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(context.r(6)),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, color: Colors.white, size: context.r(20)),
            ),
          ),
        ),
        Positioned(
          bottom: context.r(16),
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildButton(context, 'Retake', Icons.refresh, onRetake),
              SizedBox(width: context.wp(4).clamp(12.0, 24.0)),
              _buildButton(context, 'Remove', Icons.delete_outline, onRemove, color: AppColors.error),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, String label, IconData icon, VoidCallback onTap, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.r(16),
          vertical: context.hp(1.0).clamp(6.0, 10.0),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: context.r(16), color: color ?? AppColors.textPrimary),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color ?? AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: context.sp(12),
                fontFamily: 'Lato',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
