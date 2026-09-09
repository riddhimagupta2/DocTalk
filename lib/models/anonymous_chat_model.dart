import 'package:cloud_firestore/cloud_firestore.dart';

enum PostCategory {
  mentalHealth,
  sexualHealth,
  chronicIllness,
  skinConditions,
  addiction,
  pregnancy,
  other;

  String get label {
    switch (this) {
      case PostCategory.mentalHealth:
        return 'Mental Health';
      case PostCategory.sexualHealth:
        return 'Sexual Health';
      case PostCategory.chronicIllness:
        return 'Chronic Illness';
      case PostCategory.skinConditions:
        return 'Skin Conditions';
      case PostCategory.addiction:
        return 'Addiction';
      case PostCategory.pregnancy:
        return 'Pregnancy';
      case PostCategory.other:
        return 'Other';
    }
  }

  String get emoji {
    switch (this) {
      case PostCategory.mentalHealth:
        return '🧠';
      case PostCategory.sexualHealth:
        return '💗';
      case PostCategory.chronicIllness:
        return '🩺';
      case PostCategory.skinConditions:
        return '🌸';
      case PostCategory.addiction:
        return '🎗️';
      case PostCategory.pregnancy:
        return '🤰';
      case PostCategory.other:
        return '💬';
    }
  }
}

class AnonymousPost {
  final String id;
  final String authorId; // Firebase UID (hidden from display)
  final String anonymousName; // Random name like "Brave Butterfly"
  final String anonymousAvatar; // Random emoji
  final String title;
  final String content;
  final PostCategory category;
  final DateTime createdAt;
  final int replyCount;
  final int upvoteCount;
  final List<String> upvoters; // List of user IDs who upvoted

  AnonymousPost({
    required this.id,
    required this.authorId,
    required this.anonymousName,
    required this.anonymousAvatar,
    required this.title,
    required this.content,
    required this.category,
    required this.createdAt,
    this.replyCount = 0,
    this.upvoteCount = 0,
    this.upvoters = const [],
  });

  factory AnonymousPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnonymousPost(
      id: doc.id,
      authorId: data['authorId'] ?? '',
      anonymousName: data['anonymousName'] ?? 'Anonymous',
      anonymousAvatar: data['anonymousAvatar'] ?? '👤',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      category: PostCategory.values.firstWhere(
            (c) => c.name == data['category'],
        orElse: () => PostCategory.other,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      replyCount: data['replyCount'] ?? 0,
      upvoteCount: data['upvoteCount'] ?? 0,
      upvoters: List<String>.from(data['upvoters'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'anonymousName': anonymousName,
      'anonymousAvatar': anonymousAvatar,
      'title': title,
      'content': content,
      'category': category.name,
      'createdAt': FieldValue.serverTimestamp(),
      'replyCount': replyCount,
      'upvoteCount': upvoteCount,
      'upvoters': upvoters,
    };
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class AnonymousReply {
  final String id;
  final String postId;
  final String authorId;
  final String anonymousName;
  final String anonymousAvatar;
  final String content;
  final DateTime createdAt;
  final int upvoteCount;
  final List<String> upvoters;

  AnonymousReply({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.anonymousName,
    required this.anonymousAvatar,
    required this.content,
    required this.createdAt,
    this.upvoteCount = 0,
    this.upvoters = const [],
  });

  factory AnonymousReply.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnonymousReply(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      anonymousName: data['anonymousName'] ?? 'Anonymous',
      anonymousAvatar: data['anonymousAvatar'] ?? '👤',
      content: data['content'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      upvoteCount: data['upvoteCount'] ?? 0,
      upvoters: List<String>.from(data['upvoters'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'anonymousName': anonymousName,
      'anonymousAvatar': anonymousAvatar,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'upvoteCount': upvoteCount,
      'upvoters': upvoters,
    };
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}