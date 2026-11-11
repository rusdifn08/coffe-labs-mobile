import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../in_app_trainer/presentation/in_app_bean_trainer_screen.dart';
import '../../scanner/data/local/prototype_database.dart';
import '../../scanner/domain/services/incremental_vision_engine.dart';
import '../data/local/studio_database.dart';
import 'mobile_dataset_kanban_screen.dart';
import 'widgets/studio_cloud_sync_sheet.dart';
import 'widgets/studio_live_diagnostic_sheet.dart';
import 'widgets/studio_model_manager_sheet.dart';

/// Studio AI Hub Screen: Pusat kendali dan pilihan fitur AI Computer Vision Coffee Labs
/// Memadukan alur transfer learning cepat (In-App Trainer), Roboflow Dataset Kanban,
/// manajemen model NCM, sinkronisasi cloud roastery, dan live diagnostik akurasi.
class StudioAiHubScreen extends ConsumerStatefulWidget {
  const StudioAiHubScreen({super.key});

  @override
  ConsumerState<StudioAiHubScreen> createState() => _StudioAiHubScreenState();
}

class _StudioAiHubScreenState extends ConsumerState<StudioAiHubScreen> {
  int _prototypeCount = 0;
  int _datasetCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTelemetry();
  }

  Future<void> _loadTelemetry() async {
    setState(() => _isLoading = true);
    try {
      await IncrementalVisionEngine.instance.initialize();
      await StudioDatabase.seedInitialClassesIfEmpty();

      final prototypes = await PrototypeDatabase.loadAllPrototypes();
      final images = await StudioDatabase.getAllImages();

      if (mounted) {
        setState(() {
          _prototypeCount = prototypes.length;
          _datasetCount = images.length;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF17120E), // Coffee Labs Deep Warm Espresso
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F1813),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Color(0xFFD4AF37)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Studio AI Coffee Labs',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Computer Vision & On-Device Transfer Learning',
              style: TextStyle(color: Color(0xFFD4A373), fontSize: 11),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Status',
            icon: const Icon(Icons.refresh, color: Color(0xFFD4AF37), size: 20),
            onPressed: _loadTelemetry,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadTelemetry,
        color: const Color(0xFFD4AF37),
        backgroundColor: const Color(0xFF261D16),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Telemetry Banner
              _buildHeroTelemetryCard(),
              const SizedBox(height: 22),

              // Section Header
              const Text(
                'PILIHAN MODE STUDIO AI',
                style: TextStyle(
                  color: Color(0xFFD4A373),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Card 1: Latih Biji Kopi Baru (Quick 3-Foto)
              _buildStudioFeatureCard(
                badgeText: '⚡ CEPAT (3 FOTO)',
                badgeColor: const Color(0xFFD4AF37),
                icon: Icons.add_a_photo_outlined,
                iconColor: const Color(0xFFD4AF37),
                title: 'Latih Biji Kopi Baru',
                subtitle: 'Few-Shot On-Device Transfer Learning',
                description:
                    'Ambil 3 sudut kemasan kopi (depan, kiri, kanan), sesuaikan bounding box, tentukan resep V60 & rasa, lalu latih model on-device langsung di HP.',
                actionLabel: 'Buka Studio Latih Kopi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const InAppBeanTrainerScreen(),
                    ),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 14),

              // Card 2: Roboflow Annotation Studio (Batch Auto-Labeler)
              _buildStudioFeatureCard(
                badgeText: '🤖 AUTO-LABEL BATCH',
                badgeColor: const Color(0xFFECA400),
                icon: Icons.grid_view_rounded,
                iconColor: const Color(0xFFECA400),
                title: 'Roboflow Annotation Studio',
                subtitle: 'Two-Stage SAM Segmentation & Semantic OCR',
                description:
                    'Kelola puluhan foto kemasan dari galeri secara massal, auto-labeling poligon presisi tinggi (RDP), Non-Coffee Gatekeeper, dan ekstraksi OCR {brand}_{kopi}_{proses}.',
                actionLabel: 'Buka Kanban Dataset & Anotasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MobileDatasetKanbanScreen(),
                    ),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 14),

              // Card 3: Manajemen Model & Class Prototipe
              _buildStudioFeatureCard(
                badgeText: 'ZERO FORGETTING',
                badgeColor: const Color(0xFFC86D51),
                icon: Icons.memory_outlined,
                iconColor: const Color(0xFFC86D51),
                title: 'Manajemen Model & Class Prototipe',
                subtitle: 'MobileNetV4 1280-D NCM Memory',
                description:
                    'Inspeksi seluruh class kemasan kopi yang tersimpan di memori SQLite, periksa sub-prototipe multi-angle, atau latih versi NCM baru dengan 5-step stepper.',
                actionLabel: 'Kelola Prototipe & Versi Model',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StudioModelManagerSheet(),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 14),

              // Card 4: Sinkronisasi Katalog Cloud Roastery
              _buildStudioFeatureCard(
                badgeText: 'NEONDB CLOUD',
                badgeColor: const Color(0xFF10B981),
                icon: Icons.cloud_sync_outlined,
                iconColor: const Color(0xFF10B981),
                title: 'Sinkronisasi Katalog Cloud Roastery',
                subtitle: 'Rust Axum REST API v1 • NeonDB PostgreSQL',
                description:
                    'Unduh katalog model roastery terverifikasi se-Indonesia (Fugol, Tanamera, Anomali, 5758, dll.) atau sinkronkan model buatan Anda ke backend.',
                actionLabel: 'Sinkronkan Katalog Model',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StudioCloudSyncSheet(),
                  ).then((_) => _loadTelemetry());
                },
              ),
              const SizedBox(height: 14),

              // Card 5: Uji Diagnostik Akurasi (Live AI Viewfinder)
              _buildStudioFeatureCard(
                badgeText: 'REAL-TIME TEST',
                badgeColor: const Color(0xFF3B82F6),
                icon: Icons.center_focus_strong_outlined,
                iconColor: const Color(0xFF3B82F6),
                title: 'Uji Akurasi Model (Live Viewfinder)',
                subtitle: 'Cosine Similarity & Gatekeeper Telemetry',
                description:
                    'Uji coba langsung foto kemasan kopi untuk mengukur skor Cosine Similarity, jarak prototipe terdekat, dan validitas gatekeeper sebelum dipakai di kasir.',
                actionLabel: 'Mulai Uji Coba Diagnostik',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const StudioLiveDiagnosticSheet(),
                  );
                },
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroTelemetryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF261D16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF3D2D22), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFD4AF37), width: 0.8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, size: 12, color: Color(0xFFD4AF37)),
                    SizedBox(width: 5),
                    Text(
                      'AI Computer Vision Active',
                      style: TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                'MobileNetV4 1280-D',
                style: TextStyle(color: Colors.white60, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Sistem Pelatihan Visual On-Device',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Melatih klasifikasi kemasan kopi langsung di HP dengan zero catastrophic forgetting.',
            style: TextStyle(color: Color(0xFFC7BBAF), fontSize: 12, height: 1.3),
          ),
          const SizedBox(height: 16),

          // 4 Stats in 1 row
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1F1813),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF34261C)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMiniStat(
                  icon: Icons.class_outlined,
                  color: const Color(0xFFD4AF37),
                  value: _isLoading ? '...' : '$_prototypeCount',
                  label: 'Class Model',
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  icon: Icons.photo_library_outlined,
                  color: const Color(0xFFECA400),
                  value: _isLoading ? '...' : '$_datasetCount',
                  label: 'Foto Dataset',
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  icon: Icons.bolt,
                  color: const Color(0xFF10B981),
                  value: '< 12 ms',
                  label: 'Latensi NPU',
                ),
                _buildStatDivider(),
                _buildMiniStat(
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF3B82F6),
                  value: '4 Syarat',
                  label: 'Gatekeeper',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 26,
      color: Colors.white12,
    );
  }

  Widget _buildStudioFeatureCard({
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String description,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF261D16),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF3D2D22), width: 1.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Badge + Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.6), width: 0.8),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Title & Subtitle
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: iconColor.withValues(alpha: 0.9),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              style: const TextStyle(
                color: Color(0xFFC7BBAF),
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 14),

            // Action Row
            Row(
              children: [
                Text(
                  actionLabel,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.arrow_forward_rounded, size: 14, color: iconColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
