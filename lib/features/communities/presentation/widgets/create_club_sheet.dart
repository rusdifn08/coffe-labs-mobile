import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../../social_profile_feed/domain/models/social_profile_models.dart';
import '../controllers/communities_controllers.dart';
import 'club_invite_users_picker.dart';

class CreateClubSheet extends ConsumerStatefulWidget {
  const CreateClubSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const CreateClubSheet(),
    );
  }

  @override
  ConsumerState<CreateClubSheet> createState() => _CreateClubSheetState();
}

class _CreateClubSheetState extends ConsumerState<CreateClubSheet> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _inviteMessageController = TextEditingController();
  String _privacyLevel = 'PUBLIC';
  final Set<String> _selectedTags = {'V60'};
  final List<ProfileDirectoryEntry> _invitedUsers = [];
  bool _showInviteSection = true;
  bool _submitting = false;
  String? _error;

  static const _tagChoices = [
    'V60',
    'Espresso',
    'Ethiopia',
    'Colombia',
    'Gayo',
    'Natural',
    'Washed',
    'Light Roast',
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descController.dispose();
    _inviteMessageController.dispose();
    super.dispose();
  }

  String _previewSlug(String raw) {
    final lower = raw.trim().toLowerCase();
    final cleaned = lower
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    if (cleaned.isEmpty) return 'nama-coffee-club';
    return cleaned.length > 36 ? cleaned.substring(0, 36) : cleaned;
  }

  void _toggleInviteUser(ProfileDirectoryEntry user) {
    setState(() {
      final existsIdx = _invitedUsers.indexWhere((u) => u.userId == user.userId);
      if (existsIdx >= 0) {
        _invitedUsers.removeAt(existsIdx);
      } else if (_invitedUsers.length < 30) {
        _invitedUsers.add(user);
      }
    });
  }

  String _privacyHelperText() {
    return switch (_privacyLevel) {
      'RESTRICTED' => 'Privat: Muncul di direktori, masuk lewat Undangan langsung atau Secret ID.',
      'SECRET_VAULT' => 'Secret Vault: Tersembunyi dari pencarian publik; khusus Undangan / Secret ID.',
      _ => 'Publik: Terbuka untuk seluruh barista Coffee Labs di halaman Coffee Club.',
    };
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.length < 3) {
      setState(() => _error = 'Nama Coffee Club minimal 3 karakter.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final inviteIds = _invitedUsers.map((u) => u.userId).toList();
      final workspace = await ref.read(communitiesApiProvider).createCommunity(
            name: name,
            description: _descController.text.trim(),
            privacyLevel: _privacyLevel,
            focusTags: _selectedTags.toList(),
            invitedUserIds: inviteIds,
            inviteMessage: _inviteMessageController.text.trim(),
          );
      ref.invalidate(exploreCommunitiesControllerProvider);
      if (!mounted) return;
      final invitedCount = inviteIds.length;
      Navigator.of(context).pop();
      if (invitedCount > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Coffee Club "$name" dibuat & undangan dikirim ke $invitedCount barista!',
            ),
            backgroundColor: AppTheme.primaryBrown,
          ),
        );
      }
      if (GoRouter.maybeOf(context) != null) {
        context.push('/social/clubs/${workspace.community.id}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final slugPreview = _previewSlug(_nameController.text);

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.borderWarm,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBrown.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.person_3_fill,
                        color: AppTheme.primaryBrown,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Buat Coffee Club Baru',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            'Grup Live Chat, Recipe Vault, Leaderboard & Secret ID',
                            style: TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        CupertinoIcons.xmark_circle_fill,
                        color: AppTheme.textMuted,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    labelText: 'Nama Coffee Club',
                    hintText: 'Contoh: Nusantara V60 Basecamp',
                    prefixIcon: const Icon(CupertinoIcons.sparkles, size: 18),
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderWarm),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderWarm),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.at,
                      size: 13,
                      color: AppTheme.primaryBrown,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'coffeelabs.app/club/$slugPreview',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBrown,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Deskripsi Singkat',
                    hintText: 'Fokus seduhan, kalibrasi air, agenda seduh bareng...',
                    filled: true,
                    fillColor: AppTheme.surfaceWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderWarm),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppTheme.borderWarm),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Privasi Coffee Club',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'PUBLIC',
                      label: Text('Publik'),
                      icon: Icon(CupertinoIcons.globe, size: 15),
                    ),
                    ButtonSegment(
                      value: 'RESTRICTED',
                      label: Text('Privat'),
                      icon: Icon(CupertinoIcons.lock, size: 15),
                    ),
                    ButtonSegment(
                      value: 'SECRET_VAULT',
                      label: Text('Secret'),
                      icon: Icon(CupertinoIcons.eye_slash, size: 15),
                    ),
                  ],
                  selected: {_privacyLevel},
                  onSelectionChanged: (s) =>
                      setState(() => _privacyLevel = s.first),
                ),
                const SizedBox(height: 6),
                Text(
                  _privacyHelperText(),
                  style: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Karakteristik & Fokus Seduh',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 7,
                  runSpacing: 6,
                  children: _tagChoices.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      selectedColor: AppTheme.accentAmber.withValues(alpha: 0.25),
                      onSelected: (val) => setState(() {
                        if (val) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () =>
                      setState(() => _showInviteSection = !_showInviteSection),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          CupertinoIcons.person_add_solid,
                          size: 18,
                          color: AppTheme.primaryBrown,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _invitedUsers.isEmpty
                                ? 'Undang Barista Masuk Club (Opsional)'
                                : 'Barista Diundang (${_invitedUsers.length})',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        Icon(
                          _showInviteSection
                              ? CupertinoIcons.chevron_up
                              : CupertinoIcons.chevron_down,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showInviteSection) ...[
                  const SizedBox(height: 10),
                  ClubInviteUsersPicker(
                    selectedUsers: _invitedUsers,
                    onToggleUser: _toggleInviteUser,
                    messageController: _inviteMessageController,
                    maxListHeight: 175,
                  ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12.5),
                  ),
                ],
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: _submitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _submitting
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(CupertinoIcons.checkmark_seal_fill, size: 18),
                  label: Text(
                    _submitting
                        ? 'Menyiapkan Coffee Club...'
                        : (_invitedUsers.isEmpty
                            ? 'New Club'
                            : 'New Club (${_invitedUsers.length} Undangan)'),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
