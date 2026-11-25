import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:coffee_hub_mobile/core/storage/user_scoped_storage.dart';
import 'package:coffee_hub_mobile/features/game_brew/data/game_brew_progress_service.dart';
import 'package:coffee_hub_mobile/features/gamification/services/gamification_service.dart';
import 'package:coffee_hub_mobile/services/auth_service.dart';
import 'package:coffee_hub_mobile/services/user_cloud_sync_service.dart';

void main() {
  const userRisa = AuthUser(
    id: 'user-risa-15',
    username: 'risaha15',
    fullName: 'Risa Hanipah',
    role: 'user',
    status: 'approved',
    tier: 'pro',
    avatarUrl: 'assets/images/characters/avatar_2.png',
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    UserScopedStorage.resetForTesting();
    GameBrewProgressService.resetMemoryCache();
  });

  test('HP 1 (Lv.1 150 EXP) converges identically with HP 2 cloud state (Lv.2 215 EXP)', () async {
    UserScopedStorage.setActiveUserId(userRisa.id);
    await GamificationService.instance.applyCloudSnapshot(
      userId: userRisa.id,
      totalExp: 150,
      brewsCount: 0,
      toolkitCount: 5,
      cuppingCount: 0,
      streakDays: 2,
      lastActivityDate: '2026-11-24',
    );

    final localAhead = await UserCloudSyncService.applyCloudStatePayload(
      user: userRisa,
      isAuthoritativePutResponse: false,
      data: {
        'has_cloud_record': true,
        'state_version': 4,
        'total_exp': 215,
        'brews_count': 0,
        'toolkit_count': 7,
        'cupping_count': 0,
        'streak_days': 3,
        'last_activity_date': '2026-11-25',
        'full_name': 'Risa Hanipah',
        'avatar_url': 'assets/images/characters/avatar_2.png',
        'brew_history': const [],
        'brew_journal': const [],
        'favorite_recipe_ids': const [1, 5],
        'custom_recipes': const [],
        'deleted_default_ids': const [],
        'game_brew_progress': {
          'MB-01': {
            'code': 'MB-01',
            'stars': 3,
            'bestScorePct': 94.5,
            'bestMetrics': {'flow': 96.0},
            'attempts': 2,
            'updatedAt': '2026-11-25T05:00:00Z',
          },
        },
      },
    );

    expect(localAhead, isFalse);

    final stats = await GamificationService.instance.getStats(userId: userRisa.id);
    expect(stats.totalExp, 215);
    expect(stats.level.level, 2);
    expect(stats.level.title, 'Aroma Explorer');
    expect(stats.toolkitCount, 7);
    expect(stats.streakDays, 3);

    final gameMap = await GameBrewProgressService.load(userId: userRisa.id);
    expect(gameMap['MB-01']?.stars, 3);
    expect(gameMap['MB-01']?.bestScorePct, 94.5);
  });

  test('detects localAhead when local streak or Game Brew stars exceed cloud', () async {
    UserScopedStorage.setActiveUserId(userRisa.id);
    await GamificationService.instance.applyCloudSnapshot(
      userId: userRisa.id,
      totalExp: 215,
      brewsCount: 0,
      toolkitCount: 7,
      cuppingCount: 0,
      streakDays: 4,
      lastActivityDate: '2026-11-25',
    );
    await GameBrewProgressService.recordRun(
      levelCode: 'LA-01',
      stars: 2,
      scorePct: 85.0,
      metrics: const {'symmetry': 86.0},
    );

    final localAhead = await UserCloudSyncService.applyCloudStatePayload(
      user: userRisa,
      isAuthoritativePutResponse: false,
      data: {
        'has_cloud_record': true,
        'state_version': 2,
        'total_exp': 215,
        'brews_count': 0,
        'toolkit_count': 7,
        'cupping_count': 0,
        'streak_days': 3,
        'last_activity_date': '2026-11-24',
        'game_brew_progress': const <String, dynamic>{},
      },
    );

    expect(localAhead, isTrue);
    final stats = await GamificationService.instance.getStats(userId: userRisa.id);
    expect(stats.streakDays, 4);
  });

  test('GameBrewProgressService isolates accounts on the same phone', () async {
    final prefs = await SharedPreferences.getInstance();
    await AuthService.persistSessionMirrors(
      prefs,
      user: const AuthUser(
        id: 'user-alpha',
        username: 'alpha',
        fullName: 'Alpha Barista',
        role: 'user',
        status: 'approved',
        avatarUrl: 'assets/images/characters/avatar_1.png',
      ),
    );
    UserScopedStorage.setActiveUserId('user-alpha');
    await GameBrewProgressService.recordRun(
      levelCode: 'MB-01',
      stars: 3,
      scorePct: 97.0,
      metrics: const {'uniformity': 98.0},
    );

    GameBrewProgressService.notifySessionSwitched();
    await AuthService.persistSessionMirrors(
      prefs,
      user: const AuthUser(
        id: 'user-beta',
        username: 'beta',
        fullName: 'Beta Barista',
        role: 'user',
        status: 'approved',
        avatarUrl: 'assets/images/characters/avatar_2.png',
      ),
    );
    UserScopedStorage.setActiveUserId('user-beta');
    final betaProgress = await GameBrewProgressService.load();
    expect(betaProgress, isEmpty);

    GameBrewProgressService.notifySessionSwitched();
    UserScopedStorage.setActiveUserId('user-alpha');
    final alphaProgress = await GameBrewProgressService.load(userId: 'user-alpha');
    expect(alphaProgress['MB-01']?.stars, 3);
  });
}
