import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_client.dart';
import '../../../social_chat/presentation/controllers/chat_controllers.dart';
import '../../../social_profile_feed/presentation/controllers/social_profile_controllers.dart';
import '../../data/services/social_graph_api_service.dart';
import '../../domain/models/social_graph_models.dart';

part 'relationship_controller.g.dart';

@Riverpod(keepAlive: true)
SocialGraphApiService socialGraphApiService(Ref ref) {
  return SocialGraphApiService(ref.watch(dioClientProvider));
}

@Riverpod(keepAlive: true)
class RelationshipFeedbackBanner extends _$RelationshipFeedbackBanner {
  @override
  String? build() => null;

  void notify(String message) => state = message;
  void clear() => state = null;
}

@riverpod
class UserRelationshipController extends _$UserRelationshipController {
  Timer? _coalesceTimer;
  RelationshipSnapshot? _confirmedSnapshot;
  RelationshipState? _desiredState;
  bool _inFlight = false;

  static const Duration coalesceDuration = Duration(milliseconds: 350);

  @override
  Future<RelationshipSnapshot> build(String targetUserOrUsername) async {
    ref.onDispose(() {
      _coalesceTimer?.cancel();
      _coalesceTimer = null;
    });
    final snap = await ref
        .watch(socialGraphApiServiceProvider)
        .getRelationshipSnapshot(targetUserOrUsername);
    _confirmedSnapshot = snap;
    return snap;
  }

  Future<void> refresh() async {
    _coalesceTimer?.cancel();
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final snap = await ref
          .read(socialGraphApiServiceProvider)
          .getRelationshipSnapshot(targetUserOrUsername);
      _confirmedSnapshot = snap;
      return snap;
    });
  }

  Future<void> toggleFollow({Duration? debounceOverride}) async {
    if (!ref.mounted) return;
    final current = state.value;
    if (current == null || current.state == RelationshipState.selfProfile) {
      return;
    }

    _confirmedSnapshot ??= current;
    try {
      unawaited(HapticFeedback.selectionClick().catchError((_) {}));
    } catch (_) {}

    final nextState = current.state.nextOptimisticState(
      isTargetPrivate: current.targetIsPrivate,
      isFollowedByTarget: current.isFollowedByTarget,
    );

    final wasAcceptedFollower =
        current.state == RelationshipState.following ||
        current.state == RelationshipState.mutual;
    final willBeAcceptedFollower =
        nextState == RelationshipState.following ||
        nextState == RelationshipState.mutual;

    var nextFollowers = current.followersCount;
    if (!wasAcceptedFollower && willBeAcceptedFollower) {
      nextFollowers += 1;
    } else if (wasAcceptedFollower && !willBeAcceptedFollower) {
      nextFollowers = math.max(0, nextFollowers - 1);
    }

    _desiredState = nextState;
    state = AsyncData(
      current.copyWith(
        state: nextState,
        isMutual: nextState == RelationshipState.mutual,
        followersCount: nextFollowers,
      ),
    );

    _coalesceTimer?.cancel();
    final wait = debounceOverride ?? coalesceDuration;
    if (wait <= Duration.zero) {
      await _flushNetworkSync();
      return;
    }
    _coalesceTimer = Timer(wait, () {
      unawaited(_flushNetworkSync());
    });
  }

  Future<void> _flushNetworkSync() async {
    if (!ref.mounted) return;
    final confirmed = _confirmedSnapshot;
    final desired = _desiredState;
    if (confirmed == null || desired == null || _inFlight) return;

    // 350ms Coalescing Guard: net state reverted back to last confirmed state -> 0 HTTP requests
    if (desired.isOutgoingDesired == confirmed.state.isOutgoingDesired) {
      state = AsyncData(confirmed);
      return;
    }

    _inFlight = true;
    final api = ref.read(socialGraphApiServiceProvider);
    try {
      final result = desired.isOutgoingDesired
          ? await api.followUser(targetUserOrUsername)
          : await api.unfollowUser(targetUserOrUsername);

      if (!ref.mounted) return;
      final latest = state.value ?? confirmed;
      final reconciled = latest.copyWith(
        targetUserId: result.targetUserId,
        state: result.state,
        isMutual: result.state == RelationshipState.mutual,
        followersCount: result.targetFollowersCount,
        followingCount: result.targetFollowingCount,
        mutualFollowersCount: result.mutualFollowersCount,
      );
      _confirmedSnapshot = reconciled;

      // Keep UI consistent if user clicked again while previous request was in-flight
      final stillPendingDesired = _desiredState;
      if (stillPendingDesired != null &&
          stillPendingDesired.isOutgoingDesired !=
              reconciled.state.isOutgoingDesired) {
        _inFlight = false;
        await _flushNetworkSync();
        return;
      }

      state = AsyncData(reconciled);
      ref.invalidate(publicProfileControllerProvider(targetUserOrUsername));
    } on DioException catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(confirmed);
      final data = e.response?.data;
      final msg = data is Map && data['error'] != null
          ? data['error'].toString()
          : 'Gagal memperbarui status follow. Perubahan dikembalikan.';
      ref.read(relationshipFeedbackBannerProvider.notifier).notify(msg);
    } catch (_) {
      if (!ref.mounted) return;
      state = AsyncData(confirmed);
      ref
          .read(relationshipFeedbackBannerProvider.notifier)
          .notify('Koneksi terganggu. Status follow dikembalikan.');
    } finally {
      _inFlight = false;
    }
  }
}

@riverpod
class MyPrivacySettingController extends _$MyPrivacySettingController {
  @override
  Future<PrivacySettingSnapshot> build() {
    return ref.watch(socialGraphApiServiceProvider).getPrivacySetting();
  }

  Future<bool> setPrivateAccount(bool isPrivate) async {
    final prev = state.value;
    if (prev != null) {
      state = AsyncData(prev.copyWith(isPrivateAccount: isPrivate));
    }
    try {
      final updated = await ref
          .read(socialGraphApiServiceProvider)
          .updatePrivacySetting(isPrivate);
      state = AsyncData(updated);
      return true;
    } catch (_) {
      if (prev != null) state = AsyncData(prev);
      ref
          .read(relationshipFeedbackBannerProvider.notifier)
          .notify('Gagal mengubah pengaturan privasi akun.');
      return false;
    }
  }

  void adjustPendingCount(int delta) {
    final prev = state.value;
    if (prev == null) return;
    state = AsyncData(
      prev.copyWith(
        pendingFollowRequestsCount:
            math.max(0, prev.pendingFollowRequestsCount + delta),
      ),
    );
  }
}

class GraphConnectionsPageState {
  final List<SocialGraphUserItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoadingNext;

  const GraphConnectionsPageState({
    required this.items,
    required this.nextCursor,
    required this.hasMore,
    this.isLoadingNext = false,
  });

  GraphConnectionsPageState copyWith({
    List<SocialGraphUserItem>? items,
    String? nextCursor,
    bool? hasMore,
    bool? isLoadingNext,
  }) {
    return GraphConnectionsPageState(
      items: items ?? this.items,
      nextCursor: nextCursor ?? this.nextCursor,
      hasMore: hasMore ?? this.hasMore,
      isLoadingNext: isLoadingNext ?? this.isLoadingNext,
    );
  }
}

@riverpod
class SocialConnectionsTabController extends _$SocialConnectionsTabController {
  bool _fetchingNext = false;

  @override
  Future<GraphConnectionsPageState> build(
    String targetUserOrUsername,
    String kind,
  ) async {
    final res = await ref
        .watch(socialGraphApiServiceProvider)
        .listConnections(
          targetUserOrUsername: targetUserOrUsername,
          kind: kind,
        );
    return GraphConnectionsPageState(
      items: res.items,
      nextCursor: res.nextCursor,
      hasMore: res.hasMore,
    );
  }

  Future<void> fetchNextPage() async {
    final cur = state.value;
    if (cur == null || !cur.hasMore || _fetchingNext || cur.nextCursor == null) {
      return;
    }
    _fetchingNext = true;
    state = AsyncData(cur.copyWith(isLoadingNext: true));
    try {
      final res = await ref
          .read(socialGraphApiServiceProvider)
          .listConnections(
            targetUserOrUsername: targetUserOrUsername,
            kind: kind,
            cursor: cur.nextCursor,
          );
      state = AsyncData(
        GraphConnectionsPageState(
          items: [...cur.items, ...res.items],
          nextCursor: res.nextCursor,
          hasMore: res.hasMore,
        ),
      );
    } catch (_) {
      state = AsyncData(cur.copyWith(isLoadingNext: false));
    } finally {
      _fetchingNext = false;
    }
  }

  Future<void> toggleRowFollow(SocialGraphUserItem user) async {
    final cur = state.value;
    if (cur == null) return;
    final wasOut = user.relationshipState.isOutgoingDesired;
    final opt = user.relationshipState.nextOptimisticState(
      isTargetPrivate: user.isPrivateAccount,
      isFollowedByTarget:
          user.relationshipState == RelationshipState.followedByTarget ||
          user.relationshipState == RelationshipState.mutual,
    );
    state = AsyncData(
      cur.copyWith(
        items: cur.items
            .map(
              (u) => u.userId == user.userId
                  ? u.copyWith(relationshipState: opt)
                  : u,
            )
            .toList(),
      ),
    );
    try {
      final api = ref.read(socialGraphApiServiceProvider);
      final res = wasOut
          ? await api.unfollowUser(user.userId)
          : await api.followUser(user.userId);
      final latest = state.value;
      if (latest != null) {
        state = AsyncData(
          latest.copyWith(
            items: latest.items
                .map(
                  (u) => u.userId == user.userId
                      ? u.copyWith(relationshipState: res.state)
                      : u,
                )
                .toList(),
          ),
        );
      }
    } catch (_) {
      state = AsyncData(cur);
    }
  }

  Future<void> removeFollower(String followerId) async {
    final cur = state.value;
    if (cur == null) return;
    state = AsyncData(
      cur.copyWith(
        items: cur.items.where((u) => u.userId != followerId).toList(),
      ),
    );
    try {
      await ref.read(socialGraphApiServiceProvider).removeFollower(followerId);
      ref.invalidate(publicProfileControllerProvider(targetUserOrUsername));
    } catch (_) {
      state = AsyncData(cur);
    }
  }
}

@riverpod
class PendingFollowRequestsController
    extends _$PendingFollowRequestsController {
  @override
  Future<List<FollowRequestItem>> build() async {
    final res = await ref
        .watch(socialGraphApiServiceProvider)
        .listPendingRequests(limit: 50);
    return res.items;
  }

  Future<void> handleRequest({
    required String requesterId,
    required bool accept,
  }) async {
    final prev = state.value;
    if (prev == null) return;
    state = AsyncData(
      prev.where((r) => r.requesterId != requesterId).toList(),
    );
    try {
      await ref
          .read(socialGraphApiServiceProvider)
          .handleFollowRequest(requesterId: requesterId, accept: accept);
      ref.read(myPrivacySettingControllerProvider.notifier).adjustPendingCount(-1);
    } catch (_) {
      state = AsyncData(prev);
      ref
          .read(relationshipFeedbackBannerProvider.notifier)
          .notify('Gagal memproses permintaan mengikuti.');
    }
  }
}

final socialGraphRealtimeEventsProvider =
    StreamProvider<SocialGraphRealtimeEvent>((ref) {
  return ref.watch(chatWsServiceProvider).socialGraphEvents.map(
        (g) => SocialGraphRealtimeEvent(
          actorId: g.actorId,
          actorUsername: g.actorUsername,
          actorDisplayName: g.actorDisplayName,
          actorAvatarUrl: g.actorAvatarUrl,
          state: RelationshipStateX.fromWire(g.state),
          action: g.action,
          message: g.message,
          createdAt: g.createdAt,
        ),
      );
});
