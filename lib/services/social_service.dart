import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/moderation/content_moderation_guard.dart';
import '../models/social_coffee.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'profile_service.dart';

class SocialService {
  static const String _cacheKey = 'coffeehub_social_feed_cache';
  static const String _savedPostsKey = 'coffeehub_social_saved_posts_v2';
  static const String _repostedIdsKey = 'coffeehub_social_reposted_ids_v2';
  static const String _deletedIdsKey = 'coffeehub_social_deleted_ids_v2';
  static const String _reportedIdsKey = 'coffeehub_social_reported_ids_v2';
  static const String _editedPostsKey = 'coffeehub_social_edited_posts_v2';

  static final ValueNotifier<int> changeNotifier = ValueNotifier<int>(0);

  static void _notify() {
    changeNotifier.value++;
  }

  /// Ambil feed postingan Social Coffee (termasuk tab `saved` yang selalu persisten).
  static Future<List<SocialPost>> getFeed({
    String sort = 'latest',
    bool forceRefresh = false,
  }) async {
    if (sort == 'saved') {
      return getSavedPosts();
    }

    final baseUrl = await AuthService.getBaseUrl();
    final username = await _getCurrentUsername();

    try {
      final uri = Uri.parse('$baseUrl/api/v1/social/posts').replace(
        queryParameters: {
          'sort': sort == 'all' ? 'latest' : sort,
          'username': username,
          'limit': '50',
        },
      );

      final res = await http.get(uri).timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] is List) {
          final remoteList = (decoded['data'] as List)
              .map((item) => SocialPost.fromJson(item as Map<String, dynamic>))
              .toList();

          final merged = await _applyLocalOverlays(remoteList);

          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            _cacheKey,
            json.encode(merged.map((p) => p.toJson()).toList()),
          );

          return merged;
        }
      }
    } catch (e) {
      debugPrint('SocialService.getFeed network error: $e');
    }

    // Fallback ke local cache jika offline atau network gagal
    final cached = await _applyLocalOverlays(await _getCachedPosts());
    if (cached.isNotEmpty) {
      if (sort == 'popular') {
        cached.sort(
          (a, b) => (b.likesCount * 2 +
                  b.commentsCount * 3 +
                  b.repostsCount * 4 +
                  b.copiesCount * 2)
              .compareTo(
            a.likesCount * 2 +
                a.commentsCount * 3 +
                a.repostsCount * 4 +
                a.copiesCount * 2,
          ),
        );
      } else if (sort == 'recipes') {
        return cached.where((p) => p.recipeSnapshot != null).toList();
      }
      return cached;
    }

    return _getEmergencySeedPosts();
  }

  /// Ambil seluruh postingan yang disimpan (bookmark) pengguna.
  static Future<List<SocialPost>> getSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = (prefs.getStringList(_deletedIdsKey) ?? const []).toSet();
    final reportedIds = (prefs.getStringList(_reportedIdsKey) ?? const []).toSet();
    final editedMap = _decodeEditedMap(prefs.getString(_editedPostsKey));
    final repostedIds = (prefs.getStringList(_repostedIdsKey) ?? const []).toSet();

    final list = _decodePostList(prefs.getString(_savedPostsKey))
        .where((p) => !deletedIds.contains(p.id) && !reportedIds.contains(p.id))
        .toList();

    for (final p in list) {
      p.isSavedByMe = true;
      if (repostedIds.contains(p.id)) p.isRepostedByMe = true;
      _applyLocalEditToPost(p, editedMap[p.id]);
    }
    return list;
  }

  /// Buat postingan diskusi atau bagikan resep baru (dilindungi moderasi kata terlarang + auto-ban 3x strike).
  static Future<SocialPost?> createPost({
    required String content,
    Map<String, dynamic>? recipeSnapshot,
    List<String>? tags,
  }) async {
    final fields = <String, String?>{'Postingan': content};
    if (tags != null && tags.isNotEmpty) {
      fields['Tagar'] = tags.join(' ');
    }
    final verdict = await ContentModerationGuard.inspectAndEnforce(fields);
    if (!verdict.isAllowed) {
      throw ContentModerationException(verdict, banStatus: verdict.banStatus);
    }

    final baseUrl = await AuthService.getBaseUrl();
    final token = await AuthService.getToken();
    final username = await _getCurrentUsername();
    final avatar = await ProfileService.getUserImagePath();

    final payload = {
      'author_name': username,
      'author_avatar': avatar,
      'author_role': 'Barista',
      'content': content.trim(),
      'recipe_snapshot': recipeSnapshot,
      'tags': tags ?? [],
    };

    try {
      final headers = {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      final res = await http
          .post(
            Uri.parse('$baseUrl/api/v1/social/posts'),
            headers: headers,
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          final newPost =
              SocialPost.fromJson(decoded['data'] as Map<String, dynamic>);
          await _upsertInFeedCache(newPost);
          _notify();
          return newPost;
        }
      } else if (res.statusCode == 400 || res.statusCode == 422) {
        final banStatus = await ModerationStrikeTracker.recordViolation();
        throw ContentModerationException(
          ModerationVerdict.blocked(
            reasonCode: 'SERVER_MODERATION_REJECTED',
            category: 'Moderasi Komunitas',
            userMessage: _extractServerMessage(
              res.body,
              'Postingan ditolak oleh sistem moderasi bahasa Coffee Labs.',
            ),
            banStatus: banStatus,
          ),
          banStatus: banStatus,
        );
      }
    } on ContentModerationException {
      rethrow;
    } catch (e) {
      debugPrint('SocialService.createPost network error: $e');
    }

    // Offline optimistic post
    final offlinePost = SocialPost(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      authorName: username,
      authorAvatar: avatar,
      authorRole: 'Barista',
      content: content.trim(),
      recipeSnapshot: recipeSnapshot,
      likesCount: 0,
      commentsCount: 0,
      copiesCount: 0,
      repostsCount: 0,
      tags: tags ?? [],
      isLikedByMe: false,
      isRepostedByMe: false,
      isSavedByMe: false,
      isEdited: false,
      createdAt: DateTime.now(),
    );

    await _upsertInFeedCache(offlinePost);
    _notify();

    return offlinePost;
  }

  /// Perbarui / edit postingan milik sendiri (terproteksi filter bahasa + sinkron backend & cache lokal).
  static Future<SocialPost?> updatePost({
    required SocialPost post,
    required String content,
    Map<String, dynamic>? recipeSnapshot,
    List<String>? tags,
  }) async {
    final fields = <String, String?>{'Postingan': content};
    if (tags != null && tags.isNotEmpty) {
      fields['Tagar'] = tags.join(' ');
    }
    final verdict = await ContentModerationGuard.inspectAndEnforce(fields);
    if (!verdict.isAllowed) {
      throw ContentModerationException(verdict, banStatus: verdict.banStatus);
    }

    final trimmed = content.trim();
    final updatedTags = List<String>.from(tags ?? const []);
    final now = DateTime.now();

    // Update optimistic in-memory
    post.content = trimmed;
    post.tags = updatedTags;
    post.recipeSnapshot = recipeSnapshot;
    post.isEdited = true;
    post.updatedAt = now;

    final baseUrl = await AuthService.getBaseUrl();
    final token = await AuthService.getToken();
    final username = await _getCurrentUsername();

    // Persist local edit overlay immediately so edit survives offline / backend lag
    await _saveLocalEdit(
      post.id,
      content: trimmed,
      tags: updatedTags,
      recipeSnapshot: recipeSnapshot,
      updatedAt: now,
    );
    await _upsertInFeedCache(post);
    if (post.isSavedByMe) {
      await _upsertSavedPost(post);
    }
    _notify();

    if (!post.id.startsWith('local_')) {
      try {
        final res = await http
            .put(
              Uri.parse('$baseUrl/api/v1/social/posts/${post.id}'),
              headers: {
                'Content-Type': 'application/json',
                if (token != null) 'Authorization': 'Bearer $token',
              },
              body: json.encode({
                'author_name': username,
                'content': trimmed,
                'recipe_snapshot': recipeSnapshot,
                'tags': updatedTags,
              }),
            )
            .timeout(const Duration(seconds: 20));

        if (res.statusCode == 400 || res.statusCode == 422) {
          final banStatus = await ModerationStrikeTracker.recordViolation();
          throw ContentModerationException(
            ModerationVerdict.blocked(
              reasonCode: 'SERVER_MODERATION_REJECTED',
              category: 'Moderasi Komunitas',
              userMessage: _extractServerMessage(
                res.body,
                'Pembaruan ditolak karena melanggar pedoman bahasa.',
              ),
              banStatus: banStatus,
            ),
            banStatus: banStatus,
          );
        }
      } on ContentModerationException {
        rethrow;
      } catch (e) {
        debugPrint('SocialService.updatePost network error: $e');
      }
    }

    return post;
  }

  /// Hapus postingan milik sendiri dari feed, simpanan, cache lokal, dan backend.
  static Future<bool> deletePost(SocialPost post) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = (prefs.getStringList(_deletedIdsKey) ?? const []).toSet()
      ..add(post.id);
    await prefs.setStringList(_deletedIdsKey, deletedIds.toList());

    // Hapus dari feed cache & saved posts
    final currentFeed = await _getCachedPosts();
    currentFeed.removeWhere((p) => p.id == post.id);
    await prefs.setString(
      _cacheKey,
      json.encode(currentFeed.map((p) => p.toJson()).toList()),
    );

    final savedPosts = _decodePostList(prefs.getString(_savedPostsKey));
    savedPosts.removeWhere((p) => p.id == post.id);
    await prefs.setString(
      _savedPostsKey,
      json.encode(savedPosts.map((p) => p.toJson()).toList()),
    );

    _notify();

    if (!post.id.startsWith('local_')) {
      try {
        final baseUrl = await AuthService.getBaseUrl();
        final token = await AuthService.getToken();
        final username = await _getCurrentUsername();
        final uri = Uri.parse('$baseUrl/api/v1/social/posts/${post.id}')
            .replace(queryParameters: {'username': username});
        await http.delete(
          uri,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ).timeout(const Duration(seconds: 20));
      } catch (e) {
        debugPrint('SocialService.deletePost network error: $e');
      }
    }

    return true;
  }

  /// Toggle Repost pada postingan (menggantikan aksi "Salin" yang sebelumnya membingungkan).
  static Future<Map<String, dynamic>> toggleRepost(SocialPost post) async {
    final willRepost = !post.isRepostedByMe;
    post.isRepostedByMe = willRepost;
    if (willRepost) {
      post.repostsCount++;
    } else {
      post.repostsCount = (post.repostsCount - 1).clamp(0, 999999);
    }

    final prefs = await SharedPreferences.getInstance();
    final repostedIds = (prefs.getStringList(_repostedIdsKey) ?? const []).toSet();
    if (willRepost) {
      repostedIds.add(post.id);
    } else {
      repostedIds.remove(post.id);
    }
    await prefs.setStringList(_repostedIdsKey, repostedIds.toList());
    await _upsertInFeedCache(post);
    _notify();

    if (!post.id.startsWith('local_')) {
      try {
        final baseUrl = await AuthService.getBaseUrl();
        final username = await _getCurrentUsername();
        final res = await http
            .post(
              Uri.parse('$baseUrl/api/v1/social/posts/${post.id}/repost'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'username': username}),
            )
            .timeout(const Duration(seconds: 20));

        if (res.statusCode == 200) {
          final decoded = json.decode(res.body);
          if (decoded['data'] != null) {
            post.isRepostedByMe = decoded['data']['is_reposted'] == true;
            post.repostsCount =
                (decoded['data']['reposts_count'] as num?)?.toInt() ??
                    post.repostsCount;
            await _upsertInFeedCache(post);
            _notify();
          }
        }
      } catch (e) {
        debugPrint('SocialService.toggleRepost network error: $e');
      }
    }

    return {
      'is_reposted': post.isRepostedByMe,
      'reposts_count': post.repostsCount,
    };
  }

  /// Toggle Save / Bookmark postingan & resep ke tab `Tersimpan` (persisten lokal + backend).
  static Future<bool> toggleSave(SocialPost post) async {
    final willSave = !post.isSavedByMe;
    post.isSavedByMe = willSave;

    if (willSave) {
      await _upsertSavedPost(post);
    } else {
      await _removeSavedPost(post.id);
    }
    await _upsertInFeedCache(post);
    _notify();

    if (!post.id.startsWith('local_')) {
      try {
        final baseUrl = await AuthService.getBaseUrl();
        final username = await _getCurrentUsername();
        await http
            .post(
              Uri.parse('$baseUrl/api/v1/social/posts/${post.id}/save'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({'username': username}),
            )
            .timeout(const Duration(seconds: 20));
      } catch (e) {
        debugPrint('SocialService.toggleSave network error: $e');
      }
    }

    return willSave;
  }

  /// Laporkan postingan melanggar pedoman komunitas & sembunyikan otomatis dari feed pengguna.
  static Future<bool> reportPost(SocialPost post, String reason) async {
    final prefs = await SharedPreferences.getInstance();
    final reportedIds = (prefs.getStringList(_reportedIdsKey) ?? const []).toSet()
      ..add(post.id);
    await prefs.setStringList(_reportedIdsKey, reportedIds.toList());
    _notify();

    if (!post.id.startsWith('local_')) {
      try {
        final baseUrl = await AuthService.getBaseUrl();
        final username = await _getCurrentUsername();
        await http
            .post(
              Uri.parse('$baseUrl/api/v1/social/posts/${post.id}/report'),
              headers: {'Content-Type': 'application/json'},
              body: json.encode({
                'username': username,
                'reason': reason,
              }),
            )
            .timeout(const Duration(seconds: 20));
      } catch (e) {
        debugPrint('SocialService.reportPost network error: $e');
      }
    }
    return true;
  }

  /// Toggle Like pada postingan
  static Future<Map<String, dynamic>> toggleLike(SocialPost post) async {
    final baseUrl = await AuthService.getBaseUrl();
    final username = await _getCurrentUsername();

    final willLike = !post.isLikedByMe;
    post.isLikedByMe = willLike;
    if (willLike) {
      post.likesCount++;
    } else {
      post.likesCount = (post.likesCount - 1).clamp(0, 999999);
    }
    _notify();

    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/v1/social/posts/${post.id}/like'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username}),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['data'] != null) {
          post.isLikedByMe = decoded['data']['is_liked'] == true;
          post.likesCount =
              (decoded['data']['likes_count'] as num?)?.toInt() ??
                  post.likesCount;
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
      final res = await http
          .get(Uri.parse('$baseUrl/api/v1/social/posts/$postId/comments'))
          .timeout(const Duration(seconds: 25));

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

  /// Tambah komentar baru pada postingan (dilindungi moderasi kata terlarang + auto-ban 3x strike)
  static Future<SocialComment?> addComment(String postId, String text) async {
    final verdict = await ContentModerationGuard.inspectAndEnforce({
      'Komentar': text,
    });
    if (!verdict.isAllowed) {
      throw ContentModerationException(verdict, banStatus: verdict.banStatus);
    }

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
      final res = await http
          .post(
            Uri.parse('$baseUrl/api/v1/social/posts/$postId/comments'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
            body: json.encode(payload),
          )
          .timeout(const Duration(seconds: 25));

      if (res.statusCode == 201 || res.statusCode == 200) {
        final decoded = json.decode(res.body);
        if (decoded['success'] == true && decoded['data'] != null) {
          _notify();
          return SocialComment.fromJson(decoded['data'] as Map<String, dynamic>);
        }
      } else if (res.statusCode == 400 || res.statusCode == 422) {
        final banStatus = await ModerationStrikeTracker.recordViolation();
        throw ContentModerationException(
          ModerationVerdict.blocked(
            reasonCode: 'SERVER_MODERATION_REJECTED',
            category: 'Moderasi Komunitas',
            userMessage: _extractServerMessage(
              res.body,
              'Komentar ditolak oleh sistem moderasi bahasa Coffee Labs.',
            ),
            banStatus: banStatus,
          ),
          banStatus: banStatus,
        );
      }
    } on ContentModerationException {
      rethrow;
    } catch (e) {
      debugPrint('SocialService.addComment error: $e');
    }

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

  /// Susun objek resep siap seduh dari snapshot postingan tanpa menduplikasi diam-diam ke daftar resep.
  static Map<String, dynamic>? buildBrewableRecipeFromPost(SocialPost post) {
    final snapshot = post.recipeSnapshot;
    if (snapshot == null) return null;

    final title =
        snapshot['title']?.toString() ?? 'Resep Komunitas Social Coffee';
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

    return {
      'id': snapshot['id'],
      'title': title,
      'author': snapshot['author']?.toString() ?? post.authorName,
      'method': snapshot['method']?.toString() ?? 'Hario V60 02',
      'category': snapshot['category']?.toString() ?? 'V60',
      'beanName': snapshot['beanName']?.toString() ?? 'Single Origin Specialty',
      'variety': snapshot['variety']?.toString() ?? 'Specialty Arabica',
      'process': snapshot['process']?.toString() ?? 'Washed Process',
      'waterTempCelsius': (snapshot['waterTempCelsius'] as num?)?.toInt() ?? 92,
      'grindSize': snapshot['grindSize']?.toString() ?? 'Medium',
      'coffeeWeightGrams':
          (snapshot['coffeeWeightGrams'] as num?)?.toInt() ?? 15,
      'totalWaterWeightGrams':
          (snapshot['totalWaterWeightGrams'] as num?)?.toInt() ?? 225,
      'iceWeightGrams': (snapshot['iceWeightGrams'] as num?)?.toInt() ?? 0,
      'tastingNotes':
          snapshot['tastingNotes']?.toString() ?? 'Sweet, Balanced, Clean',
      'description': snapshot['description']?.toString() ?? post.content,
      'steps': stepsList,
      'isCustom': snapshot['isCustom'] == true,
    };
  }

  /// (Legacy compatibility) Copy resep dari postingan ke koleksi resep lokal user bila dibutuhkan.
  static Future<Map<String, dynamic>?> copyRecipeToMyRecipes(
      SocialPost post) async {
    final brewable = buildBrewableRecipeFromPost(post);
    if (brewable == null) return null;
    brewable['title'] = '${brewable['title']} (dari ${post.authorName})';
    brewable['isCustom'] = true;
    brewable['createdAt'] = DateTime.now().toIso8601String();
    return ApiService.createRecipe(brewable);
  }

  // --- HELPER METHODS ---

  static Future<List<SocialPost>> _applyLocalOverlays(
    List<SocialPost> basePosts,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final deletedIds = (prefs.getStringList(_deletedIdsKey) ?? const []).toSet();
    final reportedIds = (prefs.getStringList(_reportedIdsKey) ?? const []).toSet();
    final repostedIds = (prefs.getStringList(_repostedIdsKey) ?? const []).toSet();
    final savedIds =
        _decodePostList(prefs.getString(_savedPostsKey)).map((p) => p.id).toSet();
    final editedMap = _decodeEditedMap(prefs.getString(_editedPostsKey));

    // Pertahankan juga local optimistic posts yang belum terupload ke server
    final cached = await _getCachedPosts();
    final existingIds = basePosts.map((p) => p.id).toSet();
    final localOnly = cached
        .where((p) => p.id.startsWith('local_') && !existingIds.contains(p.id))
        .toList();

    final merged = [...localOnly, ...basePosts]
        .where((p) => !deletedIds.contains(p.id) && !reportedIds.contains(p.id))
        .toList();

    for (final p in merged) {
      if (savedIds.contains(p.id)) p.isSavedByMe = true;
      if (repostedIds.contains(p.id)) {
        if (!p.isRepostedByMe) {
          p.isRepostedByMe = true;
          if (p.repostsCount == 0) p.repostsCount = 1;
        }
      }
      _applyLocalEditToPost(p, editedMap[p.id]);
    }
    return merged;
  }

  static void _applyLocalEditToPost(
    SocialPost post,
    Map<String, dynamic>? editData,
  ) {
    if (editData == null) return;
    if (editData['content'] is String) {
      post.content = editData['content'] as String;
    }
    if (editData['tags'] is List) {
      post.tags = (editData['tags'] as List).map((e) => e.toString()).toList();
    }
    if (editData.containsKey('recipe_snapshot')) {
      final snap = editData['recipe_snapshot'];
      post.recipeSnapshot = snap is Map ? Map<String, dynamic>.from(snap) : null;
    }
    post.isEdited = true;
    if (editData['updated_at'] is String) {
      post.updatedAt = DateTime.tryParse(editData['updated_at'] as String);
    }
  }

  static Future<void> _saveLocalEdit(
    String postId, {
    required String content,
    required List<String> tags,
    required Map<String, dynamic>? recipeSnapshot,
    required DateTime updatedAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final map = _decodeEditedMap(prefs.getString(_editedPostsKey));
    map[postId] = {
      'content': content,
      'tags': tags,
      'recipe_snapshot': recipeSnapshot,
      'updated_at': updatedAt.toIso8601String(),
    };
    await prefs.setString(_editedPostsKey, json.encode(map));
  }

  static Future<void> _upsertInFeedCache(SocialPost post) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await _getCachedPosts();
    final idx = list.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      list[idx] = post;
    } else {
      list.insert(0, post);
    }
    await prefs.setString(
      _cacheKey,
      json.encode(list.map((p) => p.toJson()).toList()),
    );
  }

  static Future<void> _upsertSavedPost(SocialPost post) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = _decodePostList(prefs.getString(_savedPostsKey));
    final idx = saved.indexWhere((p) => p.id == post.id);
    if (idx >= 0) {
      saved[idx] = post;
    } else {
      saved.insert(0, post);
    }
    await prefs.setString(
      _savedPostsKey,
      json.encode(saved.map((p) => p.toJson()).toList()),
    );
  }

  static Future<void> _removeSavedPost(String postId) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = _decodePostList(prefs.getString(_savedPostsKey));
    saved.removeWhere((p) => p.id == postId);
    await prefs.setString(
      _savedPostsKey,
      json.encode(saved.map((p) => p.toJson()).toList()),
    );
  }

  static Map<String, Map<String, dynamic>> _decodeEditedMap(String? raw) {
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = json.decode(raw);
      if (decoded is Map) {
        return decoded.map(
          (k, v) => MapEntry(
            k.toString(),
            v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
          ),
        );
      }
    } catch (_) {}
    return {};
  }

  static List<SocialPost> _decodePostList(String? raw) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = json.decode(raw);
      if (decoded is List) {
        return decoded
            .map((e) => SocialPost.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  static String _extractServerMessage(String body, String fallback) {
    try {
      final decoded = json.decode(body);
      if (decoded is Map && decoded['message']?.toString().isNotEmpty == true) {
        return decoded['message'].toString();
      }
    } catch (_) {}
    return fallback;
  }

  static Future<String> _getCurrentUsername() async {
    final user = await AuthService.getCurrentUser();
    if (user != null && user.username.isNotEmpty) return user.username;
    return await ProfileService.getUserName();
  }

  static Future<List<SocialPost>> _getCachedPosts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return _decodePostList(prefs.getString(_cacheKey));
    } catch (_) {}
    return [];
  }

  static List<SocialPost> _getEmergencySeedPosts() {
    return [];
  }
}
