import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_graph_models.dart';
import '../controllers/relationship_controller.dart';

class FollowRequestsInboxBanner extends ConsumerStatefulWidget {
  const FollowRequestsInboxBanner({super.key});

  @override
  ConsumerState<FollowRequestsInboxBanner> createState() =>
      _FollowRequestsInboxBannerState();
}

class _FollowRequestsInboxBannerState
    extends ConsumerState<FollowRequestsInboxBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final privacyAsync = ref.watch(myPrivacySettingControllerProvider);
    final requestsAsync = ref.watch(pendingFollowRequestsControllerProvider);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.borderWarm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          privacyAsync.when(
            loading: () => const SizedBox(height: 36),
            error: (_, _) => const SizedBox.shrink(),
            data: (privacy) => Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    privacy.isPrivateAccount
                        ? CupertinoIcons.lock_fill
                        : CupertinoIcons.lock_open,
                    size: 18,
                    color: AppTheme.primaryBrown,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Akun Privat',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        privacy.isPrivateAccount
                            ? 'Pengikut baru perlu persetujuan Anda'
                            : 'Siapa saja dapat mengikuti profil Anda',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: privacy.isPrivateAccount,
                  activeTrackColor: AppTheme.primaryBrown,
                  onChanged: (val) => ref
                      .read(myPrivacySettingControllerProvider.notifier)
                      .setPrivateAccount(val),
                ),
              ],
            ),
          ),
          requestsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
            data: (requests) {
              if (requests.isEmpty) return const SizedBox.shrink();
              return Column(
                children: [
                  const Divider(height: 20, color: AppTheme.borderWarm),
                  InkWell(
                    onTap: () => setState(() => _expanded = !_expanded),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold.withValues(alpha: 0.22),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${requests.length}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.primaryBrown,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Permintaan Mengikuti Masuk',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ),
                          Icon(
                            _expanded
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_expanded) ...[
                    const SizedBox(height: 8),
                    for (final req in requests)
                      _PendingRequestRow(
                        item: req,
                        onAccept: () => ref
                            .read(
                              pendingFollowRequestsControllerProvider.notifier,
                            )
                            .handleRequest(
                              requesterId: req.requesterId,
                              accept: true,
                            ),
                        onReject: () => ref
                            .read(
                              pendingFollowRequestsControllerProvider.notifier,
                            )
                            .handleRequest(
                              requesterId: req.requesterId,
                              accept: false,
                            ),
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PendingRequestRow extends StatelessWidget {
  final FollowRequestItem item;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingRequestRow({
    required this.item,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final initial = item.displayName.isNotEmpty
        ? item.displayName[0].toUpperCase()
        : 'B';
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: AppTheme.accentGold.withValues(alpha: 0.25),
            backgroundImage:
                item.avatarUrl != null && item.avatarUrl!.isNotEmpty
                    ? NetworkImage(item.avatarUrl!)
                    : null,
            child: item.avatarUrl == null || item.avatarUrl!.isEmpty
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryBrown,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  '@${item.username} • Lv.${item.baristaLevel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onReject,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textMuted,
              minimumSize: const Size(52, 32),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text('Tolak', style: TextStyle(fontSize: 12)),
          ),
          const SizedBox(width: 4),
          FilledButton(
            onPressed: onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.primaryBrown,
              foregroundColor: Colors.white,
              minimumSize: const Size(64, 32),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Terima',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
