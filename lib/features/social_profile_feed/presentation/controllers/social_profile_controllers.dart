import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../screens/brew_timer_screen.dart';
import '../../../../services/api_service.dart';
import '../../data/services/social_profile_api_service.dart';
import '../../domain/models/social_profile_models.dart';
import '../../domain/models/social_thread_models.dart';

part 'social_profile_controllers.g.dart';

@Riverpod(keepAlive: true)
SocialProfileApiService socialProfileApiService(Ref ref) {
  return SocialProfileApiService(ref.watch(dioClientProvider));
}

@riverpod
class PublicProfileController extends _$PublicProfileController {
  @override
  Future<MaterializedProfileView> build(String targetUserOrUsername) {
    final api = ref.watch(socialProfileApiServiceProvider);
    return api.getProfile(targetUserOrUsername);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(socialProfileApiServiceProvider)
          .getProfile(targetUserOrUsername),
    );
  }

  /// Optimistic follow/unfollow update with clean rollback on network/auth failure.
  Future<bool> toggleFollowOptimistic() async {
    final previous = state.value;
    if (previous == null || previous.isOwnProfile) return false;

    await HapticFeedback.lightImpact();
    final nextFollowed = !previous.isFollowedByViewer;
    final nextCount =
        (previous.followersCount + (nextFollowed ? 1 : -1)).clamp(0, 1 << 30);

    state = AsyncData(
      previous.copyWith(
        isFollowedByViewer: nextFollowed,
        followersCount: nextCount,
      ),
    );

    try {
      final result = await ref
          .read(socialProfileApiServiceProvider)
          .toggleFollow(targetUserOrUsername);
      final latest = state.value ?? previous;
      state = AsyncData(
        latest.copyWith(
          isFollowedByViewer: result.isFollowedByViewer,
          followersCount: result.followersCount,
        ),
      );
      return true;
    } catch (_) {
      state = AsyncData(previous);
      return false;
    }
  }

  Future<bool> updateMyProfile({
    String? displayName,
    String? bio,
    RecentBrewSnapshot? recentBrewSnapshot,
  }) async {
    try {
      final updated = await ref
          .read(socialProfileApiServiceProvider)
          .updateMyProfile(
            displayName: displayName,
            bio: bio,
            recentBrewSnapshot: recentBrewSnapshot,
          );
      state = AsyncData(updated);
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
class ProfileTabFeedController extends _$ProfileTabFeedController {
  bool _isFetchingNext = false;

  @override
  Future<CursorPaginatedThreadsState> build(
    String targetUserOrUsername,
    ProfileFeedTab tab,
  ) async {
    final api = ref.watch(socialProfileApiServiceProvider);
    final res = await api.getProfileTabThreads(
      targetUserOrUsername: targetUserOrUsername,
      tab: tab,
    );
    return CursorPaginatedThreadsState(
      items: res.items,
      nextCursor: res.nextCursor,
      hasMore: res.hasMore,
    );
  }

  Future<void> refresh() async {
    final api = ref.read(socialProfileApiServiceProvider);
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final res = await api.getProfileTabThreads(
        targetUserOrUsername: targetUserOrUsername,
        tab: tab,
      );
      return CursorPaginatedThreadsState(
        items: res.items,
        nextCursor: res.nextCursor,
        hasMore: res.hasMore,
      );
    });
  }

  Future<void> fetchNextPage() async {
    final current = state.value;
    if (current == null || !current.hasMore || _isFetchingNext) return;
    if (current.nextCursor == null) return;

    _isFetchingNext = true;
    state = AsyncData(current.copyWith(isLoadingNextPage: true));
    try {
      final api = ref.read(socialProfileApiServiceProvider);
      final next = await api.getProfileTabThreads(
        targetUserOrUsername: targetUserOrUsername,
        tab: tab,
        cursor: current.nextCursor,
      );
      state = AsyncData(
        CursorPaginatedThreadsState(
          items: [...current.items, ...next.items],
          nextCursor: next.nextCursor,
          hasMore: next.hasMore,
          isLoadingNextPage: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingNextPage: false));
    } finally {
      _isFetchingNext = false;
    }
  }

  Future<bool> toggleLikeOptimistic(String threadId) async {
    final current = state.value;
    if (current == null) return false;
    await HapticFeedback.lightImpact();

    final prevItems = current.items;
    final nextItems = prevItems.map((item) {
      if (item.id != threadId) return item;
      final nextLiked = !item.isLikedByMe;
      final nextCount =
          (item.likesCount + (nextLiked ? 1 : -1)).clamp(0, 1 << 30);
      return item.copyWith(isLikedByMe: nextLiked, likesCount: nextCount);
    }).toList();

    state = AsyncData(current.copyWith(items: nextItems));

    try {
      final res = await ref
          .read(socialProfileApiServiceProvider)
          .toggleLike(threadId);
      final latest = state.value;
      if (latest != null && res['likes_count'] is num) {
        final serverLiked = res['is_liked_by_me'] == true;
        final serverCount = (res['likes_count'] as num).toInt();
        state = AsyncData(
          latest.copyWith(
            items: latest.items
                .map(
                  (it) => it.id == threadId
                      ? it.copyWith(
                          isLikedByMe: serverLiked,
                          likesCount: serverCount,
                        )
                      : it,
                )
                .toList(),
          ),
        );
      }
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(items: prevItems));
      return false;
    }
  }

  Future<bool> toggleRepostOptimistic(String threadId) async {
    final current = state.value;
    if (current == null) return false;
    await HapticFeedback.selectionClick();

    final prevItems = current.items;
    final nextItems = prevItems.map((item) {
      if (item.id != threadId) return item;
      final nextReposted = !item.isRepostedByMe;
      final nextCount =
          (item.repostsCount + (nextReposted ? 1 : -1)).clamp(0, 1 << 30);
      return item.copyWith(
        isRepostedByMe: nextReposted,
        repostsCount: nextCount,
      );
    }).toList();

    state = AsyncData(current.copyWith(items: nextItems));

    try {
      final res = await ref
          .read(socialProfileApiServiceProvider)
          .toggleRepost(threadId);
      final latest = state.value;
      if (latest != null && res['reposts_count'] is num) {
        final serverReposted = res['is_reposted_by_me'] == true;
        final serverCount = (res['reposts_count'] as num).toInt();
        state = AsyncData(
          latest.copyWith(
            items: latest.items
                .map(
                  (it) => it.id == threadId
                      ? it.copyWith(
                          isRepostedByMe: serverReposted,
                          repostsCount: serverCount,
                        )
                      : it,
                )
                .toList(),
          ),
        );
      }
      return true;
    } catch (_) {
      state = AsyncData(current.copyWith(items: prevItems));
      return false;
    }
  }

  void prependThread(SocialThreadItem created) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(items: [created, ...current.items]));
  }

  /// Increments try_recipe_count optimistically, notifies backend (+15 author XP),
  /// and launches BrewTimerScreen with a sanitized recipe payload.
  Future<void> onTryRecipeTapped({
    required BuildContext context,
    required InteractiveRecipeCardAttachment card,
    required String threadId,
  }) async {
    await HapticFeedback.mediumImpact();

    final current = state.value;
    if (current != null) {
      state = AsyncData(
        current.copyWith(
          items: current.items
              .map(
                (it) => it.id == threadId
                    ? it.copyWith(tryRecipeCount: it.tryRecipeCount + 1)
                    : it,
              )
              .toList(),
        ),
      );
    }

    // Fire & forget XP credit in background while preparing local brew payload.
    ref
        .read(socialProfileApiServiceProvider)
        .recordTryRecipe(threadId)
        .ignore();

    final recipePayload = await _buildBrewTimerPayload(card);
    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrewTimerScreen(recipeData: recipePayload),
      ),
    );
  }

  Future<Map<String, dynamic>> _buildBrewTimerPayload(
    InteractiveRecipeCardAttachment card,
  ) async {
    try {
      final allRecipes = await ApiService.getRecipes();
      final match = allRecipes.whereType<Map>().firstWhere(
            (r) => r['id']?.toString() == card.recipeId,
            orElse: () => const {},
          );
      if (match.isNotEmpty) {
        return ApiService.sanitizeRecipe(match);
      }
    } catch (_) {}

    final stepsList = card.stepsPreview.isEmpty
        ? [
            {
              'stepOrder': 1,
              'title': 'Pour ${card.method}',
              'durationSeconds': card.targetDurationSec,
              'waterAddedGrams': card.totalWaterMl.round(),
              'instruction': 'Tuang perlahan mengikuti resep ${card.title}.',
            },
          ]
        : card.stepsPreview
            .map(
              (s) => {
                'stepOrder': s.stepNumber,
                'title': s.title,
                'durationSeconds': s.durationSec,
                'waterAddedGrams': s.waterAddedMl.round(),
                'instruction': s.instruction ??
                    'Tuang ${s.waterAddedMl.round()}ml selama ${s.durationSec} detik'
                        '${s.targetTempC != null ? ' pada ${s.targetTempC}°C' : ''}.',
              },
            )
            .toList();

    return ApiService.sanitizeRecipe({
      'id': int.tryParse(card.recipeId) ?? 9001,
      'title': card.title,
      'brewer': card.brewerName,
      'method': card.method,
      'coffeeWeightGrams': card.coffeeDoseG.round(),
      'waterWeightGrams': card.totalWaterMl.round(),
      'waterTempCelsius': card.primaryTempC,
      'totalTimeSeconds': card.targetDurationSec,
      'steps': stepsList,
    });
  }
}

@riverpod
class ThreadDetailController extends _$ThreadDetailController {
  @override
  Future<ThreadDetailResponse> build(String threadId) {
    return ref.watch(socialProfileApiServiceProvider).getThreadDetail(threadId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(socialProfileApiServiceProvider).getThreadDetail(threadId),
    );
  }

  Future<bool> submitReply({
    required String bodyText,
    String? parentThreadId,
    ThreadAttachment? attachment,
  }) async {
    try {
      await ref.read(socialProfileApiServiceProvider).createThread(
            kind: 'REPLY',
            bodyText: bodyText,
            parentThreadId: parentThreadId ?? threadId,
            attachment: attachment,
          );
      await refresh();
      return true;
    } catch (_) {
      return false;
    }
  }
}

@riverpod
Future<List<ProfileDirectoryEntry>> baristaDirectorySearch(
  Ref ref,
  String query,
) async {
  final res = await ref
      .watch(socialProfileApiServiceProvider)
      .exploreProfiles(query: query, limit: 30);
  return res.items;
}
