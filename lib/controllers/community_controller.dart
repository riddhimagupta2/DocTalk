import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/anonymous_chat_model.dart';
import '../services/community_servic.dart';

class CommunityController extends GetxController {
  final CommunityService _service = CommunityService();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<PostCategory?> selectedCategory = Rx<PostCategory?>(null);
  final RxList<AnonymousPost> posts = <AnonymousPost>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToPosts();
  }

  void _listenToPosts() {
    ever(selectedCategory, (_) {
      _loadPosts();
    });
    _loadPosts();
  }

  void _loadPosts() {
    isLoading.value = true;
    _service.getPostsStream(category: selectedCategory.value).listen((loadedPosts) {
      posts.value = loadedPosts;
      isLoading.value = false;
    }, onError: (error) {
      print('Error loading posts: $error');
      isLoading.value = false;
    });
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
        'Posted! 🎉',
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
      print('Error upvoting: $e');
    }
  }

  void filterByCategory(PostCategory? category) {
    selectedCategory.value = category;
  }

  void clearFilter() {
    selectedCategory.value = null;
  }

  Future<void> searchPosts(String query) async {
    if (query.trim().isEmpty) {
      _loadPosts();
      return;
    }

    try {
      isLoading.value = true;
      final results = await _service.searchPosts(query);
      posts.value = results;
      isLoading.value = false;
    } catch (e) {
      print('Search error: $e');
      isLoading.value = false;
    }
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
      print('Error loading replies: $error');
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
        'Reply Posted! 💬',
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
      print('Error upvoting reply: $e');
    }
  }
}