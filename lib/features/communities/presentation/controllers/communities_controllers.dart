import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../social_profile_feed/domain/models/social_thread_models.dart';
import '../../data/communities_api_service.dart';
import '../../data/communities_local_cache.dart';
import '../../domain/community_models.dart';

part 'communities_controllers.g.dart';

@Riverpod(keepAlive: true)
CommunitiesApiService communitiesApi(Ref ref) {
  return CommunitiesApiService(ref.watch(dioClientProvider));
}

@Riverpod(keepAlive: true)
CommunitiesLocalDatabase communitiesLocalDb(Ref ref) {
  final db = CommunitiesLocalDatabase();
  ref.onDispose(db.close);
  return db;
}

@riverpod
class ExploreCommunitiesController extends _$ExploreCommunitiesController {
  @override
  Future<DiscoverCommunitiesResponse> build({String? query}) async {
    final api = ref.watch(communitiesApiProvider);
    final localDb = ref.watch(communitiesLocalDbProvider);
    try {
      final res = await api.discoverCommunities(query: query);
      if (query == null || query.trim().isEmpty) {
        await localDb.cacheMyClubs(res.myClubs);
      }
      return res;
    } catch (_) {
      final cached = await localDb.loadCachedMyClubs();
      if (cached.isNotEmpty) {
        return DiscoverCommunitiesResponse(
          myClubs: cached,
          discoverClubs: const [],
          hasMore: false,
        );
      }
      rethrow;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

@riverpod
class CommunityWorkspaceController extends _$CommunityWorkspaceController {
  @override
  Future<CommunityWorkspace> build(String communityId) {
    return ref.watch(communitiesApiProvider).getWorkspace(communityId);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(communitiesApiProvider).getWorkspace(communityId),
    );
  }

  Future<JoinClubResponse> joinPublic() async {
    final res = await ref
        .read(communitiesApiProvider)
        .joinPublicClub(communityId);
    ref.invalidate(exploreCommunitiesControllerProvider);
    await refresh();
    return res;
  }

  Future<SocialThreadItem> createPost({
    required String bodyText,
    String kind = 'STANDARD_POST',
    ThreadAttachment? attachment,
  }) async {
    final created = await ref.read(communitiesApiProvider).createClubPost(
          communityId: communityId,
          bodyText: bodyText,
          kind: kind,
          attachment: attachment,
        );
    ref.invalidate(clubFeedItemsProvider(communityId));
    ref.invalidate(clubRecipeVaultItemsProvider(communityId));
    ref.invalidate(clubLeaderboardItemsProvider(communityId));
    return created;
  }
}

@riverpod
Future<List<SocialThreadItem>> clubFeedItems(
  Ref ref,
  String communityId,
) {
  return ref.watch(communitiesApiProvider).getClubFeed(communityId);
}

@riverpod
Future<List<SocialThreadItem>> clubRecipeVaultItems(
  Ref ref,
  String communityId,
) {
  return ref.watch(communitiesApiProvider).getClubRecipeVault(communityId);
}

@riverpod
Future<List<CommunityLeaderboardEntry>> clubLeaderboardItems(
  Ref ref,
  String communityId,
) {
  return ref.watch(communitiesApiProvider).getLeaderboard(communityId);
}

@riverpod
Future<List<CommunityInviteSecret>> clubInvitesList(
  Ref ref,
  String communityId,
) {
  return ref.watch(communitiesApiProvider).listInvites(communityId);
}

@riverpod
class SecretIdJoinController extends _$SecretIdJoinController {
  @override
  FutureOr<JoinClubResponse?> build() => null;

  Future<JoinClubResponse> joinBySecret(String secretCode) async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(
      () => ref.read(communitiesApiProvider).joinBySecretCode(secretCode),
    );
    state = res;
    if (res.hasError) {
      throw res.error!;
    }
    ref.invalidate(exploreCommunitiesControllerProvider);
    return res.requireValue;
  }

  Future<JoinClubResponse> joinByToken(String token) async {
    state = const AsyncLoading();
    final res = await AsyncValue.guard(
      () => ref.read(communitiesApiProvider).joinByInviteToken(token),
    );
    state = res;
    if (res.hasError) {
      throw res.error!;
    }
    ref.invalidate(exploreCommunitiesControllerProvider);
    return res.requireValue;
  }
}
