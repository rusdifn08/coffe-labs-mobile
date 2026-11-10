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
    final state = ref.watch(annotationStudioProvider);

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF161B26),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6D28D9).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.smart_toy_outlined, color: Color(0xFF8B5CF6), size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konfigurasi Auto-Label Batch',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Segmentasi Poligon, Gatekeeper & OCR On-Device',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Real-Time Progress Card if running
            if (state.isBatchProcessing) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0B0F19),
                  border: Border.all(color: const Color(0xFF8B5CF6)),
                  borderRadius: BorderRadius.circular(16),
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
                            color: Color(0xFFD4A373),
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8B5CF6)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: state.batchTotal > 0 ? state.batchCurrent / state.batchTotal : 0.0,
                        backgroundColor: Colors.white12,
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.batchStatusMessage,
                      style: const TextStyle(color: Colors.white70, fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.check_circle_outline,
                          color: const Color(0xFF10B981),
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
              const SizedBox(height: 20),
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
            const Divider(color: Colors.white10, height: 16),

            _buildSwitchTile(
              title: 'Filter Foto Bukan Kopi (Non-Coffee Gatekeeper)',
              subtitle: 'Verifikasi visual confidence, rasio luas, aspect ratio & solidity',
              value: _enableGatekeeper,
              onChanged: state.isBatchProcessing
                  ? null
                  : (val) {
                      setState(() => _enableGatekeeper = val);
                      _saveConfig();
                    },
            ),
            const Divider(color: Colors.white10, height: 16),

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
            const SizedBox(height: 16),

            // Class Resolution Radio
            const Text(
              'Strategi Resolusi Class OCR:',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            RadioListTile<bool>(
              value: true,
              groupValue: _autoCreateNew,
              activeColor: const Color(0xFF8B5CF6),
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Cocokkan (>=85%) atau Otomatis Buat Class Baru',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              subtitle: const Text(
                'Direkomendasikan untuk mendata kopi baru secara instan',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              onChanged: state.isBatchProcessing
                  ? null
                  : (val) {
                      setState(() => _autoCreateNew = val ?? true);
                      _saveConfig();
                    },
            ),
            RadioListTile<bool>(
              value: false,
              groupValue: _autoCreateNew,
              activeColor: const Color(0xFF8B5CF6),
              contentPadding: EdgeInsets.zero,
              dense: true,
              title: const Text(
                'Hanya Gunakan Class yang Ada di coffee.json',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
              subtitle: const Text(
                'Batasi hanya pada class katalog terverifikasi',
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              onChanged: state.isBatchProcessing
                  ? null
                  : (val) {
                      setState(() => _autoCreateNew = val ?? false);
                      _saveConfig();
                    },
            ),
            const SizedBox(height: 20),

            // Start Batch Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6D28D9),
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
                icon: const Icon(Icons.play_arrow, size: 20),
                label: Text(
                  state.isBatchProcessing
                      ? 'Sedang Memproses Batch...'
                      : '🤖 Jalankan Auto-Label Batch Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF8B5CF6),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
