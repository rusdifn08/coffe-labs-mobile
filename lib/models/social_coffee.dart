import 'dart:convert';

class SocialPost {
  final String id;
  final String? userId;
  final String authorName;
  final String authorAvatar;
  final String authorRole;
  final String content;
  final int? recipeId;
  final Map<String, dynamic>? recipeSnapshot;
  int likesCount;
  int commentsCount;
  int copiesCount;
  final List<String> tags;
  bool isLikedByMe;
  final DateTime createdAt;

  SocialPost({
    required this.id,
    this.userId,
    required this.authorName,
    required this.authorAvatar,
    required this.authorRole,
    required this.content,
    this.recipeId,
    this.recipeSnapshot,
    required this.likesCount,
    required this.commentsCount,
    required this.copiesCount,
    required this.tags,
    required this.isLikedByMe,
    required this.createdAt,
  });

  factory SocialPost.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? recipeSnap;
    if (json['recipe_snapshot'] != null) {
      if (json['recipe_snapshot'] is Map) {
        recipeSnap = Map<String, dynamic>.from(json['recipe_snapshot'] as Map);
      } else if (json['recipe_snapshot'] is String) {
        try {
          recipeSnap = Map<String, dynamic>.from(jsonDecode(json['recipe_snapshot']) as Map);
        } catch (_) {}
      }
    }

    List<String> tagsList = [];
    if (json['tags'] is List) {
      tagsList = (json['tags'] as List).map((t) => t.toString()).toList();
    }

    DateTime created;
    try {
      created = DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      created = DateTime.now();
    }

    return SocialPost(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      authorName: json['author_name']?.toString() ?? 'Barista',
      authorAvatar: json['author_avatar']?.toString() ?? 'assets/images/characters/avatar_1.png',
      authorRole: json['author_role']?.toString() ?? 'Barista',
      content: json['content']?.toString() ?? '',
      recipeId: json['recipe_id'] as int?,
      recipeSnapshot: recipeSnap,
      likesCount: (json['likes_count'] as num?)?.toInt() ?? 0,
      commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      copiesCount: (json['copies_count'] as num?)?.toInt() ?? 0,
      tags: tagsList,
      isLikedByMe: json['is_liked_by_me'] == true,
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'author_role': authorRole,
      'content': content,
      'recipe_id': recipeId,
      'recipe_snapshot': recipeSnapshot,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'copies_count': copiesCount,
      'tags': tags,
      'is_liked_by_me': isLikedByMe,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SocialComment {
  final String id;
  final String postId;
  final String? userId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;

  SocialComment({
    required this.id,
    required this.postId,
    this.userId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
  });

  factory SocialComment.fromJson(Map<String, dynamic> json) {
    DateTime created;
    try {
      created = DateTime.parse(json['created_at']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      created = DateTime.now();
    }

    return SocialComment(
      id: json['id']?.toString() ?? '',
      postId: json['post_id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      authorName: json['author_name']?.toString() ?? 'Barista',
      authorAvatar: json['author_avatar']?.toString() ?? 'assets/images/characters/avatar_1.png',
      content: json['content']?.toString() ?? '',
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
