import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/models/social_profile_models.dart';
import '../controllers/social_profile_controllers.dart';

class FollowConnectionsSheet extends ConsumerStatefulWidget {
  final String targetUserOrUsername;
  final String displayName;
  final bool initialShowFollowers;

  const FollowConnectionsSheet({
    super.key,
    required this.targetUserOrUsername,
    required this.displayName,
    required this.initialShowFollowers,
  });

  static Future<void> show(
    BuildContext context, {
    required String targetUserOrUsername,
    required String displayName,
    required bool showFollowers,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.72,
        child: FollowConnectionsSheet(
          targetUserOrUsername: targetUserOrUsername,
          displayName: displayName,
          initialShowFollowers: showFollowers,
        ),
      ),
    );
  }

  @override
  ConsumerState<FollowConnectionsSheet> createState() =>
      _FollowConnectionsSheetState();
}

class _FollowConnectionsSheetState
    extends ConsumerState<FollowConnectionsSheet> {
  late bool _showFollowers;
  late Future<List<ProfileDirectoryEntry>> _future;

  @override
  void initState() {
    super.initState();
    _showFollowers = widget.initialShowFollowers;
    _load();
  }

  void _load() {
    final api = ref.read(socialProfileApiServiceProvider);
    _future = _showFollowers
        ? api.getFollowers(widget.targetUserOrUsername)
        : api.getFollowing(widget.targetUserOrUsername);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 42,
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.borderWarm,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
          child: Column(
            children: [
              Text(
                widget.displayName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 10),
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment<bool>(
                    value: true,
                    label: Text('Followers'),
                    icon: Icon(CupertinoIcons.person_2_fill, size: 15),
                  ),
                  ButtonSegment<bool>(
                    value: false,
                    label: Text('Following'),
                    icon: Icon(CupertinoIcons.person_badge_plus, size: 15),
                  ),
                ],
                selected: {_showFollowers},
                onSelectionChanged: (next) {
                  setState(() {
                    _showFollowers = next.first;
                    _load();
                  });
                },
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.dividerColor),
        Expanded(
          child: FutureBuilder<List<ProfileDirectoryEntry>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'Gagal memuat daftar koneksi: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                );
              }
              final entries = snapshot.data ?? const [];
              if (entries.isEmpty) {
                return Center(
                  child: Text(
                    _showFollowers
                        ? 'Belum ada followers.'
                        : 'Belum mengikuti siapa pun.',
                    style: const TextStyle(color: AppTheme.textMuted),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: entries.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final entry = entries[idx];
                  return ListTile(
                    tileColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.borderWarm),
                    ),
                    leading: CircleAvatar(
                      backgroundColor:
                          AppTheme.primaryBrown.withValues(alpha: 0.14),
                      child: Text(
                        entry.displayName.isNotEmpty
                            ? entry.displayName[0].toUpperCase()
                            : 'B',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            entry.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.bgCream,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Lv.${entry.baristaLevel}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBrown,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      entry.recentBrewSnapshot != null
                          ? '@${entry.username} • Menyeduh ${entry.recentBrewSnapshot!.beanName}'
                          : '@${entry.username} • ${entry.baristaRankTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    trailing: const Icon(
                      CupertinoIcons.chevron_forward,
                      size: 16,
                      color: AppTheme.textMuted,
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push(
                        '/social/profile/${Uri.encodeComponent(entry.username)}',
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
