import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../theme/app_theme.dart';
import '../../data/services/chat_ws_service.dart';
import '../../domain/chat_view_models.dart';
import '../controllers/chat_controllers.dart';
import '../widgets/new_chat_peer_sheet.dart';

class SocialCoffeeChatListScreen extends ConsumerStatefulWidget {
  const SocialCoffeeChatListScreen({super.key});

  @override
  ConsumerState<SocialCoffeeChatListScreen> createState() =>
      _SocialCoffeeChatListScreenState();
}

class _SocialCoffeeChatListScreenState
    extends ConsumerState<SocialCoffeeChatListScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';
  List<LocalChatMessageView> _ftsResults = [];
  bool _searchingFts = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String raw) async {
    final q = raw.trim();
    setState(() => _searchQuery = q);
    if (q.length < 2) {
      setState(() {
        _ftsResults = const [];
        _searchingFts = false;
      });
      return;
    }

    setState(() => _searchingFts = true);
    try {
      final db = ref.read(chatDriftDatabaseProvider);
      final hits = await db.searchMessagesFtsViews(q);
      if (mounted && _searchQuery == q) {
        setState(() {
          _ftsResults = hits;
          _searchingFts = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _searchingFts = false);
    }
  }

  Future<void> _openNewChatSheet() async {
    final convId = await NewChatPeerSheet.show(context);
    if (convId != null && mounted) {
      context.push(AppRoutes.socialChatRoom.replaceFirst(':conversationId', convId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomsAsync = ref.watch(chatRoomListControllerProvider);
    final connState = ref.watch(chatConnectionStateProvider).value ??
        WsConnectionState.disconnected;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'Obrolan Barista',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            Text(
              'Direct & Group Social Coffee',
              style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _ConnectionBadge(state: connState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'new_social_chat_fab',
        backgroundColor: AppTheme.primaryBrown,
        foregroundColor: Colors.white,
        onPressed: _openNewChatSheet,
        icon: const Icon(CupertinoIcons.square_pencil, size: 19),
        label: const Text(
          'Chat Baru',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cari pesan atau resep offline (FTS5)...',
                prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(CupertinoIcons.clear_circled_solid,
                            size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
          ),
          Expanded(
            child: _searchQuery.length >= 2
                ? _buildFtsSearchBody()
                : _buildConversationsBody(roomsAsync),
          ),
        ],
      ),
    );
  }

  Widget _buildFtsSearchBody() {
    if (_searchingFts) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      );
    }
    if (_ftsResults.isEmpty) {
      return Center(
        child: Text(
          'Tidak ditemukan pesan offline untuk "$_searchQuery".',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
      itemCount: _ftsResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final msg = _ftsResults[idx];
        return ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppTheme.borderWarm),
          ),
          leading: const CircleAvatar(
            backgroundColor: AppTheme.bgCream,
            child: Icon(CupertinoIcons.doc_text_search,
                color: AppTheme.primaryBrown, size: 18),
          ),
          title: Text(
            msg.bodyText?.isNotEmpty == true
                ? msg.bodyText!
                : 'Lampiran Kartu (${msg.messageType})',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            DateFormat('dd MMM • HH:mm').format(msg.createdAt.toLocal()),
            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          onTap: () {
            context.push(
              AppRoutes.socialChatRoom
                  .replaceFirst(':conversationId', msg.conversationId),
            );
          },
        );
      },
    );
  }

  Widget _buildConversationsBody(AsyncValue<List<ChatRoomListItemView>> roomsAsync) {
    return roomsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
      ),
      error: (err, _) => Center(
        child: Text('Gagal memuat daftar obrolan: $err'),
      ),
      data: (items) {
        if (items.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: const Icon(
                      CupertinoIcons.chat_bubble_2_fill,
                      color: AppTheme.primaryBrown,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum Ada Percakapan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Mulai obrolan 1-on-1 atau grup untuk berbagi resep V60 & profil biji kopi real-time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _openNewChatSheet,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBrown,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(CupertinoIcons.person_add_solid, size: 17),
                    label: const Text('Cari Barista / Buat Grup'),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryBrown,
          onRefresh: () => ref
              .read(chatRoomListControllerProvider.notifier)
              .refreshFromServer(),
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, idx) {
              final view = items[idx];
              final room = view.conversation;
              final isTyping = view.typingUserName != null;
              final timeText = room.lastMessageAt != null
                  ? DateFormat('HH:mm').format(room.lastMessageAt!.toLocal())
                  : '';

              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    context.push(
                      AppRoutes.socialChatRoom
                          .replaceFirst(':conversationId', room.id),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.borderWarm),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor:
                                  AppTheme.primaryBrown.withValues(alpha: 0.12),
                              child: room.kind == 'GROUP'
                                  ? const Icon(
                                      CupertinoIcons.person_3_fill,
                                      color: AppTheme.primaryBrown,
                                    )
                                  : Text(
                                      room.title.isNotEmpty
                                          ? room.title[0].toUpperCase()
                                          : 'B',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                        color: AppTheme.primaryBrown,
                                      ),
                                    ),
                            ),
                            if (room.peerOnline && room.kind == 'DIRECT')
                              Positioned(
                                right: 0,
                                bottom: 0,
                                child: Container(
                                  width: 13,
                                  height: 13,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white, width: 2),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      room.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.5,
                                        color: AppTheme.textDark,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeText,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      isTyping
                                          ? '${view.typingUserName} sedang mengetik...'
                                          : (room.lastMessagePreview ??
                                              'Mulai percakapan sekarang'),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontStyle: isTyping
                                            ? FontStyle.italic
                                            : FontStyle.normal,
                                        fontWeight: isTyping
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isTyping
                                            ? AppTheme.primaryBrown
                                            : AppTheme.textMuted,
                                      ),
                                    ),
                                  ),
                                  if (room.unreadCount > 0)
                                    Container(
                                      margin: const EdgeInsets.only(left: 8),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryBrown,
                                        borderRadius:
                                            BorderRadius.circular(999),
                                      ),
                                      child: Text(
                                        room.unreadCount > 99
                                            ? '99+'
                                            : '${room.unreadCount}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _ConnectionBadge extends StatelessWidget {
  final WsConnectionState state;

  const _ConnectionBadge({required this.state});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (state) {
      WsConnectionState.connected => (const Color(0xFF10B981), 'Live'),
      WsConnectionState.connecting => (AppTheme.accentAmber, 'Sync'),
      WsConnectionState.reconnecting => (AppTheme.accentAmber, 'Reconnecting'),
      WsConnectionState.disconnected => (AppTheme.textMuted, 'Offline'),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
