import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/auth_service.dart';
import '../../../social_chat/domain/chat_protocol.dart';
import '../../../social_chat/presentation/controllers/chat_controllers.dart';
import '../../data/services/device_token_lifecycle_service.dart';
import '../../data/services/notification_api_service.dart';
import '../../domain/models/notification_models.dart';

class UnreadNotificationsCountNotifier extends Notifier<int> {
  StreamSubscription<ServerPushNotificationEventFrame>? _wsSub;

  @override
  int build() {
    final ws = ref.watch(chatWsServiceProvider);
    _wsSub?.cancel();
    _wsSub = ws.pushNotificationEvents.listen((evt) {
      if (evt.unreadCount >= 0) {
        state = evt.unreadCount;
      } else {
        state = state + 1;
      }
    });
    ref.onDispose(() {
      _wsSub?.cancel();
      _wsSub = null;
    });
    unawaited(refresh());
    return 0;
  }

  Future<void> refresh() async {
    final loggedIn = await AuthService.isLoggedIn();
    if (!ref.mounted) return;
    if (!loggedIn) {
      state = 0;
      return;
    }
    try {
      final count =
          await ref.read(notificationApiServiceProvider).getUnreadCount();
      if (!ref.mounted) return;
      state = count;
    } catch (_) {}
  }

  void setCount(int count) {
    state = count < 0 ? 0 : count;
  }

  void decrement() {
    if (state > 0) {
      state = state - 1;
    }
  }
}

final unreadNotificationsCountProvider =
    NotifierProvider<UnreadNotificationsCountNotifier, int>(
  () => UnreadNotificationsCountNotifier(),
);

class NotificationCenterState {
  final OmnichannelNotificationCategory selectedCategory;
  final List<NotificationInboxItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final int unreadCount;
  final Set<String> follbackInFlightIds;
  final Set<String> followedBackActorIds;
  final String? errorMessage;

  const NotificationCenterState({
    this.selectedCategory = OmnichannelNotificationCategory.all,
    this.items = const <NotificationInboxItem>[],
    this.nextCursor,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.unreadCount = 0,
    this.follbackInFlightIds = const <String>{},
    this.followedBackActorIds = const <String>{},
    this.errorMessage,
  });

  NotificationCenterState copyWith({
    OmnichannelNotificationCategory? selectedCategory,
    List<NotificationInboxItem>? items,
    String? nextCursor,
    bool clearNextCursor = false,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    int? unreadCount,
    Set<String>? follbackInFlightIds,
    Set<String>? followedBackActorIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return NotificationCenterState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      items: items ?? this.items,
      nextCursor: clearNextCursor ? null : (nextCursor ?? this.nextCursor),
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      unreadCount: unreadCount ?? this.unreadCount,
      follbackInFlightIds: follbackInFlightIds ?? this.follbackInFlightIds,
      followedBackActorIds: followedBackActorIds ?? this.followedBackActorIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class NotificationCenterController extends Notifier<NotificationCenterState> {
  StreamSubscription<ServerPushNotificationEventFrame>? _wsSub;
  bool _initialLoadTriggered = false;

  NotificationApiService get _api => ref.read(notificationApiServiceProvider);

  @override
  NotificationCenterState build() {
    _initialLoadTriggered = false;
    final ws = ref.watch(chatWsServiceProvider);
    _wsSub?.cancel();
    _wsSub = ws.pushNotificationEvents.listen((_) {
      unawaited(refresh(silent: true));
    });
    ref.onDispose(() {
      _wsSub?.cancel();
      _wsSub = null;
    });
    Future.microtask(() {
      if (ref.mounted && !_initialLoadTriggered) {
        unawaited(refresh());
      }
    });
    return const NotificationCenterState(isLoading: true);
  }

  Future<void> selectCategory(
    OmnichannelNotificationCategory category,
  ) async {
    if (state.selectedCategory == category && state.items.isNotEmpty) return;
    state = state.copyWith(
      selectedCategory: category,
      isLoading: true,
      clearNextCursor: true,
      clearError: true,
    );
    await refresh();
  }

  Future<void> refresh({bool silent = false}) async {
    _initialLoadTriggered = true;
    if (!silent) {
      state = state.copyWith(isLoading: true, clearError: true);
    }
    try {
      final page = await _api.getInbox(
        category: state.selectedCategory.apiFilterValue,
      );
      if (!ref.mounted) return;
      state = state.copyWith(
        items: page.items,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        unreadCount: page.unreadCount,
        isLoading: false,
        isLoadingMore: false,
        clearError: true,
      );
      ref
          .read(unreadNotificationsCountProvider.notifier)
          .setCount(page.unreadCount);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: 'Gagal memuat notifikasi: $e',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore ||
        !state.hasMore ||
        state.nextCursor == null ||
        state.nextCursor!.isEmpty) {
      return;
    }
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _api.getInbox(
        category: state.selectedCategory.apiFilterValue,
        cursor: state.nextCursor,
      );
      if (!ref.mounted) return;
      final existingIds = state.items.map((e) => e.id).toSet();
      final appended = <NotificationInboxItem>[
        ...state.items,
        ...page.items.where((e) => !existingIds.contains(e.id)),
      ];
      state = state.copyWith(
        items: appended,
        nextCursor: page.nextCursor,
        hasMore: page.hasMore,
        unreadCount: page.unreadCount,
        isLoadingMore: false,
      );
      ref
          .read(unreadNotificationsCountProvider.notifier)
          .setCount(page.unreadCount);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        errorMessage: 'Gagal memuat halaman berikutnya: $e',
      );
    }
  }

  /// Optimistic mark-as-read with rollback if the server call fails.
  Future<void> markAsRead(String notificationId) async {
    final prevItems = state.items;
    final prevUnread = state.unreadCount;
    final idx = prevItems.indexWhere((e) => e.id == notificationId);
    if (idx == -1 || prevItems[idx].isRead) return;

    final updated = List<NotificationInboxItem>.from(prevItems);
    updated[idx] = prevItems[idx].copyWith(
      isRead: true,
      readAt: DateTime.now().toUtc(),
    );
    final optimisticUnread = prevUnread > 0 ? prevUnread - 1 : 0;

    state = state.copyWith(items: updated, unreadCount: optimisticUnread);
    ref
        .read(unreadNotificationsCountProvider.notifier)
        .setCount(optimisticUnread);

    try {
      final serverUnread = await _api.markAsRead(notificationId);
      if (!ref.mounted) return;
      state = state.copyWith(unreadCount: serverUnread);
      ref
          .read(unreadNotificationsCountProvider.notifier)
          .setCount(serverUnread);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        items: prevItems,
        unreadCount: prevUnread,
        errorMessage: 'Gagal menandai notifikasi dibaca: $e',
      );
      ref.read(unreadNotificationsCountProvider.notifier).setCount(prevUnread);
    }
  }

  /// Optimistic mark-all-as-read with rollback on network error.
  Future<void> markAllAsRead() async {
    final prevItems = state.items;
    final prevUnread = state.unreadCount;
    final now = DateTime.now().toUtc();
    final updated = prevItems
        .map((e) => e.isRead ? e : e.copyWith(isRead: true, readAt: now))
        .toList();

    state = state.copyWith(items: updated, unreadCount: 0);
    ref.read(unreadNotificationsCountProvider.notifier).setCount(0);

    try {
      final serverUnread = await _api.markAllAsRead();
      if (!ref.mounted) return;
      state = state.copyWith(unreadCount: serverUnread);
      ref
          .read(unreadNotificationsCountProvider.notifier)
          .setCount(serverUnread);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        items: prevItems,
        unreadCount: prevUnread,
        errorMessage: 'Gagal menandai semua dibaca: $e',
      );
      ref.read(unreadNotificationsCountProvider.notifier).setCount(prevUnread);
    }
  }

  Future<void> quickFollback(NotificationInboxItem item) async {
    final actorId = item.actorId?.trim();
    if (actorId == null || actorId.isEmpty) return;

    final nextInFlight = Set<String>.from(state.follbackInFlightIds)
      ..add(item.id);
    state = state.copyWith(follbackInFlightIds: nextInFlight, clearError: true);

    try {
      await _api.quickFollback(actorId);
      if (!ref.mounted) return;
      final doneActors = Set<String>.from(state.followedBackActorIds)
        ..add(actorId);
      final doneInFlight = Set<String>.from(state.follbackInFlightIds)
        ..remove(item.id);
      state = state.copyWith(
        follbackInFlightIds: doneInFlight,
        followedBackActorIds: doneActors,
      );
      await markAsRead(item.id);
    } catch (e) {
      if (!ref.mounted) return;
      final doneInFlight = Set<String>.from(state.follbackInFlightIds)
        ..remove(item.id);
      state = state.copyWith(
        follbackInFlightIds: doneInFlight,
        errorMessage: 'Follback gagal diproses: $e',
      );
    }
  }
}

final notificationCenterControllerProvider =
    NotifierProvider<NotificationCenterController, NotificationCenterState>(
  () => NotificationCenterController(),
);

class NotificationPreferencesController
    extends Notifier<AsyncValue<NotificationPreferences>> {
  NotificationApiService get _api => ref.read(notificationApiServiceProvider);

  @override
  AsyncValue<NotificationPreferences> build() {
    Future.microtask(load);
    return const AsyncValue.loading();
  }

  Future<void> load() async {
    try {
      final prefs = await _api.getPreferences();
      if (!ref.mounted) return;
      state = AsyncValue.data(prefs);
    } catch (e, st) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(NotificationPreferences updated) async {
    final previous = state;
    state = AsyncValue.data(updated);
    try {
      final saved = await _api.updatePreferences(updated);
      if (!ref.mounted) return;
      state = AsyncValue.data(saved);
    } catch (e) {
      if (ref.mounted) {
        state = previous;
      }
      rethrow;
    }
  }
}

final notificationPreferencesControllerProvider = NotifierProvider<
    NotificationPreferencesController,
    AsyncValue<NotificationPreferences>>(
  () => NotificationPreferencesController(),
);
