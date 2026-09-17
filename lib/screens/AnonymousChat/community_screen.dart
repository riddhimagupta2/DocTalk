import 'package:doctalk/screens/AnonymousChat/post_detail_scrren.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/community_controller.dart';
import '../../models/anonymous_chat_model.dart';
import '../../resources/responsive.dart';
import 'create_post_screen.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CommunityController());

    return Obx(() {
      final isSearch = controller.isSearchOpen.value;

      return PopScope(
        canPop: !isSearch,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (controller.isSearchOpen.value) {
            controller.closeSearch();
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: _buildAppBar(context, controller, isSearch),
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
                        label: cat.label,
                        icon: cat.icon,
                        isSelected: controller.selectedCategory.value == cat,
                        onTap: () => controller.filterByCategory(cat),
                      ),
                    ),
                  ],
                )),
              ),

              // Active search/filter indicator
              Obx(() {
                final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
                final selectedCat = controller.selectedCategory.value;

                if (!hasSearch && selectedCat == null) {
                  return const SizedBox.shrink();
                }

                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: context.wp(4).clamp(12.0, 20.0),
                    vertical: 6,
                  ),
                  color: const Color(0xFF161628),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded,
                          color: const Color(0xFF9B59B6), size: context.r(14)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          [
                            if (selectedCat != null) 'Category: ${selectedCat.label}',
                            if (hasSearch) 'Search: "${controller.searchQuery.value}"',
                          ].join(' • '),
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: context.sp(11.5),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.clearFilter();
                          controller.clearSearchQuery();
                        },
                        child: Text(
                          'Clear all',
                          style: TextStyle(
                            color: const Color(0xFF9B59B6),
                            fontSize: context.sp(11.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

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
                    return _buildEmptyState(context, controller);
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
        ),
      );
    });
  }

  PreferredSizeWidget _buildAppBar(
      BuildContext context, CommunityController controller, bool isSearch) {
    if (isSearch) {
      return AppBar(
        backgroundColor: const Color(0xFF0F0F1E),
        elevation: 0,
        leadingWidth: 44,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: context.r(18)),
          onPressed: () => controller.closeSearch(),
        ),
        title: Center(
          child: Container(
            height: 36,
            constraints: BoxConstraints(
              maxWidth: context.wp(58).clamp(150.0, 230.0),
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF222238),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF3D3D60), width: 1),
            ),
            child: TextField(
              controller: controller.searchTextController,
              autofocus: true,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(13.5),
              ),
              cursorColor: const Color(0xFFB388FF),
              textAlignVertical: TextAlignVertical.center,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                hintText: 'Search topics...',
                hintStyle: TextStyle(
                  color: Colors.white54,
                  fontSize: context.sp(13),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: const Color(0xFFB388FF),
                  size: context.r(18),
                ),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 32,
                  minHeight: 32,
                ),
                suffixIcon: Obx(() => controller.searchQuery.value.isNotEmpty
                    ? GestureDetector(
                        onTap: () => controller.clearSearchQuery(),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: context.r(16),
                        ),
                      )
                    : const SizedBox.shrink()),
                suffixIconConstraints: const BoxConstraints(
                  minWidth: 28,
                  minHeight: 28,
                ),
              ),
              onChanged: (val) {
                controller.searchQuery.value = val;
              },
            ),
          ),
        ),
        actions: const [
          SizedBox(width: 8),
        ],
      );
    }

    return AppBar(
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
          icon: Icon(Icons.search_rounded,
              color: Colors.white, size: context.r(22)),
          onPressed: () => controller.openSearch(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context, CommunityController controller) {
    final hasSearch = controller.searchQuery.value.trim().isNotEmpty;
    final hasCat = controller.selectedCategory.value != null;

    String title = 'No discussions found';
    String subtitle = 'Be the first to share your story!';

    if (hasSearch && hasCat) {
      title = 'No matches found';
      subtitle = 'Try searching in "All" or using different keywords';
    } else if (hasSearch) {
      title = 'No results for "${controller.searchQuery.value}"';
      subtitle = 'Try searching with different keywords';
    } else if (hasCat) {
      title = 'No posts in ${controller.selectedCategory.value!.label}';
      subtitle = 'Be the first to share in this category!';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.r(24)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasSearch ? Icons.search_off_rounded : Icons.forum_outlined,
              size: context.r(56),
              color: Colors.white24,
            ),
            SizedBox(height: context.hp(2)),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(16),
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: context.hp(0.8)),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.sp(13),
                color: Colors.white54,
              ),
            ),
            if (hasSearch || hasCat) ...[
              SizedBox(height: context.hp(2)),
              TextButton.icon(
                onPressed: () {
                  controller.clearFilter();
                  controller.clearSearchQuery();
                },
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF9B59B6)),
                label: const Text(
                  'Reset Filters',
                  style: TextStyle(color: Color(0xFF9B59B6), fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: context.r(12), vertical: context.hp(0.6)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF9B59B6) : const Color(0xFF1E1E38),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF9B59B6) : Colors.white12,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: context.r(14),
                color: isSelected ? Colors.white : Colors.white60,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: context.sp(12.5),
              ),
            ),
          ],
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
    final authController = Get.find<AuthController>();
    final isUpvoted = post.upvoters.contains(authController.currentUserId);

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
                      backgroundColor: const Color(0xFF9B59B6).withValues(alpha: 0.3),
                      child: Icon(Icons.person_outline_rounded, color: Colors.white, size: context.r(16)),
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
                        color: Colors.white.withValues(alpha: 0.08),
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
                          Icon(
                            isUpvoted ? Icons.arrow_upward_rounded : Icons.arrow_upward_outlined,
                            color: isUpvoted ? const Color(0xFF9B59B6) : Colors.white60,
                            size: context.r(16),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.upvoteCount}',
                            style: TextStyle(
                              color: isUpvoted ? const Color(0xFF9B59B6) : Colors.white70,
                              fontWeight: isUpvoted ? FontWeight.bold : FontWeight.normal,
                              fontSize: context.sp(12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: context.wp(5)),
                    Row(
                      children: [
                        Icon(Icons.mode_comment_outlined, color: Colors.white38, size: context.r(15)),
                        const SizedBox(width: 4),
                        Text(
                          '${post.replyCount}',
                          style: TextStyle(color: Colors.white70, fontSize: context.sp(12)),
                        ),
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


