import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../data/roastery_catalog.dart';
import '../../../../services/seed_data.dart';
import '../../domain/live_brew_mirror_models.dart';
import '../controllers/live_brew_mirror_controller.dart';
import 'mirrored_circular_timer_card.dart';

class BrewerLiveStudioTab extends ConsumerStatefulWidget {
  const BrewerLiveStudioTab({super.key});

  @override
  ConsumerState<BrewerLiveStudioTab> createState() => _BrewerLiveStudioTabState();
}

class _BrewerLiveStudioTabState extends ConsumerState<BrewerLiveStudioTab> {
  final TextEditingController _customerCtrl = TextEditingController(text: 'Tamu Slow Bar');
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
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFD4A373).withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A373).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      CupertinoIcons.dot_radiowaves_left_right,
                      color: Color(0xFFD4A373),
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
                            color: Color(0xFFF9F5EE),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Penonton menyaksikan pemilihan resep, biji kopi, & timer NTP sinkron (< 25ms) sejak detik pertama.',
                          style: TextStyle(
                            color: Color(0xFFCBBFB2),
                            fontSize: 11.5,
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
                style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                decoration: _darkInputDecoration('Nama Pelanggan / Penonton'),
              ),
              if (state.isBusinessUser && state.seats.isNotEmpty) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<String?>(
                  initialValue: state.selectedSeatId,
                  dropdownColor: const Color(0xFF1C1714),
                  style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                  decoration: _darkInputDecoration('Ikat ke Meja / Kursi Kafe (Opsional)'),
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
                  style: const TextStyle(color: Color(0xFFF9F5EE), fontSize: 13),
                  decoration: _darkInputDecoration('Nomor Pesanan POS (contoh: ORD-042)'),
                ),
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: 10),
                Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Color(0xFFF87171), fontSize: 12),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
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
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFF12100E),
                          ),
                        )
                      : const Icon(CupertinoIcons.play_circle_fill, size: 18),
                  label: const Text(
                    'Mulai Siarkan Live Brew Real-Time',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4A373),
                    foregroundColor: const Color(0xFF12100E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // Floating Share QR & Live Viewers Pill
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1714),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFDC2626).withValues(alpha: 0.45),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: QrImageView(
                  data: session.shareUrl,
                  size: 62,
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
                            color: Color(0xFFD4A373),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      session.shareUrl.replaceFirst('https://', ''),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFF9F5EE),
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _MiniBtn(
                          label: 'Salin Link',
                          icon: Icons.copy_rounded,
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: session.shareUrl));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Tautan Live Brew disalin.')),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        _MiniBtn(
                          label: 'Bagikan',
                          icon: CupertinoIcons.share,
                          onTap: () => SharePlus.instance.share(
                            ShareParams(
                              text: 'Pantau seduhan kopi Live Brew 1:1 di ${session.shareUrl}',
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
        const SizedBox(height: 14),

        // Step 1: Pilih Metode & Resep (Siaran Real-Time)
        const _SectionLabel(title: '1. Pilih Metode & Resep (Disiarkan Live)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
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
                  width: 168,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFD4A373).withValues(alpha: 0.2)
                        : const Color(0xFF1C1714),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFD4A373)
                          : Colors.white.withValues(alpha: 0.12),
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
                          color: Color(0xFFD4A373),
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
                          color: Color(0xFFF9F5EE),
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
        const SizedBox(height: 14),

        // Step 2: Pilih Biji Kopi (Disiarkan Live)
        const _SectionLabel(title: '2. Pilih Biji Kopi Roastery (Disiarkan Live)'),
        const SizedBox(height: 8),
        SizedBox(
          height: 76,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: beansList.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (_, idx) {
              final roastery = beansList[idx];
              final bean = roastery.lineups.isNotEmpty ? roastery.lineups.first : null;
              final beanName = bean?.name ?? roastery.specialties;
              final selected = session.beanSnapshot['name'] == beanName;
              return InkWell(
                onTap: () => ctrl.broadcastBeanSelection({
                  'name': beanName,
                  'roastery': roastery.name,
                  'origin': bean?.origin ?? roastery.location,
                  'process': bean?.process ?? 'Washed / Natural',
                  'roast_profile': bean?.roastProfile ?? 'Light to Medium',
                  'tasting_notes': bean?.tastingNotes ?? 'Floral, Sweet Berry, Cocoa',
                }),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 175,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFD4A373).withValues(alpha: 0.2)
                        : const Color(0xFF1C1714),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFD4A373)
                          : Colors.white.withValues(alpha: 0.12),
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
                          color: Color(0xFFD4A373),
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
                          color: Color(0xFFF9F5EE),
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
                  backgroundColor: const Color(0xFFD4A373),
                  foregroundColor: const Color(0xFF12100E),
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                foregroundColor: const Color(0xFFF9F5EE),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.25)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
            style: TextStyle(color: Color(0xFFF87171), fontSize: 12),
          ),
        ),
      ],
    );
  }

  InputDecoration _darkInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFCBBFB2), fontSize: 12),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD4A373)),
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
        color: Color(0xFFF9F5EE),
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
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: const Color(0xFFD4A373)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFFF9F5EE),
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
