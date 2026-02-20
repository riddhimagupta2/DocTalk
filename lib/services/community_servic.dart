import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/anonymous_chat_model.dart';
import '../resources/anonymous_name_generator.dart';


class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Create a new anonymous post
  Future<String> createPost({
    required String authorId,
    required String title,
    required String content,
    required PostCategory category,
  }) async {
    final identity = AnonymousNameGenerator.generateIdentity();

    final post = AnonymousPost(
      id: '',
      authorId: authorId,
      anonymousName: identity['name']!,
      anonymousAvatar: identity['avatar']!,
      title: title,
      content: content,
      category: category,
      createdAt: DateTime.now(),
    );

    final docRef = await _db.collection('community_posts').add(post.toFirestore());
    return docRef.id;
  }

  /// Get all posts (stream for real-time updates)
  Stream<List<AnonymousPost>> getPostsStream({PostCategory? category}) {
    Query query = _db
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(50);

    if (category != null) {
      query = query.where('category', isEqualTo: category.name);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => AnonymousPost.fromFirestore(doc))
          .toList();
    });
  }

  /// Create a reply to a post
  Future<void> createReply({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    final identity = AnonymousNameGenerator.generateIdentity();

    final reply = AnonymousReply(
      id: '',
      postId: postId,
      authorId: authorId,
      anonymousName: identity['name']!,
      anonymousAvatar: identity['avatar']!,
      content: content,
      createdAt: DateTime.now(),
    );

    // Add reply
    await _db
        .collection('community_posts')
        .doc(postId)
        .collection('replies')
        .add(reply.toFirestore());

    // Increment reply count
    await _db.collection('community_posts').doc(postId).update({
      'replyCount': FieldValue.increment(1),
    });
  }

  /// Get replies for a post (stream)
  Stream<List<AnonymousReply>> getRepliesStream(String postId) {
    return _db
        .collection('community_posts')
        .doc(postId)
        .collection('replies')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AnonymousReply.fromFirestore(doc))
          .toList();
    });
  }

  /// Upvote a post
  Future<void> upvotePost(String postId, String userId) async {
    final postRef = _db.collection('community_posts').doc(postId);
    final doc = await postRef.get();
    final upvoters = List<String>.from(doc.data()?['upvoters'] ?? []);

    if (upvoters.contains(userId)) {
      // Remove upvote
      await postRef.update({
        'upvoters': FieldValue.arrayRemove([userId]),
        'upvoteCount': FieldValue.increment(-1),
      });
    } else {
      // Add upvote
      await postRef.update({
        'upvoters': FieldValue.arrayUnion([userId]),
        'upvoteCount': FieldValue.increment(1),
      });
    }
  }

  /// Upvote a reply
  Future<void> upvoteReply(String postId, String replyId, String userId) async {
    final replyRef = _db
        .collection('community_posts')
        .doc(postId)
        .collection('replies')
        .doc(replyId);

    final doc = await replyRef.get();
    final upvoters = List<String>.from(doc.data()?['upvoters'] ?? []);

    if (upvoters.contains(userId)) {
      // Remove upvote
      await replyRef.update({
        'upvoters': FieldValue.arrayRemove([userId]),
        'upvoteCount': FieldValue.increment(-1),
      });
    } else {
      // Add upvote
      await replyRef.update({
        'upvoters': FieldValue.arrayUnion([userId]),
        'upvoteCount': FieldValue.increment(1),
      });
    }
  }

  /// Search posts by keyword
  Future<List<AnonymousPost>> searchPosts(String keyword) async {
    // Simple search - in production use Algolia or similar
    final snapshot = await _db
        .collection('community_posts')
        .orderBy('createdAt', descending: true)
        .limit(100)
        .get();

    final allPosts = snapshot.docs
        .map((doc) => AnonymousPost.fromFirestore(doc))
        .toList();

    final lowerKeyword = keyword.toLowerCase();
    return allPosts.where((post) {
      return post.title.toLowerCase().contains(lowerKeyword) ||
          post.content.toLowerCase().contains(lowerKeyword);
    }).toList();
  }
}