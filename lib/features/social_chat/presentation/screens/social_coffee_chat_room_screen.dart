import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../theme/app_theme.dart';
import '../../../auth/controllers/auth_controller.dart';
import '../../../notifications/data/services/device_token_lifecycle_service.dart';
import '../../../notifications/data/services/local_push_orchestrator.dart';
import '../../data/services/chat_ws_service.dart';
import '../../domain/chat_protocol.dart';
import '../../domain/chat_view_models.dart';
import '../controllers/chat_controllers.dart';
import '../widgets/animated_typing_indicator_bubble.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_quick_share_sheet.dart';

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

  late final ChatWsService _wsService;
  late final LocalPushOrchestrator _pushOrchestrator;
  late final DeviceTokenLifecycleService _tokenLifecycle;

  @override
  void initState() {
    super.initState();
    _wsService = ref.read(chatWsServiceProvider);
    _pushOrchestrator = ref.read(localPushOrchestratorProvider);
    _tokenLifecycle = ref.read(deviceTokenLifecycleServiceProvider);

    _pushOrchestrator.setActiveChatRoomId(widget.conversationId);
    unawaited(_wsService.setActiveRoom(widget.conversationId));
    unawaited(_tokenLifecycle.syncActiveChatRoom(widget.conversationId));

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

  @override
  void dispose() {
    _pushOrchestrator.setActiveChatRoomId(null);
    unawaited(_wsService.setActiveRoom(null));
    unawaited(_tokenLifecycle.syncActiveChatRoom(null));
    _typingSub?.cancel();
    _errorSub?.cancel();
    _typingExpiryTimer?.cancel();
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendText() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    _inputCtrl.clear();
    await ref
        .read(activeChatRoomControllerProvider(widget.conversationId).notifier)
        .sendTextMessage(text);
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
    final currentUserId = ref.watch(authControllerProvider).value?.id ?? '';
    final db = ref.watch(chatDriftDatabaseProvider);

    return StreamBuilder<ChatConversationView?>(
      stream: db.watchConversationViewById(widget.conversationId),
      builder: (context, roomSnap) {
        final room = roomSnap.data;
        final roomTitle = room?.title ?? 'Ruang Obrolan';
        final isOnline = room?.peerOnline ?? false;

        return Scaffold(
          backgroundColor: AppTheme.bgCream,
          appBar: AppBar(
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
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor:
                              AppTheme.primaryBrown.withValues(alpha: 0.14),
                          child: room?.kind == 'GROUP'
                              ? const Icon(
                                  CupertinoIcons.person_3_fill,
                                  size: 16,
                                  color: AppTheme.primaryBrown,
                                )
                              : Text(
                                  roomTitle.isNotEmpty
                                      ? roomTitle[0].toUpperCase()
                                      : 'B',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBrown,
                                  ),
                                ),
                        ),
                        if (isOnline && room?.kind == 'DIRECT')
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                            ),
                          ),
                      ],
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
          ),
          body: Column(
            children: [
              if (connState != WsConnectionState.connected)
                Container(
                  width: double.infinity,
                  color: AppTheme.accentAmber.withValues(alpha: 0.18),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.wifi_slash,
                        size: 14,
                        color: AppTheme.primaryBrown,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          connState == WsConnectionState.reconnecting
                              ? 'Menyambung ulang... Pesan tersimpan di Outbox offline.'
                              : 'Mode Offline • Pesan masuk antrean kirim otomatis.',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: messagesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppTheme.primaryBrown),
                  ),
                  error: (err, _) =>
                      Center(child: Text('Gagal membaca DB lokal: $err')),
                  data: (messages) {
                    if (messages.isEmpty) {
                      return const Center(
                        child: Text(
                          'Kirim sapaan, resep V60, atau profil biji kopi pertamamu!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                      );
                    }

                    return CustomScrollView(
                      controller: _scrollCtrl,
                      reverse: true,
                      slivers: [
                        const SliverToBoxAdapter(child: SizedBox(height: 10)),
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final msg = messages[index];
                              final isMine = msg.senderId == currentUserId;
                              return ChatMessageBubble(
                                message: msg,
                                isMine: isMine,
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
                              );
                            },
                            childCount: messages.length,
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 12)),
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
                  ),
                ),
              _buildComposer(),
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
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppTheme.borderWarm)),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Bagikan Resep V60 / Biji Kopi',
              onPressed: _openQuickShare,
              icon: Container(
                padding: const EdgeInsets.all(7),
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
                maxLines: 4,
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
                  filled: true,
                  fillColor: AppTheme.bgCream,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Material(
              color: AppTheme.primaryBrown,
              borderRadius: BorderRadius.circular(999),
              child: InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: _sendText,
                child: const Padding(
                  padding: EdgeInsets.all(11),
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
