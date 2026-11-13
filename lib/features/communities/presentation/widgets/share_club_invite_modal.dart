import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/community_models.dart';
import '../controllers/communities_controllers.dart';

class ShareClubInviteModal extends ConsumerStatefulWidget {
  final String communityId;
  final String clubName;

  const ShareClubInviteModal({
    super.key,
    required this.communityId,
    required this.clubName,
  });

  static Future<void> show(
    BuildContext context, {
    required String communityId,
    required String clubName,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareClubInviteModal(
        communityId: communityId,
        clubName: clubName,
      ),
    );
  }

  @override
  ConsumerState<ShareClubInviteModal> createState() =>
      _ShareClubInviteModalState();
}

class _ShareClubInviteModalState extends ConsumerState<ShareClubInviteModal> {
  bool _creating = false;

  Future<void> _rotateNewSecret() async {
    setState(() => _creating = true);
    try {
      await ref
          .read(communitiesApiProvider)
          .createInvite(communityId: widget.communityId);
      ref.invalidate(clubInvitesListProvider(widget.communityId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat Secret ID baru: $e')),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncInvites = ref.watch(clubInvitesListProvider(widget.communityId));

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      child: SafeArea(
        top: false,
        child: asyncInvites.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (err, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Hanya Owner/Admin yang dapat mengelola undangan: $err'),
          ),
          data: (invites) {
            final CommunityInviteSecret? active =
                invites.isNotEmpty ? invites.first : null;
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderWarm,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Undang ke ${widget.clubName}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bagikan QR Code, Deep Link, atau kode Secret ID Crockford Base32.',
                  style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 16),
                if (active == null)
                  ElevatedButton(
                    onPressed: _creating ? null : _rotateNewSecret,
                    child: const Text('Terbitkan Secret ID'),
                  )
                else ...[
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.borderWarm),
                      ),
                      child: QrImageView(
                        data: active.inviteWebLink,
                        version: QrVersions.auto,
                        size: 168,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: AppTheme.primaryBrown,
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: AppTheme.textDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            active.secretCodeDisplay,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryBrown,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(CupertinoIcons.doc_on_clipboard),
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: active.secretCodeDisplay),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kode Secret ID disalin!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _creating ? null : _rotateNewSecret,
                          icon: const Icon(CupertinoIcons.refresh, size: 16),
                          label: const Text('Kode Baru'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryBrown,
                            side: const BorderSide(color: AppTheme.borderWarm),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await SharePlus.instance.share(
                              ShareParams(
                                text:
                                    'Yuk gabung ke Coffee Club "${widget.clubName}" di Coffee Labs!\n'
                                    'Kode Secret ID: ${active.secretCodeDisplay}\n'
                                    'Atau klik link: ${active.inviteWebLink}',
                              ),
                            );
                          },
                          icon: const Icon(CupertinoIcons.share, size: 17),
                          label: const Text('Bagikan Undangan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBrown,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
