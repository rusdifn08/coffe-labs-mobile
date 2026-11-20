import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../theme/app_theme.dart';
import '../../domain/live_brew_models.dart';
import '../controllers/barista_live_transmitter_controller.dart';
import '../screens/customer_live_brew_tracker_screen.dart';

class TableQrManagerModal extends ConsumerStatefulWidget {
  final Map<String, dynamic>? activeRecipe;
  final double Function()? weightSampler;

  const TableQrManagerModal({
    super.key,
    this.activeRecipe,
    this.weightSampler,
  });

  static Future<void> show(
    BuildContext context, {
    Map<String, dynamic>? activeRecipe,
    double Function()? weightSampler,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TableQrManagerModal(
        activeRecipe: activeRecipe,
        weightSampler: weightSampler,
      ),
    );
  }

  @override
  ConsumerState<TableQrManagerModal> createState() => _TableQrManagerModalState();
}

class _TableQrManagerModalState extends ConsumerState<TableQrManagerModal> {
  final TextEditingController _tableCtrl = TextEditingController();
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(baristaLiveTransmitterProvider.notifier).refreshTables();
    });
  }

  @override
  void dispose() {
    _tableCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final broadcastState = ref.watch(baristaLiveTransmitterProvider);
    final notifier = ref.read(baristaLiveTransmitterProvider.notifier);
    final activeSession = broadcastState.activeSession;

    final LiveBrewTableModel? selectedTable = broadcastState.tables
        .where((t) => t.id == broadcastState.selectedTableId)
        .firstOrNull;

    final String? activeUrl = activeSession?.livebrewUrl ??
        selectedTable?.livebrewUrl;
    final String? activeCode = activeSession?.dynamicAddressCode ??
        selectedTable?.staticAddressCode;

    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
      decoration: const BoxDecoration(
        color: AppTheme.bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 14, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4.5,
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.qr_code_2_rounded, color: AppTheme.primaryBrown, size: 24),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Live Brew QR & Meja Slow Bar',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                  ),
                ),
                if (broadcastState.isBroadcasting)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'LIVE 10Hz',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // QR Card Preview pointing to Landing Pages URL (100% Real Session / Table — Zero Mock)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7DDD3)),
              ),
              child: activeUrl == null || activeCode == null
                  ? Column(
                      children: [
                        const Icon(
                          Icons.qr_code_2_rounded,
                          size: 56,
                          color: AppTheme.primaryBrown,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Belum Ada Sesi Live Brew Aktif',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Mulai siaran nyata di bawah atau pilih meja terdaftar untuk menghasilkan QR unik Coffee Labs.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        TextButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LiveBrewHubScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.open_in_new_rounded, size: 17),
                          label: const Text('Buka Live Brewing 2.0 Hub & Studio Meja'),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        QrImageView(
                          data: activeUrl,
                          version: QrVersions.auto,
                          size: 165,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          activeUrl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryBrown,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(text: activeUrl));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Link Live Brew berhasil disalin!'),
                                    ),
                                  );
                                },
                                icon: const Icon(CupertinoIcons.doc_on_clipboard, size: 16),
                                label: const Text('Salin Link'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  SharePlus.instance.share(
                                    ShareParams(
                                      text:
                                          'Pantau kopi Anda diseduh langsung oleh Barista Coffee Labs: $activeUrl',
                                    ),
                                  );
                                },
                                icon: const Icon(CupertinoIcons.share, size: 16),
                                label: const Text('Bagikan'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CustomerLiveBrewTrackerScreen(addressCode: activeCode),
                                ),
                              );
                            },
                            icon: const Icon(Icons.visibility_rounded, size: 18),
                            label: const Text('Buka Tampilan Pelanggan (Live Mirror)'),
                          ),
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),
            const Text(
              'Pilih / Tambah Meja Static QR (7...)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tableCtrl,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Meja 04 / Slow Bar A',
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _creating
                      ? null
                      : () async {
                          final txt = _tableCtrl.text.trim();
                          if (txt.isEmpty) return;
                          setState(() => _creating = true);
                          await notifier.createStaticTable(txt);
                          _tableCtrl.clear();
                          if (mounted) setState(() => _creating = false);
                        },
                  child: const Text('Tambah'),
                ),
              ],
            ),

            if (broadcastState.tables.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: broadcastState.tables.map((t) {
                  final sel = t.id == broadcastState.selectedTableId;
                  return ChoiceChip(
                    label: Text('${t.tableNumber} • ${t.staticAddressCode.substring(0, 6)}..'),
                    selected: sel,
                    selectedColor: AppTheme.primaryBrown,
                    labelStyle: TextStyle(
                      fontSize: 11.5,
                      color: sel ? Colors.white : AppTheme.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                    onSelected: (_) => notifier.selectTable(sel ? null : t.id),
                  );
                }).toList(),
              ),
            ],

            if (widget.activeRecipe != null) ...[
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Kamera Overhead Barista',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      value: broadcastState.isCameraActive,
                      onChanged: broadcastState.isBroadcasting
                          ? (v) => notifier.toggleOverheadCamera(v)
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: broadcastState.isBroadcasting
                        ? const Color(0xFFDC2626)
                        : AppTheme.primaryBrown,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () async {
                    if (broadcastState.isBroadcasting) {
                      await notifier.stopBroadcast();
                    } else {
                      await notifier.startLiveSession(
                        recipe: widget.activeRecipe!,
                        weightSampler: widget.weightSampler ?? () => 0.0,
                      );
                    }
                  },
                  icon: Icon(broadcastState.isBroadcasting
                      ? Icons.stop_circle_rounded
                      : Icons.broadcast_on_personal_rounded),
                  label: Text(
                    broadcastState.isBroadcasting
                        ? 'Hentikan Siaran Live Brew'
                        : 'Mulai Siaran Live Brew & Buat QR',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
