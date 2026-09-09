import 'package:flutter/material.dart';
import 'package:doctalk/resources/AppTheme.dart';
import 'package:doctalk/resources/responsive.dart';

class ImageSourcePicker extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;

  const ImageSourcePicker({
    Key? key,
    required this.onCameraTap,
    required this.onGalleryTap,
  }) : super(key: key);

  static void show(BuildContext context, {required VoidCallback onCamera, required VoidCallback onGallery}) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(24))),
      ),
      backgroundColor: AppColors.cardBg,
      builder: (context) => ImageSourcePicker(
        onCameraTap: () {
          Navigator.pop(context);
          onCamera();
        },
        onGalleryTap: () {
          Navigator.pop(context);
          onGallery();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: context.hp(2.5).clamp(16.0, 28.0),
          horizontal: context.wp(5).clamp(16.0, 24.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: context.wp(10).clamp(36.0, 48.0),
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: context.hp(2.5)),
            Text(
              'Select Image Source',
              style: TextStyle(
                fontSize: context.sp(18),
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontFamily: 'Lato',
              ),
            ),
            SizedBox(height: context.hp(3)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  context,
                  icon: Icons.camera_alt_rounded,
                  label: 'Camera',
                  onTap: onCameraTap,
                  color: AppColors.primary,
                ),
                _buildOption(
                  context,
                  icon: Icons.photo_library_rounded,
                  label: 'Gallery',
                  onTap: onGalleryTap,
                  color: AppColors.coral,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(context.r(16)),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: context.r(32), color: color),
          ),
          SizedBox(height: context.hp(1)),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: context.sp(14),
              fontFamily: 'Lato',
            ),
          ),
        ],
      ),
    );
  }
}
