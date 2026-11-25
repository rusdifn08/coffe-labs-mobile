import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_theme.dart';
import '../../data/services/device_token_lifecycle_service.dart';
import '../../data/services/local_push_orchestrator.dart';
import '../../domain/models/notification_models.dart';
import '../controllers/notification_center_controller.dart';

class NotificationPreferencesSheet extends ConsumerStatefulWidget {
  const NotificationPreferencesSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.bgCream,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const NotificationPreferencesSheet(),
    );
  }

  @override
  ConsumerState<NotificationPreferencesSheet> createState() =>
      _NotificationPreferencesSheetState();
}

class _NotificationPreferencesSheetState
    extends ConsumerState<NotificationPreferencesSheet> {
  NotificationPreferences? _draft;
  PushNotificationDiagnostics? _diagnostics;
  bool _saving = false;
  bool _testingPush = false;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    final diag = await ref
        .read(deviceTokenLifecycleServiceProvider)
        .inspectDiagnostics();
    if (mounted) setState(() => _diagnostics = diag);
  }

  Future<void> _enablePermissionsAndTest() async {
    if (_testingPush) return;
    setState(() => _testingPush = true);
    try {
      await ref
          .read(deviceTokenLifecycleServiceProvider)
          .initializeAndSyncToken(requestPermission: true);
      await ref.read(localPushOrchestratorProvider).showForegroundNotification(
            const PushDeepLinkPayload(
              category: 'CHAT',
              eventType: 'DIRECT_CHAT_MESSAGE_RECEIVED',
              title: 'Coffee Labs Chat',
              body: 'Pop-up notifikasi pesan ala WhatsApp berhasil aktif di HP Anda!',
              deepLinkPath: '/social/chat',
              collapseKey: 'CHAT_TEST_BANNER',
              actionButtons: ['INLINE_REPLY', 'MARK_AS_READ'],
            ),
          );
      try {
        await ref.read(notificationApiServiceProvider).sendTestPushNotification();
      } catch (_) {}
      await _loadDiagnostics();
    } finally {
      if (mounted) setState(() => _testingPush = false);
    }
  }

  String _formatMinute(int? minuteOfDay, String fallback) {
    if (minuteOfDay == null) return fallback;
    final h = (minuteOfDay ~/ 60).clamp(0, 23).toString().padLeft(2, '0');
    final m = (minuteOfDay % 60).clamp(0, 59).toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _pickQuietTime({required bool isStart}) async {
    final current = _draft ?? const NotificationPreferences();
    final baseMinute = isStart
        ? (current.quietHoursStartMinute ?? 22 * 60)
        : (current.quietHoursEndMinute ?? 7 * 60);
    final initial = TimeOfDay(hour: baseMinute ~/ 60, minute: baseMinute % 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final total = picked.hour * 60 + picked.minute;
    setState(() {
      _draft = isStart
          ? current.copyWith(quietHoursStartMinute: total)
          : current.copyWith(quietHoursEndMinute: total);
    });
  }

  Future<void> _savePreferences() async {
    final prefs = _draft;
    if (prefs == null || _saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(notificationPreferencesControllerProvider.notifier)
          .save(prefs);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferensi notifikasi berhasil disimpan.'),
            backgroundColor: AppTheme.primaryBrown,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan preferensi: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncPrefs = ref.watch(notificationPreferencesControllerProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: asyncPrefs.when(
          loading: () => const SizedBox(
            height: 240,
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryBrown),
            ),
          ),
          error: (err, _) => SizedBox(
            height: 220,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Gagal memuat pengaturan notifikasi',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => ref
                        .read(
                          notificationPreferencesControllerProvider.notifier,
                        )
                        .load(),
                    child: const Text('Muat Ulang'),
                  ),
                ],
              ),
            ),
          ),
          data: (loaded) {
            final draft = _draft ?? loaded;
            _draft ??= loaded;
            final quietEnabled =
                draft.quietHoursStartMinute != null &&
                draft.quietHoursEndMinute != null;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.slider_horizontal_3,
                        color: AppTheme.primaryBrown,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Preferensi Push Notification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_diagnostics != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _diagnostics!.osPermissionEnabled
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _diagnostics!.osPermissionEnabled
                              ? const Color(0xFFBBF7D0)
                              : const Color(0xFFFDE68A),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _diagnostics!.osPermissionEnabled
                                    ? CupertinoIcons.bell_circle_fill
                                    : CupertinoIcons.bell_slash_fill,
                                size: 18,
                                color: _diagnostics!.osPermissionEnabled
                                    ? const Color(0xFF15803D)
                                    : const Color(0xFFB45309),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _diagnostics!.osPermissionEnabled
                                      ? 'Izin Pop-Up Notifikasi OS Aktif'
                                      : 'Izin Notifikasi HP Belum Aktif',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            _diagnostics!.statusNote,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppTheme.textMuted,
                              height: 1.35,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _testingPush ? null : _enablePermissionsAndTest,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryBrown,
                                side: const BorderSide(
                                  color: AppTheme.primaryBrown,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: _testingPush
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppTheme.primaryBrown,
                                      ),
                                    )
                                  : const Icon(
                                      CupertinoIcons.paperplane_fill,
                                      size: 14,
                                    ),
                              label: Text(
                                _diagnostics!.osPermissionEnabled
                                    ? 'Uji Pop-Up Notifikasi Sekarang'
                                    : 'Aktifkan Izin & Uji Pop-Up',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  _SwitchTile(
                    title: 'Obrolan Social Coffee',
                    subtitle: 'Pesan langsung 1-on-1 dan grup barista.',
                    value: draft.enableChatMessages,
                    onChanged: (v) => setState(
                      () => _draft = draft.copyWith(enableChatMessages: v),
                    ),
                  ),
                  _SwitchTile(
                    title: 'Pengikut Baru & Mutual Follback',
                    subtitle: 'Tombol cepat follback di layar kunci.',
                    value: draft.enableFollowFollback,
                    onChanged: (v) => setState(
                      () => _draft = draft.copyWith(enableFollowFollback: v),
                    ),
                  ),
                  _SwitchTile(
                    title: 'Balasan & Quote Resep',
                    subtitle: 'Komentar baru pada thread dan resep Anda.',
                    value: draft.enableThreadReplies,
                    onChanged: (v) => setState(
                      () => _draft = draft.copyWith(enableThreadReplies: v),
                    ),
                  ),
                  _SwitchTile(
                    title: 'Likes & Seduhan Ulang (Coalesced)',
                    subtitle: 'Dirangkum cerdas dalam jendela 15 detik.',
                    value: draft.enableLikesAndRecipeTries,
                    onChanged: (v) => setState(
                      () => _draft = draft.copyWith(enableLikesAndRecipeTries: v),
                    ),
                  ),
                  _SwitchTile(
                    title: 'Streak Seduh & Gamifikasi',
                    subtitle: 'Pengingat streak harian & lencana XP.',
                    value: draft.enableLiveBrewAndStreak,
                    onChanged: (v) => setState(
                      () => _draft = draft.copyWith(enableLiveBrewAndStreak: v),
                    ),
                  ),
                  _SwitchTile(
                    title: 'Transaksi & Upgrade Pro',
                    subtitle: 'Aktivasi akun dan status pembayaran.',
                    value: draft.enableTransactionalBilling,
                    onChanged: (v) => setState(
                      () => _draft = draft.copyWith(
                        enableTransactionalBilling: v,
                      ),
                    ),
                  ),
                  const Divider(height: 24, color: AppTheme.borderWarm),
                  _SwitchTile(
                    title: 'Jam Hening (Quiet Hours)',
                    subtitle: 'Tahan push non-kritis saat jam istirahat.',
                    value: quietEnabled,
                    onChanged: (enabled) => setState(() {
                      _draft = enabled
                          ? draft.copyWith(
                              quietHoursStartMinute:
                                  draft.quietHoursStartMinute ?? 22 * 60,
                              quietHoursEndMinute:
                                  draft.quietHoursEndMinute ?? 7 * 60,
                            )
                          : draft.copyWith(
                              quietHoursStartMinute: null,
                              quietHoursEndMinute: null,
                            );
                    }),
                  ),
                  if (quietEnabled) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickQuietTime(isStart: true),
                            icon: const Icon(CupertinoIcons.moon_stars),
                            label: Text(
                              'Mulai ${_formatMinute(draft.quietHoursStartMinute, "22:00")}',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _pickQuietTime(isStart: false),
                            icon: const Icon(CupertinoIcons.sunrise),
                            label: Text(
                              'Selesai ${_formatMinute(draft.quietHoursEndMinute, "07:00")}',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: const [
                        'Asia/Jakarta',
                        'Asia/Makassar',
                        'Asia/Jayapura',
                      ].contains(draft.timezone)
                          ? draft.timezone
                          : 'Asia/Jakarta',
                      decoration: const InputDecoration(
                        labelText: 'Zona Waktu',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Asia/Jakarta',
                          child: Text('WIB — Asia/Jakarta'),
                        ),
                        DropdownMenuItem(
                          value: 'Asia/Makassar',
                          child: Text('WITA — Asia/Makassar'),
                        ),
                        DropdownMenuItem(
                          value: 'Asia/Jayapura',
                          child: Text('WIT — Asia/Jayapura'),
                        ),
                      ],
                      onChanged: (tz) {
                        if (tz != null) {
                          setState(() => _draft = draft.copyWith(timezone: tz));
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _savePreferences,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBrown,
                      ),
                      child: Text(
                        _saving ? 'Menyimpan...' : 'Simpan Preferensi',
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      contentPadding: EdgeInsets.zero,
      activeThumbColor: AppTheme.primaryBrown,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
      ),
      value: value,
      onChanged: onChanged,
    );
  }
}
