import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../theme/app_theme.dart';
import '../../../social_profile_feed/domain/models/social_profile_models.dart';
import '../../domain/community_models.dart';
import '../controllers/communities_controllers.dart';
import 'club_invite_users_picker.dart';

class ShareClubInviteModal extends ConsumerStatefulWidget {
  final String communityId;
  final String clubName;
  final int initialTabIndex;

  const ShareClubInviteModal({
    super.key,
    required this.communityId,
    required this.clubName,
    this.initialTabIndex = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required String communityId,
    required String clubName,
    int initialTabIndex = 0,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ShareClubInviteModal(
        communityId: communityId,
        clubName: clubName,
        initialTabIndex: initialTabIndex,
      ),
    );
  }

  @override
  ConsumerState<ShareClubInviteModal> createState() =>
      _ShareClubInviteModalState();
}

class _ShareClubInviteModalState extends ConsumerState<ShareClubInviteModal>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final List<ProfileDirectoryEntry> _selectedUsers = [];
  final TextEditingController _messageCtrl = TextEditingController();
  bool _creatingSecret = false;
  bool _sendingInvites = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 1),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _toggleUser(ProfileDirectoryEntry user) {
    setState(() {
      final idx = _selectedUsers.indexWhere((u) => u.userId == user.userId);
      if (idx >= 0) {
        _selectedUsers.removeAt(idx);
      } else if (_selectedUsers.length < 30) {
        _selectedUsers.add(user);
      }
    });
  }

  Future<void> _sendDirectInvites() async {
    if (_selectedUsers.isEmpty || _sendingInvites) return;
    setState(() => _sendingInvites = true);
    try {
      final ids = _selectedUsers.map((u) => u.userId).toList();
      final res = await ref.read(clubInvitationActionsProvider).inviteUsers(
            communityId: widget.communityId,
            userIds: ids,
            message: _messageCtrl.text.trim(),
          );
      if (!mounted) return;
      setState(() {
        _selectedUsers.clear();
        _messageCtrl.clear();
        _sendingInvites = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            res.invitedCount > 0
                ? 'Undangan berhasil dikirim ke ${res.invitedCount} barista!'
                : 'Semua barista yang dipilih sudah menjadi anggota club.',
          ),
          backgroundColor: AppTheme.primaryBrown,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _sendingInvites = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim undangan: $e')),
      );
    }
  }

  Future<void> _rotateNewSecret() async {
    setState(() => _creatingSecret = true);
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
      if (mounted) setState(() => _creatingSecret = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.86,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Undang ke ${widget.clubName}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const Text(
                            'Kirim undangan langsung atau bagikan Secret ID',
                            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppTheme.primaryBrown,
                unselectedLabelColor: AppTheme.textMuted,
                indicatorColor: AppTheme.accentAmber,
                tabs: const [
                  Tab(text: 'Undang Barista'),
                  Tab(text: 'Secret ID & QR'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDirectInviteTab(),
                    _buildSecretQrTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDirectInviteTab() {
    final asyncSent = ref.watch(clubSentInvitationsProvider(widget.communityId));

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      children: [
        ClubInviteUsersPicker(
          selectedUsers: _selectedUsers,
          onToggleUser: _toggleUser,
          messageController: _messageCtrl,
          maxListHeight: 190,
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: (_selectedUsers.isEmpty || _sendingInvites)
              ? null
              : _sendDirectInvites,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 13),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: const Icon(CupertinoIcons.paperplane_fill, size: 16),
          label: Text(
            _sendingInvites
                ? 'Mengirim Undangan...'
                : (_selectedUsers.isEmpty
                    ? 'Pilih Barista Terlebih Dahulu'
                    : 'Kirim Undangan (${_selectedUsers.length})'),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        asyncSent.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (sent) {
            if (sent.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Undangan Menunggu Respon (${sent.length})',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                ...sent.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.inviteeDisplayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '@${item.inviteeUsername} • Menunggu Accept/Decline',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () => ref
                              .read(clubInvitationActionsProvider)
                              .cancelInvitation(widget.communityId, item.id),
                          child: const Text(
                            'Batalkan',
                            style: TextStyle(fontSize: 12, color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildSecretQrTab() {
    final asyncInvites = ref.watch(clubInvitesListProvider(widget.communityId));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: asyncInvites.when(
        loading: () => const SizedBox(
          height: 220,
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (err, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Hanya Owner/Admin yang dapat mengelola Secret ID: $err'),
        ),
        data: (invites) {
          final CommunityInviteSecret? active =
              invites.isNotEmpty ? invites.first : null;
          if (active == null) {
            return ElevatedButton(
              onPressed: _creatingSecret ? null : _rotateNewSecret,
              child: const Text('Terbitkan Secret ID'),
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          const SnackBar(content: Text('Kode Secret ID disalin!')),
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
                      onPressed: _creatingSecret ? null : _rotateNewSecret,
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
                      label: const Text('Bagikan Link'),
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
          );
        },
      ),
    );
  }
}
