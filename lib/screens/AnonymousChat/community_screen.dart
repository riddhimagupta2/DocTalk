import 'package:doctalk/screens/AnonymousChat/post_detail_scrren.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';
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
        title: const Text(
          'Anonymous Community',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            onPressed: () => _showSearchDialog(context, controller),
          ),
        ],
      ),
      body: Column(
        children: [
          // Privacy Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFF8E44AD)],
              ),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Share experiences anonymously. Your identity is protected.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Category Filter
          Container(
            height: 60,
            color: const Color(0xFF0F0F1E),
            child: Obx(() => ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _CategoryChip(
                  label: 'All',
                  isSelected: controller.selectedCategory.value == null,
                  onTap: () => controller.clearFilter(),
                ),
                ...PostCategory.values.map(
                      (cat) => _CategoryChip(
                    label: '${cat.emoji} ${cat.label}',
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
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
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
        label: const Text('Share Your Story'),
        icon: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('💬', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your story',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog(BuildContext context, CommunityController controller) {
    final searchController = TextEditingController();
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2A2A3E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Search Posts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: searchController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter keywords...',
            hintStyle: TextStyle(color: Colors.white38),
            border: OutlineInputBorder(),
          ),
          onSubmitted: (query) {
            Get.back();
            controller.searchPosts(query);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.searchPosts(searchController.text);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9B59B6),
            ),
            child: const Text('Search'),
          ),
        ],
      ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9B59B6) : const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF9B59B6) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A3E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF3A3A4E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author info
            Row(
              children: [
                Text(post.anonymousAvatar, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.anonymousName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${post.category.emoji} ${post.category.label} • ${post.timeAgo}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),

            // Content preview
            Text(
              post.content,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),

            // Stats
            Row(
              children: [
                GestureDetector(
                  onTap: onUpvote,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3A3A4E),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_upward_rounded,
                            size: 16, color: Color(0xFF9B59B6)),
                        const SizedBox(width: 4),
                        Text(
                          '${post.upvoteCount}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A4E),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.chat_bubble_outline_rounded,
                          size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        '${post.replyCount}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}