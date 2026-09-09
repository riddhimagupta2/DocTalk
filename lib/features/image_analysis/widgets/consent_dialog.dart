import 'package:flutter/material.dart';
import 'package:doctalk/resources/AppTheme.dart';

class ConsentDialog extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const ConsentDialog({
    Key? key,
    required this.onAccept,
    required this.onDecline,
  }) : super(key: key);

  static Future<bool> show(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConsentDialog(
        onAccept: () => Navigator.of(context).pop(true),
        onDecline: () => Navigator.of(context).pop(false),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: AppColors.cardBg,
      title: const Text('🔒 Privacy & Consent', style: TextStyle(fontWeight: FontWeight.bold)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('By proceeding, you acknowledge that:'),
            const SizedBox(height: 12),
            _buildBullet('Your medical image will be uploaded securely to our servers'),
            _buildBullet('The image will be processed securely by OpenAI AI for analysis'),
            _buildBullet('The analysis is AI-generated and NOT a medical diagnosis'),
            _buildBullet('You can delete your images and analysis history at any time'),
            _buildBullet('We do not share your medical images with third parties'),
            const Divider(height: 24),
            const Text(
              'This analysis is AI generated and is not a medical diagnosis. Please consult a licensed doctor.',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: onDecline,
          style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
          child: const Text('Decline'),
        ),
        ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          child: const Text('I Agree & Continue', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
