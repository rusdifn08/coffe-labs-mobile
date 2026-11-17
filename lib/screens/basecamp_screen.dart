import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/explore_feed/presentation/screens/social_explore_and_feed_screen.dart';

/// Penyatuan Basecamp Komunitas & Club Kopi ke dalam Coffee Club (Modul 3.5).
class BasecampScreen extends StatelessWidget {
  const BasecampScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var hasScope = true;
    try {
      ProviderScope.containerOf(context, listen: false);
    } catch (_) {
      hasScope = false;
    }

    const unifiedClubView = SocialExploreAndFeedScreen(initialTabIndex: 0);
    if (hasScope) {
      return unifiedClubView;
    }
    return const ProviderScope(child: unifiedClubView);
  }
}
