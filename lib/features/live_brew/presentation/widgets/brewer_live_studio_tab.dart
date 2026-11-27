import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/external_url_launcher.dart';
import '../../../../data/roastery_catalog.dart';
import '../../../../services/seed_data.dart';
import '../../../../theme/app_theme.dart';
import '../../data/live_brew_v2_api_service.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../controllers/live_brew_mirror_controller.dart';
import 'mirrored_circular_timer_card.dart';

class BrewerLiveStudioTab extends ConsumerStatefulWidget {
  const BrewerLiveStudioTab({super.key});

  @override
  ConsumerState<BrewerLiveStudioTab> createState() => _BrewerLiveStudioTabState();
}

class _BrewerLiveStudioTabState extends ConsumerState<BrewerLiveStudioTab> {
  final TextEditingController _customerCtrl =
      TextEditingController(text: 'Tamu Slow Bar');
  final TextEditingController _posOrderCtrl = TextEditingController();
  late final List<Map<String, dynamic>> _sampleRecipes;

  @override
  void initState() {
    super.initState();
    _sampleRecipes = SeedData.getDefaultRecipes().take(12).toList();
  }

  @override
  void dispose() {
    _customerCtrl.dispose();
    _posOrderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(liveBrewMirrorProvider);
    final ctrl = ref.read(liveBrewMirrorProvider.notifier);
    final session = state.activeSession;

    if (session == null) {
      return _buildStartStudioView(state, ctrl);
    }

    return _buildActiveBroadcastView(state, ctrl, session);
  }

  Widget _buildStartStudioView(
    LiveBrewMirrorState state,
    LiveBrewMirrorController ctrl,
  ) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
      children: [
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppTheme.borderWarm),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBrown.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.dot_radiowaves_left_right,
                      color: AppTheme.primaryBrown,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Siaran Live Brew 1:1 Real-Time',
                          style: TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Penonton menyaksikan pemilihan resep, biji kopi, & timer NTP sinkron (< 25ms) langsung di browser.',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11.5,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customerCtrl,
                style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
                decoration: _brightInputDecoration('Nama Pelanggan / Penonton'),
              ),
              if (state.isBusinessUser && state.seats.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: state.selectedSeatId,
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
                  decoration: _brightInputDecoration('Ikat ke Meja / Kursi Kafe (Opsional)'),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Sesi Personal / Takeaway'),
                    ),
                    ...state.seats.map(
                      (s) => DropdownMenuItem<String?>(
                        value: s.id,
                        child: Text('${s.seatLabel} (${s.zoneArea})'),
                      ),
                    ),
                  ],
                  onChanged: ctrl.selectSeatForBroadcast,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _posOrderCtrl,
                  style: const TextStyle(color: AppTheme.textDark, fontSize: 13),
                  decoration:
                      _brightInputDecoration('Nomor Pesanan POS (contoh: ORD-042)'),
                ),
              ],
              if (state.broadcastError != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 17,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.broadcastError!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: state.isStartingSession
                      ? null
                      : () {
                          ctrl.startRealSession(
                            customerName: _customerCtrl.text.trim().isEmpty
                                ? 'Tamu Coffee Labs'
                                : _customerCtrl.text.trim(),
                            posOrderNumber: _posOrderCtrl.text.trim().isEmpty
                                ? null
                                : _posOrderCtrl.text.trim(),
                          );
                        },
                  icon: state.isStartingSession
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(CupertinoIcons.play_circle_fill, size: 19),
                  label: const Text(
                    'Mulai Siarkan Live Brew Real-Time',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppTheme.borderWarm),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.tips_and_updates_rounded,
                  color: AppTheme.accentAmber, size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tip: Anda juga bisa langsung mengaktifkan Live Brew & membagikan QR saat sedang menyeduh lewat tombol garis tiga (☰) di layar Brew Timer.',
                  style: TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11.5,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveBroadcastView(
    LiveBrewMirrorState state,
    LiveBrewMirrorController ctrl,
    LiveSessionMirrorSnapshot session,
  ) {
    final beansList = RoasteryCatalog.list.take(10).toList();
    final isRunning = session.timerStatus == LiveTimerStatus.running;
    final liveUrl = LiveBrewV2ApiService.normalizePublicShareUrl(session.shareUrl);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // Floating Share QR & Live Viewers Card
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF16A34A).withValues(alpha: 0.45),
              width: 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF16A34A).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderWarm),
                ),
                child: QrImageView(
                  data: liveUrl,
                  size: 70,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'LIVE 1:1',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          '${session.activeViewersCount} Menonton • ${session.cheersCount} Cheers',
                          style: const TextStyle(
                            color: Color(0xFF15803D),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      liveUrl.replaceFirst('https://', ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.primaryBrown,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MiniBtn(
                          label: 'Salin',
                          icon: Icons.copy_rounded,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: liveUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                behavior: SnackBarBehavior.floating,
                                content: Text('Tautan Live Brew disalin.'),
                              ),
                            );
                          },
                        ),
                        _MiniBtn(
                          label: 'Bagikan',
                          icon: CupertinoIcons.share,
                          onTap: () => SharePlus.instance.share(
                            ShareParams(
                              text: 'Pantau seduhan kopi Live Brew 1:1 di $liveUrl',
                            ),
                          ),
                        ),
                        _MiniBtn(
                          label: 'Buka Web',
                          icon: Icons.open_in_browser_rounded,
                          onTap: () => launchExternalUri(Uri.parse(liveUrl)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Step 1: Pilih Metode & Resep (Disiarkan Live)
        const _SectionLabel(title: '1. Pilih Metode & Resep (Disiarkan Live)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _sampleRecipes.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, idx) {
              final r = _sampleRecipes[idx];
              final title = (r['title'] ?? 'V60 Recipe').toString();
              final method = (r['method'] ?? 'V60').toString();
              final selected = session.selectedRecipeTitle == title;
              return InkWell(
                onTap: () => ctrl.broadcastRecipeSelection(
                  methodId: method.toLowerCase().replaceAll(' ', '_'),
                  methodName: method,
                  recipeTitle: title,
                  recipeSnapshot: r,
                ),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 170,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryBrown.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppTheme.primaryBrown : AppTheme.borderWarm,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        method,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.primaryBrown,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Step 2: Pilih Biji Kopi (Disiarkan Live)
        const _SectionLabel(title: '2. Pilih Biji Kopi Roastery (Disiarkan Live)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: beansList.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, idx) {
              final roastery = beansList[idx];
              final bean =
                  roastery.lineups.isNotEmpty ? roastery.lineups.first : null;
              final beanName = bean?.name ?? roastery.specialties;
              final selected = session.beanSnapshot['name'] == beanName;
              return InkWell(
                onTap: () => ctrl.broadcastBeanSelection({
                  'name': beanName,
                  'roastery': roastery.name,
                  'origin': bean?.origin ?? roastery.location,
                  'process': bean?.process ?? 'Washed / Natural',
                  'roast_profile': bean?.roastProfile ?? 'Light to Medium',
                  'tasting_notes':
                      bean?.tastingNotes ?? 'Floral, Sweet Berry, Cocoa',
                }),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 175,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.primaryBrown.withValues(alpha: 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected ? AppTheme.primaryBrown : AppTheme.borderWarm,
                      width: selected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        roastery.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.primaryBrown,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        beanName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        // Step 3: 1:1 Synchronized Timer Control
        const _SectionLabel(title: '3. Kontrol Timer Seduh 1:1 (NTP Synced)'),
        const SizedBox(height: 8),
        MirroredCircularTimerCard(
          snapshot: session,
          timerEngine: ctrl.timerEngine,
          clockOffsetMs: state.clockOffsetMs,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isRunning ? ctrl.timerPause : ctrl.timerStartOrResume,
                icon: Icon(
                  isRunning ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                  size: 16,
                ),
                label: Text(
                  isRunning ? 'Jeda' : 'Mulai / Lanjut',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBrown,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: ctrl.timerReset,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryBrown,
                side: const BorderSide(color: AppTheme.borderWarm),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Icon(CupertinoIcons.refresh, size: 17),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => ctrl.completeAndServe(
                finalWeightG: session.targetWaterMl,
              ),
              icon: const Icon(CupertinoIcons.checkmark_seal_fill, size: 16),
              label: const Text(
                'Selesai',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF16A34A),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: ctrl.stopBroadcast,
          child: const Text(
            'Akhiri & Tutup Sesi Siaran',
            style: TextStyle(
              color: Color(0xFFDC2626),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _brightInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 12.5),
      filled: true,
      fillColor: AppTheme.bgCream,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppTheme.borderWarm),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppTheme.borderWarm),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: AppTheme.primaryBrown, width: 1.5),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;
  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textDark,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _MiniBtn({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.bgCream,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.borderWarm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.primaryBrown),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
