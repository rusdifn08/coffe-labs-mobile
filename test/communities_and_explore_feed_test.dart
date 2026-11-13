import 'package:coffee_hub_mobile/features/communities/domain/community_models.dart';
import 'package:coffee_hub_mobile/features/communities/presentation/utils/crockford_input_formatter.dart';
import 'package:coffee_hub_mobile/features/communities/presentation/widgets/join_club_by_secret_id_sheet.dart';
import 'package:coffee_hub_mobile/features/explore_feed/domain/explore_feed_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CrockfordSecretIdInputFormatter', () {
    test('normalizes typos O->0, I/L->1 and formats CLB-XXXX-XXXXXX', () {
      final formatter = CrockfordSecretIdInputFormatter();
      final res = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: 'clb-4fok-il2p4w999'),
      );
      expect(res.text, 'CLB-4F0K-112P4W');
      expect(
        CrockfordSecretIdInputFormatter.normalizeCore('o-i-l 1234567'),
        '0111234567',
      );
    });
  });

  group('Module 3.5 JSON Wire Contracts', () {
    test('parses CommunityWorkspace and JoinClubResponse', () {
      final ws = CommunityWorkspace.fromJson({
        'community': {
          'id': 'club-1',
          'handle_slug': 'v60-lab',
          'name': 'V60 Lab',
          'description': 'Eksperimen pour over',
          'privacy_level': 'SECRET_VAULT',
          'owner_id': 'user-1',
          'focus_tags': ['V60', 'Ethiopia'],
          'members_count': 42,
          'threads_count': 12,
          'shared_recipes_count': 8,
          'total_club_xp': 450,
          'viewer_role': 'OWNER',
          'is_member': true,
          'created_at': '2026-11-13T10:00:00Z',
        },
        'channels': [
          {
            'id': 'ch-1',
            'community_id': 'club-1',
            'name': '#general-lounge',
            'kind': 'REALTIME_CHAT',
            'linked_conversation_id': 'conv-1',
            'display_order': 1,
            'is_readonly_announcement': false,
          },
        ],
        'my_role': 'OWNER',
        'is_member': true,
        'can_post': true,
        'can_manage_invites': true,
        'active_secret_code_preview': 'CLB-4F9K-2X8P4W',
      });

      expect(ws.community.privacyLevel, 'SECRET_VAULT');
      expect(ws.channels.first.linkedConversationId, 'conv-1');
      expect(ws.canManageInvites, isTrue);
    });

    test('parses flattened RecommendedThreadItem inside ForYouFeedResponse', () {
      final res = ForYouFeedResponse.fromJson({
        'user_top_tastes': ['Citrus & Bergamot', 'V60 & Pour-Over'],
        'next_offset': 20,
        'has_more': true,
        'items': [
          {
            'id': 'thr-1',
            'author_id': 'auth-1',
            'author_username': 'barista_koko',
            'author_display_name': 'Barista Koko',
            'body_text': 'V60 Ethiopia Washed mantap!',
            'created_at': '2026-11-13T11:00:00Z',
            'relevance_score': 0.89,
            'taste_match_pct': 92,
            'reason_badge': 'Cocok 92% • Selera Kopimu',
            'is_trending': true,
            'community_id': 'club-1',
            'community_name': 'V60 Lab',
          },
        ],
      });

      expect(res.hasMore, isTrue);
      expect(res.userTopTastes, contains('V60 & Pour-Over'));
      expect(res.items.single.thread.authorUsername, 'barista_koko');
      expect(res.items.single.tasteMatchPct, 92);
      expect(res.items.single.communityName, 'V60 Lab');
    });
  });

  testWidgets('JoinClubBySecretIdSheet validates incomplete Secret ID',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: JoinClubBySecretIdSheet()),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'ab12');
    await tester.tap(find.text('Gabung Club Sekarang'));
    await tester.pump();

    expect(find.text('CLB-AB12'), findsOneWidget);
    expect(
      find.text('Masukkan 10 karakter lengkap kode Secret ID.'),
      findsOneWidget,
    );
  });
}
