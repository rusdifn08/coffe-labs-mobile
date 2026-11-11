import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/annotation_studio_controller.dart';

class BatchAutoLabelConfigSheet extends ConsumerStatefulWidget {
  const BatchAutoLabelConfigSheet({super.key});

  @override
  ConsumerState<BatchAutoLabelConfigSheet> createState() => _BatchAutoLabelConfigSheetState();
}

class _BatchAutoLabelConfigSheetState extends ConsumerState<BatchAutoLabelConfigSheet> {
  late bool _enableSeg;
  late bool _enableGatekeeper;
  late bool _enableOcr;
  late bool _autoCreateNew;

  @override
  void initState() {
    super.initState();
    final cfg = ref.read(annotationStudioProvider).config;
    _enableSeg = cfg.enableSegmentation;
    _enableGatekeeper = cfg.enableGatekeeper;
    _enableOcr = cfg.enableOcrSlug;
    _autoCreateNew = cfg.autoCreateNewClasses;
  }

  void _saveConfig() {
    final cfg = ref.read(annotationStudioProvider).config.copyWith(
      enableSegmentation: _enableSeg,
      enableGatekeeper: _enableGatekeeper,
      enableOcrSlug: _enableOcr,
      autoCreateNewClasses: _autoCreateNew,
    );
    ref.read(annotationStudioProvider.notifier).updateConfig(cfg);
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    final state = ref.watch(annotationStudioProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 18,
        right: 18,
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8CFBE),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F3FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF7C3AED), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konfigurasi Auto-Label Batch',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Segmentasi Poligon, Gatekeeper & OCR On-Device',
                        style: TextStyle(color: textMuted, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Real-Time Progress Card if running
            if (state.isBatchProcessing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFF7C3AED), width: 1.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Memproses Batch (${state.batchCurrent}/${state.batchTotal})...',
                          style: const TextStyle(
                            color: Color(0xFF7C3AED),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF7C3AED)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.batchTotal > 0 ? state.batchCurrent / state.batchTotal : 0.0,
                        backgroundColor: const Color(0xFFE8DFD8),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C3AED)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.batchStatusMessage,
                      style: const TextStyle(color: textDark, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF059669),
                          label: '${state.batchLabeledCount} Kemasan',
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: Icons.block,
                          color: const Color(0xFFEF4444),
                          label: '${state.batchRejectedCount} Non-Kopi',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],

            // 3 Switches
            _buildSwitchTile(
              title: 'Segmentasi Poligon Presisi Tinggi',
              subtitle: 'Deteksi kemasan pouch & simplifikasi kontur poligon RDP',
              value: _enableSeg,
              onChanged: state.isBatchProcessing
                  ? null
                  : (val) {
                      setState(() => _enableSeg = val);
                      _saveConfig();
                    },
            ),
            const Divider(color: Color(0xFFEFE8DE), height: 16),

            _buildSwitchTile(
              title: 'Filter Foto Bukan Kopi (Gatekeeper)',
              subtitle: 'Verifikasi visual confidence, rasio luas, aspect ratio & solidity',
              value: _enableGatekeeper,
              onChanged: state.isBatchProcessing
                  ? null
                  : (val) {
                      setState(() => _enableGatekeeper = val);
                      _saveConfig();
                    },
            ),
            const Divider(color: Color(0xFFEFE8DE), height: 16),

            _buildSwitchTile(
              title: 'Coffee Packaging OCR (brand_kopi_proses)',
              subtitle: 'Ekstrak brand roastery, origin/nama kopi, dan proses pascapanen',
              value: _enableOcr,
              onChanged: state.isBatchProcessing
                  ? null
                  : (val) {
                      setState(() => _enableOcr = val);
                      _saveConfig();
                    },
            ),
            const SizedBox(height: 14),

            // Class Resolution Radio
            const Text(
              'Strategi Resolusi Class OCR:',
              style: TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEFE8DE)),
              ),
              child: Column(
                children: [
                  RadioListTile<bool>(
                    value: true,
                    groupValue: _autoCreateNew,
                    activeColor: const Color(0xFF7C3AED),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    dense: true,
                    title: const Text(
                      'Cocokkan (>=85%) atau Otomatis Buat Class Baru',
                      style: TextStyle(color: textDark, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Direkomendasikan untuk mendata kopi baru secara instan',
                      style: TextStyle(color: textMuted, fontSize: 10),
                    ),
                    onChanged: state.isBatchProcessing
                        ? null
                        : (val) {
                            setState(() => _autoCreateNew = val ?? true);
                            _saveConfig();
                          },
                  ),
                  const Divider(color: Color(0xFFEFE8DE), height: 1),
                  RadioListTile<bool>(
                    value: false,
                    groupValue: _autoCreateNew,
                    activeColor: const Color(0xFF7C3AED),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    dense: true,
                    title: const Text(
                      'Hanya Gunakan Class yang Ada di coffee.json',
                      style: TextStyle(color: textDark, fontSize: 11.5, fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Batasi hanya pada class katalog terverifikasi',
                      style: TextStyle(color: textMuted, fontSize: 10),
                    ),
                    onChanged: state.isBatchProcessing
                        ? null
                        : (val) {
                            setState(() => _autoCreateNew = val ?? false);
                            _saveConfig();
                          },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Start Batch Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: state.isBatchProcessing
                    ? null
                    : () {
                        _saveConfig();
                        ref.read(annotationStudioProvider.notifier).runBatchAutoLabel();
                      },
                icon: const Icon(Icons.play_arrow_rounded, size: 18),
                label: Text(
                  state.isBatchProcessing
                      ? 'Sedang Memproses Batch...'
                      : '🤖 Jalankan Auto-Label Batch Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: textDark, fontSize: 12.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(color: textMuted, fontSize: 10.5),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF7C3AED),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10.5, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
