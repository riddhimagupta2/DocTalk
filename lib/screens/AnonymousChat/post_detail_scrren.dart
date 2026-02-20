import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';

class PostDetailScreen extends StatefulWidget {
  final AnonymousPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostDetailController controller;
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(PostDetailController(postId: widget.post.id));
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _submitReply() {
    if (_replyController.text.trim().isEmpty) return;
    controller.createReply(_replyController.text.trim());
    _replyController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: const Text('Discussion',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Original Post
                _buildPostCard(),
                const SizedBox(height: 20),

                // Replies
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.replies.isEmpty) {
                    return const Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF9B59B6))));
                  }

                  if (controller.replies.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No replies yet. Be the first to help!',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 14)),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${controller.replies.length} Replies',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      ...controller.replies.map((reply) => _ReplyCard(
                          reply: reply,
                          onUpvote: () => controller.upvoteReply(reply))),
                    ],
                  );
                }),
              ],
            ),
          ),

          // Reply Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1E),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _replyController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF2A2A3E),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _submitReply,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF9B59B6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(widget.post.anonymousAvatar,
                  style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.anonymousName,
                        style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(
                        '${widget.post.category.emoji} ${widget.post.category.label} • ${widget.post.timeAgo}',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(widget.post.title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          const SizedBox(height: 8),
          Text(widget.post.content,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.6)),
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final AnonymousReply reply;
  final VoidCallback onUpvote;

  const _ReplyCard({required this.reply, required this.onUpvote});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(reply.anonymousAvatar, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reply.anonymousName,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(reply.timeAgo,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.5))),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onUpvote,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                      color: const Color(0xFF3A3A4E),
                      borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    children: [
                      const Icon(Icons.arrow_upward_rounded,
                          size: 14, color: Color(0xFF9B59B6)),
                      const SizedBox(width: 4),
                      Text('${reply.upvoteCount}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(reply.content,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                  height: 1.5)),
        ],
      ),
    );
  }
}
