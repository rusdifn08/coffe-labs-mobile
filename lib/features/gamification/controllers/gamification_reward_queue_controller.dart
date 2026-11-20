import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gamification_reward_delta.dart';

class GamificationRewardQueueNotifier
    extends Notifier<List<GamificationRewardDelta>> {
  @override
  List<GamificationRewardDelta> build() => const [];

  void enqueue(GamificationRewardDelta delta) {
    if (delta.xpGained <= 0) return;
    state = [...state, delta];
  }

  void popFront() {
    if (state.isEmpty) return;
    state = state.sublist(1);
  }
}

final gamificationRewardQueueProvider = NotifierProvider<
    GamificationRewardQueueNotifier, List<GamificationRewardDelta>>(
  GamificationRewardQueueNotifier.new,
);
