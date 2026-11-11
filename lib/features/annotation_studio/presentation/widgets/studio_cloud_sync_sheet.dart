import 'package:flutter/material.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/data/local/studio_database.dart';
import 'package:coffee_hub_mobile/features/annotation_studio/data/remote/vision_cloud_sync_service.dart';

class StudioCloudSyncSheet extends StatefulWidget {
  const StudioCloudSyncSheet({super.key});

  @override
  State<StudioCloudSyncSheet> createState() => _StudioCloudSyncSheetState();
}

class _StudioCloudSyncSheetState extends State<StudioCloudSyncSheet> {
  bool _isSyncing = false;
  String _statusMessage = 'Siap menyinkronkan katalog model dengan server cloud.';
  int _downloadedCount = 0;
  int _uploadedCount = 0;

  Future<void> _downloadCatalog() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = 'Mengambil katalog model global dari NeonDB Cloud...';
    });

    try {
      final classes = await VisionCloudSyncService.fetchGlobalClasses();
      int added = 0;
      for (final cls in classes) {
        await StudioDatabase.upsertClass(cls);
        added++;
      }

      setState(() {
        _isSyncing = false;
        _downloadedCount = added;
        _statusMessage = added > 0
            ? 'Sukses! Berhasil mengunduh $added class model roastery ke database lokal.'
            : 'Katalog lokal sudah mutakhir dengan cloud.';
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = 'Gagal sinkronisasi cloud: $e';
      });
    }
  }

  Future<void> _uploadLocalClasses() async {
    setState(() {
      _isSyncing = true;
      _statusMessage = 'Mengunggah class kemasan kopi lokal ke cloud...';
    });

    try {
      final localClasses = await StudioDatabase.getAllClasses();
      int success = 0;

      for (final cls in localClasses) {
        final ok = await VisionCloudSyncService.syncClassToCloud(
          classSlug: cls.classSlug,
          brand: cls.brand,
          coffeeName: cls.coffeeName,
          process: cls.process,
          tastingNotes: cls.tastingNotes,
        );
        if (ok) success++;
      }

      setState(() {
        _isSyncing = false;
        _uploadedCount = success;
        _statusMessage = success > 0
            ? 'Sukses! $success class berhasil disinkronkan ke NeonDB Cloud.'
            : 'Belum ada class lokal baru yang perlu diunggah.';
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = 'Gagal upload ke cloud: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgCream = Color(0xFFF9F6F0);
    const textDark = Color(0xFF2D1F17);
    const textMuted = Color(0xFF8F857D);

    return Container(
      padding: const EdgeInsets.only(top: 14, left: 16, right: 16, bottom: 24),
      decoration: const BoxDecoration(
        color: bgCream,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cloud_sync_rounded, color: Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinkronisasi Cloud Roastery',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rust Axum REST API • NeonDB PostgreSQL Cloud',
                      style: TextStyle(color: textMuted, fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEFE8DE), width: 1.1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSyncing) ...[
                  const LinearProgressIndicator(
                    backgroundColor: Color(0xFFE8DFD8),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                  ),
                  const SizedBox(height: 10),
                ],
                Text(
                  _statusMessage,
                  style: const TextStyle(color: textDark, fontSize: 12),
                ),
                if (_downloadedCount > 0 || _uploadedCount > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      if (_downloadedCount > 0)
                        Text(
                          '📥 $_downloadedCount diunduh  ',
                          style: const TextStyle(color: Color(0xFF059669), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      if (_uploadedCount > 0)
                        Text(
                          '📤 $_uploadedCount diunggah',
                          style: const TextStyle(color: Color(0xFFD97706), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action 1: Download global models
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              icon: const Icon(Icons.download_for_offline_outlined, size: 17),
              label: const Text(
                'Unduh Katalog Model Roastery Global',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              onPressed: _isSyncing ? null : _downloadCatalog,
            ),
          ),
          const SizedBox(height: 8),

          // Action 2: Upload local models
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6B4423),
                side: const BorderSide(color: Color(0xFFD8CFBE)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.cloud_upload_outlined, size: 17),
              label: const Text(
                'Unggah Class Baru Lokal ke Cloud',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              ),
              onPressed: _isSyncing ? null : _uploadLocalClasses,
            ),
          ),
        ],
      ),
    );
  }
}
