import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../services/auth_service.dart';
import '../../../../theme/app_theme.dart';
import '../../../../widgets/user_avatar_circle.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../notifications/data/services/device_token_lifecycle_service.dart';
import '../../../notifications/data/services/local_push_orchestrator.dart';
import '../../data/local/chat_drift_database.dart';
import '../../data/services/chat_ws_service.dart';
import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';
import '../controllers/chat_controllers.dart';
import '../widgets/animated_typing_indicator_bubble.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_quick_share_sheet.dart';
import '../widgets/chat_room_sheets.dart';

class SocialCoffeeChatRoomScreen extends ConsumerStatefulWidget {
  final String conversationId;

  const SocialCoffeeChatRoomScreen({
    super.key,
    required this.conversationId,
  });

  @override
  ConsumerState<SocialCoffeeChatRoomScreen> createState() =>
      _SocialCoffeeChatRoomScreenState();
}

class _SocialCoffeeChatRoomScreenState
    extends ConsumerState<SocialCoffeeChatRoomScreen> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  StreamSubscription<ServerTypingIndicatorFrame>? _typingSub;
  StreamSubscription<ServerFrameErrorFrame>? _errorSub;
  Timer? _typingExpiryTimer;
  String? _peerTypingName;
  String _fallbackUserId = '';
  bool _hasDraftText = false;
  bool _showScrollToBottom = false;
  LocalChatMessageView? _replyingTo;

  late final ChatWsService _wsService;
  late final LocalPushOrchestrator _pushOrchestrator;
  late final DeviceTokenLifecycleService _tokenLifecycle;
  late final ChatDriftDatabase _db;

  @override
  void initState() {
    super.initState();
    _wsService = ref.read(chatWsServiceProvider);
    _pushOrchestrator = ref.read(localPushOrchestratorProvider);
    _tokenLifecycle = ref.read(deviceTokenLifecycleServiceProvider);
    _db = ref.read(chatDriftDatabaseProvider);

    _pushOrchestrator.setActiveChatRoomId(widget.conversationId);
    unawaited(_wsService.setActiveRoom(widget.conversationId));
    unawaited(_tokenLifecycle.syncActiveChatRoom(widget.conversationId));
    unawaited(_hydrateFallbackUserId());

    _scrollCtrl.addListener(_onScrollChanged);
    _inputCtrl.addListener(_onInputTextChanged);

    _typingSub = _wsService.typingStream.listen((evt) {
      if (evt.conversationId != widget.conversationId) return;
      _typingExpiryTimer?.cancel();
      if (!mounted) return;
      if (evt.isTyping) {
        setState(() => _peerTypingName = evt.displayName);
        _typingExpiryTimer = Timer(const Duration(milliseconds: 3500), () {
          if (mounted) setState(() => _peerTypingName = null);
        });
      } else {
        setState(() => _peerTypingName = null);
      }
    });

    _errorSub = _wsService.errorStream.listen((err) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err.message),
          backgroundColor: AppTheme.primaryBrown,
        ),
      );
    });
  }

  Future<void> _hydrateFallbackUserId() async {
    final user = await AuthService.getCurrentUser();
    final uid = user?.id.trim() ?? '';
    if (uid.isEmpty) return;
    await _db.reconcileLocalSenderId(uid);
    if (mounted && _fallbackUserId != uid) {
      setState(() => _fallbackUserId = uid);
    }
  }

  void _onScrollChanged() {
    if (!_scrollCtrl.hasClients) return;
    final show = _scrollCtrl.offset > 260;
    if (show != _showScrollToBottom && mounted) {
      setState(() => _showScrollToBottom = show);
    }
  }

  void _onInputTextChanged() {
    final hasText = _inputCtrl.text.trim().isNotEmpty;
    if (hasText != _hasDraftText && mounted) {
      setState(() => _hasDraftText = hasText);
    }
  }

  @override
  void dispose() {
    _pushOrchestrator.setActiveChatRoomId(null);
    unawaited(_wsService.setActiveRoom(null));
    unawaited(_tokenLifecycle.syncActiveChatRoom(null));
    _typingSub?.cancel();
    _errorSub?.cancel();
    _typingExpiryTimer?.cancel();
    _scrollCtrl.removeListener(_onScrollChanged);
    _inputCtrl.removeListener(_onInputTextChanged);
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _sendText() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final replyTargetId = _replyingTo?.serverMsgId ?? _replyingTo?.clientMsgId;
    _inputCtrl.clear();
    if (mounted && _replyingTo != null) {
      setState(() => _replyingTo = null);
    }
    await ref
        .read(activeChatRoomControllerProvider(widget.conversationId).notifier)
        .sendTextMessage(text, replyToMsgId: replyTargetId);
    _scrollToBottom();
  }

  Future<void> _openQuickShare() async {
    final selection = await ChatQuickShareSheet.show(context);
    if (selection == null) return;
    final ctrl = ref.read(
      activeChatRoomControllerProvider(widget.conversationId).notifier,
    );
    switch (selection.attachment) {
      case V60RecipeCardAttachment recipe:
        await ctrl.sendV60RecipeCard(recipe, caption: selection.optionalCaption);
      case CoffeeBeanCardAttachment bean:
        await ctrl.sendBeanProfileCard(bean, caption: selection.optionalCaption);
      case BrewSessionResultAttachment res:
        await ctrl.sendBrewSessionResult(res);
      case BrewImageMediaAttachment _:
        break;
    }
    _scrollToBottom();
  }

  bool _isMessageMine(LocalChatMessageView msg, String resolvedUserId) {
    if (resolvedUserId.isNotEmpty) {
      return ChatDriftDatabase.isSameSender(msg.senderId, resolvedUserId);
    }
    return msg.senderId == 'local_barista';
  }

  bool _isSameCalendarDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _subtitleForRoom(ChatConversationView? room) {
    if (_peerTypingName != null) {
      return '$_peerTypingName sedang mengetik...';
    }
    if (room == null) return 'Memuat...';
    if (room.kind == 'GROUP') return 'Grup Komunitas Social Coffee';
    if (room.peerOnline) return 'Online';
    if (room.peerLastSeenAt != null) {
      return 'Terakhir dilihat ${DateFormat('HH:mm').format(room.peerLastSeenAt!.toLocal())}';
    }
    return 'Offline';
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync =
        ref.watch(activeChatRoomControllerProvider(widget.conversationId));
    final connState = ref.watch(chatConnectionStateProvider).value ??
        WsConnectionState.disconnected;
    final providerUid = ref.watch(authControllerProvider).value?.id.trim() ?? '';
    final currentUserId = providerUid.isNotEmpty ? providerUid : _fallbackUserId;

    return StreamBuilder<ChatConversationView?>(
      stream: _db.watchConversationViewById(widget.conversationId),
      builder: (context, roomSnap) {
        final room = roomSnap.data;
        final roomTitle = room?.title ?? 'Ruang Obrolan';
        final isOnline = room?.peerOnline ?? false;

        return Scaffold(
          backgroundColor: AppTheme.bgCream,
          appBar: AppBar(
            backgroundColor: AppTheme.bgCream,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            bottom: const PreferredSize(
              preferredSize: Size.fromHeight(1),
              child: Divider(height: 1, color: AppTheme.borderWarm),
            ),
            titleSpacing: 0,
            title: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: (room?.kind == 'DIRECT' &&
                      ((room?.peerUsername?.isNotEmpty ?? false) ||
                          (room?.peerUserId?.isNotEmpty ?? false)))
                  ? () {
                      final target = (room!.peerUsername?.isNotEmpty ?? false)
                          ? room.peerUsername!
                          : room.peerUserId!;
                      context.push(
                        '/social/profile/${Uri.encodeComponent(target)}',
                      );
                    }
                  : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                child: Row(
                  children: [
                    UserAvatarCircle(
                      avatarUrl: room?.avatarUrl,
                      displayName: roomTitle,
                      radius: 18,
                      isGroup: room?.kind == 'GROUP',
                      isOnline: isOnline && room?.kind == 'DIRECT',
                      onlineDotSize: 10,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            roomTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textDark,
                            ),
                          ),
                          Text(
                            _subtitleForRoom(room),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontStyle: _peerTypingName != null
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                              color: isOnline || _peerTypingName != null
                                  ? AppTheme.primaryBrown
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              _HeaderSyncBadge(connState: connState),
              IconButton(
                tooltip: 'Panduan Status Pesan',
                onPressed: () => ChatRoomSheets.showStatusLegend(context),
                icon: const Icon(
                  CupertinoIcons.info_circle,
                  size: 20,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: messagesAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                      ),
                      error: (err, _) =>
                          Center(child: Text('Gagal membaca DB lokal: $err')),
                      data: (messages) {
                        if (messages.isEmpty) {
                          return _EmptyRoomView(
                            peerName: roomTitle,
                            onShowLegend: () =>
                                ChatRoomSheets.showStatusLegend(context),
                          );
                        }

                        final lookup = <String, LocalChatMessageView>{};
                        for (final m in messages) {
                          lookup[m.clientMsgId] = m;
                          if (m.serverMsgId != null) {
                            lookup[m.serverMsgId!] = m;
                          }
                        }

                        return CustomScrollView(
                          controller: _scrollCtrl,
                          reverse: true,
                          slivers: [
                            const SliverToBoxAdapter(child: SizedBox(height: 12)),
                            SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final msg = messages[index];
                                  final prevMsg = index + 1 < messages.length
                                      ? messages[index + 1]
                                      : null;
                                  final nextMsg = index - 1 >= 0
                                      ? messages[index - 1]
                                      : null;

                                  final msgLocal = msg.createdAt.toLocal();
                                  final showDateDivider = prevMsg == null ||
                                      !_isSameCalendarDay(
                                        prevMsg.createdAt.toLocal(),
                                        msgLocal,
                                      );

                                  final isMine = _isMessageMine(msg, currentUserId);
                                  final prevMine = prevMsg != null &&
                                      _isMessageMine(prevMsg, currentUserId);
                                  final nextMine = nextMsg != null &&
                                      _isMessageMine(nextMsg, currentUserId);

                                  final sameSenderPrev = prevMsg != null &&
                                      !showDateDivider &&
                                      (isMine == prevMine) &&
                                      ChatDriftDatabase.isSameSender(
                                        prevMsg.senderId,
                                        msg.senderId,
                                      );
                                  final sameSenderNext = nextMsg != null &&
                                      _isSameCalendarDay(
                                        nextMsg.createdAt.toLocal(),
                                        msgLocal,
                                      ) &&
                                      (isMine == nextMine) &&
                                      ChatDriftDatabase.isSameSender(
                                        nextMsg.senderId,
                                        msg.senderId,
                                      );

                                  final quoted = msg.replyToMsgId != null
                                      ? lookup[msg.replyToMsgId!]
                                      : null;
                                  final quotedMine = quoted != null &&
                                      _isMessageMine(quoted, currentUserId);

                                  final bubble = ChatMessageBubble(
                                    message: msg,
                                    isMine: isMine,
                                    isFirstInGroup: !sameSenderPrev,
                                    isLastInGroup: !sameSenderNext,
                                    showPeerAvatar: !isMine,
                                    peerAvatarInitial: roomTitle,
                                    peerAvatarUrl:
                                        room?.kind == 'DIRECT' ? room?.avatarUrl : null,
                                    quotedMessage: quoted,
                                    quotedAuthorLabel: quoted == null
                                        ? null
                                        : (quotedMine ? 'Anda' : roomTitle),
                                    onVisibleSeq: (seqId) {
                                      ref
                                          .read(
                                            activeChatRoomControllerProvider(
                                              widget.conversationId,
                                            ).notifier,
                                          )
                                          .markViewportSeqAsRead(seqId);
                                    },
                                    onRetryFailed: () {
                                      ref
                                          .read(
                                            activeChatRoomControllerProvider(
                                              widget.conversationId,
                                            ).notifier,
                                          )
                                          .retryFailedMessage(msg);
                                    },
                                    onLongPressReply: () {
                                      ChatRoomSheets.showMessageActions(
                                        context,
                                        message: msg,
                                        isMine: isMine,
                                        onReply: () => setState(() => _replyingTo = msg),
                                        onRetry: isMine
                                            ? () => ref
                                                .read(
                                                  activeChatRoomControllerProvider(
                                                    widget.conversationId,
                                                  ).notifier,
                                                )
                                                .retryFailedMessage(msg)
                                            : null,
                                      );
                                    },
                                  );

                                  if (!showDateDivider) return bubble;
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ChatDatePill(date: msg.createdAt),
                                      bubble,
                                    ],
                                  );
                                },
                                childCount: messages.length,
                              ),
                            ),
                            const SliverToBoxAdapter(child: SizedBox(height: 14)),
                          ],
                        );
                      },
                    ),
                  ),
                  if (_peerTypingName != null)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: AnimatedTypingIndicatorBubble(
                        displayName: _peerTypingName!,
                        avatarUrl: room?.kind == 'DIRECT' ? room?.avatarUrl : null,
                      ),
                    ),
                  if (_replyingTo != null)
                    ChatReplyComposerBanner(
                      replyingTo: _replyingTo!,
                      isMine: _isMessageMine(_replyingTo!, currentUserId),
                      peerTitle: roomTitle,
                      onCancel: () => setState(() => _replyingTo = null),
                    ),
                  _buildComposer(),
                ],
              ),
              if (_showScrollToBottom)
                Positioned(
                  right: 16,
                  bottom: _replyingTo != null ? 132 : 84,
                  child: FloatingActionButton.small(
                    heroTag: 'chat_scroll_bottom_fab',
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryBrown,
                    elevation: 3,
                    onPressed: _scrollToBottom,
                    child: const Icon(CupertinoIcons.chevron_down, size: 18),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 8, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.borderWarm)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              tooltip: 'Bagikan Resep V60 / Biji Kopi',
              onPressed: _openQuickShare,
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.bgCream,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: const Icon(
                  CupertinoIcons.plus,
                  size: 18,
                  color: AppTheme.primaryBrown,
                ),
              ),
            ),
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendText(),
                onChanged: (_) {
                  ref
                      .read(
                        activeChatRoomControllerProvider(widget.conversationId)
                            .notifier,
                      )
                      .notifyTyping();
                },
                decoration: InputDecoration(
                  hintText: 'Tulis pesan atau diskusi ekstraksi...',
                  hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 14),
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AppTheme.borderWarm.withValues(alpha: 0.7)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide(color: AppTheme.borderWarm.withValues(alpha: 0.7)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: _hasDraftText
                    ? AppTheme.primaryBrown
                    : AppTheme.primaryBrown.withValues(alpha: 0.42),
                shape: BoxShape.circle,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _hasDraftText ? _sendText : null,
                child: const Padding(
                  padding: EdgeInsets.all(11.5),
                  child: Icon(
                    CupertinoIcons.paperplane_fill,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSyncBadge extends StatelessWidget {
  final WsConnectionState connState;

  const _HeaderSyncBadge({required this.connState});

  @override
  Widget build(BuildContext context) {
    final (color, label) = switch (connState) {
      WsConnectionState.connected => (const Color(0xFF10B981), 'Live'),
      WsConnectionState.connecting => (AppTheme.accentAmber, 'Sync'),
      WsConnectionState.reconnecting => (AppTheme.accentAmber, 'Sync'),
      WsConnectionState.disconnected => (AppTheme.textMuted, 'REST'),
    };
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoomView extends StatelessWidget {
  final String peerName;
  final VoidCallback onShowLegend;

  const _EmptyRoomView({
    required this.peerName,
    required this.onShowLegend,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.borderWarm),
              ),
              child: const Icon(
                CupertinoIcons.chat_bubble_2_fill,
                color: AppTheme.primaryBrown,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Mulai Obrolan dengan $peerName',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Kirim pesan teks, kartu resep V60, atau profil biji kopi secara real-time.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onShowLegend,
              icon: const Icon(CupertinoIcons.checkmark_shield, size: 16),
              label: const Text('Lihat arti status Pending & Ceklis'),
              style: TextButton.styleFrom(foregroundColor: AppTheme.primaryBrown),
            ),
          ],
        ),
      ),
    );
  }
}
