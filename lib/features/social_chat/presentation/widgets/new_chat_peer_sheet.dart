import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/chat_protocol.dart';
import '../controllers/chat_controllers.dart';

class NewChatPeerSheet extends ConsumerStatefulWidget {
  const NewChatPeerSheet({super.key});

  static Future<String?> show(BuildContext context) {
    return showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NewChatPeerSheet(),
    );
  }

  @override
  ConsumerState<NewChatPeerSheet> createState() => _NewChatPeerSheetState();
}

class _NewChatPeerSheetState extends ConsumerState<NewChatPeerSheet> {
  final TextEditingController _searchCtrl = TextEditingController();
  final TextEditingController _groupTitleCtrl = TextEditingController();
  final Set<String> _selectedGroupMemberIds = {};

  bool _isGroupMode = false;
  bool _loading = true;
  bool _submitting = false;
  List<ChatPeerDto> _peers = [];
  String? _error;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _fetchPeers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    _groupTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchPeers([String? query]) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final api = ref.read(chatApiServiceProvider);
      final list = await api.searchPeers(query: query);
      if (!mounted) return;
      setState(() {
        _peers = list;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Tidak dapat memuat daftar barista (periksa koneksi).';
      });
    }
  }

  Future<void> _startDirect(ChatPeerDto peer) async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final convId = await ref
          .read(chatRoomListControllerProvider.notifier)
          .startDirectChat(peer.id);
      if (mounted) Navigator.pop(context, convId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Gagal membuat ruang chat: $e';
        });
      }
    }
  }

  Future<void> _createGroup() async {
    final title = _groupTitleCtrl.text.trim();
    if (title.length < 2 || _selectedGroupMemberIds.isEmpty) {
      setState(() => _error = 'Isi nama grup dan pilih minimal 1 barista.');
      return;
    }
    setState(() => _submitting = true);
    try {
      final convId = await ref
          .read(chatRoomListControllerProvider.notifier)
          .createGroupChat(
            title: title,
            memberIds: _selectedGroupMemberIds.toList(),
          );
      if (mounted) Navigator.pop(context, convId);
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = 'Gagal membuat grup: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.borderWarm,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 8),
            child: Row(
              children: [
                const Icon(CupertinoIcons.chat_bubble_2_fill,
                    color: AppTheme.primaryBrown),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Mulai Obrolan Baru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Direct')),
                    ButtonSegment(value: true, label: Text('Grup')),
                  ],
                  selected: {_isGroupMode},
                  onSelectionChanged: (s) {
                    setState(() {
                      _isGroupMode = s.first;
                      _error = null;
                    });
                  },
                ),
              ],
            ),
          ),
          if (_isGroupMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: TextField(
                controller: _groupTitleCtrl,
                decoration: InputDecoration(
                  hintText: 'Nama Grup (mis. Komunitas V60 Bandung)',
                  prefixIcon: const Icon(CupertinoIcons.person_3_fill, size: 18),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppTheme.borderWarm),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) {
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 280), () {
                  _fetchPeers(val);
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari username atau nama barista...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.borderWarm),
                ),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                  )
                : _peers.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada barista ditemukan.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                        itemCount: _peers.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, idx) {
                          final peer = _peers[idx];
                          final selected = _selectedGroupMemberIds.contains(peer.id);
                          return ListTile(
                            tileColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: BorderSide(
                                color: selected
                                    ? AppTheme.primaryBrown
                                    : AppTheme.borderWarm,
                              ),
                            ),
                            leading: Stack(
                              children: [
                                CircleAvatar(
                                  backgroundColor:
                                      AppTheme.primaryBrown.withValues(alpha: 0.12),
                                  child: Text(
                                    peer.fullName.isNotEmpty
                                        ? peer.fullName[0].toUpperCase()
                                        : 'B',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primaryBrown,
                                    ),
                                  ),
                                ),
                                if (peer.isOnline)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 11,
                                      height: 11,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: Colors.white, width: 1.8),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            title: Text(
                              peer.fullName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              '@${peer.username} • ${peer.isOnline ? 'Online' : peer.role}',
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textMuted),
                            ),
                            trailing: _isGroupMode
                                ? Icon(
                                    selected
                                        ? CupertinoIcons.checkmark_circle_fill
                                        : CupertinoIcons.circle,
                                    color: selected
                                        ? AppTheme.primaryBrown
                                        : AppTheme.textMuted,
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Lihat Profil Publik',
                                        icon: const Icon(
                                          CupertinoIcons.person_crop_circle,
                                          size: 19,
                                          color: AppTheme.primaryBrown,
                                        ),
                                        onPressed: () {
                                          final target =
                                              peer.username.isNotEmpty
                                                  ? peer.username
                                                  : peer.id;
                                          Navigator.of(context).pop();
                                          context.push(
                                            '/social/profile/${Uri.encodeComponent(target)}',
                                          );
                                        },
                                      ),
                                      const Icon(
                                        CupertinoIcons.chevron_forward,
                                        size: 16,
                                        color: AppTheme.textMuted,
                                      ),
                                    ],
                                  ),
                            onTap: _submitting
                                ? null
                                : () {
                                    if (_isGroupMode) {
                                      setState(() {
                                        if (selected) {
                                          _selectedGroupMemberIds.remove(peer.id);
                                        } else {
                                          _selectedGroupMemberIds.add(peer.id);
                                        }
                                      });
                                    } else {
                                      _startDirect(peer);
                                    }
                                  },
                          );
                        },
                      ),
          ),
          if (_isGroupMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _createGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _submitting
                        ? 'Membuat Grup...'
                        : 'Buat Grup (${_selectedGroupMemberIds.length} Anggota)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
