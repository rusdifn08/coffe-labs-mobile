import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../screens/brew_timer_screen.dart';
import '../../../../services/api_service.dart';
import '../../../social_profile_feed/domain/models/social_thread_models.dart';
import '../../../social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import '../../data/explore_feed_api_service.dart';
import '../../domain/explore_feed_models.dart';

part 'explore_feed_controllers.g.dart';

@Riverpod(keepAlive: true)
ExploreFeedApiService exploreFeedApi(Ref ref) {
  return ExploreFeedApiService(ref.watch(dioClientProvider));
}

@riverpod
class ForYouFeedController extends _$ForYouFeedController {
  @override
  Future<ForYouFeedResponse> build({String methodFilter = 'ALL'}) {
    return ref
        .watch(exploreFeedApiProvider)
        .getForYouFeed(methodFilter: methodFilter);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref
          .read(exploreFeedApiProvider)
          .getForYouFeed(methodFilter: methodFilter, refresh: true),
    );
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || !current.hasMore || current.nextOffset == null) {
      return;
    }
    final nextPage = await ref.read(exploreFeedApiProvider).getForYouFeed(
          cursorOffset: current.nextOffset!,
          methodFilter: methodFilter,
        );
    state = AsyncData(
      ForYouFeedResponse(
        items: [...current.items, ...nextPage.items],
        userTopTastes: nextPage.userTopTastes,
        nextOffset: nextPage.nextOffset,
        hasMore: nextPage.hasMore,
      ),
    );
  }

  Future<void> toggleLike(String threadId) async {
    final current = state.value;
    if (current == null) return;
    await HapticFeedback.lightImpact();

    state = AsyncData(
      ForYouFeedResponse(
        userTopTastes: current.userTopTastes,
        nextOffset: current.nextOffset,
        hasMore: current.hasMore,
        items: current.items.map((item) {
          if (item.thread.id != threadId) return item;
          final liked = !item.thread.isLikedByMe;
          return item.copyWith(
            thread: item.thread.copyWith(
              isLikedByMe: liked,
              likesCount: (item.thread.likesCount + (liked ? 1 : -1))
                  .clamp(0, 1 << 30),
            ),
          );
        }).toList(),
      ),
    );

    try {
      await ref.read(socialProfileApiServiceProvider).toggleLike(threadId);
      ref
          .read(exploreFeedApiProvider)
          .markSeenAndEngaged(engagedThreadIds: [threadId])
          .ignore();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> toggleRepost(String threadId) async {
    final current = state.value;
    if (current == null) return;
    await HapticFeedback.lightImpact();

    state = AsyncData(
      ForYouFeedResponse(
        userTopTastes: current.userTopTastes,
        nextOffset: current.nextOffset,
        hasMore: current.hasMore,
        items: current.items.map((item) {
          if (item.thread.id != threadId) return item;
          final reposted = !item.thread.isRepostedByMe;
          return item.copyWith(
            thread: item.thread.copyWith(
              isRepostedByMe: reposted,
              repostsCount: (item.thread.repostsCount + (reposted ? 1 : -1))
                  .clamp(0, 1 << 30),
            ),
          );
        }).toList(),
      ),
    );

    try {
      await ref.read(socialProfileApiServiceProvider).toggleRepost(threadId);
      ref
          .read(exploreFeedApiProvider)
          .markSeenAndEngaged(engagedThreadIds: [threadId])
          .ignore();
    } catch (_) {
      await refresh();
    }
  }

  Future<void> onTryRecipeTapped({
    required BuildContext context,
    required InteractiveRecipeCardAttachment card,
    required String threadId,
  }) async {
    await HapticFeedback.mediumImpact();
    ref
        .read(socialProfileApiServiceProvider)
        .recordTryRecipe(threadId)
        .ignore();
    ref
        .read(exploreFeedApiProvider)
        .markSeenAndEngaged(engagedThreadIds: [threadId])
        .ignore();

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
                    'Tuang ${s.waterAddedMl.round()}ml selama ${s.durationSec} detik.',
              },
            )
            .toList();

    final payload = ApiService.sanitizeRecipe({
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

    if (!context.mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrewTimerScreen(recipeData: payload),
      ),
    );
  }
}

@riverpod
Future<TrendingFeedResponse> trendingFeed(Ref ref) {
  return ref.watch(exploreFeedApiProvider).getTrendingFeed();
}

@riverpod
Future<RecommendedClubsResponse> recommendedClubs(Ref ref) {
  return ref.watch(exploreFeedApiProvider).getRecommendedClubs();
}
