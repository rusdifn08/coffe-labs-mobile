import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../data/roastery_catalog.dart';
import '../../../../models/roastery.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/subscription_service.dart';
import '../data/services/roastery_api_service.dart';
import '../data/services/roastery_media_uploader.dart';

class RoasteryCatalogState {
  final bool isLoading;
  final bool isMutating;
  final bool isBusinessUser;
  final String? currentUserId;
  final List<Roastery> businessRoasteries;
  final Roastery? myRoastery;
  final String? errorMessage;

  const RoasteryCatalogState({
    this.isLoading = false,
    this.isMutating = false,
    this.isBusinessUser = false,
    this.currentUserId,
    this.businessRoasteries = const [],
    this.myRoastery,
    this.errorMessage,
  });

  List<Roastery> get allMergedRoasteries {
    final seenIds = <String>{};
    final merged = <Roastery>[];

    // 1. Jika user Business punya roastery, tampilkan versi terbaru miliknya lebih dulu
    if (myRoastery != null && myRoastery!.id.isNotEmpty) {
      seenIds.add(myRoastery!.id);
      merged.add(myRoastery!);
    }

    // 2. Roastery Business publik dari NeonDB
    for (final r in businessRoasteries) {
      if (r.id.isNotEmpty && !seenIds.contains(r.id)) {
        seenIds.add(r.id);
        merged.add(r);
      }
    }

    // 3. 127+ Roastery kurasi bawaan aplikasi
    for (final seed in RoasteryCatalog.list) {
      if (!seenIds.contains(seed.id)) {
        merged.add(seed);
      }
    }
    return merged;
  }

  bool isOwnedByCurrentUser(Roastery r) {
    if (currentUserId == null || currentUserId!.isEmpty) return false;
    return r.ownerUserId == currentUserId || (myRoastery != null && myRoastery!.id == r.id);
  }

  RoasteryCatalogState copyWith({
    bool? isLoading,
    bool? isMutating,
    bool? isBusinessUser,
    String? currentUserId,
    List<Roastery>? businessRoasteries,
    Roastery? myRoastery,
    bool clearMyRoastery = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RoasteryCatalogState(
      isLoading: isLoading ?? this.isLoading,
      isMutating: isMutating ?? this.isMutating,
      isBusinessUser: isBusinessUser ?? this.isBusinessUser,
      currentUserId: currentUserId ?? this.currentUserId,
      businessRoasteries: businessRoasteries ?? this.businessRoasteries,
      myRoastery: clearMyRoastery ? null : (myRoastery ?? this.myRoastery),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

final roasteryApiServiceProvider = Provider<RoasteryApiService>((ref) {
  return RoasteryApiService(ref.watch(dioClientProvider));
});

final roasteryMediaUploaderProvider = Provider<RoasteryMediaUploader>((ref) {
  return RoasteryMediaUploader(apiDio: ref.watch(dioClientProvider));
});

final roasteryCatalogProvider =
    NotifierProvider<RoasteryCatalogController, RoasteryCatalogState>(
  RoasteryCatalogController.new,
);

class RoasteryCatalogController extends Notifier<RoasteryCatalogState> {
  static const String businessClusterLabel = 'Roastery Bisnis';

  @override
  RoasteryCatalogState build() {
    Future.microtask(initialize);
    return const RoasteryCatalogState(isLoading: true);
  }

  RoasteryApiService get _api => ref.read(roasteryApiServiceProvider);

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await AuthService.getCurrentUser();
      final isBiz = user != null
          ? (user.isAdmin ||
              user.isBusiness ||
              user.username.toLowerCase() == 'bisnis123')
          : await SubscriptionService.isBusiness();

      final cachedPublic = await RoasteryApiService.loadCachedPublicRoasteries();
      final cachedMine =
          isBiz ? await RoasteryApiService.loadCachedMyRoastery() : null;

      state = state.copyWith(
        isBusinessUser: isBiz,
        currentUserId: user?.id,
        businessRoasteries: cachedPublic,
        myRoastery: cachedMine,
        clearMyRoastery: !isBiz,
      );

      final futures = <Future<void>>[
        _api.fetchPublicBusinessRoasteries().then((list) {
          state = state.copyWith(businessRoasteries: list);
        }),
        if (isBiz)
          _api.fetchMyRoastery().then((mine) {
            state = state.copyWith(
              myRoastery: mine,
              clearMyRoastery: mine == null,
            );
          }),
      ];
      await Future.wait(futures);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refreshCatalog() => initialize();

  Future<Roastery> fetchLatestDetail(Roastery current) async {
    if (!current.isVerifiedBusiness || current.ownerUserId == null) {
      return current;
    }
    try {
      final fresh = await _api.fetchRoasteryDetail(current.id);
      if (fresh != null) {
        final updatedList = state.businessRoasteries
            .map((e) => e.id == fresh.id ? fresh : e)
            .toList();
        state = state.copyWith(
          businessRoasteries: updatedList,
          myRoastery: state.myRoastery?.id == fresh.id ? fresh : state.myRoastery,
        );
        return fresh;
      }
    } catch (_) {}
    return current;
  }

  Future<Roastery> registerRoastery({
    required String name,
    required String city,
    required String address,
    required String description,
    required String specialties,
    required String cluster,
    required String salesHighlight,
    required String logoUrl,
    String? logoPublicId,
    String? bannerUrl,
    String? bannerPublicId,
    String? whatsappNumber,
    String? instagramHandle,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final created = await _api.createMyRoastery(
        name: name,
        city: city,
        address: address,
        description: description,
        specialties: specialties,
        cluster: cluster,
        salesHighlight: salesHighlight,
        logoUrl: logoUrl,
        logoPublicId: logoPublicId,
        bannerUrl: bannerUrl,
        bannerPublicId: bannerPublicId,
        whatsappNumber: whatsappNumber,
        instagramHandle: instagramHandle,
      );
      final updatedPublic = [
        created,
        ...state.businessRoasteries.where((r) => r.id != created.id),
      ];
      state = state.copyWith(
        myRoastery: created,
        businessRoasteries: updatedPublic,
      );
      return created;
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }

  Future<Roastery> updateMyRoastery(Map<String, dynamic> fields) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final updated = await _api.updateMyRoastery(fields);
      final updatedPublic = state.businessRoasteries.any((r) => r.id == updated.id)
          ? state.businessRoasteries
              .map((r) => r.id == updated.id ? updated : r)
              .toList()
          : [updated, ...state.businessRoasteries];
      state = state.copyWith(
        myRoastery: updated,
        businessRoasteries: updatedPublic,
      );
      return updated;
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }

  Future<CoffeeLineupItem> saveLineup({
    String? existingLineupId,
    required CoffeeLineupItem item,
  }) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      final saved = existingLineupId != null && existingLineupId.isNotEmpty
          ? await _api.updateLineup(existingLineupId, item)
          : await _api.addLineup(item);

      final mine = state.myRoastery;
      if (mine != null) {
        final nextLineups = existingLineupId != null
            ? mine.lineups.map((l) => l.id == existingLineupId ? saved : l).toList()
            : [saved, ...mine.lineups];
        final updatedMine = mine.copyWith(
          lineups: nextLineups,
          totalLineupsCount: nextLineups.length,
        );
        final updatedPublic = state.businessRoasteries
            .map((r) => r.id == updatedMine.id ? updatedMine : r)
            .toList();
        state = state.copyWith(
          myRoastery: updatedMine,
          businessRoasteries: updatedPublic,
        );
      }
      return saved;
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }

  Future<void> removeLineup(String lineupId) async {
    state = state.copyWith(isMutating: true, clearError: true);
    try {
      await _api.deleteLineup(lineupId);
      final mine = state.myRoastery;
      if (mine != null) {
        final nextLineups = mine.lineups.where((l) => l.id != lineupId).toList();
        final updatedMine = mine.copyWith(
          lineups: nextLineups,
          totalLineupsCount: nextLineups.length,
        );
        final updatedPublic = state.businessRoasteries
            .map((r) => r.id == updatedMine.id ? updatedMine : r)
            .toList();
        state = state.copyWith(
          myRoastery: updatedMine,
          businessRoasteries: updatedPublic,
        );
      }
    } finally {
      state = state.copyWith(isMutating: false);
    }
  }
}
