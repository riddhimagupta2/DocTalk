import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';
import '../../resources/responsive.dart';


class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  PostCategory _selectedCategory = PostCategory.other;

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty ||
        _contentController.text.trim().isEmpty) {
      Get.snackbar('Required', 'Please fill in all fields',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final controller = Get.find<CommunityController>();
    controller.createPost(
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Share Your Story',
          style: TextStyle(fontSize: context.sp(17), fontWeight: FontWeight.w800, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              'Post',
              style: TextStyle(color: Color(0xFF9B59B6), fontSize: context.sp(15), fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(context.r(20)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anonymous info
            Container(
              padding: EdgeInsets.all(context.r(16)),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withValues(alpha:0.1),
                borderRadius: BorderRadius.circular(context.r(12)),
                border: Border.all(color: const Color(0xFF9B59B6).withValues(alpha:0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF9B59B6), size: context.r(20)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You will be anonymous. A random name will be generated.',
                      style: TextStyle(color: Colors.white70, fontSize: context.sp(11.5)),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: context.hp(2.5)),

            // Category selector
            Text('Category', style: TextStyle(fontSize: context.sp(13.5), fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: context.hp(0.8)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PostCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: context.r(14), vertical: context.hp(1.0)),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF9B59B6) : const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(context.r(20)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(cat.icon, size: context.r(14), color: isSelected ? Colors.white : Colors.white70),
                        SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: context.sp(12.5)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: context.hp(2.0)),

            // Title
            Text('Title', style: TextStyle(fontSize: context.sp(13.5), fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: context.hp(0.8)),
            TextField(
              controller: _titleController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Brief title for your post...',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.r(12)), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: context.hp(2.0)),

            // Content
            Text('Your Story', style: TextStyle(fontSize: context.sp(13.5), fontWeight: FontWeight.w700, color: Colors.white)),
            SizedBox(height: context.hp(0.8)),
            TextField(
              controller: _contentController,
              style: TextStyle(color: Colors.white),
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Share your experience, ask for help, or offer guidance...',
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(context.r(12)), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

