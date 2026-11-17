import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/community_models.dart';
import '../controllers/communities_controllers.dart';

class PendingClubInvitationsSection extends ConsumerStatefulWidget {
  const PendingClubInvitationsSection({super.key});

  @override
  ConsumerState<PendingClubInvitationsSection> createState() =>
      _PendingClubInvitationsSectionState();
}

class _PendingClubInvitationsSectionState
    extends ConsumerState<PendingClubInvitationsSection> {
  final Set<String> _inFlightInviteIds = {};

  Future<void> _respond(ClubMemberInvitation invite, {required bool accept}) async {
    if (_inFlightInviteIds.contains(invite.id)) return;
    setState(() => _inFlightInviteIds.add(invite.id));
    try {
      final res = accept
          ? await ref
              .read(clubInvitationActionsProvider)
              .acceptInvitation(invite.id)
          : await ref
              .read(clubInvitationActionsProvider)
              .declineInvitation(invite.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            accept
                ? 'Berhasil bergabung ke Coffee Club "${invite.communityName}"!'
                : 'Undangan ke "${invite.communityName}" ditolak.',
          ),
          backgroundColor: AppTheme.primaryBrown,
        ),
      );
      if (accept && GoRouter.maybeOf(context) != null) {
        context.push('/social/clubs/${res.communityId}');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memproses undangan: $e'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _inFlightInviteIds.remove(invite.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncInvites = ref.watch(pendingClubInvitationsProvider);
    return asyncInvites.maybeWhen(
      data: (invitations) {
        if (invitations.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.accentAmber.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${invitations.length}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.primaryBrown,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Undangan Masuk Coffee Club',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ...invitations.map(
                (invite) => _InvitationCard(
                  invite: invite,
                  inFlight: _inFlightInviteIds.contains(invite.id),
                  onAccept: () => _respond(invite, accept: true),
                  onDecline: () => _respond(invite, accept: false),
                ),
              ),
            ],
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}

class _InvitationCard extends StatelessWidget {
  final ClubMemberInvitation invite;
  final bool inFlight;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const _InvitationCard({
    required this.invite,
    required this.inFlight,
    required this.onAccept,
    required this.onDecline,
  });

  String _privacyLabel(String privacy) {
    return switch (privacy) {
      'SECRET_VAULT' => 'Secret Vault',
      'RESTRICTED' => 'Privat',
      _ => 'Publik',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF3),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.accentAmber.withValues(alpha: 0.65),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBrown.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppTheme.primaryBrown,
                child: Text(
                  invite.communityName.isNotEmpty
                      ? invite.communityName[0].toUpperCase()
                      : 'C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      invite.communityName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '${invite.inviterDisplayName} (@${invite.inviterUsername}) • ${invite.membersCount} anggota',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _privacyLabel(invite.privacyLevel),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBrown,
                  ),
                ),
              ),
            ],
          ),
          if (invite.message.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: Text(
                '"${invite.message.trim()}"',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textDark,
                ),
              ),
            ),
          ] else if (invite.communityDescription.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              invite.communityDescription,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: inFlight ? null : onDecline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    side: const BorderSide(color: AppTheme.borderWarm),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tolak',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: inFlight ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(
                    inFlight ? CupertinoIcons.hourglass : CupertinoIcons.checkmark_alt,
                    size: 15,
                  ),
                  label: Text(
                    inFlight ? 'Memproses...' : 'Terima & Gabung',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
