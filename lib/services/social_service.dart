import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/social_coffee.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'profile_service.dart';

class SocialService {
  static const String _cacheKey = 'coffeehub_social_feed_cache';
  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  static void _notify() {
    changeNotifier.value++;
  }

  /// Ambil feed postingan Social Coffee
  static Future<List<SocialPost>> getFeed({
    String sort = 'latest',
    bool forceRefresh = false,
  }) async {
    final baseUrl = await AuthService.getBaseUrl();
    final username = await _getCurrentUsername();

    try {
      final uri = Uri.parse('$baseUrl/api/v1/social/posts').replace(queryParameters: {
        'sort': sort,
        'username': username,
        'limit': '50',
      });

      final res = await http.get(uri).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final list = (decoded['data'] as List)
              .map((item) => SocialPost.fromJson(item as Map<String, dynamic>))
              .toList();

          // Simpan ke local cache untuk offline availability
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, json.encode(decoded['data']));

          return list;
        }
      }
    } catch (e) {
      debugPrint('SocialService.getFeed network error: $e');
    }

    // Fallback ke local cache jika offline atau network gagal
    final cached = await _getCachedPosts();
    if (cached.isNotEmpty) {
      if (sort == 'popular') {
        cached.sort((a, b) => (b.likesCount * 2 + b.commentsCount * 3 + b.copiesCount * 4)
            .compareTo(a.likesCount * 2 + a.commentsCount * 3 + a.copiesCount * 4));
      } else if (sort == 'recipes') {
        return cached.where((p) => p.recipeSnapshot != null).toList();
      }
      return cached;
    }

    // Default emergency seed data jika offline dan cache masih kosong
    return _getEmergencySeedPosts();
  }

  /// Buat postingan diskusi atau bagikan resep baru
  static Future<SocialPost?> createPost({
    required String content,
    Map<String, dynamic>? recipeSnapshot,
    List<String>? tags,
  }) async {
    final baseUrl = await AuthService.getBaseUrl();
    final token = await AuthService.getToken();
    final username = await _getCurrentUsername();
    final avatar = await ProfileService.getUserImagePath();

    final payload = {
      'author_name': username,
      'author_avatar': avatar,
      'author_role': 'Barista',
      'content': content,
      'recipe_snapshot': recipeSnapshot,
      'tags': tags ?? [],
    };

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/social/posts'),
        headers: headers,
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final newPost = SocialPost.fromJson(decoded['data'] as Map<String, dynamic>);
          _notify();
          return newPost;
        }
      }
    } catch (e) {
      debugPrint('SocialService.createPost network error: $e');
    }

    // Offline optimistic post
    final offlinePost = SocialPost(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorName: username,
      authorAvatar: avatar,
      authorRole: 'Barista',
      content: content,
      recipeSnapshot: recipeSnapshot,
      likesCount: 0,
      commentsCount: 0,
      copiesCount: 0,
      tags: tags ?? [],
      isLikedByMe: false,
      createdAt: DateTime.now(),
    );

    // Simpan ke cache
    final current = await _getCachedPosts();
    current.insert(0, offlinePost);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, json.encode(current.map((p) => p.toJson()).toList()));
    _notify();

    return offlinePost;
  }

  /// Toggle Like pada postingan
  static Future<Map<String, dynamic>> toggleLike(SocialPost post) async {
    final baseUrl = await AuthService.getBaseUrl();
    final username = await _getCurrentUsername();

    // Optimistic UI state
    final willLike = !post.isLikedByMe;
    post.isLikedByMe = willLike;
    if (willLike) {
      post.likesCount++;
    } else {
      post.likesCount = (post.likesCount - 1).clamp(0, 999999);
    }
    _notify();

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/social/posts/${post.id}/like'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username}),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['data'] != null) {
          post.isLikedByMe = decoded['data']['is_liked'] == true;
          post.likesCount = (decoded['data']['likes_count'] as num?)?.toInt() ?? post.likesCount;
          _notify();
          return {
            'is_liked': post.isLikedByMe,
            'likes_count': post.likesCount,
          };
        }
      }
    } catch (e) {
      debugPrint('SocialService.toggleLike network error: $e');
    }

    return {
      'is_liked': post.isLikedByMe,
      'likes_count': post.likesCount,
    };
  }

  /// Ambil komentar untuk suatu postingan
  static Future<List<SocialComment>> getComments(String postId) async {
    final baseUrl = await AuthService.getBaseUrl();

    try {
      final res = await http.get(
        Uri.parse('$baseUrl/api/v1/social/posts/$postId/comments'),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          return (decoded['data'] as List)
              .map((c) => SocialComment.fromJson(c as Map<String, dynamic>))
              .toList();
        }
      }
    } catch (e) {
      debugPrint('SocialService.getComments error: $e');
    }

    return [];
  }

  /// Tambah komentar baru pada postingan
  static Future<SocialComment?> addComment(String postId, String text) async {
    final baseUrl = await AuthService.getBaseUrl();
    final token = await AuthService.getToken();
    final username = await _getCurrentUsername();
    final avatar = await ProfileService.getUserImagePath();

    final payload = {
      'author_name': username,
      'author_avatar': avatar,
      'content': text.trim(),
    };

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/social/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 25));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          _notify();
          return SocialComment.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      }
    } catch (e) {
      debugPrint('SocialService.addComment error: $e');
    }

    // Offline fallback comment
    final offlineComment = SocialComment(
      id: 'comment_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      authorName: username,
      authorAvatar: avatar,
      content: text.trim(),
      createdAt: DateTime.now(),
    );
    _notify();
    return offlineComment;
  }

  /// Copy resep dari postingan dan simpan langsung ke koleksi resep lokal user
  static Future<Map<String, dynamic>?> copyRecipeToMyRecipes(SocialPost post) async {
    final snapshot = post.recipeSnapshot;
    if (snapshot == null) return null;

    final baseUrl = await AuthService.getBaseUrl();

    // 1. Beritahu backend untuk menambah counter copies_count
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/v1/social/posts/${post.id}/copy-recipe'),
      ).timeout(const Duration(seconds: 20));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['data'] != null && decoded['data']['copies_count'] != null) {
          post.copiesCount = (decoded['data']['copies_count'] as num).toInt();
          _notify();
        }
      }
    } catch (e) {
      post.copiesCount++;
      _notify();
    }

    // 2. Format resep snapshot menjadi Custom Recipe dan simpan via ApiService
    final title = snapshot['title']?.toString() ?? 'Resep Komunitas Social Coffee';
    final rawSteps = snapshot['steps'];
    final List<Map<String, dynamic>> stepsList = [];

    if (rawSteps is List) {
      for (int i = 0; i < rawSteps.length; i++) {
        final s = rawSteps[i];
        if (s is Map) {
          stepsList.add({
            'stepOrder': i + 1,
            'title': s['title']?.toString() ?? 'Tuang ${i + 1}',
            'durationSeconds': (s['durationSeconds'] as num?)?.toInt() ?? 30,
            'waterAddedGrams': (s['waterAddedGrams'] as num?)?.toInt() ?? 50,
            'instruction': s['instruction']?.toString() ?? '',
          });
        }
      }
    }

    final newCustomRecipe = {
      'title': '$title (dari ${post.authorName})',
      'author': '${post.authorName} [Komunitas]',
      'method': snapshot['method']?.toString() ?? 'Hario V60 02',
      'category': snapshot['category']?.toString() ?? 'V60',
      'beanName': snapshot['beanName']?.toString() ?? 'Single Origin Specialty',
      'variety': snapshot['variety']?.toString() ?? 'Specialty Arabica',
      'process': snapshot['process']?.toString() ?? 'Washed Process',
      'waterTempCelsius': (snapshot['waterTempCelsius'] as num?)?.toInt() ?? 92,
      'grindSize': snapshot['grindSize']?.toString() ?? 'Medium',
      'coffeeWeightGrams': (snapshot['coffeeWeightGrams'] as num?)?.toInt() ?? 15,
      'totalWaterWeightGrams': (snapshot['totalWaterWeightGrams'] as num?)?.toInt() ?? 225,
      'iceWeightGrams': (snapshot['iceWeightGrams'] as num?)?.toInt() ?? 0,
      'tastingNotes': snapshot['tastingNotes']?.toString() ?? 'Sweet, Balanced, Clean',
      'description': 'Resep dibagikan oleh ${post.authorName} di Social Coffee: ${snapshot['description'] ?? post.content}',
      'steps': stepsList,
      'isCustom': true,
      'createdAt': DateTime.now().toIso8601String(),
    };

    final savedRecipe = await ApiService.createRecipe(newCustomRecipe);
    return savedRecipe;
  }

  // --- HELPER METHODS ---

  static Future<String> _getCurrentUsername() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && user.username.isNotEmpty) return user.username;
    return await ProfileService.getUserName();
  }

  static Future<List<SocialPost>> _getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final str = prefs.getString(_cacheKey);
      if (str != null) {
        final decoded = json.decode(str);
        if (decoded is List) {
          return decoded.map((e) => SocialPost.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
    } catch (_) {}
    return [];
  }

  static List<SocialPost> _getEmergencySeedPosts() {
    return [];
  }
}
