import 'package:doctalk/screens/AnonymousChat/post_detail_scrren.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';
import '../../resources/responsive.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityController());

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        title: Text(
          'Anonymous Community',
          style: TextStyle(
            fontSize: context.sp(18),
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: context.r(20)),
                onPressed: () => Get.back(),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(Icons.search_rounded, color: Colors.white, size: context.r(22)),
            onPressed: () => _showSearchDialog(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Privacy Banner
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: context.wp(4).clamp(12.0, 20.0),
              vertical: context.hp(1.2).clamp(8.0, 14.0),
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: context.r(16)),
                SizedBox(width: context.wp(2).clamp(6.0, 10.0)),
                Expanded(
                  child: Text(
                    'Share experiences anonymously. Your identity is protected.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(12),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter
          Container(
            height: context.hp(7.5).clamp(52.0, 68.0),
            color: const Color(0xFF0F0F1E),
            child: Obx(() => ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(
                horizontal: context.wp(4).clamp(12.0, 20.0),
                vertical: context.hp(1.0).clamp(6.0, 10.0),
              ),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: controller.selectedCategory.value == null,
                  onTap: () => controller.clearFilter(),
                ),
                ...PostCategory.values.map(
                      (cat) => _CategoryChip(
                    label: ' ',
                    isSelected: controller.selectedCategory.value == cat,
                    onTap: () => controller.filterByCategory(cat),
                  ),
                ),
              ],
            )),
          ),

          // Posts List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.posts.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF9B59B6)),
                  ),
                );
              }

              if (controller.posts.isEmpty) {
                return _buildEmptyState(context);
              }

              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: context.wp(4).clamp(12.0, 20.0),
                  vertical: context.hp(1.5).clamp(10.0, 18.0),
                ),
                itemCount: controller.posts.length,
                itemBuilder: (context, index) {
                  return _PostCard(
                    post: controller.posts[index],
                    onTap: () => Get.to(
                          () => PostDetailScreen(post: controller.posts[index]),
                      transition: Transition.rightToLeft,
                    ),
                    onUpvote: () => controller.upvotePost(controller.posts[index]),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(
              () => const CreatePostScreen(),
          transition: Transition.downToUp,
        ),
        backgroundColor: const Color(0xFF9B59B6),
        label: Text('Share Your Story', style: TextStyle(fontSize: context.sp(14))),
        icon: Icon(Icons.add_rounded, size: context.r(22)),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.forum_outlined, size: context.r(60), color: Colors.white24),
          SizedBox(height: context.hp(2)),
          Text(
            'No discussions found',
            style: TextStyle(fontSize: context.sp(16), color: Colors.white70, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, CommunityController controller) {
    final searchCtrl = TextEditingController();
    Get.defaultDialog(
      title: 'Search Discussions',
      titleStyle: TextStyle(color: Colors.black, fontSize: context.sp(16), fontWeight: FontWeight.bold),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: searchCtrl,
          decoration: InputDecoration(
            hintText: 'Type to search...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onSubmitted: (val) {
            controller.searchQuery.value = val;
            Get.back();
          },
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            controller.searchQuery.value = searchCtrl.text;
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF9B59B6)),
          child: const Text('Search', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: context.r(14), vertical: context.hp(0.8)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9B59B6) : const Color(0xFF1E1E38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF9B59B6) : Colors.white12,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: context.sp(13),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final AnonymousPost post;
  final VoidCallback onTap;
  final VoidCallback onUpvote;

  const _PostCard({
    required this.post,
    required this.onTap,
    required this.onUpvote,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.hp(1.5).clamp(8.0, 14.0)),
      decoration: BoxDecoration(
        color: const Color(0xFF22223B),
        borderRadius: BorderRadius.circular(context.r(16)),
        border: Border.all(color: Colors.white10),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(context.r(16)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(context.r(16)),
          child: Padding(
            padding: EdgeInsets.all(context.r(16)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: context.r(14),
                      backgroundColor: const Color(0xFF9B59B6).withOpacity(0.3),
                      child: Text(post.anonymousAvatar, style: TextStyle(fontSize: context.sp(14))),
                    ),
                    SizedBox(width: context.wp(2.5)),
                    Text(
                      post.anonymousName,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: context.sp(13),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: context.r(8), vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        post.category.label,
                        style: TextStyle(color: Colors.white70, fontSize: context.sp(11)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: context.hp(1.2)),
                Text(
                  post.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: context.sp(15),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.content,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: context.sp(13),
                    height: 1.4,
                  ),
                ),
                SizedBox(height: context.hp(1.5)),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onUpvote,
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward_rounded, color: const Color(0xFF9B59B6), size: context.r(16)),
                          const SizedBox(width: 4),
                          Text('', style: TextStyle(color: Colors.white70, fontSize: context.sp(12))),
                        ],
                      ),
                    ),
                    SizedBox(width: context.wp(5)),
                    Row(
                      children: [
                        Icon(Icons.mode_comment_outlined, color: Colors.white38, size: context.r(15)),
                        const SizedBox(width: 4),
                        Text('', style: TextStyle(color: Colors.white70, fontSize: context.sp(12))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
