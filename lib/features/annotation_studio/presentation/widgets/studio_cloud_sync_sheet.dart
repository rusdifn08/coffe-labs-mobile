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
        _statusMessage = 'Selesai: $success class berhasil disinkronkan ke server cloud.';
      });
    } catch (e) {
      setState(() {
        _isSyncing = false;
        _statusMessage = 'Gagal mengunggah: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 16, left: 18, right: 18, bottom: 28),
      decoration: const BoxDecoration(
        color: Color(0xFF1F1813), // Warm Dark Roast
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
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
                  color: const Color(0xFF10B981).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_sync, color: Color(0xFF10B981), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinkronisasi Katalog Cloud',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Rust Axum REST API • NeonDB PostgreSQL Cloud',
                      style: TextStyle(color: Color(0xFFD4A373), fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Status card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF261D16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3D2D22)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_isSyncing) ...[
                  const LinearProgressIndicator(
                    backgroundColor: Colors.white12,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  _statusMessage,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
                if (_downloadedCount > 0 || _uploadedCount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_downloadedCount > 0)
                        Text(
                          '📥 $_downloadedCount diunduh  ',
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      if (_uploadedCount > 0)
                        Text(
                          '📤 $_uploadedCount diunggah',
                          style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action 1: Download global models
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.download_for_offline_outlined, size: 18),
              label: const Text(
                'Unduh Katalog Model Roastery Global',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _isSyncing ? null : _downloadCatalog,
            ),
          ),
          const SizedBox(height: 10),

          // Action 2: Upload local models
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFD4AF37),
                side: const BorderSide(color: Color(0xFFD4AF37)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.cloud_upload_outlined, size: 18),
              label: const Text(
                'Unggah Class Baru Lokal ke Cloud',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              onPressed: _isSyncing ? null : _uploadLocalClasses,
            ),
          ),
        ],
      ),
    );
  }
}
