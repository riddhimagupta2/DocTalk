import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';
import '../../resources/responsive.dart';

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
        title: Text('Discussion',
            style: TextStyle(
                fontSize: context.sp(17),
                fontWeight: FontWeight.w800,
                color: Colors.white)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: context.r(20)),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(context.r(16)),
              children: [
                // Original Post
                _buildPostCard(),
                SizedBox(height: context.hp(2.0)),

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
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(context.r(28)),
                        child: Text('No replies yet. Be the first to help!',
                            style:
                                TextStyle(color: Colors.white70, fontSize: context.sp(13))),
                      ),
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${controller.replies.length} Replies',
                          style: TextStyle(
                              fontSize: context.sp(15),
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      SizedBox(height: context.hp(1.2)),
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
            padding: EdgeInsets.all(context.r(16)),
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F1E),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha:0.2),
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
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Share your thoughts...',
                        hintStyle: TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF2A2A3E),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(context.r(20)),
                            borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      maxLines: 3,
                      minLines: 1,
                    ),
                  ),
                  SizedBox(width: context.wp(2.5)),
                  GestureDetector(
                    onTap: _submitReply,
                    child: Container(
                      width: context.r(46),
                      height: context.r(46),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                            colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send_rounded,
                          color: Colors.white, size: context.r(20)),
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
      padding: EdgeInsets.all(context.r(16)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(context.r(14)),
        border: Border.all(color: const Color(0xFF9B59B6).withValues(alpha:0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Colors.white, size: context.sp(26)),
              SizedBox(width: context.wp(2.5)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.post.anonymousName,
                        style: TextStyle(
                            fontSize: context.sp(14),
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Row(
                      children: [
                        Icon(widget.post.category.icon, size: context.sp(12), color: Colors.white.withValues(alpha:0.5)),
                        SizedBox(width: 4),
                        Text(
                            '${widget.post.category.label} • ${widget.post.timeAgo}',
                            style: TextStyle(
                                fontSize: context.sp(11),
                                color: Colors.white.withValues(alpha:0.5))),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(1.6)),
          Text(widget.post.title,
              style: TextStyle(
                  fontSize: context.sp(17),
                  fontWeight: FontWeight.w700,
                  color: Colors.white)),
          SizedBox(height: context.hp(0.8)),
          Text(widget.post.content,
              style: TextStyle(
                  fontSize: context.sp(14),
                  color: Colors.white.withValues(alpha:0.9),
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
      padding: EdgeInsets.all(context.r(14)),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: BorderRadius.circular(context.r(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: Colors.white, size: context.sp(18)),
              SizedBox(width: context.wp(2.0)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reply.anonymousName,
                        style: TextStyle(
                            fontSize: context.sp(12),
                            fontWeight: FontWeight.w700,
                            color: Colors.white)),
                    Text(reply.timeAgo,
                        style: TextStyle(
                            fontSize: context.sp(10.5),
                            color: Colors.white.withValues(alpha:0.5))),
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
                      borderRadius: BorderRadius.circular(context.r(14))),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_upward_rounded,
                          size: context.r(14), color: Color(0xFF9B59B6)),
                      SizedBox(width: context.wp(1.0)),
                      Text('${reply.upvoteCount}',
                          style: TextStyle(
                              fontSize: context.sp(11),
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: context.hp(1.0)),
          Text(reply.content,
              style: TextStyle(
                  fontSize: context.sp(13),
                  color: Colors.white.withValues(alpha:0.9),
                  height: 1.5)),
        ],
      ),
    );
  }
}


