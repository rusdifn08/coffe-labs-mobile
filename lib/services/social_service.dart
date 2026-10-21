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

      final res = await http.get(uri).timeout(const Duration(seconds: 15));

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
      ).timeout(const Duration(seconds: 15));

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
      ).timeout(const Duration(seconds: 10));

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
      ).timeout(const Duration(seconds: 10));

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
      ).timeout(const Duration(seconds: 10));

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
      ).timeout(const Duration(seconds: 8));

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
    return [
      SocialPost(
        id: 'seed_1',
        authorName: 'Mikael Jasin 🇮🇩',
        authorAvatar: 'assets/images/characters/avatar_1.png',
        authorRole: 'World Barista Champion',
        content: 'Teman-teman barista! Buat yang sering ngerasa kopi natural gampang over-ferment, coba teknik 4-pour dengan suhu 91°C ini di dripper V60. Hasil cup di Kintamani Anaerobic keluar peach dan jackfruit yang super sparkling! Silakan copy resepnya & coba di bar kalian ☕🔥',
        likesCount: 48,
        commentsCount: 2,
        copiesCount: 29,
        tags: ['V60', 'Kintamani', 'WBC2024', 'Sweetness'],
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        recipeSnapshot: {
          'title': 'Sweetness Boost Bali Kintamani Anaerobic',
          'author': 'Mikael Jasin 🇮🇩',
          'method': 'Hario V60 02',
          'category': 'V60',
          'waterTempCelsius': 91,
          'grindSize': 'Medium (22 Klik Comandante)',
          'coffeeWeightGrams': 15,
          'totalWaterWeightGrams': 225,
          'totalTimeSeconds': 150,
          'tastingNotes': 'Ripe Peach, Jackfruit, Wild Honey, Sparkling Acidity',
          'description': 'Tuangan perlahan terkontrol untuk menonjolkan sweetness alami tanpa rasa over-fermented.',
          'steps': [
            {'stepOrder': 1, 'title': 'Blooming', 'durationSeconds': 40, 'waterAddedGrams': 45, 'instruction': 'Tuang 45g melingkar.'},
            {'stepOrder': 2, 'title': 'Second Pour', 'durationSeconds': 40, 'waterAddedGrams': 65, 'instruction': 'Tuang spiral halus hingga 110g.'},
            {'stepOrder': 3, 'title': 'Third Pour', 'durationSeconds': 35, 'waterAddedGrams': 60, 'instruction': 'Tuang stabil hingga 170g.'},
            {'stepOrder': 4, 'title': 'Final Pour', 'durationSeconds': 35, 'waterAddedGrams': 55, 'instruction': 'Tuang tengah hingga 225g.'}
          ]
        },
      ),
      SocialPost(
        id: 'seed_2',
        authorName: 'Yoshua Tanu 🇮🇩',
        authorAvatar: 'assets/images/characters/avatar_2.png',
        authorRole: 'Indonesian Barista Champion',
        content: 'Banyak yang tanya settingan terbaik buat Aceh Gayo Wine Process biar ga terlalu asem nusuk. Kuncinya ada di rasio 1:15 dan potong tetesan akhir tepat di 02:30. Karakter anggur sangria dan buah tin keringnya jadi manis elegan!',
        likesCount: 42,
        commentsCount: 1,
        copiesCount: 34,
        tags: ['WineProcess', 'AcehGayo', 'CommonGrounds', 'HighSweetness'],
        isLikedByMe: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        recipeSnapshot: {
          'title': 'V60 High-Sweetness Gayo Wine Process',
          'author': 'Yoshua Tanu 🇮🇩',
          'method': 'Hario V60 02',
          'category': 'V60',
          'waterTempCelsius': 89,
          'grindSize': 'Medium-Coarse (26 Klik Comandante)',
          'coffeeWeightGrams': 16,
          'totalWaterWeightGrams': 240,
          'totalTimeSeconds': 150,
          'tastingNotes': 'Sangria, Dried Fig, Concord Grape, Cocoa Nibs',
          'description': 'Potong tetesan di 02:30 untuk meredam kelat dan mengangkat manis buah anggur.',
          'steps': [
            {'stepOrder': 1, 'title': 'Degassing Bloom', 'durationSeconds': 45, 'waterAddedGrams': 50, 'instruction': 'Tuang 50g air bersuhu 89°C.'},
            {'stepOrder': 2, 'title': 'Sweet Extraction', 'durationSeconds': 45, 'waterAddedGrams': 90, 'instruction': 'Tuang memutar koin hingga 140g.'},
            {'stepOrder': 3, 'title': 'Clean Finish', 'durationSeconds': 60, 'waterAddedGrams': 100, 'instruction': 'Tuang 100g hingga 240g, angkat di 02:30.'}
          ]
        },
      ),
    ];
  }
}
