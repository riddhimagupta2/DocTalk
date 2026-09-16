import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/anonymous_chat_model.dart';
import '../services/community_servic.dart';

class CommunityController extends GetxController {
  final CommunityService _service = CommunityService();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<PostCategory?> selectedCategory = Rx<PostCategory?>(null);
  final RxList<AnonymousPost> _allPosts = <AnonymousPost>[].obs;
  final RxList<AnonymousPost> posts = <AnonymousPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isSearchOpen = false.obs;
  final TextEditingController searchTextController = TextEditingController();

  StreamSubscription<List<AnonymousPost>>? _postsSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToPosts();
    ever(_allPosts, (_) => _applyFilter());
    ever(selectedCategory, (_) => _applyFilter());
    ever(searchQuery, (_) => _applyFilter());
  }

  @override
  void onClose() {
    _postsSubscription?.cancel();
    searchTextController.dispose();
    super.onClose();
  }

  void _listenToPosts() {
    isLoading.value = true;
    _postsSubscription?.cancel();
    _postsSubscription = _service.getPostsStream().listen(
      (loadedPosts) {
        _allPosts.value = loadedPosts;
        _applyFilter();
        isLoading.value = false;
      },
      onError: (error) {
        debugPrint('Error loading posts: $error');
        isLoading.value = false;
      },
    );
  }

  void _applyFilter() {
    List<AnonymousPost> result = List.from(_allPosts);

    // 1. Filter by category
    if (selectedCategory.value != null) {
      result = result.where((p) => p.category == selectedCategory.value).toList();
    }

    // 2. Filter by search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((p) {
        final title = p.title.toLowerCase();
        final content = p.content.toLowerCase();
        final cat = p.category.label.toLowerCase();
        final name = p.anonymousName.toLowerCase();
        return title.contains(query) ||
            content.contains(query) ||
            cat.contains(query) ||
            name.contains(query);
      }).toList();
    }

    posts.value = result;
  }

  void openSearch() {
    isSearchOpen.value = true;
  }

  void closeSearch() {
    isSearchOpen.value = false;
    searchTextController.clear();
    searchQuery.value = '';
  }

  void clearSearchQuery() {
    searchTextController.clear();
    searchQuery.value = '';
  }

  void filterByCategory(PostCategory? category) {
    if (selectedCategory.value == category) {
      selectedCategory.value = null;
    } else {
      selectedCategory.value = category;
    }
  }

  void clearFilter() {
    selectedCategory.value = null;
  }

  Future<void> createPost({
    required String title,
    required String content,
    required PostCategory category,
  }) async {
    try {
      await _service.createPost(
        authorId: _authController.currentUserId,
        title: title,
        content: content,
        category: category,
      );
      Get.back(); // Close create post screen
      Get.snackbar(
        'Posted! ',
        'Your anonymous post is live',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not create post: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> upvotePost(AnonymousPost post) async {
    try {
      await _service.upvotePost(post.id, _authController.currentUserId);
    } catch (e) {
      debugPrint('Error upvoting: $e');
    }
  }

  Future<void> searchPosts(String query) async {
    searchQuery.value = query;
    _applyFilter();
  }
}

class PostDetailController extends GetxController {
  final String postId;
  final CommunityService _service = CommunityService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<AnonymousReply> replies = <AnonymousReply>[].obs;
  final RxBool isLoading = false.obs;

  PostDetailController({required this.postId});

  @override
  void onInit() {
    super.onInit();
    _loadReplies();
  }

  void _loadReplies() {
    isLoading.value = true;
    _service.getRepliesStream(postId).listen((loadedReplies) {
      replies.value = loadedReplies;
      isLoading.value = false;
    }, onError: (error) {
      debugPrint('Error loading replies: $error');
      isLoading.value = false;
    });
  }

  Future<void> createReply(String content) async {
    try {
      await _service.createReply(
        postId: postId,
        authorId: _authController.currentUserId,
        content: content,
      );
      Get.snackbar(
        'Reply Posted! ',
        'Your anonymous reply is live',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not post reply: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> upvoteReply(AnonymousReply reply) async {
    try {
      await _service.upvoteReply(
        postId,
        reply.id,
        _authController.currentUserId,
      );
    } catch (e) {
      debugPrint('Error upvoting reply: $e');
    }
  }
}

