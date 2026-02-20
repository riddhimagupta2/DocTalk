import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';


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
        title: const Text(
          'Share Your Story',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          TextButton(
            onPressed: _submit,
            child: const Text(
              'Post',
              style: TextStyle(color: Color(0xFF9B59B6), fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Anonymous info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF9B59B6).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Color(0xFF9B59B6), size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'You will be anonymous. A random name will be generated.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Category selector
            const Text('Category', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: PostCategory.values.map((cat) {
                final isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF9B59B6) : const Color(0xFF2A2A3E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${cat.emoji} ${cat.label}',
                      style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 13),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Title
            const Text('Title', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Brief title for your post...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 20),

            // Content
            const Text('Your Story', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
            const SizedBox(height: 8),
            TextField(
              controller: _contentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 8,
              decoration: InputDecoration(
                hintText: 'Share your experience, ask for help, or offer guidance...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A3E),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
      ),
    );
  }
}